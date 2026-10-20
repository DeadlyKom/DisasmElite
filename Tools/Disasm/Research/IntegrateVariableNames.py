"""Связь ручных карт переменных с общими ссылками, без изменений бинарной структуры."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]


def address(value):
    return int(value.lstrip("#$"), 16) if isinstance(value, str) else value


def bindings():
    result = []
    for file in sorted((ROOT / "Tools/Disasm/Reports").glob("VariableNames*.json")):
        result.extend(json.loads(file.read_text("utf-8"))["bindings"])
    return result


def align(code, comment):
    if len(code) > 79:
        return "                ; " + comment.strip() + "\n" + code
    return code.ljust(80) + "; " + comment.strip()


def main():
    names = {}
    for item in bindings():
        # Меню C800 и игровая сохранённая область C800 имеют разные фазы использования.
        if item["file"].startswith("Source/Game/"):
            names[address(item["address"])] = item["symbol"]
    report = json.loads((ROOT / "Tools/Disasm/Reports/VariableNamesGame.json").read_text("utf-8"))
    names.update({address(a): name for a, name in report.get("address_replacements", {}).items()})
    names[0xD061] = "State.Rating + 1"
    changed = []
    folders = [p.name for p in (ROOT / "Source/Game").iterdir() if p.is_dir()]
    for folder in folders:
        for path in (ROOT / "Source/Game" / folder).glob("*.asm"):
            rows = []
            replacements = 0
            for raw in path.read_text("utf-8-sig").splitlines():
                code, separator, comment = raw.partition(";")
                before = code
                # Только память по доказанному адресу. Не меняет порты и числовые константы.
                code = re.sub(r"\(#([\dA-F]{4})\)",
                              lambda m: "(" + names.get(int(m[1], 16), "#" + m[1]) + ")", code)
                # Именованные указатели HL/DE/IX/IY, подтверждённые картами читателей/писателей.
                if re.search(r"\bLD (?:HL|DE|IX|IY),\s*#[\dA-F]{4}\s*$", code):
                    code = re.sub(r"(?<=,)\s*#([\dA-F]{4})",
                                  lambda m: " " + names.get(int(m[1], 16), "#" + m[1]), code)
                if code != before:
                    # Оформление изменяемых операндов по образцу HoMM.
                    code = re.sub(r",\s*", ", ", code.rstrip())
                    code = re.sub(r"\((IX|IY)\+", r"(\1 + ", code)
                    replacements += 1
                    raw = align(code, comment) if separator else code
                rows.append(raw)
            if replacements:
                path.write_text("\n".join(rows) + "\n", "utf-8")
                changed.append({"file": path.relative_to(ROOT).as_posix(), "references": replacements})

    # Прежние общие имена сохраняются, но ведут к физической метке, а не голому адресу.
    storage = {address(b["address"]): b.get("storage", b["symbol"]) for b in bindings()
               if b["file"].startswith("Source/Game/")}
    path = ROOT / "Includes/Variables/GameState.inc"
    rows = []
    for raw in path.read_text("utf-8-sig").splitlines():
        code, sep, comment = raw.partition(";")
        match = re.search(r"EQU #([\dA-F]{4})\s*$", code)
        if match and int(match[1], 16) in storage:
            code = code[:match.start()] + "EQU " + storage[int(match[1], 16)]
            raw = align(code.rstrip(), comment) if sep else code.rstrip()
        rows.append(raw)
    path.write_text("\n".join(rows) + "\n", "utf-8")
    print("Updated", len(changed), "source files, references", sum(x["references"] for x in changed))


if __name__ == "__main__":
    main()
