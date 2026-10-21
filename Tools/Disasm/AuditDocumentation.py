"""Контроль покрытия ручными описаниями и оформления исходников.

Машинная проверка не доказывает смысл комментариев. Реестры содержат результаты
отдельного чтения оригинальных инструкций, а этот отчёт проверяет их полноту.
"""

import json
import re
from collections import Counter
from pathlib import Path
from AuditCodeTargets import source_statement

ROOT = Path(__file__).resolve().parents[2]


def main():
    coverage = json.loads((ROOT / "Tools/Disasm/Reports/SourceCoverage.json").read_text("utf-8"))
    records = {}
    for path in (ROOT / "Tools/Disasm/Reports/Semantics").glob("*.json"):
        content = json.loads(path.read_text("utf-8"))
        if isinstance(content, list):
            for item in content:
                if isinstance(item, dict) and "semantic_name" in item:
                    if item["file"] in records:
                        raise ValueError("Повторная запись " + item["file"])
                    records[item["file"]] = item
    missing = []
    unresolved = []
    for fragment in coverage["fragments"]:
        item = records.get(fragment["file"])
        if item is None:
            missing.append(fragment["file"])
        elif item.get("status") != "reviewed" or item.get("unresolved"):
            unresolved.append(item)
        elif item["start"] != fragment["start"] or item["end"] != fragment["end"]:
            raise ValueError("Несовпадение границ описания " + fragment["file"])

    issues = []
    conditional_count = 0
    generic = re.compile(
        r"назначение (?:процедуры|фрагмента|входа|участка).*требу|контракт .*уточня|расчёт исходного значения|"
        r"проверка исходного условия|переход, если флаг (?:Z|переноса|знака)|"
        r"выход, если флаг (?:Z|переноса|знака)")
    paths = sorted((ROOT / "Source").rglob("*.asm")) + sorted((ROOT / "Includes").rglob("*.inc"))
    for path in paths:
        for number, raw in enumerate(path.read_text("utf-8-sig").splitlines(), 1):
            code, separator, comment = raw.partition(";")
            reasons = []
            label_only = bool(re.fullmatch(r"[\w.]+:", code.strip()) or
                              (code and not code[0].isspace() and
                               re.fullmatch(r"[\w.]+", code.strip())))
            if separator and code.strip():
                expected = 16 if label_only else 80
                # Для длинной инструкции допустим сдвиг комментария через один пробел.
                if not label_only and raw.index(";") > 80:
                    expected = max(80, len(code.rstrip()) + 1)
                if raw.index(";") != expected:
                    reasons.append(f"правый комментарий вне позиции {expected}")
            if separator and ";" in comment:
                reasons.append("точка с запятой внутри текста комментария")
            if generic.search(raw):
                reasons.append("предварительное или механическое описание")
            label = re.match(r"^[\w.]+(?::\s*|\s+)(\S)", code)
            if label and label.start(1) != 16:
                reasons.append("код после метки начинается не с позиции 16")
            instruction = source_statement(raw)
            if re.match(r"^(JP|JR|CALL)\s+(NZ|Z|NC|C|PO|PE|P|M),"
                        r"|^RET\s+(NZ|Z|NC|C|PO|PE|P|M)\s*$", instruction, re.I):
                conditional_count += 1
                if not separator:
                    reasons.append("нет пояснения условного управления")
                elif instruction.upper().startswith(("JP ", "JR ")) and not comment.strip().startswith("переход, если "):
                    reasons.append("условный переход без требуемой формулировки")
                elif instruction.upper().startswith("RET ") and not comment.strip().startswith("выход, если "):
                    reasons.append("условный выход без требуемой формулировки")
            if reasons:
                issues.append({"file": path.relative_to(ROOT).as_posix(),
                               "line": number, "reasons": reasons})
    report = {
        "scope": "покрытие ручными реестрами и проверка оформления, не автоматическое доказательство семантики",
        "game_bytes": coverage["source_length"],
        "game_fragments": len(coverage["fragments"]),
        "registered_fragments": len(coverage["fragments"]) - len(missing),
        "reviewed_fragments": len(coverage["fragments"]) - len(missing) - len(unresolved),
        "missing": missing, "unresolved": unresolved,
        "checked_source_files": len(paths), "conditional_instructions": conditional_count,
        "format_issues": issues,
        "categories": dict(Counter(Path(x["file"]).parent.name for x in coverage["fragments"])),
        "all_fragments_manually_reviewed": not missing and not unresolved,
        "format_passed": not issues,
        "historical_unknowns": [
            {"file": item["file"], "details": item["historical_unknowns"]}
            for item in records.values() if item.get("historical_unknowns")
        ],
        "hardware_effects": [
            {"file": item["file"], "details": item["hardware_effects"]}
            for item in records.values() if item.get("hardware_effects")
        ],
    }
    (ROOT / "Tools/Disasm/Reports/SemanticAudit.json").write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n", "utf-8")
    print(f"Reviewed {report['reviewed_fragments']}/{report['game_fragments']}, "
          f"unresolved {len(unresolved)}, format issues {len(issues)}")
    for item in issues[:30]:
        print(f"{item['file']}:{item['line']} " + ", ".join(item["reasons"]))
    if issues or missing or unresolved:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
