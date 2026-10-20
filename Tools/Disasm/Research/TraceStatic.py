"""Карта прямых переходов, кандидаты требуют ручного разбора косвенных входов."""

import json
import re
import sys
from collections import deque
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "Tools/Disasm"))
from InspectZ80 import decoder, memory_for


def main():
    memory = memory_for("decoded")
    disassembler = decoder(memory)
    reference = json.loads((ROOT / "Tools/Disasm/Reports/ReferenceMatches.json").read_text("utf-8"))
    roots = {0x7394, 0x7ABF, 0xE063, 0xFEFE, 0xFF25, 0xFF4C, 0xFF53}
    # Поиск начальных адресов в сопоставленных последовательностях инструкций.
    for chunk in reference["chunks"]:
        roots.add(chunk["target_start"])
    queue = deque(sorted(roots))
    instructions = {}
    calls = set()
    branches = set()
    indirect = set()
    outside = set()
    inline = set()
    inline_calls = {0xD421: 1, 0xE2BC: 1, 0xF068: 1, 0xD956: 2}
    # Обход только прямых рёбер, без предположений о содержимом регистров.
    while queue:
        address = queue.popleft()
        if address in instructions:
            continue
        if not 0x5C00 <= address < 65536 or 0xC000 <= address < 0xD000:
            outside.add(address)
            continue
        ins = disassembler.disassemble(address, address + 1, "h")[0]
        operation = ins.operation
        if operation.startswith("DEF"):
            continue
        instructions[address] = {
            "address": address, "operation": operation,
            "bytes": ins.bytes.hex(), "length": len(ins.bytes),
        }
        following = address + len(ins.bytes)
        match = re.match(r"^(CALL|JP|JR|DJNZ) (?:([A-Z]+),)?\$([0-9A-F]+)$", operation)
        if match:
            kind, condition, operand = match.groups()
            target = int(operand, 16)
            queue.append(target)
            branches.add(target)
            if kind == "CALL":
                calls.add(target)
                # Пропуск аргументов, извлекаемых процедурой из адреса возврата.
                size = inline_calls.get(target, 0)
                inline.update(range(following, following + size))
                following += size
            if kind in ("JP", "JR") and condition is None:
                continue
        if operation in ("JP (HL)", "JP (IX)", "JP (IY)"):
            indirect.add(address)
            continue
        if operation in ("RET", "RETI", "RETN"):
            continue
        queue.append(following)
    occupied = {}
    overlaps = set()
    # Проверка перекрывающихся входов, возможны намеренные перекрытия Z80.
    for address, ins in sorted(instructions.items()):
        for byte in range(address, address + ins["length"]):
            if byte in occupied:
                overlaps.add((occupied[byte], address))
            else:
                occupied[byte] = address
    report = {
        "warning": "Кандидатная карта, косвенные переходы и inline-данные ещё не разобраны",
        "instruction_count": len(instructions), "covered_bytes": len(occupied),
        "roots": sorted(roots), "call_targets": sorted(calls),
        "branch_targets": sorted(branches), "indirect": sorted(indirect),
        "outside": sorted(outside), "overlaps": sorted(overlaps),
        "inline_data": sorted(inline),
        "instructions": [instructions[key] for key in sorted(instructions)],
    }
    (ROOT / "Tools/Disasm/Reports/ControlFlow.json").write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    for key in ("instruction_count", "covered_bytes", "indirect", "outside", "overlaps"):
        print(key, report[key])


if __name__ == "__main__":
    main()
