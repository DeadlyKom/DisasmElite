"""Завершение конкретных смысловых ссылок после ручного разбора.

Не часть сборки. Меняет только имена меток и подтверждённые адресные операнды.
Адреса инструкций берутся из карты оригинала, перестановки байтов здесь нет.
"""

import json
import re
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "Tools/Disasm"))
from AuditCodeTargets import source_map


# Имена проверенных вторичных входов, короткие имена остаются внутри модуля.
ENTRY_NAMES = {
    0x70E0: "StartGame", 0x72DD: "ToggleScanner", 0x7315: "ScannerKey",
    0x7328: "ToggleJoystick", 0x7366: "Bootstrap", 0x7426: "DrawDemoTitle",
    0x9337: "FadeTunnel", 0x9364: "EndDocking", 0x93C0: "FinishTunnel",
    0xD018: "OpenCargo", 0xD01B: "CursorLeft", 0xD01E: "CursorRight",
    0xD021: "CursorDown", 0xD024: "CursorUp", 0xD027: "CurrentSystem",
    0xD02A: "SelectSystem", 0xD02D: "FindSystem", 0xD030: "NextGalaxy",
    0xD0D7: "ShowBoarding", 0xD32D: "PrintCash", 0xD55C: "IgnoreToken",
    0xD5F5: "CheckWarSupply", 0xD822: "PrintCashLine", 0xD84B: "PrintGalaxy",
    0xD885: "RandomName", 0xD8E9: "Disable", 0xD8EF: "RowSix",
    0xD956: "CallDosInline", 0xD99B: "LoadDemo", 0xD9C7: "Write",
    0xDFEE: "ToggleBit1", 0xE34C: "UsesTonnes", 0xE45B: "SelectSystem",
    0xE4D4: "CursorUp", 0xE4E6: "CursorDown", 0xE4F9: "CursorLeft",
    0xE509: "CursorRight", 0xE51A: "CurrentSystem", 0xE6AE: "OfferRefugees",
    0xE6D6: "BoardRefugees", 0xE6FA: "PrepareBuy", 0xE75E: "ClearTradeAttr",
    0xE7DB: "BuyQuantity", 0xE820: "NoCargoSpace", 0xE8AE: "UnloadRefugees",
    0xE8EA: "SellCargo", 0xE935: "SellQuantity", 0xEB2D: "AcceptInput",
    0xEB7C: "GalaxyChart", 0xED27: "PlotStar", 0xEDDF: "ShowSystem",
    0xEEA8: "EconomyText", 0xEF48: "MarketPrices",
}


def split_line(raw):
    code, separator, comment = raw.partition(";")
    return code.rstrip(), comment if separator else None


def line_scopes(text):
    stack = ["Game"]
    result = []
    for raw in text.splitlines():
        code = raw.split(";", 1)[0].strip()
        match = re.fullmatch(r"module\s+(\w+)", code, re.I)
        if match:
            stack.append(match[1])
        elif code.lower() == "endmodule":
            stack.pop()
        result.append(".".join(stack))
    return result


def join_line(code, comment):
    if comment is None:
        return code
    if not code.strip():
        return code + ";" + comment
    width = 16 if re.fullmatch(r"[\w.]+:", code.strip()) else 80
    if len(code) > width:
        raise ValueError("Имя не помещается перед комментарием: " + code)
    return code.ljust(width) + ";" + comment


def main():
    occupied, instructions = source_map()
    changes = []
    by_file = {}
    for address, name in ENTRY_NAMES.items():
        item = instructions[address]
        assert len(name) <= 14
        by_file.setdefault(item["file"], {})[item["line"]] = (address, name)

    # Именование существующих входов без добавления команд или изменения адресов.
    for relative, entries in by_file.items():
        path = ROOT / relative
        lines = path.read_text("utf-8-sig").splitlines()
        old_names = {}
        for number, (address, name) in entries.items():
            code, comment = split_line(lines[number - 1])
            old = re.match(r"^(\w+):\s*", code)
            if old:
                old_names[old[1]] = name
                code = old.re.sub("", code)
            else:
                code = code.strip()
            lines[number - 1] = join_line((name + ":").ljust(16) + code.strip(), comment)
            if old is None or old[1] != name:
                changes.append({"kind": "entry", "file": relative, "address": address,
                                "name": name})
        scope = line_scopes("\n".join(lines))[min(entries) - 1]
        for number, raw in enumerate(lines):
            code, comment = split_line(raw)
            before = code
            for old, new in old_names.items():
                code = re.sub(r"\b" + re.escape(old) + r"\b", new, code)
            lines[number] = join_line(code, comment) if code != before else raw
        path.write_text("\n".join(lines) + "\n", "utf-8")
        # Обновление уже существовавших полных ссылок на переименованный вход.
        for other in (ROOT / "Source/Game").rglob("*.asm"):
            text = other.read_text("utf-8-sig")
            updated_lines = []
            for raw in text.splitlines():
                code, comment = split_line(raw)
                before = code
                for old, new in old_names.items():
                    code = code.replace(scope + "." + old, scope + "." + new)
                updated_lines.append(join_line(code, comment) if code != before else raw)
            updated = "\n".join(updated_lines) + "\n"
            if updated != text:
                other.write_text(updated, "utf-8")

    # Построение карты реальных меток команд, таблицы данных не становятся входами.
    occupied, instructions = source_map()
    line_address = {(item["file"], item["line"]): address
                    for address, item in instructions.items()}
    targets = {}
    for path in (ROOT / "Source/Game").rglob("*.asm"):
        if path.parent.name == "Math":
            continue
        scopes = line_scopes(path.read_text("utf-8-sig"))
        relative = path.relative_to(ROOT).as_posix()
        pending = []
        for number, raw in enumerate(path.read_text("utf-8-sig").splitlines(), 1):
            code = raw.split(";", 1)[0]
            match = re.match(r"^(\w+):", code)
            if match and " EQU " not in code.upper():
                pending.append(scopes[number - 1] + "." + match[1])
            address = line_address.get((relative, number))
            if address is not None:
                if pending:
                    assert address not in targets
                    targets[address] = pending[0]
                pending = []
            elif re.match(r"\s*(?:\w+:\s*)?(?:DB|DW|INCBIN|ENDMODULE)\b", code, re.I):
                pending = []

    aliases = {item["address"]: item["symbol"] for item in json.loads(
        (ROOT / "Tools/Disasm/Reports/RuntimeStateNames.json").read_text("utf-8"))["aliases"]}
    # Имена двенадцати рабочих байтов после основного цикла, не исполняемый код.
    aliases[0x7578] = "Game.Flight.MainGameLoop.SavedSP"
    for base, axis in ((0x757A, "BodyX"), (0x757D, "BodyY"), (0x7580, "BodyZ")):
        for offset, field in enumerate(("", "+FCoordinate.Low", "+FCoordinate.SignHigh")):
            aliases[base + offset] = "Game.Flight.MainGameLoop." + axis + field
    aliases[0x7577] = "Game.Flight.MainGameLoop.BodyX-FCoordinate"
    aliases[0x7583] = "Game.Flight.MainGameLoop.NovaRadius"
    branch = re.compile(r"\b(CALL|JP|JR|DJNZ)\s+((?:NZ|Z|NC|C|PO|PE|P|M),)?#([0-9A-F]{4})\b")
    address_ld = re.compile(r"\bLD\s+(?:\(#[0-9A-F]{4}\),[A-Z]+|[A-Z]+,\(#[0-9A-F]{4}\)|(?:HL|DE|IX|IY),#[0-9A-F]{4})$")
    for path in (ROOT / "Source/Game").rglob("*.asm"):
        relative = path.relative_to(ROOT).as_posix()
        text = path.read_text("utf-8-sig")
        scopes = line_scopes(text)
        lines = []
        for number, raw in enumerate(text.splitlines(), 1):
            scope = scopes[number - 1]
            code, comment = split_line(raw)
            before = code
            match = branch.search(code)
            if match and int(match[3], 16) in targets:
                target = int(match[3], 16)
                symbol = targets[target]
                if symbol.startswith(scope + "."):
                    symbol = symbol[len(scope) + 1:]
                code = code[:match.start(3) - 1] + symbol + code[match.end(3):]
                changes.append({"kind": "branch", "file": relative, "line": number,
                                "address": target, "symbol": symbol})
            elif address_ld.search(code):
                match = re.search(r"#([0-9A-F]{4})", code)
                target = int(match[1], 16)
                if target in aliases:
                    code = code[:match.start()] + aliases[target] + code[match.end():]
                    changes.append({"kind": "state", "file": relative, "line": number,
                                    "address": target, "symbol": aliases[target]})
            lines.append(join_line(code, comment) if code != before else raw)
        updated = "\n".join(lines) + "\n"
        if updated != text:
            path.write_text(updated, "utf-8")

    report_path = ROOT / "Tools/Disasm/Reports/SemanticLinks.json"
    if report_path.exists():
        changes = json.loads(report_path.read_text("utf-8"))["changes"] + changes
    report = {"scope": "имена доказанных входов и адресных операндов, без изменения байтов",
              "counts": dict(Counter(item["kind"] for item in changes)),
              "changes": changes}
    report_path.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n", "utf-8")
    print(report["counts"])


if __name__ == "__main__":
    main()
