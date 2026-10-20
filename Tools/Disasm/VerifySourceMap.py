"""Статическая сверка текста инструкций и DB с исходным разбором.

Не ассемблирует исходники, не вызывает сборку и не создаёт двоичный результат.
"""

import ast
import json
import operator
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "Tools/Disasm"))
from InspectZ80 import decoder, memory_for
from AuditCodeTargets import source_statements


SYMBOLS = {}


def integer_expression(text):
    """Вычисление числовых адресных выражений после подстановки символов."""
    operators = {ast.Add: operator.add, ast.Sub: operator.sub, ast.Mult: operator.mul,
                 ast.LShift: operator.lshift, ast.RShift: operator.rshift,
                 ast.BitOr: operator.or_, ast.BitAnd: operator.and_, ast.BitXor: operator.xor}
    def value(node):
        if isinstance(node, ast.Constant) and type(node.value) is int:
            return node.value
        if isinstance(node, ast.BinOp) and type(node.op) in operators:
            left, right = value(node.left), value(node.right)
            return operators[type(node.op)](left, right)
        if isinstance(node, ast.UnaryOp) and isinstance(node.op, (ast.UAdd, ast.USub)):
            operand = value(node.operand)
            return operand if isinstance(node.op, ast.UAdd) else -operand
        raise ValueError("Неподдержанное выражение смещения " + text)

    source = re.sub(r"#([0-9A-Fa-f]+)", r"0x\1", text)
    return str(value(ast.parse(source, mode="eval").body))


def normalize(text, math_names, scope="", anchor=""):
    # Префикс @ выбирает глобальную область sjasmplus, значения символа не меняет.
    text = re.sub(r"@(?=[A-Za-z_])", "", text)
    # Разрешение только явно именованных адресов, без кодирования команд.
    for name, address in sorted(math_names.items(), key=lambda item: -len(item[0])):
        text = text.replace("Game.Math." + name, f"#{address:04X}")
    text = re.sub(r"Game\.\w+\.\w+_([0-9A-F]{4})\.Entry",
                  lambda match: "#" + match[1], text)
    # Поиск полного либо локального имени в символах текущей сборки.
    def resolve(match):
        name = match[0]
        candidates = ([scope + "." + anchor + name] if name.startswith(".") else
                      [name, scope + "." + name])
        for candidate in candidates:
            if candidate in SYMBOLS:
                return f"#{SYMBOLS[candidate]:04X}"
        return name

    text = re.sub(r"(?<![\w#])[.]?[A-Za-z_][A-Za-z0-9_.]*\b", resolve, text)
    # Расчёт полного знакового смещения IX/IY, включая вычитание первого слагаемого.
    def indexed(match):
        offset = int(integer_expression("0" + match[2]))
        return "(" + match[1] + ("+" if offset >= 0 else "-") + str(abs(offset)) + ")"

    text = re.sub(r"\((IX|IY)\s*((?:\s*(?:<<|>>|[+*\-&|^])\s*(?:#[0-9A-Fa-f]+|\d+))+\s*)\)",
                  indexed, text.replace("$", "#"))
    # Расчёт смещения поля структуры и приведение разных записей одного числа.
    text = re.sub(r"(?<![\w])(?:#[0-9A-Fa-f]+|\d+)"
                  r"(?:\s*(?:<<|>>|[+*\-&|^])\s*(?:#[0-9A-Fa-f]+|\d+))*",
                  lambda match: integer_expression(match[0]), text.replace("$", "#"))
    text = re.sub(r"\b(HIGH|LOW)\s+(\d+)\b",
                  lambda m: str((int(m[2]) >> 8) if m[1].upper() == "HIGH" else (int(m[2]) & 255)),
                  text, flags=re.I)
    text = re.sub(r"\s+", "", text).replace("$", "#").upper()
    # Знаковый шаг в 16-битном непосредственном операнде имеет то же кодирование.
    text = re.sub(r"^(LD(?:HL|DE|BC|SP|IX|IY),)(-\d+)$",
                  lambda m: m[1] + str(int(m[2]) & 0xFFFF), text)
    return text


def main():
    # Чтение символов последней сборки разрешает окончательные смысловые имена.
    symbol_path = ROOT / "Tmp/ELITE3HL.sym"
    if symbol_path.exists():
        for line in symbol_path.read_text("utf-8-sig").splitlines():
            match = re.fullmatch(r"([\w.]+): EQU 0x([0-9A-Fa-f]+)", line)
            if match:
                SYMBOLS[match[1]] = int(match[2], 16)
    coverage = json.loads((ROOT / "Tools/Disasm/Reports/SourceCoverage.json").read_text("utf-8"))
    maths = json.loads((ROOT / "Tools/Disasm/Reports/MathRanges.json").read_text("utf-8"))
    math_names = {name: address for item in maths
                  for name, address in item["entries"].items()}
    memory = memory_for("decoded")
    disassembler = decoder(memory)
    expected_start = 0x4000
    checked_instructions = 0
    checked_literals = 0
    manual_bytes = 0
    for fragment in coverage["fragments"]:
        # Проверка непрерывности файлового покрытия всех 48 КБ.
        if fragment["start"] != expected_start:
            raise ValueError(f"Разрыв покрытия у {fragment['file']}")
        expected_start = fragment["end"]
        if fragment["status"] == "manual":
            manual_bytes += fragment["end"] - fragment["start"]
            continue
        address = fragment["start"]
        path = ROOT / fragment["file"]
        scopes = ["Game"]
        anchor = ""
        for number, raw, instruction in source_statements(path):
            label = re.match(r"^([A-Za-z_][\w.]*):?(?:\s|$)", raw)
            if label:
                anchor = label[1]
            if not instruction:
                continue
            if instruction.upper().startswith("MODULE "):
                scopes.append(instruction.split()[1])
                continue
            if instruction.upper() == "ENDMODULE":
                scopes.pop()
                continue
            if instruction.upper().startswith(("ASSERT ", "EQU ")):
                continue
            if re.match(r"^\w+\s+EQU\s", instruction, re.I):
                continue
            if instruction.upper().startswith("INCBIN "):
                resource = re.fullmatch(r'INCBIN\s+"([^"]+)"', instruction, re.I)
                if resource is None:
                    raise ValueError(f"Не поддержан формат INCBIN, {path}:{number}")
                data = (path.parent / resource[1]).read_bytes()
                if data != memory[address:address + len(data)]:
                    raise ValueError(f"Не совпадает ресурс, {path}:{number}")
                checked_literals += len(data)
                address += len(data)
            elif instruction.upper().startswith(("DB ", "DW ")):
                width = 2 if instruction.upper().startswith("DW ") else 1
                data = b"".join(int(normalize(token.strip(), math_names,
                                            ".".join(scopes), anchor)).to_bytes(width, "little")
                                for token in instruction[3:].split(","))
                if data != memory[address:address + len(data)]:
                    raise ValueError(f"Не совпадают DB, {path}:{number}")
                checked_literals += len(data)
                address += len(data)
            else:
                original = disassembler.disassemble(address, address + 1, "h")[0]
                if normalize(instruction, math_names, ".".join(scopes), anchor) != normalize(
                        original.operation, math_names):
                    raise ValueError(f"Не совпадает инструкция {path}:{number}, "
                                     f"{instruction} != {original.operation}")
                checked_instructions += 1
                address += len(original.bytes)
        if address != fragment["end"]:
            raise ValueError(f"Не совпала граница {path}, {address:04X}")
    if expected_start != 0x10000:
        raise ValueError("Не достигнут конец исходного файла")
    print(f"Проверено инструкций {checked_instructions}, литеральных байтов "
          f"{checked_literals}, отдельно разобранных байтов Math {manual_bytes}")
    print("Файловое покрытие 49152 байта без разрывов и пересечений")
    print("Это статическая сверка, готовый TRD отдельно проверяется Tools/Disasm/VerifyBuild.ps1")


if __name__ == "__main__":
    main()
