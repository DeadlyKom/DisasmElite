"""Описание 102 полей-байтов ROBOT тем же форматом, что дисковые командиры."""

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]


def main():
    data = (ROOT / "Tools/Disasm/Extracted/Active/03_cl.C").read_bytes()[0x800:0x900]
    structure = (ROOT / "Includes/Structs/Commander.inc").read_text("utf-8")
    fields = []
    for line in structure.splitlines():
        match = re.match(r"(\w+)\s+(DB|DW|DS)\s+([^;]+);\s*(.*)", line)
        if not match:
            continue
        name, operation, operand, comment = match.groups()
        size = 1 if operation == "DB" else 2 if operation == "DW" else int(operand.split(",")[0])
        fields.append((name, size, comment))
    assert sum(size for _, size, _ in fields) == 102
    lines = [
        "; -----------------------------------------",
        "; сектор состояния ROBOT между двумя исполняемыми оверлеями",
        "; #D99B читает сектор в #606F, затем копирует ровно 102 байта в #D054",
        "; первые 102 байта имеют формат FCommander, описанный для QS1 и DEADLY",
        "; остальные 154 байта не включаются в состояние командира",
        "; среди них сохранились похожие на машинный код байты прежнего снимка",
        "; штатная загрузка ROBOT не передаёт им управление и сохраняет их как дополнение",
        "; -----------------------------------------",
        "RobotState:     EQU $",
    ]
    offset = 0
    for name, size, comment in fields:
        lines.append(f"                ; поле {name}, {comment}")
        for start in range(offset, offset + size, 8):
            values = data[start:min(start + 8, offset + size)]
            lines.append("                DB " + ", ".join(f"#{x:02X}" for x in values))
        offset += size
    lines += ["                ; проверка границы сериализуемого состояния",
              "                ASSERT $ - RobotState == FCommander",
              "RobotTail:      EQU $",
              "                ; сохранение исходного секторного дополнения"]
    for start in range(102, 256, 8):
        lines.append("                DB " + ", ".join(f"#{x:02X}" for x in data[start:start + 8]))
    lines += ["                ; проверка размера полного сектора",
              "                ASSERT $ - RobotState == 256", ""]
    (ROOT / "Source/DiskUtility/Robot.asm").write_text("\n".join(lines), "utf-8")
    print("ROBOT: 37 fields, 102 commander bytes and 154 preserved sector bytes")


if __name__ == "__main__":
    main()
