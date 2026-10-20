"""Проверки контрактов на исходных инструкциях cl.C, без ассемблера и FDC."""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "Tools/Disasm/Research/vendor/skoolkit-10.1"))
from skoolkit.simulator import Simulator
from skoolkit.simutils import A, F, B, C, D, E, H, L, IXh, IYh, SP, PC

BASE = [0] * 0x4000 + list((ROOT / "Tools/Disasm/Research/GameCode.bin").read_bytes())
BASE[0xC800:0xD000] = (ROOT / "Tools/Disasm/Extracted/Active/03_cl.C").read_bytes()[:0x800]


def put(r, h, value):
    r[h:h + 2] = [value >> 8, value & 255]


def word(r, h):
    return r[h] * 256 + r[h + 1]


def prepare(entry):
    sim = Simulator(BASE.copy())
    sim.registers[SP] = 0xF000
    sim.registers[PC] = entry
    sim.memory[0xF000:0xF002] = [0, 0x40]
    return sim


def finish(sim, hook=None):
    for n in range(200000):
        if sim.registers[PC] == 0x4000:
            return n
        if hook and hook(sim):
            continue
        sim.run()
    raise AssertionError("Проверяемая процедура не завершилась")


cases = []
# Позиции сетки и сохранность пар, объявленных сохранёнными.
for index in range(24):
    sim = prepare(0xCBDB)
    sim.registers[A] = index
    put(sim.registers, H, 0x1234)
    put(sim.registers, D, 0x5678)
    finish(sim)
    assert word(sim.registers, H) == 0x1234
    assert word(sim.registers, D) == 0x5678
    assert sim.registers[B] == 5 + (index & 7)
    assert sim.registers[C] == 2 + 10 * (index // 8)
    cases.append({"entry": "CBDB", "position": index})

# Число и адрес записи не ограничиваются просмотром одной страницы.
for index in range(128):
    sim = prepare(0xCBF4)
    sim.registers[A] = index
    sim.memory[0x5000 + 16 * index] = index
    finish(sim)
    assert word(sim.registers, H) == 0x5000 + 16 * index
    assert sim.registers[A] == index
    assert bool(sim.registers[F] & 0x40) == (index == 0)
    cases.append({"entry": "CBF4", "record": index})

# Десятичный вывод проверяется у границ каждого разряда.
for number in (0, 1, 9, 10, 99, 100, 999, 1000, 9999, 10000, 65535):
    sim = prepare(0xCE87)
    put(sim.registers, H, number)
    put(sim.registers, IXh, 0x5900)
    put(sim.registers, B, 0x1234)
    finish(sim)
    assert bytes(sim.memory[0x5900:0x5905]) == f"{number:05d}".encode()
    assert word(sim.registers, H) == 0 and word(sim.registers, D) == 1
    assert word(sim.registers, IXh) == 0x5905 and word(sim.registers, B) == 0x1234
    cases.append({"entry": "CE87", "number": number})

# XOR использует полные индексные адреса IY+1/IY+2, включая соседнюю страницу.
for key in (0, 1, 0x127E, 0x55FE, 0xAAFF, 0xFFFF):
    sim = prepare(0xC959)
    put(sim.registers, D, key)
    sim.registers[C] = 0xA5
    source = bytes((i * 17 + 3) & 255 for i in range(256))
    sim.memory[0x606F:0x616F] = source
    high, low = key >> 8, key & 255
    expected = bytes(
        b ^ ((high - i) & 255) ^ low
        ^ sim.memory[0xBE00 + ((low + i) & 255) + 1]
        ^ sim.memory[0xBE00 + ((low + i) & 255) + 2]
        for i, b in enumerate(source))
    finish(sim)
    assert bytes(sim.memory[0x606F:0x616F]) == expected
    assert word(sim.registers, D) == key
    assert word(sim.registers, H) == 0x616F
    assert word(sim.registers, IYh) == 0xBE00 + low
    assert sim.registers[B] == 0 and sim.registers[C] == 0xA5
    sim.registers[PC], sim.registers[SP] = 0xC959, 0xF000
    finish(sim)
    assert bytes(sim.memory[0x606F:0x616F]) == source
    cases.append({"entry": "C959", "key": f"{key:04X}", "round_trip": True})

# Очистка должна включать первый байт и не затрагивать адрес возврата.
for size in (0x0EDF, 0x16DF):
    sim = prepare(0xCA48)
    sim.memory[0x4120:0x5800] = [0xA5] * (0x5800 - 0x4120)
    sim.memory[0xE7FE:0xF000] = [0xA5] * (0xF000 - 0xE7FE)
    put(sim.registers, B, size)
    finish(sim)
    assert sim.memory[0x4120:0x4120 + size + 1] == [0] * (size + 1)
    assert sim.memory[0xE7FF:0xF000] == [0] * 0x801
    assert sim.memory[0xE7FE] == 0xA5
    assert sim.memory[0xF000:0xF002] == [0, 0x40]
    cases.append({"entry": "CA48", "forward_bytes": size + 1, "stack_bytes": 0x801})

# Подменяется только конечный вывод символа, токенизация игры исполняется полностью.
sim = prepare(0xD48E)
put(sim.registers, H, 0xC859)
sim.memory[0xD420] = 1
printed = []


def output(sim):
    if sim.registers[PC] != 0xD499:
        return False
    printed.append(sim.registers[A])
    sp = sim.registers[SP]
    sim.registers[PC] = sim.memory[sp] + 256 * sim.memory[sp + 1]
    sim.registers[SP] = sp + 2
    return True


finish(sim, output)
assert bytes(printed) == b"NO SPACE!"
cases.append({"entry": "D48E", "string": "C859", "mode": 1, "result": "NO SPACE!"})

report = {
    "source": "исходные байты 03_cl.C и Tools/Disasm/Research/GameCode.bin",
    "scope": "арифметические контракты и раскрытие текста, без сборки и моделирования FDC",
    "cases": cases,
    "count": len(cases),
}
(ROOT / "Tools/Disasm/Reports/DiskUtilityMenuValidation.json").write_text(
    json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"Passed {len(cases)} original-instruction checks.")
