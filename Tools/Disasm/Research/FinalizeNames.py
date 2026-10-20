"""Однократное применение имён из проверенных реестров к итоговым исходникам.

Запускается только после завершения ручных правок всех модулей. Сборка не вызывает
этот инструмент. Числа в инструкциях не меняются, перемещение кода не выполняется.
"""

import json
import re
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SHORT_NAMES = {
    "DivideLineSlopeAndDrawAlternateScanner": "DivideSlopeAndDrawScanner",
    "OfferShipUpgradeAndCorrectCoordinates": "OfferUpgradeAndCorrectPosition",
    "RefreshScannerBackgroundAndAttributes": "RefreshScannerBackground",
    "DrawCompressedModelAndModelResources": "DrawModelAndResources",
    "PrintExtendedEquipmentAndSelectIcon": "PrintEquipmentAndSelectIcon",
    "AttributeVectorAndCloakActivation": "CloakAttributeVector",
    "ProcessThargoidCounterAndBodyCoordinates": "UpdateThargoidAndBodyCoords",
    "ChooseHyperjumpConditionAndContinueLeftFill": "SelectJumpAndContinueLeftFill",
    "PrintUpgradedShipNameAndContinueRightFill": "PrintShipAndContinueRightFill",
    "CheckSunAndPlanetDistanceAndRestoreViewport": "CheckBodiesAndRestoreViewport",
    "UpdateInvasionAfterRatingOverflow": "UpdateInvasionOnRatingOverflow",
    "UpdateStationAndSpawnSpecialShips": "UpdateStationAndSpecialShips",
    "DispatchDeviceAttributesAndAppendDigit": "DispatchDeviceAndAppendDigit",
    "ScaleScannerValueAndFinishBackgroundCopy": "ScaleValueAndFinishBackground",
}


def read_records():
    records = {}
    for path in sorted((ROOT / "Tools/Disasm/Reports/Semantics").glob("*.json")):
        document = json.loads(path.read_text("utf-8"))
        if isinstance(document, list):
            for item in document:
                if isinstance(item, dict) and "semantic_name" in item and "file" in item:
                    if item["file"] in records:
                        raise ValueError(f"Повторное описание {item['file']}")
                    records[item["file"]] = item
    return records


def main():
    coverage_path = ROOT / "Tools/Disasm/Reports/SourceCoverage.json"
    coverage = json.loads(coverage_path.read_text("utf-8"))
    records = read_records()
    missing = [fragment["file"] for fragment in coverage["fragments"]
               if fragment["file"] not in records]
    if missing:
        raise ValueError("Не закончены описания: " + ", ".join(missing))

    # Проверка полноты ручных записей до первой правки исходников.
    unfinished = [fragment["file"] for fragment in coverage["fragments"]
                  if records[fragment["file"]]["status"] != "reviewed"
                  or records[fragment["file"]].get("unresolved")]
    if unfinished:
        raise ValueError("Остались открытые вопросы: " + ", ".join(unfinished))

    replacements = {}
    file_moves = {}
    module_edits = {}
    names_used = set()
    symbol_addresses = {}
    for fragment in coverage["fragments"]:
        item = records[fragment["file"]]
        path = ROOT / fragment["file"]
        text = path.read_text("utf-8-sig")
        modules = re.findall(r"^\s*module\s+(\w+)\s*$", text, re.M | re.I)
        if len(modules) < 2 or path.parent.name == "Math":
            for name, address in item.get("entries", {}).items():
                symbol_addresses["Game.Math." + name] = address
            continue
        category, old_name = modules[:2]
        name = re.sub(r"[^A-Za-z0-9_]", "", SHORT_NAMES.get(
            item["semantic_name"], item["semantic_name"]))
        if not name or name[0].isdigit():
            raise ValueError(f"Недопустимое имя {item['semantic_name']}")
        if (category, name) in names_used:
            name += f"At{fragment['start']:04X}"
        names_used.add((category, name))
        old_prefix, new_prefix = f"Game.{category}.{old_name}", f"Game.{category}.{name}"
        replacements[old_prefix + "."] = new_prefix + "."
        module_edits[fragment["file"]] = (old_name, name)
        destination = path.with_name(name + ".asm")
        if destination != path and destination.exists():
            raise ValueError(f"Путь уже занят {destination}")
        file_moves[fragment["file"]] = destination.relative_to(ROOT).as_posix()
        if re.search(r"^Entry:\s", text, re.M):
            symbol_addresses[new_prefix + ".Entry"] = fragment["start"]

    # Подготовка имён полей по фактическим смещениям проверенной структуры.
    commander_text = (ROOT / "Includes/Structs/Commander.inc").read_text("utf-8")
    fields = {}
    for line in commander_text.splitlines():
        match = re.match(r"(\w+)\s+(?:DB|DW|DS)\s+.+?;\s*\+([0-9A-F]{2})", line)
        if match:
            fields[0xD054 + int(match[2], 16)] = "State." + match[1]
    symbol_addresses.update({name: address for address, name in fields.items()})
    symbol_addresses.update({"Rom.PixelAddress": 0x22B1, "Rom.TrDos": 0x3D13})

    changed = 0
    # Остальные оверлеи оформляются отдельно и не ссылаются на игровые MODULE.
    sources = sorted((ROOT / "Source/Game").rglob("*.asm")) + sorted((ROOT / "Includes").rglob("*.inc"))
    for path in sources:
        old_text = path.read_text("utf-8-sig")
        text = old_text
        relative = path.relative_to(ROOT).as_posix()
        if relative in module_edits:
            old_name, new_name = module_edits[relative]
            text = re.sub(r"(?im)^(\s*module\s+)" + re.escape(old_name) + r"\s*$",
                          lambda match: match[1] + new_name, text, count=1)
        lines = []
        for line in text.splitlines():
            code, separator, comment = line.partition(";")
            for old, new in replacements.items():
                code = code.replace(old, new)
            # Подстановка полей только в обращения к памяти и загрузку адресных регистров.
            if relative.startswith("Source/Game/"):
                def memory_name(match):
                    address = int(match[1], 16)
                    return "(" + fields.get(address, "#" + match[1]) + ")"
                code = re.sub(r"\(#([0-9A-F]{4})\)", memory_name, code)
                match = re.search(r"\bLD\s+(?:HL|DE|IX|IY),\s*#([0-9A-F]{4})\s*$", code, re.I)
                if match and int(match[1], 16) in fields:
                    code = code[:match.start(1) - 1] + fields[int(match[1], 16)]
                code = re.sub(r"\bCALL\s+#22B1\b", "CALL Rom.PixelAddress", code)
            if separator and code.strip():
                label_only = bool(re.fullmatch(r"[\w.]+:", code.strip()) or
                                  (code and not code[0].isspace() and
                                   re.fullmatch(r"[\w.]+", code.strip())))
                line = code.rstrip().ljust(16 if label_only else 80) + ";" + comment
            elif separator:
                line = code + ";" + comment
            else:
                line = code.rstrip()
            lines.append(line)
        result = "\n".join(lines) + "\n"
        if result != old_text or path.read_bytes().startswith(b"\xef\xbb\xbf"):
            path.write_text(result, "utf-8")
            changed += 1

    # Перемещение только явно перечисленных файлов внутри исходного рабочего каталога.
    for old, new in file_moves.items():
        if old != new:
            source, destination = (ROOT / old).resolve(), (ROOT / new).resolve()
            if not source.is_relative_to(ROOT) or not destination.is_relative_to(ROOT):
                raise ValueError("Путь вне рабочего проекта")
            source.rename(destination)

    include_path = ROOT / "Source/Game/Include.inc"
    include = include_path.read_text("utf-8")
    for old, new in file_moves.items():
        include = include.replace('"' + old.removeprefix("Source/Game/") + '"',
                                  '"' + new.removeprefix("Source/Game/") + '"')
    include_path.write_text(include, "utf-8")

    # Обновление ссылок в материалах анализа без изменения исторических кандидатов reference.
    def relocate(value):
        if isinstance(value, dict):
            return {key: relocate(item) for key, item in value.items()}
        if isinstance(value, list):
            return [relocate(item) for item in value]
        if isinstance(value, str):
            return file_moves.get(value, value)
        return value
    for path in (ROOT / "Tools/Disasm/Reports").rglob("*.json"):
        document = json.loads(path.read_text("utf-8-sig"))
        replaced = relocate(document)
        if replaced != document:
            path.write_text(json.dumps(replaced, ensure_ascii=False, indent=2) + "\n", "utf-8")
    names_path = ROOT / "Tools/Disasm/Reports/SourceNames.json"
    previous_moves = {}
    if names_path.exists():
        previous_moves = json.loads(names_path.read_text("utf-8"))["file_moves"]
    previous_moves = {old: file_moves.get(new, new) for old, new in previous_moves.items()}
    previous_moves.update(file_moves)
    names_path.write_text(json.dumps({
        "file_moves": previous_moves, "symbols": symbol_addresses,
        "purpose": "проверенные имена, без перемещения исходных адресов",
        "changed_source_files": changed,
        "categories": dict(Counter(Path(name).parent.name for name in file_moves.values())),
    }, ensure_ascii=False, indent=2) + "\n", "utf-8")
    print(f"Named modules: {len(file_moves)}, changed source files: {changed}")


if __name__ == "__main__":
    main()
