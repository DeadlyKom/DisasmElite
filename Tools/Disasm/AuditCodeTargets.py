"""Поиск прямых переходов в литеральные данные и внутрь другой инструкции.

Результат требует проверки перекрытий, таблиц и оверлеев. Не объявляет любой
найденный вход исполняемым и не изменяет исходники.
"""

import ast
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "Tools/Disasm"))
from InspectZ80 import decoder, memory_for


def source_statement(raw):
    """Отделение метки в нулевом столбце, двоеточие в sjasmplus необязательно."""
    text = raw.split(";", 1)[0].rstrip()
    if text and not text[0].isspace():
        text = re.sub(r"^[@\w.]+:?\s*", "", text, count=1)
    return text.strip()


def structure_layouts():
    """Поля сериализуемых структур читаются из тех же объявлений, что и сборка."""
    layouts = {}
    sizes = {}
    for name, filename, expected_size in (("FGoods", "Goods.inc", 17),
                                          ("FSystemSeed", "GameWorkspace.inc", 6),
                                          ("FCoordinate", "SpaceObject.inc", 3),
                                          ("FSpacePosition", "GraphicsWorkspace.inc", 9),
                                          ("FCommander", "Commander.inc", 102)):
        path = ROOT / "Includes/Structs" / filename
        fields = []
        inside = False
        found = False
        for number, raw in enumerate(path.read_text("utf-8-sig").splitlines(), 1):
            text = raw.split(";", 1)[0].strip()
            if re.fullmatch(rf"struct\s+{name}", text, re.I):
                if found:
                    raise ValueError(f"Повторное объявление {name}, {path}:{number}")
                inside = found = True
                continue
            if not inside or not text:
                continue
            if text.lower() == "ends":
                inside = False
                continue
            match = re.fullmatch(r"(\w+)\s+(\w+)(?:\s+(.*))?", text, re.I)
            if match is None:
                raise ValueError(f"Неподдержанное поле {name}, {path}:{number}")
            field, kind, defaults = match.groups()
            if kind.upper() in {"DB", "DW", "TEXT"}:
                kind = kind.upper()
            if kind == "TEXT":
                count = re.fullmatch(r"(\d+)\s*,\s*\{\s*(?:[#\$][0-9A-Fa-f]+|\d+)\s*\}", defaults or "")
                if count is None or int(count[1]) == 0:
                    raise ValueError(f"Неподдержанный размер {name}.{field}, {path}:{number}")
                count = int(count[1])
            elif kind in {"DB", "DW"}:
                if defaults is None or "," in defaults:
                    raise ValueError(f"Ожидается одно поле {name}.{field}, {path}:{number}")
                count = 2 if kind == "DW" else 1
            elif kind in layouts:
                if defaults:
                    raise ValueError(f"Неподдержанное вложенное поле {name}.{field}, {path}:{number}")
                count = sizes[kind]
            else:
                raise ValueError(f"Неподдержанный тип {kind} поля {name}.{field}, {path}:{number}")
            if any(previous[0] == field for previous in fields):
                raise ValueError(f"Повторное поле {name}.{field}, {path}:{number}")
            fields.append((field, kind, count))
        if not found or inside:
            raise ValueError(f"Не найдено полное объявление {name}, {path}")
        size = sum(count for _, _, count in fields)
        if size != expected_size:
            raise ValueError(f"Размер {name} равен {size}, ожидается {expected_size}, {path}")
        layouts[name], sizes[name] = fields, size
    return layouts


def initializer_values(text, context):
    """Дерево явных значений с проверкой скобок, запятых и пустых элементов."""
    tokens = re.findall(r"[{},]|[^{},]+", text)
    position = 0

    def block():
        nonlocal position
        if position == len(tokens) or tokens[position] != "{":
            raise ValueError(f"Ожидается открытие инициализатора, {context}")
        position += 1
        values = []
        while position < len(tokens):
            token = tokens[position]
            if token == "}":
                position += 1
                return values
            if token == ",":
                raise ValueError(f"Пропущено значение инициализатора, {context}")
            if token == "{":
                values.append(block())
            else:
                values.append(token)
                position += 1
            if position == len(tokens):
                break
            if tokens[position] == "}":
                position += 1
                return values
            if tokens[position] != ",":
                raise ValueError(f"Ожидается запятая между значениями, {context}")
            position += 1
        raise ValueError(f"Не закрыт инициализатор, {context}")

    tokens = [token.strip() for token in tokens if token.strip()]
    values = block()
    if position != len(tokens):
        raise ValueError(f"Лишний текст после инициализатора, {context}")
    return values


def initializer_bytes(name, values, layouts, context):
    """Развёртка полей без неявных значений и без потери порядка DB/DW."""
    fields = layouts[name]
    if len(values) != len(fields):
        raise ValueError(f"{name} требует {len(fields)} явных полей, получено {len(values)}, {context}")
    result = []
    for (field, kind, count), value in zip(fields, values):
        field_context = f"{name}.{field}, {context}"
        if kind in layouts:
            if not isinstance(value, list):
                raise ValueError(f"Ожидается вложенная структура, {field_context}")
            result.extend(initializer_bytes(kind, value, layouts, field_context))
            continue
        if kind == "TEXT":
            if not isinstance(value, list) or len(value) != count:
                raise ValueError(f"Ожидается массив из {count} явных байтов, {field_context}")
            items = value
        else:
            items = [value]
        for item in items:
            if not isinstance(item, str):
                raise ValueError(f"Ожидается числовое значение, {field_context}")
            # Разрешение имён и диапазон значения проверяет VerifySourceMap.
            expression = re.sub(r"^(?:HIGH|LOW)\s+", "", item, flags=re.I)
            expression = re.sub(r"[#\$]([0-9A-Fa-f]+)", r"0x\1", expression)
            expression = re.sub(r"(?<![\w])@?\.?[A-Za-z_][\w.]*", "0", expression)
            try:
                tree = ast.parse(expression, mode="eval")
            except SyntaxError:
                raise ValueError(f"Неподдержанное значение {item!r}, {field_context}") from None
            allowed = (ast.Expression, ast.Constant, ast.BinOp, ast.UnaryOp,
                       ast.Add, ast.Sub, ast.Mult, ast.LShift, ast.RShift,
                       ast.BitOr, ast.BitAnd, ast.BitXor, ast.UAdd, ast.USub)
            if any(not isinstance(node, allowed) or
                   (isinstance(node, ast.Constant) and type(node.value) is not int)
                   for node in ast.walk(tree)):
                raise ValueError(f"Неподдержанное значение {item!r}, {field_context}")
            result.append(("DW" if kind == "DW" else "DB", item))
    return result


def source_statements(path):
    """Чтение команд и строгая развёртка FGoods/FCommander в исходные DB/DW."""
    layouts = None
    lines = iter(enumerate(path.read_text("utf-8-sig").splitlines(), 1))
    for number, raw in lines:
        statement = source_statement(raw)
        opening = re.fullmatch(r"(FGoods|FCommander)\s*(\{.*)", statement, re.I)
        if opening is None:
            if re.match(r"(?:FGoods|FCommander)\b", statement, re.I):
                raise ValueError(f"Ожидается явный инициализатор {{ ... }}, {path}:{number}")
            yield number, raw, statement
            continue
        name = "FGoods" if opening[1].lower() == "fgoods" else "FCommander"
        parts = [opening[2]]
        depth = opening[2].count("{") - opening[2].count("}")
        while depth > 0:
            try:
                _, next_raw = next(lines)
            except StopIteration:
                raise ValueError(f"Не закрыт инициализатор {name}, {path}:{number}") from None
            part = next_raw.split(";", 1)[0].strip()
            parts.append(part)
            depth += part.count("{") - part.count("}")
        context = f"{path}:{number}"
        values = initializer_values(" ".join(parts), context)
        if layouts is None:
            layouts = structure_layouts()
        items = initializer_bytes(name, values, layouts, context)
        # Последовательные поля одной ширины объединяются, слова остаются DW.
        # Метка открытия выдаётся ровно один раз и сохраняет привязку local-имён.
        opcode, operands = items[0][0], []
        for kind, value in items:
            if kind != opcode:
                yield number, raw, opcode + " " + ", ".join(operands)
                raw, opcode, operands = "", kind, []
            operands.append(value)
        yield number, raw, opcode + " " + ", ".join(operands)


def source_map():
    coverage = json.loads((ROOT / "Tools/Disasm/Reports/SourceCoverage.json").read_text("utf-8"))
    memory = memory_for("decoded")
    dasm = decoder(memory)
    occupied = {}
    instructions = {}
    for fragment in coverage["fragments"]:
        address = fragment["start"]
        path = ROOT / fragment["file"]
        for number, raw, text in source_statements(path):
            if not text or " EQU " in f" {text.upper()} ":
                continue
            opcode = text.split()[0].upper()
            if opcode in {"MODULE", "ENDMODULE", "IFNDEF", "DEFINE", "ENDIF", "ASSERT"}:
                continue
            if text.startswith("."):
                parts = text.split(None, 1)
                if len(parts) == 1:
                    continue
                text = parts[1]
                opcode = text.split()[0].upper()
            kind = "code"
            if opcode in {"DB", "DW"}:
                length = len(text.split(None, 1)[1].split(",")) * (2 if opcode == "DW" else 1)
                kind = "literal"
            elif opcode == "INCBIN":
                name = re.search(r'"([^"]+)"', text)[1]
                length = (path.parent / name).stat().st_size
                kind = "resource"
            else:
                item = dasm.disassemble(address, address + 1, "h")[0]
                length = len(item.bytes)
                instructions[address] = {
                    "address": address, "operation": item.operation,
                    "file": fragment["file"], "line": number, "length": length,
                }
            for byte in range(address, address + length):
                occupied[byte] = {"kind": kind, "start": address, "file": fragment["file"],
                                  "line": number}
            address += length
        if address != fragment["end"]:
            raise ValueError(f"{path}: {address:04X} != {fragment['end']:04X}")
    return occupied, instructions


def main():
    occupied, instructions = source_map()
    findings = []
    indirect = []
    writes = []
    for address, item in instructions.items():
        operation = item["operation"]
        match = re.fullmatch(r"(CALL|JP|JR|DJNZ) (?:(\w+),)?\$([0-9A-F]{4})", operation)
        if match:
            target = int(match[3], 16)
            if target < 0x4000 or 0xC800 <= target < 0xD000:
                continue
            destination = occupied.get(target)
            if destination and (destination["kind"] != "code" or destination["start"] != target):
                findings.append({**item, "target": target, "destination": destination})
        if operation in ("JP (HL)", "JP (IX)", "JP (IY)"):
            indirect.append(item)
        match = re.match(r"LD \(\$([0-9A-F]{4})\),", operation)
        if match:
            target = int(match[1], 16)
            destination = occupied.get(target)
            if destination and destination["kind"] == "code":
                writes.append({**item, "target": target, "destination": destination})
    report = {
        "scope": "прямые переходы, косвенные JP и абсолютные LD в код, не полная трасса",
        "instruction_count": len(instructions), "review_required": findings,
        "indirect_jumps": indirect, "absolute_code_writes": writes,
    }
    (ROOT / "Tools/Disasm/Reports/CodeTargets.json").write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n", "utf-8")
    print(f"Instructions {len(instructions)}, target findings {len(findings)}, "
          f"indirect jumps {len(indirect)}, direct code writes {len(writes)}")
    for item in findings:
        print(f"{item['address']:04X} -> {item['target']:04X} "
              f"{item['destination']['kind']} {item['destination']['file']}")


if __name__ == "__main__":
    main()
