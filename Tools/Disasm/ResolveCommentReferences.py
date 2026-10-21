"""Инвентаризация адресных ссылок в комментариях, исходники не изменяются.

Назначение адреса не выводится из его величины. Кандидатами становятся только
имена текущей таблицы символов, связанные с исходным кодом или ручным реестром
переменных. Указатель исходных диапазонов и словарь опкодных байтов остаются
числовыми. Даже однозначное совпадение адреса требует смысловой проверки.
"""

import argparse
import json
import re
from collections import Counter, defaultdict
from pathlib import Path

from AuditCodeTargets import source_map, structure_layouts
from AuditVariables import evaluate

ROOT = Path(__file__).resolve().parents[2]
REPORTS = ROOT / "Tools/Disasm/Reports"
ADDRESS = re.compile(r"(?<![A-Za-z0-9_#])#?([0-9A-F]{4})(?![\w])")
RANGE = re.compile(r"#?[0-9A-F]{4}\s*(?:\.\.|[-–])\s*#?[0-9A-F]{4}")
REFERENCE = re.compile(
    r"адрес|пол[еяю]|состояни|буфер|таблиц|указател|вектор|ячейк|переменн|"
    r"вызов|вход|процедур|обработчик|переход|проверя|проверит|копиру|"
    r"запис|чита|сбрасыва|увеличива|уменьша|возвраща|выводит|рисует|очища", re.I)
NUMBER = re.compile(
    r"(?:порог|маск[аыу]|цен[аыу]|констант[аыу]|токен[а]?|значени[ея]|"
    r"рав[ен]{2}|сумм[аыу]|счёт[а]?|байт[а]?)[^#\d\n]{0,12}$|(?:[=<>]|:=)\s*$", re.I)
SOURCE_RANGE = re.compile(r"исходн\w* (?:диапазон|байт|границ)|продолжение данных|данные\s+#", re.I)


def comment_parts(line):
    """Отделение комментария без захвата точки с запятой внутри строк."""
    quote = None
    for index, char in enumerate(line):
        if quote:
            if char == quote:
                quote = None
        elif char == '"' or (char == "'" and (index == 0 or not line[index - 1].isalnum())):
            quote = char
        elif char == ";":
            return line[:index], line[index + 1:], index + 1
    return line, "", len(line)


def read_symbols():
    symbols = {}
    for line in (ROOT / "Tmp/ELITE3HL.sym").read_text("utf-8-sig").splitlines():
        match = re.fullmatch(r"([\w.]+): EQU 0x([0-9A-Fa-f]+)", line)
        if match:
            symbols[match[1]] = int(match[2], 16)
    if not symbols:
        raise ValueError("Нет символов последней сборки")
    return symbols


def read_bindings(symbols):
    bindings = defaultdict(list)
    for path in sorted(REPORTS.glob("VariableNames*.json")):
        for item in json.loads(path.read_text("utf-8"))["bindings"]:
            address = item["address"]
            if isinstance(address, str):
                address = int(address.lstrip("#$"), 16)
            name = item["symbol"]
            try:
                actual = evaluate(name, symbols)
            except (ValueError, SyntaxError, KeyError):
                actual = None
            if actual == address:
                bindings[address].append({"symbol": name, "kind": "variable",
                                          "file": item["file"], "meaning": item.get("meaning", ""),
                                          "evidence": path.relative_to(ROOT).as_posix()})
    return bindings


def definitions(paths, symbols):
    result = defaultdict(list)
    layouts = structure_layouts()

    def nested(kind, prefix, relative, number):
        for field, subtype, _ in layouts[kind]:
            name = prefix + "." + field
            if name in symbols:
                result[symbols[name]].append({"symbol": name, "kind": "structure_field",
                                              "file": relative, "line": number})
            if subtype in layouts:
                nested(subtype, name, relative, number)

    for path in paths:
        relative = path.relative_to(ROOT).as_posix()
        scopes = ["Game"] if relative.startswith("Source/Game/") else []
        anchor = ""
        for number, raw in enumerate(path.read_text("utf-8-sig").splitlines(), 1):
            code = comment_parts(raw)[0]
            module = re.fullmatch(r"\s*module\s+(\w+)\s*", code, re.I)
            if module:
                scopes.append(module[1])
                continue
            if re.fullmatch(r"\s*endmodule\s*", code, re.I):
                if scopes:
                    scopes.pop()
                continue
            label = re.match(r"^([@\w.]+):?(?:\s|$)", code)
            if not label:
                continue
            name = label[1]
            if name.startswith("."):
                name = anchor + name
            else:
                anchor = name
            full = name[1:] if name.startswith("@") else ".".join(scopes + [name])
            if full in symbols:
                result[symbols[full]].append({"symbol": full, "kind": "definition",
                                              "file": relative, "line": number})
                instance = re.search(r"\b(FCommander|FGoods)\s*\{", code)
                if instance:
                    nested(instance[1], full, relative, number)
    return result


def classify(code, comment, match):
    start, end = match.span()
    before = comment[max(0, start - 30):start]
    if SOURCE_RANGE.search(comment):
        return "source_location"
    if any(begin <= start < finish for begin, finish in (item.span() for item in RANGE.finditer(comment))):
        return "address_range_review"
    if re.fullmatch(r"\s*#?[0-9A-F]{4}\s+(?:[0-9A-F]{2}\s*)+", comment):
        return "opcode_trace"
    if NUMBER.search(before):
        return "numeric_value_review"
    if re.search(r"\b(?:CP|AND|OR|XOR|SUB|ADD|ADC|SBC)\s+.*?" + re.escape(match[0]) + r"\b", code):
        return "instruction_constant"
    if REFERENCE.search(comment):
        return "address_reference"
    return "ambiguous_number"


def inventory():
    paths = sorted((ROOT / "Source/Game").rglob("*.asm")) + sorted((ROOT / "Includes").rglob("*.inc"))
    symbols = read_symbols()
    bindings = read_bindings(symbols)
    declared = definitions(paths, symbols)
    occupied, _ = source_map()
    fragments = json.loads((REPORTS / "SourceCoverage.json").read_text("utf-8"))["fragments"]
    fragment_by_file = {item["file"]: item for item in fragments}
    occurrences = []
    for path in paths:
        relative = path.relative_to(ROOT).as_posix()
        for number, raw in enumerate(path.read_text("utf-8-sig").splitlines(), 1):
            code, comment, offset = comment_parts(raw)
            for match in ADDRESS.finditer(comment):
                address = int(match[1], 16)
                category = classify(code, comment, match)
                candidates = {}
                for candidate in bindings.get(address, []) + declared.get(address, []):
                    name = candidate["symbol"]
                    origin = candidate["file"]
                    if candidate["kind"] == "definition" and origin.startswith(("Includes/Const/", "Includes/Structs/")):
                        continue
                    fragment = fragment_by_file.get(origin)
                    if fragment and not fragment["start"] <= address < fragment["end"]:
                        continue
                    candidates.setdefault(name, candidate)
                location = occupied.get(address)
                ordered = sorted(candidates.values(), key=lambda item: (item["kind"] != "variable", len(item["symbol"]), item["symbol"]))
                same_operand = [item for item in ordered if re.search(r"(?<![\w.])" + re.escape(item["symbol"]) + r"(?![\w.])", code)]
                proposal = None
                evidence = None
                if category == "address_reference":
                    variables = [item for item in ordered if item["kind"] == "variable"]
                    aliases = [item for item in ordered if item["file"].startswith("Includes/Variables/")]
                    choices = same_operand or aliases or variables or ordered
                    if len(choices) == 1 and not choices[0]["symbol"].startswith(("Manual.", "Loader.", "CommanderQS1.", "CommanderDeadly.")):
                        proposal = choices[0]["symbol"]
                        evidence = ("same_instruction_symbol" if same_operand else
                                    "single_variable_alias" if aliases else
                                    "single_verified_variable_binding" if variables else "single_exact_address_symbol")
                occurrences.append({"file": relative, "line": number,
                                    "column": offset + match.start() + 1,
                                    "token": match[0], "address": address,
                                    "classification": category, "comment": comment.strip(),
                                    "instruction": code.strip(), "source_location": location,
                                    "candidates": ordered, "proposal": proposal,
                                    "proposal_evidence": evidence,
                                    "requires_semantic_review": True})
    counts = Counter(item["classification"] for item in occurrences)
    return {"scope": "инвентаризация комментариев Source/Game и Includes, без изменения исходников",
            "warning": "Совпадение адреса подтверждает расположение, но не смысл фразы. Предложения не применяются автоматически.",
            "symbol_source": "Tmp/ELITE3HL.sym", "files_scanned": len(paths),
            "occurrences": len(occurrences), "classification_counts": dict(sorted(counts.items())),
            "proposals": sum(item["proposal"] is not None for item in occurrences),
            "files_with_address_references": len({item["file"] for item in occurrences if item["classification"] == "address_reference"}),
            "items": occurrences}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", help="Записать JSON-отчёт, исходники не изменяются")
    args = parser.parse_args()
    report = inventory()
    if args.output:
        destination = Path(args.output).resolve()
        reports = REPORTS.resolve()
        if not destination.is_relative_to(reports) or destination.suffix.lower() != ".json":
            raise ValueError("Отчёт разрешён только как JSON внутри Tools/Disasm/Reports")
        destination.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({key: value for key, value in report.items() if key != "items"}, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
