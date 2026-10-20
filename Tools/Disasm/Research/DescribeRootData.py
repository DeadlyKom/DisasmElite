"""Реестр вручную разобранных общих данных, ресурсов и математических процедур."""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]


def main():
    coverage = json.loads((ROOT / "Tools/Disasm/Reports/SourceCoverage.json").read_text("utf-8"))
    resources_path = ROOT / "Tools/Disasm/Reports/Resources.json"
    resources = json.loads(resources_path.read_text("utf-8"))
    records = []
    for resource in resources:
        source = ROOT / "Source/Game/Resources" / (resource["name"] + ".asm")
        comments = [line[2:] for line in source.read_text("utf-8").splitlines()
                    if line.startswith("; ") and not line.startswith("; --")]
        resource["description"] = comments
        records.append({
            "start": resource["start"], "end": resource["end"],
            "file": str(source.relative_to(ROOT)).replace("\\", "/"),
            "semantic_name": resource["name"], "status": "reviewed",
            "kind": "resource", "summary": comments[0], "unresolved": [],
            "evidence": comments[1:], "resource_file": resource["file"],
        })
    resources_path.write_text(json.dumps(resources, ensure_ascii=False, indent=2) + "\n", "utf-8")
    data = {
        0xAFF0: ("LegacyClipTables", "сохранившиеся таблицы предыдущего алгоритма отсечения",
                 "новый алгоритм #B044 таблицы не читает, данные сохраняются без изменения"),
        0xBE00: ("SquareTables", "младшие и старшие байты квадратов аргументов 0..255",
                 "потребители #87BF, #AB0B и #AB34"),
        0xD000: ("MenuDispatchTable", "семь исполняемых JP основных экранов",
                 "диспетчер #813E вычисляет адрес записи как #D000+A*3"),
        0xE07A: ("LaunchCounter", "отложенный флаг и счётчик вылетов",
                 "#D8DD устанавливает флаг, #5E55 увеличивает счётчик, #FC33 очищает"),
    }
    for fragment in coverage["fragments"]:
        if fragment["start"] in data:
            name, purpose, evidence = data[fragment["start"]]
            records.append({
                "start": fragment["start"], "end": fragment["end"],
                "file": fragment["file"], "semantic_name": name,
                "status": "reviewed", "kind": "data", "summary": purpose,
                "evidence": [evidence], "unresolved": [],
            })
    maths = json.loads((ROOT / "Tools/Disasm/Reports/MathRanges.json").read_text("utf-8"))
    for item in maths:
        source = ROOT / item["file"]
        title = next(line[2:] for line in source.read_text("utf-8").splitlines()
                     if line.startswith("; ") and not line.startswith("; --"))
        records.append({
            "start": item["start"], "end": item["end_exclusive"], "file": item["file"],
            "semantic_name": source.stem, "status": "reviewed", "summary": title,
            "evidence": ["ручной разбор контракта и исходных инструкций",
                         "исполнение оригинального кода, Tools/Disasm/Reports/MathValidation.json"],
            "unresolved": [], "entries": item["entries"],
        })
    (ROOT / "Tools/Disasm/Reports/Semantics/RootData.json").write_text(
        json.dumps(records, ensure_ascii=False, indent=2) + "\n", "utf-8")
    print(f"Root data and maths: {len(records)} entries")


if __name__ == "__main__":
    main()
