"""Независимая проверка модели расшифровки исполнением исходного загрузчика."""

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "Tools/Disasm"))
sys.path.insert(0, str(ROOT / "Tools/Disasm/Research"))
from InspectZ80 import memory_for
from DecodeGame import decode
from ValidateMath import Simulator, run


def main():
    disk_data = (ROOT / "Tools/Disasm/Extracted/Active/02_ELITE3.C").read_bytes()
    decoded, report = decode(disk_data)
    memory = memory_for("game")
    loader = memory_for("loader")
    memory[0xC800:0xC90A] = loader[0xC800:0xC90A]
    sim = Simulator(list(memory))
    # Исполнение фактического DJNZ и генератора, включая запись в его собственное состояние.
    run(sim, 0xC8E5, limit=100000)
    expected = bytearray(0x4000) + bytearray(decoded)
    expected[0xDEC0:0xDEC6] = bytes.fromhex(report["runtime_final_seed_hex"])
    # Проверка всех затрагиваемых диапазонов, исключённых из мутации загрузчиком.
    for start, end in ((0x5B00, 0xC800), (0xD000, 0x10000)):
        assert sim.memory[start:end] == list(expected[start:end]), f"{start:04X}..{end:04X}"
    assert sim.memory[0xC800:0xD000] == list(memory[0xC800:0xD000])

    # Проверка обратимости обмена двух областей системных переменных.
    first = [(i * 37) & 255 for i in range(1024)]
    second = [(i * 53 + 11) & 255 for i in range(1024)]
    sim.memory[0x5C00:0x6000] = first
    sim.memory[0xCC00:0xD000] = second
    run(sim, 0xC8CE, limit=20000)
    assert sim.memory[0x5C00:0x6000] == second and sim.memory[0xCC00:0xD000] == first
    run(sim, 0xC8CE, limit=20000)
    assert sim.memory[0x5C00:0x6000] == first and sim.memory[0xCC00:0xD000] == second
    result = {
        "method": "исполнение исходного кода загрузчика и PRNG в симуляторе Z80",
        "scope": "XOR и обмен памяти, без вызовов дискового ROM",
        "xor_bytes_compared": (0xC800 - 0x5B00) + (0x10000 - 0xD000),
        "unchanged_excluded_bytes": 2048,
        "runtime_seed_hex": bytes(expected[0xDEC0:0xDEC6]).hex(),
        "exchange_bytes": 1024, "exchange_calls": 2,
        "matches_independent_python_model": True,
    }
    (ROOT / "Tools/Disasm/Reports/LoaderValidation.json").write_text(
        json.dumps(result, ensure_ascii=False, indent=2) + "\n", "utf-8")
    print(json.dumps(result, ensure_ascii=False))


if __name__ == "__main__":
    main()
