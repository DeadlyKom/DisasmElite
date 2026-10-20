"""Проверка арифметических контрактов исполнением исходных инструкций Z80.

Память берётся из восстановленного файла игры. Процедуры запускаются изолированно,
без ROM, прерываний, видеоконтенции и дисковых операций. Ассемблер не вызывается.
"""

import hashlib
import json
import random
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "Tools/Disasm/Research/vendor/skoolkit-10.1"))
from skoolkit.simulator import Simulator
from skoolkit.simutils import A, F, B, C, D, E, H, L, SP, PC


def word(registers, high):
    return registers[high] * 256 + registers[high + 1]


def set_word(registers, high, value):
    registers[high], registers[high + 1] = value >> 8, value & 255


def run(simulator, start, hl=0, de=0, bc=0, a=0, flags=0, limit=10000):
    registers = simulator.registers
    for i in range(30):
        registers[i] = 0
    set_word(registers, H, hl)
    set_word(registers, D, de)
    set_word(registers, B, bc)
    registers[A], registers[F], registers[SP], registers[PC] = a, flags, 0x411E, start
    # Подготовка адреса возврата вне проверяемого кода.
    simulator.memory[0x411E:0x4120] = [0, 0x40]
    for _ in range(limit):
        simulator.run()
        if registers[PC] == 0x4000:
            assert registers[SP] == 0x4120
            return registers
    raise AssertionError(f"Процедура {start:04X} не вернулась")


def signed_average(first, second):
    sign1, sign2 = first & 0x8000, second & 0x8000
    first, second = first & 0x7FFF, second & 0x7FFF
    if sign1 == sign2:
        magnitude, sign = first + second, sign1
    elif first >= second:
        magnitude, sign = first - second, sign1
    else:
        magnitude, sign = second - first, sign2
    return (magnitude >> 1) | sign, magnitude & 1


def main():
    payload = (ROOT / "Tools/Disasm/Research/GameCode.bin").read_bytes()
    simulator = Simulator([0] * 0x4000 + list(payload))
    totals = {}
    # Проверка всех возможных аргументов табличного возведения в квадрат.
    for value in range(256):
        r = run(simulator, 0x87BF, hl=0x1234, a=value, bc=0xCAFE)
        assert word(r, D) == value * value
        assert word(r, H) == 0x1234 and r[A] == value and word(r, B) == 0xCAFE
    totals["square"] = 256

    # Проверка деления на границах и на воспроизводимой случайной выборке.
    cases = set()
    for divisor in (1, 2, 3, 127, 128, 255, 256, 257, 32767, 32768, 65535):
        for high in (0, divisor // 2, divisor - 1):
            for low in (0, 1, 127, 128, 254, 255):
                cases.add((high, divisor, low))
    rng = random.Random(0xE117E)
    for _ in range(1024):
        divisor = rng.randrange(1, 65536)
        cases.add((rng.randrange(divisor), divisor, rng.randrange(256)))
    for high, divisor, low in sorted(cases):
        r = run(simulator, 0xAFA8, hl=high, de=divisor, a=low)
        quotient, remainder = divmod(high * 65536 + low * 256, divisor)
        assert (word(r, B), word(r, H)) == (quotient, remainder)
        assert word(r, D) == divisor and r[A] == 0 and r[F] & 1 == 0
    totals["divide"] = len(cases)

    # Проверка знака, округления и обоих представлений нуля у суммы и разности.
    coordinates = (0, 1, 2, 3, 255, 256, 32766, 32767,
                   32768, 32769, 32770, 33023, 33024, 65534, 65535)
    for first in coordinates:
        for second in coordinates:
            for entry, arg2 in ((0xAFCD, second), (0xAFC9, second ^ 0x8000)):
                expected, carry = signed_average(first, arg2)
                r = run(simulator, entry, hl=first, de=second)
                assert word(r, H) == expected and r[F] & 1 == carry
    totals["signed_sum_and_difference"] = len(coordinates) ** 2 * 2

    # Проверка трёхсловного генератора по независимой модульной формуле.
    for _ in range(128):
        seeds = [rng.randrange(65536) for _ in range(3)]
        simulator.memory[0xDEC0:0xDEC6] = list(
            b"".join(value.to_bytes(2, "little") for value in seeds))
        r = run(simulator, 0xE063, a=0xA5, bc=0xCAFE)
        result = bytes(simulator.memory[0xDEC0:0xDEC6])
        expected = [seeds[1], seeds[2], sum(seeds) & 65535]
        assert result == b"".join(value.to_bytes(2, "little") for value in expected)
        assert word(r, H) == expected[2] and word(r, D) == sum(seeds[:2]) & 65535
        assert r[A] == 0xA5 and word(r, B) == 0xCAFE
    totals["random_step"] = 128

    # Измерение исходного приближения корня без подмены его точным sqrt.
    roots = {}
    for value in (0, 1, 2, 3, 4, 15, 16, 63, 64, 127, 128, 255,
                  256, 257, 1023, 1024, 4095, 4096, 16383, 16384, 65535):
        r = run(simulator, 0x9EF1, hl=value)
        roots[str(value)] = word(r, H)
        assert r[A] == 0
    assert roots["0"] == 0x0200 and roots["4096"] == 0x422F
    totals["square_root_observations"] = len(roots)
    report = {
        "source_sha256": hashlib.sha256(payload).hexdigest(),
        "method": "SkoolKit 10.1 Simulator, исходные инструкции Z80",
        "scope": "изолированные процедуры, без ROM, прерываний и контенции",
        "passed": totals, "square_root_q8_8": roots,
    }
    (ROOT / "Tools/Disasm/Reports/MathValidation.json").write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n", "utf-8")
    print(json.dumps(totals))


if __name__ == "__main__":
    main()
