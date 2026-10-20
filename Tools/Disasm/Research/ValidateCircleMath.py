"""Исполнение исходного вычислителя катета, без сборки и обращения к ROM."""
import json
import math
from pathlib import Path
from ValidateMath import Simulator, run, word, A, F, H, D, B

ROOT = Path(__file__).resolve().parents[3]
simulator = Simulator([0] * 0x4000 + list((ROOT / "Tools/Disasm/Research/GameCode.bin").read_bytes()))
count = 0
# Проверка обоих входных переносов и границ радиуса, включая отрицательное подкоренное значение.
for radius in (0, 1, 2, 3, 7, 8, 9, 31, 32, 63, 64, 120, 127, 128, 191, 254, 255):
    for offset in range(radius + 1):
        for carry in (0, 1):
            registers = run(simulator, 0x8ACD, hl=0x1234, de=radius * 256 + 0x57,
                            bc=0x7654, a=offset, flags=carry)
            radicand = (radius * radius - offset * offset - carry) & 65535
            assert registers[A] == math.isqrt(radicand)
            assert word(registers, H) == 0x1234
            assert word(registers, D) == radius * 256 + 0x57
            assert word(registers, B) == 0x7654
            assert registers[F] & 0x41 == 0x41
            count += 1
report = {
    "entry": "8ACD",
    "cases": count,
    "formula": "A_out=floor(sqrt((D_in^2-A_in^2-C_in) mod 65536))",
    "preserved": ["HL", "DE", "BC"],
    "flags": "Z=1, C=1",
    "scope": "Исполнение байтов GameCode.bin в SkoolKit Simulator, без ROM, прерываний и видеоконтенции",
}
(ROOT / "Tools/Disasm/Reports/Semantics/CircleMathValidation.json").write_text(
    json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf8")
print(json.dumps(report, ensure_ascii=False))
