"""Проверка и разметка продолжений между файлами игрового блока.

По умолчанию пишет только отчёт. --apply добавляет комментарии и номера include,
не добавляя ни одной машинной инструкции. Не запускает сборку.
"""
import argparse
import json
import re
from pathlib import Path
from AuditCodeTargets import source_map

ROOT = Path(__file__).resolve().parents[2]
REPORT = ROOT / "Tools/Disasm/Reports/FallThroughAudit.json"
STOP = re.compile(r"(?:RET|RETI|RETN)|(?:JP|JR) (?!NZ,|Z,|NC,|C,|PO,|PE,|P,|M,).*")


def source_definitions(path, symbols):
    scopes = ["Game"]
    anchor = ""
    result = {}
    for raw in path.read_text("utf-8-sig").splitlines():
        code = raw.partition(";")[0]
        module = re.fullmatch(r"\s*module\s+(\w+)\s*", code, re.I)
        if module:
            scopes.append(module[1]); continue
        if re.fullmatch(r"\s*endmodule\s*", code, re.I):
            scopes.pop(); continue
        match = re.match(r"^([@\w.]+):?(?:\s|$)", code)
        if not match:
            continue
        name = match[1]
        if name.startswith("."):
            name = anchor + name
        elif not name.startswith("@"):
            anchor = name
        name = name[1:] if name.startswith("@") else ".".join(scopes + [name])
        if name in symbols:
            result[name] = symbols[name]
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()
    symbols = {m[1]: int(m[2], 16) for m in re.finditer(
        r"^([\w.]+): EQU 0x([\dA-Fa-f]+)$", (ROOT / "Tmp/ELITE3HL.sym").read_text("utf-8-sig"), re.M)}
    fragments = json.loads((ROOT / "Tools/Disasm/Reports/SourceCoverage.json").read_text("utf-8"))["fragments"]
    occupied, instructions = source_map()
    rows = []
    updates = {}
    chains = {}
    for fragment in fragments[:-1]:
        end = fragment["end"]
        last = occupied[end - 1]
        if last["kind"] != "code":
            continue
        item = instructions[last["start"]]
        if STOP.fullmatch(item["operation"]):
            continue
        target = occupied[end]
        if target["kind"] != "code":
            raise ValueError(("Продолжение попадает в данные", fragment, target))
        names = source_definitions(ROOT / target["file"], symbols)
        candidates = [name for name, address in names.items() if address == end]
        if not candidates:
            raise ValueError(("Нет имени входа продолжения", target))
        candidates.sort(key=lambda name: (not name.endswith(".Entry"), len(name), name))
        destination = candidates[0]
        source = fragment["file"]
        lines = updates.setdefault(source, (ROOT / source).read_text("utf-8-sig").splitlines())
        raw = lines[item["line"] - 1]
        code, sep, comment = raw.partition(";")
        marker = "далее " + destination + " без команды перехода"
        present = marker in comment
        if args.apply and not present:
            text = comment.strip()
            connector = ", иначе " if re.match(r"(?:RET|JP|JR) (?:NZ|Z|NC|C|PO|PE|P|M)(?:,|$)", item["operation"]) else ", "
            text = text + connector + marker if text else marker
            lines[item["line"] - 1] = code.rstrip().ljust(max(80, len(code.rstrip()) + 1)) + "; " + text
            present = True
        chains[source] = target["file"]
        rows.append({"file": source, "line": item["line"], "address": item["address"],
                     "operation": item["operation"], "target_file": target["file"],
                     "target_address": end, "target_symbol": destination, "annotated": present})
    include_path = ROOT / "Source/Game/Include.inc"
    include_lines = include_path.read_text("utf-8-sig").splitlines()
    include_order = []
    for number, raw in enumerate(include_lines):
        match = re.match(r'\s*include\s+"([^"]+)"', raw, re.I)
        if match:
            include_order.append(("Source/Game/" + match[1], number))
    groups = {}
    index = 0
    while index < len(include_order):
        file, number = include_order[index]
        if file not in chains:
            index += 1; continue
        group = [(file, number)]
        while file in chains:
            index += 1
            if index >= len(include_order) or include_order[index][0] != chains[file]:
                raise ValueError(("Нарушен порядок include", file, chains[file]))
            file, number = include_order[index]
            group.append((file, number))
        for ordinal, (file, number) in enumerate(group):
            groups[file] = ordinal
            raw = include_lines[number]
            code, sep, comment = raw.partition(";")
            marker = f"({ordinal})"
            if args.apply and not re.match(r"\s*" + re.escape(marker) + r"(?:\s|$)", comment):
                note = marker + (" " + comment.strip() if comment.strip() else "")
                include_lines[number] = code.rstrip().ljust(max(80, len(code.rstrip()) + 1)) + "; " + note
        index += 1
    for row in rows:
        row["include_position"] = groups[row["file"]]
        row["target_include_position"] = groups[row["target_file"]]
    if args.apply:
        for file, lines in updates.items():
            path = ROOT / file
            text = "\n".join(lines) + "\n"
            before = path.read_text("utf-8-sig")
            code = lambda value: [line.partition(";")[0].strip() for line in value.splitlines() if line.partition(";")[0].strip()]
            if code(before) != code(text):
                raise ValueError(("Изменился код", file))
            if text != before:
                path.write_text(text, encoding="utf-8", newline="\r\n")
        marker = "; цепочки include с номерами (0), (1) продолжают код без перехода, порядок жёсткий"
        if marker not in include_lines:
            include_lines.insert(4, marker)
        include_path.write_text("\n".join(include_lines) + "\n", encoding="utf-8", newline="\r\n")
    report = {"scope": "возможное последовательное продолжение по границам файлов игрового блока",
              "note": "Проверена адресная смежность. CALL может менять адрес возврата, это описывается контрактом вызываемой процедуры.",
              "boundary_count": len(rows), "annotated_count": sum(row["annotated"] for row in rows),
              "include_chain_files": len(groups), "boundaries": rows,
              "passed": all(row["annotated"] for row in rows)}
    REPORT.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Fall-through boundaries {len(rows)}, annotated {report['annotated_count']}, include chain files {len(groups)}")


if __name__ == "__main__":
    main()
