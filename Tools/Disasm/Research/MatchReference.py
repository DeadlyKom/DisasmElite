"""Сопоставление инструкций справочника с исходным снимком, без ассемблирования."""

import json
import re
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "Tools/Disasm"))
from InspectZ80 import decoder, memory_for


def normalize(operation, address):
    """Сохранить команды, константы и относительные смещения, скрыть RAM-адреса."""
    operation = re.sub(r"\s+", "", operation.upper())
    if operation.startswith(("JR", "DJNZ")):
        match = re.search(r"\$([0-9A-F]{4})$", operation)
        if match:
            relative = (int(match[1], 16) - address - 2) & 65535
            operation = operation[:match.start()] + "REL" + str(relative)
    operation = re.sub(
        r"\$([0-9A-F]{4})",
        lambda match: "$RAM" if 0x4000 <= int(match[1], 16) < 0xFF00
        else match[0],
        operation,
    )
    return operation


def read_reference():
    records = []
    routines = []
    labels = {}
    comments = []
    pending_label = None
    for line in (ROOT / "Tools/Disasm/Research/References/elite128.skool").read_text(
            encoding="utf-8-sig").splitlines():
        if line.startswith("@label="):
            pending_label = line[7:]
        elif line.startswith(";"):
            comments.append(line[1:].strip())
        elif match := re.match(r"([cbwtusig *])\$([0-9A-F]{4})\s+([^;]+)", line):
            kind, address, operation = match.groups()
            address = int(address, 16)
            operation = operation.strip()
            is_code = not operation.upper().startswith(("DEF", "DB", "DW"))
            if pending_label:
                labels[address] = pending_label
                pending_label = None
            if kind == "c":
                title = next((text for text in comments if text), f"Routine_{address:04X}")
                routines.append({"address": address, "title": title})
            records.append({"address": address, "operation": operation,
                            "code": is_code})
            comments = []
    instructions = {}
    for index, record in enumerate(records[:-1]):
        length = records[index + 1]["address"] - record["address"]
        if record["code"] and 1 <= length <= 4:
            instructions[record["address"]] = {
                **record, "length": length,
                "token": (normalize(record["operation"], record["address"]), length),
            }
    return instructions, routines, labels


def token_window(instructions, address, count=10):
    tokens = []
    for _ in range(count):
        instruction = instructions.get(address)
        if instruction is None:
            return None
        tokens.append(instruction["token"])
        address += instruction["length"]
    return tuple(tokens)


def follow_direct_jumps(instructions, address):
    """Проследить только безусловные JP, без выполнения кода."""
    visited = set()
    while address not in visited:
        visited.add(address)
        instruction = instructions.get(address)
        if not instruction:
            break
        match = re.fullmatch(r"JP \$([0-9A-F]{4})", instruction["operation"])
        if not match:
            break
        address = int(match[1], 16)
    return address


def main():
    reference, routines, labels = read_reference()
    target = {}
    memory = memory_for("game")
    decoded_path = ROOT / "Tools/Disasm/Research/GameCode.bin"
    if decoded_path.exists():
        decoded = decoded_path.read_bytes()
        if len(decoded) == 65536:
            memory[:] = decoded
        elif len(decoded) == 49152:
            memory[0x4000:] = decoded
        else:
            raise ValueError("Decoded image has an unexpected size")
    disassembler = decoder(memory)
    # Декодирование с каждого смещения позволяет не задавать неподтверждённые границы кода.
    for address in range(0x5B00, 0xFFFE):
        instruction = disassembler.disassemble(address, address + 1, "h")[0]
        target[address] = {
            "length": len(instruction.bytes),
            "token": (normalize(instruction.operation, address), len(instruction.bytes)),
            "operation": instruction.operation,
        }
    # Индекс последовательностей используется только для поиска кандидатов.
    index = defaultdict(list)
    for address in target:
        tokens = token_window(target, address)
        if tokens:
            index[tokens].append(address)
    anchors = defaultdict(set)
    for address in reference:
        tokens = token_window(reference, address)
        if tokens and len(index.get(tokens, ())) == 1:
            target_address = index[tokens][0]
            anchors[target_address - address].add(address)
    chunks = []
    for delta, starts in anchors.items():
        covered = set()
        for start in sorted(starts):
            if start in covered:
                continue
            addresses = []
            address = start
            while (address in reference and address + delta in target
                   and reference[address]["token"] == target[address + delta]["token"]):
                covered.add(address)
                addresses.append(address)
                address += reference[address]["length"]
            if len(addresses) >= 10:
                chunks.append({
                    "reference_start": start, "reference_end": address,
                    "target_start": start + delta, "target_end": address + delta,
                    "instructions": len(addresses), "delta": delta,
                })
    candidates = defaultdict(list)
    for chunk in chunks:
        for routine in routines:
            if chunk["reference_start"] <= routine["address"] < chunk["reference_end"]:
                candidates[routine["address"]].append((chunk, routine))
    # Независимые ссылки между найденными участками подтверждают их назначение.
    branch_votes = defaultdict(lambda: defaultdict(set))
    operand_votes = defaultdict(lambda: defaultdict(set))
    for chunk in chunks:
        address = chunk["reference_start"]
        while address < chunk["reference_end"]:
            original = reference[address]["operation"]
            restored = target[address + chunk["delta"]]["operation"]
            source_branch = re.match(r"(?:CALL|JP)\s+(?:(?:NZ|Z|NC|C|PO|PE|P|M),)?\$([0-9A-F]{4})$", original)
            target_branch = re.match(r"(?:CALL|JP)\s+(?:(?:NZ|Z|NC|C|PO|PE|P|M),)?\$([0-9A-F]{4})$", restored)
            if source_branch and target_branch:
                destination = follow_direct_jumps(target, int(target_branch[1], 16))
                branch_votes[int(source_branch[1], 16)][destination].add(
                    (address, address + chunk["delta"]))
            source_values = re.findall(r"\$([0-9A-F]{4})", original)
            target_values = re.findall(r"\$([0-9A-F]{4})", restored)
            if len(source_values) == len(target_values) and not original.startswith(("JR ", "DJNZ ")):
                for old_value, new_value in zip(source_values, target_values):
                    operand_votes[int(old_value, 16)][int(new_value, 16)].add(
                        (address, address + chunk["delta"]))
            address += reference[address]["length"]
    routine_ends = {
        routine["address"]: routines[index + 1]["address"] if index + 1 < len(routines) else 65536
        for index, routine in enumerate(routines)
    }
    matches = []
    for address, options in sorted(candidates.items()):
        distinct = {chunk["delta"] for chunk, _ in options}
        if len(distinct) != 1:
            continue
        chunk, routine = max(options, key=lambda pair: pair[0]["instructions"])
        matches.append({
            "reference": address, "target": address + chunk["delta"],
            "title": routine["title"],
            "anchor_reference": chunk["reference_start"],
            "anchor_target": chunk["target_start"],
            "anchor_instructions": chunk["instructions"],
            "anchor_end": chunk["target_end"],
        })
    existing = {item["reference"] for item in matches}
    for routine in routines:
        address = routine["address"]
        if address in existing:
            continue
        options = branch_votes.get(address, {})
        if len(options) == 1:
            new_target, evidence = next(iter(options.items()))
            if len(evidence) >= 2:
                matches.append({
                    "reference": address, "target": new_target,
                    "title": routine["title"],
                    "anchor_reference": address, "anchor_target": new_target,
                    "anchor_instructions": 0, "anchor_end": new_target,
                    "inferred_from_calls": True,
                })
    target_uses = defaultdict(list)
    for item in matches:
        target_uses[item["target"]].append(item["reference"])
    for item in matches:
        address = item["reference"]
        target_address = item["target"]
        prefix = 0
        while (address in reference and target_address in target
               and address < routine_ends[item["reference"]]
               and reference[address]["token"] == target[target_address]["token"]):
            prefix += 1
            address += reference[address]["length"]
            target_address += target[target_address]["length"]
        evidence = branch_votes.get(item["reference"], {})
        canonical_target = follow_direct_jumps(target, item["target"])
        item["matching_prefix_instructions"] = prefix
        item["entire_declared_routine_matches"] = address == routine_ends[item["reference"]]
        item["canonical_target"] = canonical_target
        item["caller_support"] = len(evidence.get(canonical_target, ()))
        item["caller_conflicts"] = {
            f"{destination:04X}": len(sources)
            for destination, sources in evidence.items()
            if destination != canonical_target
        }
        item["other_reference_entries_at_target"] = [
            f"{value:04X}" for value in target_uses[item["target"]]
            if value != item["reference"]
        ]
        item["confidence"] = (
            "supported" if prefix >= 3 and item["caller_support"] >= 2
            and not item["caller_conflicts"]
            and not item["other_reference_entries_at_target"]
            else "candidate"
        )
    mapped_labels = []
    for address, name in labels.items():
        evidence = operand_votes.get(address, {})
        if len(evidence) == 1:
            destination, sources = next(iter(evidence.items()))
            if len(sources) >= 2:
                mapped_labels.append({
                    "reference": address, "target": destination, "name": name,
                    "independent_instructions": len(sources),
                    "evidence": [{"reference": old, "target": new}
                                 for old, new in sorted(sources)],
                })
    # Для каждого совпавшего участка сохранены точные границы и сила совпадения.
    result = {
        "method": "unique normalized 10-instruction windows, extended consecutively",
        "normalization": "ignore 16-bit operands #4000..#FEFF; retain relative branch distances, other immediates and instruction lengths",
        "warning": "candidates require cross-reference checks; no assembly or runtime verification",
        "reference_instructions": len(reference),
        "decoded_view": decoded_path.relative_to(ROOT).as_posix() if decoded_path.exists() else None,
        "chunks": chunks, "routines": sorted(matches, key=lambda item: item["target"]),
        "referenced_labels": sorted(mapped_labels, key=lambda item: item["target"]),
    }
    path = ROOT / "Tools/Disasm/Reports/ReferenceMatches.json"
    path.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n",
                    encoding="utf-8")
    print(f"Matched {len(matches)}/{len(routines)} named entries in {len(chunks)} chunks")
    for item in sorted(matches, key=lambda item: item["target"]):
        print(f"{item['reference']:04X} -> {item['target']:04X} "
              f"[{item['anchor_instructions']:4}] [{item['confidence']}, "
              f"calls={item['caller_support']}] {item['title']}")


if __name__ == "__main__":
    main()
