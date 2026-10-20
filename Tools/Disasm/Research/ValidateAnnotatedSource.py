"""Независимая сверка записанных инструкций и DB с исследуемым образом, без сборки."""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "Tools/Disasm"))
from InspectZ80 import decoder, memory_for


def check(folders):
    mem = memory_for("decoded")
    dis = decoder(mem)
    symbols = {}
    files = list((ROOT / "Source/Game").rglob("*.asm"))
    for path in files:
        source = path.read_text(encoding="utf-8-sig")
        start = re.search(r"ASSERT \$ == #([0-9A-F]+)", source)
        modules = re.findall(r"^\s*module\s+(\S+)", source, re.M)
        if start and modules:
            prefix = "GAME." + ".".join(modules).upper() + "."
            symbols[prefix + "ENTRY"] = int(start[1], 16)
            first_label = re.search(r"^(\w+):\s+\S+", source[start.end():], re.M)
            if first_label:
                symbols[prefix + first_label[1].upper()] = int(start[1], 16)

    def normalize(text):
        text = text.upper().replace("$", "#")
        for symbol in re.findall(r"GAME\.[\w.]+", text):
            if symbol in symbols:
                text = text.replace(symbol, f"#{symbols[symbol]:04X}")
        return re.sub(r"\s+", "", text)

    errors = []
    instructions = data_bytes = file_count = 0
    for path in files:
        if path.parent.name not in folders:
            continue
        file_count += 1
        pc = None
        for number, line in enumerate(path.read_text(encoding="utf8").splitlines(), 1):
            code = line.split(";", 1)[0].strip()
            at = f"{path.relative_to(ROOT)}:{number}"
            if ";" in line:
                if line.count(";") != 1:
                    errors.append([at, "несколько точек начала комментария"])
                if code and not code.endswith(":") and line.index(";") != 80:
                    errors.append([at, "правый комментарий вне столбца81"])
            match = re.search(r"ASSERT \$ == #([0-9A-F]+)", code)
            if match:
                boundary = int(match[1], 16)
                if pc is not None and pc != boundary:
                    errors.append([at, f"граница #{pc:04X}, ожидалось #{boundary:04X}"])
                pc = boundary
                continue
            if pc is None or not code or code.lower().startswith(("module ", "endmodule")):
                continue
            if ":" in code:
                _, code = code.split(":", 1)
                code = code.strip()
                if not code:
                    errors.append([at, "метка без пояснения или команды"])
                    continue
            if code.startswith("DB "):
                raw = bytes(int(x.strip().replace("#", ""), 16) for x in code[3:].split(","))
                if raw != bytes(mem[pc:pc + len(raw)]):
                    errors.append([at, f"данные не совпадают по #{pc:04X}"])
                data_bytes += len(raw)
                pc += len(raw)
            else:
                expected = dis.disassemble(pc, pc + 1, "h")[0]
                if normalize(code) != normalize(expected.operation):
                    errors.append([at, f"#{pc:04X}", code, expected.operation])
                instructions += 1
                pc += len(expected.bytes)
    report = dict(
        files=file_count, instructions=instructions, data_bytes=data_bytes, errors=errors,
        scope="Статическая сверка мнемоник, адресов, буквальных данных и комментариев с Tools/Disasm/Research/GameCode.bin, без запуска ассемблера"
    )
    name = "Circles" if folders == ["Circles"] else "".join(folders)
    (ROOT / f"Tools/Disasm/Reports/Semantics/{name}Validation.json").write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf8")
    print(json.dumps(report, ensure_ascii=False))
    if errors:
        raise SystemExit(1)


if __name__ == "__main__":
    check(sys.argv[1:] or ["Circles"])
