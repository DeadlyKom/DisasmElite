"""Обновление итогового указателя исходников из проверенных реестров.

Не часть сборки, не создаёт машинный код и не заменяет ручной разбор процедур.
"""

import json
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "Tools/Disasm/Research"))
sys.path.insert(0, str(ROOT / "Tools/Disasm"))
from FinalizeNames import read_records
from AuditCodeTargets import source_map


def main():
    records = read_records()
    coverage_path = ROOT / "Tools/Disasm/Reports/SourceCoverage.json"
    coverage = json.loads(coverage_path.read_text("utf-8"))
    occupied, instructions = source_map()
    groups = defaultdict(list)
    for fragment in coverage["fragments"]:
        item = records[fragment["file"]]
        if item["status"] != "reviewed" or item.get("unresolved"):
            raise ValueError("Не завершён разбор " + fragment["file"])
        start, end = fragment["start"], fragment["end"]
        fragment["initial_status"] = fragment.get("initial_status", fragment["status"])
        category = Path(fragment["file"]).parent.name
        fragment["status"] = "manual" if category == "Math" else "resource" if category == "Resources" else "reviewed"
        fragment["semantic_name"] = item["semantic_name"]
        fragment["description"] = item["summary"]
        fragment["instructions"] = sum(address in instructions for address in range(start, end))
        fragment["code_bytes"] = sum(occupied[a]["kind"] == "code" for a in range(start, end))
        fragment["literal_bytes"] = sum(occupied[a]["kind"] == "literal" for a in range(start, end))
        fragment["resource_bytes"] = sum(occupied[a]["kind"] == "resource" for a in range(start, end))
        groups[category].append(fragment)
    coverage["warning"] = (
        "Файловые границы сохраняют порядок байтов. Фрагмент может содержать несколько "
        "входов или продолжаться в следующем файле. Смысловые описания находятся в реестрах Semantics.")
    coverage["all_fragments_reviewed"] = True
    coverage["instruction_count"] = len(instructions)
    coverage["code_bytes"] = sum(x["code_bytes"] for x in coverage["fragments"])
    coverage["literal_bytes"] = sum(x["literal_bytes"] for x in coverage["fragments"])
    coverage["resource_bytes"] = sum(x["resource_bytes"] for x in coverage["fragments"])
    assert coverage["code_bytes"] + coverage["literal_bytes"] + coverage["resource_bytes"] == 49152
    coverage_path.write_text(json.dumps(coverage, ensure_ascii=False, indent=2) + "\n", "utf-8")

    lines = [
        "# Указатель игрового исходника", "",
        f"Файловый диапазон `#4000..#FFFF` покрыт {len(coverage['fragments'])} фрагментами.",
        "Это число файлов, а не число логических процедур. Отдельные файлы содержат",
        "дополнительные входы, таблицы или продолжения соседних процедур.",
        "В исходниках указаны регистры, алгоритм, специальные входы и изменяемые данные.", "",
        "Исходные адреса сохранены. Имена обозначают проверенное действие, смысловые",
        "метки переходов и контрольные ASSERT позволяют сопоставить код с оригиналом.", "",
        f"В текущей разметке {len(instructions)} инструкций, {coverage['code_bytes']} байтов кода,",
        f"{coverage['literal_bytes']} байтов литеральных данных и перекрытий, "
        f"{coverage['resource_bytes']} байтов внешних ресурсов.", "",
        "| Подсистема | Файлов |", "|---|---:|",
    ]
    for category, fragments in sorted(groups.items()):
        lines.append(f"| {category} | {len(fragments)} |")
    for category, fragments in sorted(groups.items()):
        lines += ["", "## " + category, "", "| Адреса | Исходник | Назначение |", "|---|---|---|"]
        for fragment in fragments:
            path = fragment["file"]
            name = Path(path).stem
            purpose = fragment["description"].replace("|", "\\|").replace("\n", " ")
            lines.append(f"| `#{fragment['start']:04X}..#{fragment['end'] - 1:04X}` "
                         f"| [{name}](../{path}) | {purpose} |")
    (ROOT / "Docs/Functions.md").write_text("\n".join(lines) + "\n", "utf-8")

    # Построение навигации по фактическим источникам абсолютных патчей кода.
    targets = json.loads((ROOT / "Tools/Disasm/Reports/CodeTargets.json").read_text("utf-8"))
    lines = [
        "# Изменяемый код и непрямое управление", "",
        "Перечень построен по окончательной разметке инструкций и дополняет пояснения",
        "в исходниках. Он перечисляет абсолютные `LD (nn),...`, попадающие в код.",
        "Записи через регистровые указатели и перестройку стека нужно смотреть",
        "в описании соответствующего алгоритма.", "",
        "## Абсолютные записи в код", "",
        "| Команда | Запись | Изменяемый участок |", "|---|---|---|",
    ]
    for item in targets["absolute_code_writes"]:
        source = item["file"]
        destination = item["destination"]["file"]
        lines.append(f"| [`#{item['address']:04X}`](../{source}) "
                     f"| `{item['operation'].replace('$', '#')}` "
                     f"| [`#{item['target']:04X}`, {Path(destination).stem}](../{destination}) |")
    lines += ["", "## Косвенные JP", "",
              "Такие переходы используют адрес в регистре. Их таблицы и вызывающий",
              "контекст разобраны в указанных исходниках.", "",
              "| Адрес | Команда | Исходник |", "|---|---|---|"]
    for item in targets["indirect_jumps"]:
        lines.append(f"| `#{item['address']:04X}` | `{item['operation']}` "
                     f"| [{Path(item['file']).stem}](../{item['file']}) |")
    lines += ["", "## Перекрывающиеся входы", "",
              "В [CodeTargets.json](../Tools/Disasm/Reports/CodeTargets.json) отдельно перечислены переходы внутрь",
              "другой инструкции и в литерально сохранённые перекрытия. Наличие",
              "записи в этом списке само по себе не означает ошибку исходника.",
              "Проверка всех найденных входов зафиксирована в [CodeTargetReview.json](../Tools/Disasm/Reports/CodeTargetReview.json).",
              "", "| Вход | Источник | Объяснение |", "|---|---|---|"]
    reviews = json.loads((ROOT / "Tools/Disasm/Reports/CodeTargetReview.json").read_text("utf-8"))
    assert not reviews["unresolved"]
    assert len(reviews["reviews"]) == len(targets["review_required"])
    grouped = defaultdict(list)
    for item in reviews["reviews"]:
        grouped[item["target"]].append(item)
    for target, items in sorted(grouped.items()):
        sources = ", ".join(f"`#{item['source']:04X}`" for item in items)
        explanation = items[0]["explanation"].replace("|", "\\|")
        lines.append(f"| [`#{target:04X}`](../{items[0]['destination_file']}) "
                     f"| {sources} | {explanation} |")
    lines.append("")
    (ROOT / "Docs/ModifiedCode.md").write_text("\n".join(lines), "utf-8")
    print(f"Documentation: {len(groups)} categories, {len(instructions)} instructions")


if __name__ == "__main__":
    main()
