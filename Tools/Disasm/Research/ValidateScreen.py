"""Исполнение экранных примитивов для проверки адресов и точного числа строк."""

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "Tools/Disasm/Research"))
from ValidateMath import Simulator, run, word, H, D


def address(y, column=0, base=0x4000):
    return base + ((y & 0xC0) << 5) + ((y & 7) << 8) + ((y & 0x38) << 2) + column


def main():
    payload = (ROOT / "Tools/Disasm/Research/GameCode.bin").read_bytes()
    simulator = Simulator([0] * 0x4000 + list(payload))
    checks = {}
    # Проверка перехода по всем строкам экрана и граничным столбцам.
    for y in range(191):
        for column in (0, 1, 15, 30, 31):
            r = run(simulator, 0x7FE7, hl=address(y, column))
            assert word(r, H) == address(y + 1, column)
    checks["next_scanline"] = 191 * 5

    # Проверка необычного CALL с повторным входом в его собственное продолжение.
    for y in range(118):
        r = run(simulator, 0x7FE3, hl=0xCAFE, de=address(y, 5))
        assert word(r, H) == address(y + 2, 5) and word(r, D) == 0xCAFE
    checks["swap_and_skip"] = 118

    # Проверка всех записанных строк кадра с узнаваемыми исходными данными.
    source = bytes((i * 37 + (i >> 8) * 11) & 255 for i in range(4096))
    simulator.memory[0xC000:0xD000] = source
    run(simulator, 0x7FBE, limit=100000)
    for y in range(120):
        a = address(y, base=0xC000)
        b = address(y + 8)
        assert simulator.memory[b:b + 32] == list(source[a - 0xC000:a - 0xC000 + 32])
    checks["copied_view_rows"] = 120
    checks["copied_view_bytes"] = 3840

    # Проверка формы рамки по пикселям, включая верхнюю и нижнюю границы.
    run(simulator, 0x8080)
    for y in range(120):
        a = address(y, base=0xC000)
        expected = ([0] + [255] * 30 + [0] if y in (0, 119)
                    else [0, 128] + [0] * 28 + [1, 0])
        assert simulator.memory[a:a + 32] == expected
    checks["cleared_view_rows"] = 120

    # Проверка зеркального фона компаса и влияния LDI на регистр B.
    simulator = Simulator([0] * 0x4000 + list(payload))
    source = list(simulator.memory[0x8491:0x84B5])
    for y in range(24):
        a = address(y + 136, 21)
        simulator.memory[a:a + 3] = [0xA5] * 3
    run(simulator, 0x84B5)
    for y in range(23):
        row = y if y < 12 else 22 - y
        a = address(y + 136, 21)
        assert simulator.memory[a:a + 3] == source[row * 3:row * 3 + 3]
    assert simulator.memory[address(159, 21):address(159, 21) + 3] == [0xA5] * 3
    checks["compass_background_rows"] = 23
    checks["compass_background_width"] = 24
    (ROOT / "Tools/Disasm/Reports/ScreenValidation.json").write_text(
        json.dumps({
            "method": "исполнение исходных инструкций SkoolKit 10.1 Simulator",
            "scope": "без прерываний, ROM и видеоконтенции",
            "passed": checks,
        }, ensure_ascii=False, indent=2) + "\n", "utf-8")
    print(json.dumps(checks))


if __name__ == "__main__":
    main()
