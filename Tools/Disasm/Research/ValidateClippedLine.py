"""Исполнение оригинального отсечения и обоих изменяемых растровых циклов."""

import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "Tools/Disasm/Research"))
from ValidateMath import Simulator, run
from ValidateScreen import address


def point(x, y):
    """Преобразование экранной точки в исходный знако-модульный интерфейс."""
    return (abs(x - 127) << 8) | abs(y - 63), (y >= 63) | ((x < 127) << 1)


def draw(x1, y1, x2, y2, xor=False, background=0):
    payload = (ROOT / "Tools/Disasm/Research/GameCode.bin").read_bytes()
    rom = (ROOT / "Tools/Disasm/Research/vendor/skoolkit-10.1/skoolkit/resources/48.rom").read_bytes()
    simulator = Simulator(list(rom) + list(payload))
    simulator.memory[0xC000:0xD000] = [background] * 4096
    if xor:
        for opcode in (0xB1B7, 0xB232, 0xB244, 0xB252):
            simulator.memory[opcode] = 0xAE
    hl, first = point(x1, y1)
    de, second = point(x2, y2)
    run(simulator, 0xB044, hl=hl, de=de, bc=first | (second << 2), limit=100000)
    pixels = {
        (x, y)
        for y in range(128)
        for x in range(256)
        if simulator.memory[address(y, x >> 3, 0xC000)] & (128 >> (x & 7))
    }
    return simulator, pixels


def main():
    checks = {}
    cases = 0
    # Проверка точного набора пикселей вертикалей с переходом через знакоместа.
    for x in (8, 31, 64, 126, 127, 128, 192, 240):
        for a, b in ((1, 7), (7, 8), (20, 100), (63, 64), (118, 125)):
            for y1, y2 in ((a, b), (b, a)):
                _, pixels = draw(x, y1, x, y2)
                assert pixels == {(x, y) for y in range(a, b + 1)}, (x, y1, y2, pixels)
                cases += 1
    checks["vertical_exact"] = cases
    cases = 0
    # Проверка горизонталей, ADC при разных знаках X добавляет один пиксель.
    for y in (1, 7, 8, 31, 63, 64, 100, 118):
        for a, b in ((8, 15), (15, 16), (20, 220), (126, 128), (231, 246)):
            for x1, x2 in ((a, b), (b, a)):
                _, pixels = draw(x1, y, x2, y)
                end = b + int((a < 127) != (b < 127))
                assert pixels == {(x, y) for x in range(a, end)}, (x1, y, x2, pixels)
                cases += 1
    checks["horizontal_exact"] = cases
    # Проверка всех направлений уклона и обоих растровых циклов без эталона Bresenham.
    samples = []
    for ends in ((20, 20, 220, 90), (220, 20, 20, 90),
                 (100, 10, 130, 110), (130, 10, 100, 110)):
        sim, pixels = draw(*ends)
        x1, y1, x2, y2 = ends
        assert pixels and all(min(x1, x2) <= x <= max(x1, x2)
                              and min(y1, y2) <= y <= max(y1, y2) for x, y in pixels)
        assert set(y for _, y in pixels) == set(range(min(y1, y2), max(y1, y2) + 1))
        samples.append({"ends": ends, "pixels": len(pixels),
                        "steep_step": sim.memory[0xB1B5],
                        "shallow_step": sim.memory[0xB20D]})
    checks["slope_quadrants"] = len(samples)
    # Проверка патча четырёх OR в XOR на непустом фоне для обоих циклов и направлений.
    for ends in ((20, 20, 220, 90), (220, 20, 20, 90),
                 (100, 10, 130, 110), (130, 10, 100, 110)):
        normal, _ = draw(*ends)
        altered, _ = draw(*ends, xor=True, background=0xA5)
        assert altered.memory[0xC000:0xD000] == [
            value ^ 0xA5 for value in normal.memory[0xC000:0xD000]]
    checks["xor_variants"] = 4
    # Проверка отбрасывания двух концов за общей горизонтальной/вертикальной границей.
    for ends in ((250, 20, 252, 90), (2, 20, 4, 90),
                 (20, -10, 220, -20), (20, 140, 220, 150)):
        _, pixels = draw(*ends)
        assert not pixels, ends
    checks["outside_rejected"] = 4
    result = {
        "method": "исходные инструкции Z80 и ROM 48K в SkoolKit 10.1 Simulator",
        "scope": "изолированная процедура, без прерываний и контенции",
        "source_sha256": hashlib.sha256((ROOT / "Tools/Disasm/Research/GameCode.bin").read_bytes()).hexdigest(),
        "passed": checks, "slope_samples": samples,
    }
    (ROOT / "Tools/Disasm/Reports/ClippedLineValidation.json").write_text(
        json.dumps(result, ensure_ascii=False, indent=2) + "\n", "utf-8")
    print(json.dumps(checks))


if __name__ == "__main__":
    main()
