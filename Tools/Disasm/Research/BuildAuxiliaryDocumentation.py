"""Указатель разобранных файлов руководства, загрузчика и дисковых оверлеев."""

import json
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]


def title(path):
    for line in path.read_text("utf-8-sig").splitlines():
        text = line.strip()
        if text.startswith(";"):
            text = text[1:].strip()
            if text and set(text) != {"-"}:
                return text
    raise ValueError("Нет заголовка " + str(path))


def main():
    records = {}
    for name in ("DiskUtilityMenuSemantics", "DiskUtilityDemoSemantics"):
        document = json.loads((ROOT / "Tools/Disasm/Reports" / (name + ".json")).read_text("utf-8"))
        for item in document:
            assert item["status"] == "reviewed" and not item.get("unresolved"), item["file"]
            assert item["file"] not in records, item["file"]
            records[item["file"]] = item
    expected = {
        path.relative_to(ROOT).as_posix()
        for folder in ("Menu", "Demo", "DemoSetup")
        for path in (ROOT / "Source/DiskUtility" / folder).glob("*.asm")
    }
    assert expected == set(records), (expected - set(records), set(records) - expected)

    manual_audit = json.loads(
        (ROOT / "Tools/Disasm/Reports/ManualLoaderDocumentationAudit.json").read_text("utf-8"))
    manual_paths = list((ROOT / "Source/Manual").glob("*.asm"))
    loader_paths = list((ROOT / "Source/Loader").glob("*.asm"))
    assert len(manual_paths) + len(loader_paths) == manual_audit["asm_files_reviewed"]
    assert not manual_audit["style_errors"]

    groups = defaultdict(list)
    for path in manual_paths + loader_paths:
        groups[path.parent.name].append((path, title(path)))
    for file, item in records.items():
        path = ROOT / file
        groups["DiskUtility/" + path.parent.name].append((path, item["summary"]))
    for path in (ROOT / "Source/Commanders").glob("*.asm"):
        groups["Commanders"].append((path, title(path)))
    for name in ("Source/DiskUtility/Robot.asm", "Source/Boot/Include.inc"):
        path = ROOT / name
        groups["Данные и BASIC"].append((path, title(path)))

    lines = [
        "# Руководство, загрузчик и дисковые оверлеи", "",
        "Исходники здесь сохраняют собственные адреса исполнения через `DISP/ENT`.",
        "Положение внутри файла и адрес команды в памяти различаются.",
        "Встроенные байты после CALL, текстовые токены, таблицы и секторные хвосты",
        "отмечены отдельно. Команды ROM/TR-DOS остаются внешними вызовами.", "",
        "Полное устройство просмотрщика описано в [его README](../Source/Manual/README.md).",
        "Главный [указатель игрового блока](Functions.md) находится отдельно.", "",
    ]
    for category, values in sorted(groups.items()):
        lines += ["## " + category, "", "| Исходник | Назначение |", "|---|---|"]
        for path, summary in sorted(values):
            summary = summary.replace("|", "\\|").replace("\n", " ")
            lines.append(f"| [{path.stem}](../{path.relative_to(ROOT).as_posix()}) | {summary} |")
        lines.append("")
    lines += [
        "## Основания проверки", "",
        "- [ManualLoaderDocumentationAudit.json](../Tools/Disasm/Reports/ManualLoaderDocumentationAudit.json) — повторное чтение 31 ASM-файла, уточнение контрактов и проверка неизменности команд",
        "- [DiskUtilityMenuSemantics.json](../Tools/Disasm/Reports/DiskUtilityMenuSemantics.json) — описание всех файлов первого оверлея",
        "- [DiskUtilityDemoSemantics.json](../Tools/Disasm/Reports/DiskUtilityDemoSemantics.json) — описание установщика и корутины демонстрации",
        "- [InterfaceWorld.json](../Tools/Disasm/Reports/Semantics/InterfaceWorld.json) — формат двух сохранённых командиров",
        "- [ManualBasic.json](../Tools/Disasm/Reports/ManualBasic.json) — исходные строки BASIC в файле руководства",
        "- [BuildVerification.json](../Tools/Disasm/Reports/BuildVerification.json) — результаты сборки и совпадения каждого логического файла",
        "",
    ]
    (ROOT / "Docs/Auxiliary.md").write_text("\n".join(lines), "utf-8")
    report = {
        "disk_utility_fragments": len(records),
        "disk_utility_reviewed": len(records),
        "manual_loader_asm_reviewed": len(manual_paths) + len(loader_paths),
        "commander_files": len(groups["Commanders"]),
        "basic_and_robot_files": len(groups["Данные и BASIC"]),
        "unresolved": [],
        "scope": "статическое описание дополнительных файлов, без запуска дискового ROM и полного игрового сеанса",
    }
    (ROOT / "Tools/Disasm/Reports/AuxiliaryAudit.json").write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n", "utf-8")
    print(f"Auxiliary documentation: {len(records)} overlay fragments, "
          f"{len(manual_paths) + len(loader_paths)} manual/loader files")


if __name__ == "__main__":
    main()
