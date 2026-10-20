"""Проверка двух необычных контрактов исходного кода, без сборки."""
import json
from pathlib import Path
from ValidateMath import Simulator, run, word, A, F, H

ROOT = Path(__file__).resolve().parents[3]
payload = (ROOT / "Tools/Disasm/Research/GameCode.bin").read_bytes()
checks = []

# Проверка раннего Z из INC A, минуя полную геометрическую проверку системы.
simulator = Simulator([0] * 0x4000 + list(payload))
simulator.memory[0xD062] = 0
simulator.memory[0xD065] = 1
simulator.memory[0xD097] = 255
simulator.memory[0xD099] = 80
registers = run(simulator, 0xFCEA)
assert registers[A] == 0 and registers[F] & 0x41 == 0x40
checks.append({
    "entry": "FCEA", "input": "D062=0, Galaxy=1, Y=FF, X=50",
    "output": "A=0, Z=1, C=0",
    "meaning": "Ранний RET NC сохраняет Z от Y+1, совпадение специальных координат не является единственным путём Z=1",
})

# Проверка изменившегося HL при завершённом вторжении, уменьшается D064, а не D062.
simulator = Simulator([0] * 0x4000 + list(payload))
for addr, value in ((0xD062, 0x42), (0xD064, 2), (0xD08F, 1),
                    (0xD081, 0), (0xD0AF, 0), (0xD086, 1), (0xD087, 0)):
    simulator.memory[addr] = value
registers = run(simulator, 0x5E78, hl=0xD062)
assert simulator.memory[0xD062] == 2
assert simulator.memory[0xD064] == 0x81
assert word(registers, H) == 0xD0C9
checks.append({
    "entry": "5E78", "input": "D062=42, D064=02, Invasion=1, Mission1=Mission3=0, AlienComputer=1",
    "output": "D062=02, D064=81, HL=D0C9",
    "meaning": "RES6 меняет старший рейтинг, затем SET7 и условный DEC работают со старшим счётчиком переходов",
})

report = {
    "scope": "Исполнение исходных байтов GameCode.bin в SkoolKit Simulator, без ROM и прерываний",
    "checks": checks,
}
(ROOT / "Tools/Disasm/Reports/Semantics/ExtensionContractsValidation.json").write_text(
    json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf8")
print(json.dumps(report, ensure_ascii=False))
