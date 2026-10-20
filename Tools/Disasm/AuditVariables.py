"""Проверка ручных имён переменных по символам сборки и указатель хранения.

Не выводит назначение памяти из числового адреса. Семантика поступает из карт
ручного разбора, проверяются только адреса, ссылки и отсутствие голых операндов.
"""
import ast
import json
import operator
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
REPORTS = ROOT / "Tools/Disasm/Reports"


def number(value):
    return int(value.lstrip("#$"), 16) if isinstance(value, str) else value


def evaluate(expression, symbols):
    operators = {ast.Add: operator.add, ast.Sub: operator.sub, ast.Mult: operator.mul,
                 ast.LShift: operator.lshift, ast.RShift: operator.rshift,
                 ast.BitOr: operator.or_, ast.BitAnd: operator.and_}
    expression = re.sub(r"#([0-9A-Fa-f]+)", r"0x\1", expression)
    expression = re.sub(r"(?<![\w])[A-Za-z_][\w.]*",
                        lambda m: str(symbols[m[0]]) if m[0] in symbols else m[0], expression)

    def read(node):
        if isinstance(node, ast.Constant) and type(node.value) is int:
            return node.value
        if isinstance(node, ast.BinOp) and type(node.op) in operators:
            return operators[type(node.op)](read(node.left), read(node.right))
        raise ValueError("Не разрешено выражение " + expression)
    return read(ast.parse(expression, mode="eval").body)


def main():
    symbols = {}
    for line in (ROOT / "Tmp/ELITE3HL.sym").read_text("utf-8-sig").splitlines():
        match = re.fullmatch(r"([\w.]+): EQU 0x([\dA-Fa-f]+)", line)
        if match:
            symbols[match[1]] = int(match[2], 16)
    rows, issues = [], []
    for file in sorted(REPORTS.glob("VariableNames*.json")):
        for item in json.loads(file.read_text("utf-8"))["bindings"]:
            item = dict(item)
            item["address"] = number(item["address"])
            try:
                actual = evaluate(item["symbol"], symbols)
            except (ValueError, SyntaxError) as exc:
                actual = None
            if actual != item["address"]:
                issues.append({"symbol": item["symbol"], "expected": item["address"], "actual": actual})
            if not (ROOT / item["file"]).exists():
                issues.append({"missing_file": item["file"]})
            rows.append(item)

    raw_memory, raw_indexed = [], []
    references = {}
    for path in (ROOT / "Source").rglob("*.asm"):
        file = path.relative_to(ROOT).as_posix()
        for n, raw in enumerate(path.read_text("utf-8-sig").splitlines(), 1):
            code = raw.split(";", 1)[0]
            for target in re.findall(r"\(#([\dA-Fa-f]{4})\)", code):
                raw_memory.append({"file": file, "line": n, "address": int(target, 16), "code": code.strip()})
            if re.search(r"\((IX|IY)\s*[+-]\s*(?:#[\dA-Fa-f]+|\d+)\s*\)", code):
                raw_indexed.append({"file": file, "line": n, "code": code.strip()})
            for operand in re.findall(r"\(([^()]+)\)", code):
                key = re.sub(r"\s+", "", operand).lstrip("@")
                references.setdefault(key, []).append({"file": file, "line": n, "code": code.strip()})
    for item in rows:
        key = re.sub(r"\s+", "", item["symbol"]).lstrip("@")
        item["direct_memory_references"] = references.get(key, [])
    report = {
        "scope": "ручные привязки проверены по символам текущей сборки, смысл задают инструкции и карты разбора",
        "bindings_checked": len(rows), "address_issues": issues,
        "raw_memory_operands": raw_memory, "raw_indexed_operands": raw_indexed,
        "bindings": rows,
        "limitations": "перечень прямых обращений не включает все обращения через HL/DE, наложения и косвенные вызовы описаны в исходниках",
    }
    (REPORTS / "VariableAudit.json").write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", "utf-8")
    lines = ["# Переменные, поля и изменяемые операнды", "",
             "Имена получены по коду этого TRD. Объявления `STRUCT` задают смещения и размеры,",
             "`Includes/Variables` связывает имена с физическими метками в исходниках.",
             "Размещение памяти не меняется. Операнды команд и экранные оверлеи отмечены отдельно.", "",
             "`DB #00` обозначает исходное значение, оно само по себе не означает мусор или свободную память.",
             "Например, `GalaxyState.NameCursor` указывает на следующее место записи имени,",
             "`FlightState.SoundRequests` содержит запросы звука, а `Keyboard.RowPOIUY` — полуряд клавиш.", "",
             "Схемы битов находятся рядом с полями в `Includes/Structs`, номера клавиш — в `Includes/Const`.",
             "Для `IX/IY` назначение поля определяется текущей базой регистра, а не только смещением.", "",
             f"Проверено привязок к символам сборки: {len(rows)}. Ошибок адресов: {len(issues)}.",
             "Подробные прямые обращения и доказательства находятся в [VariableAudit.json](../Tools/Disasm/Reports/VariableAudit.json).", ""]
    by_file = {}
    for item in rows:
        by_file.setdefault(item["file"], []).append(item)
    for file, items in sorted(by_file.items()):
        lines += [f"## [{Path(file).stem}](../{file})", "",
                  "| Имя или поле | Адрес | Представление | Назначение |", "|---|---|---|---|"]
        for item in sorted(items, key=lambda i: (i["address"], i["symbol"])):
            kind = item.get("kind", "")
            kind = {"instruction operand": "операнд команды", "instruction opcode": "код команды",
                    "operand": "операнд команды", "opcode": "код команды", "data": "данные",
                    "pointer": "указатель", "physical-data": "данные", "physical-patch": "патч команды",
                    "model": "заголовок модели", "code/data": "код и данные", "overlay": "наложение в памяти",
                    "biased pointer": "база индексирования", "ROM": "адрес ROM",
                    "code_operand": "операнд команды", "pointer-constant": "адресная константа",
                    "external-patch-operand": "операнд внешнего патча", "workspace-view": "представление буфера",
                    "rom_entry": "вход ROM", "workspace-field": "поле буфера", "table": "таблица",
                    "operand-or-offset": "операнд или смещение", "buffer offset": "смещение в буфере",
                    "overlay-source": "источник оверлея", "data field": "поле данных",
                    "pointer-expression": "адресное выражение", "physical-operand": "операнд команды",
                    "index_base": "база индексирования", "rom_data": "адрес данных ROM",
                    "ROM read address": "адрес чтения ROM"}.get(kind, kind)
            lines.append(f"| `{item['symbol']}` | `#{item['address']:04X}` | {kind} | {item['meaning'].replace('|', '/')} |")
        lines.append("")
    (ROOT / "Docs/Variables.md").write_text("\n".join(lines), "utf-8")
    print(f"Bindings {len(rows)}, address issues {len(issues)}, raw memory {len(raw_memory)}, raw indexed {len(raw_indexed)}")
    for item in issues[:30]:
        print(item)
    if issues or raw_memory or raw_indexed:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
