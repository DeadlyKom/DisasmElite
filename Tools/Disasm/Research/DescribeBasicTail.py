"""Представление BASIC-оболочки руководства исходными токенизированными строками."""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
DESCRIPTIONS = {
    10: "установка цветов, очистка места под код и запуск просмотрщика через PROG+5",
    64: "комментарий автора о руководстве и распакованном тексте по адресу #A000",
    100: "вывод предложения вставить диск, переименовать загрузчик и сохранить руководство",
    110: "ожидание ENTER, остальные клавиши и отсутствие клавиши повторяют строку",
    120: "вызов TR-DOS и передача NEW с исходными аргументами ELITE3 и boot",
    130: "вызов TR-DOS и сохранение текущей BASIC-программы как boot1 с автозапуском 10",
    150: "перебор восьми цветов с надписью READY и звуковым сигналом",
    160: "восстановление белой бумаги, чёрных чернил и возврат к предложению копирования",
}


def main():
    source = (ROOT / "Source/Manual/Resources/BasicTail.bin").read_bytes()
    lines = [
        "; -----------------------------------------",
        "; токенизированные строки BASIC после машинного кода и ресурсов руководства",
        "; числа содержат исходные текстовые формы и пятибайтовые числовые значения",
        "; команды представлены данными BASIC, процессор Z80 их напрямую не исполняет",
        "; строка 100 обещает имя boot, но фактический SAVE строки 130 задаёт boot1",
        "; это исходное различие сохранено",
        "; -----------------------------------------",
        "BasicTail:      DB #0D".ljust(80) + "; завершение исходной строки REM 0",
    ]
    address = 1
    records = []
    while address < len(source):
        number = int.from_bytes(source[address:address + 2], "big")
        length = int.from_bytes(source[address + 2:address + 4], "little")
        body = source[address + 4:address + 4 + length]
        assert body[-1] == 13 and number in DESCRIPTIONS
        lines += ["", "                ; " + DESCRIPTIONS[number],
                  (f"Line{number}:").ljust(16) +
                  f"DB #{number >> 8:02X}, #{number & 255:02X}",
                  f"                DW End{number} - Body{number}"]
        for index in range(0, len(body), 8):
            label = f"Body{number}:" if index == 0 else ""
            code = label.ljust(16) + "DB " + ", ".join(f"#{byte:02X}" for byte in body[index:index + 8])
            lines.append(code)
        lines += [(f"End{number}:").ljust(16) + "EQU $",
                  "                ; проверка исходной длины строки вместе с ENTER",
                  f"                ASSERT End{number} - Body{number} == {length}"]
        records.append({"line": number, "tail_offset": address, "body_length": length,
                        "purpose": DESCRIPTIONS[number]})
        address += 4 + length
    assert address == len(source) == 751
    lines += ["", "                ; проверка полного хвоста BASIC-оболочки",
              "                ASSERT $ - BasicTail == 751", ""]
    (ROOT / "Source/Manual/BasicTail.asm").write_text("\n".join(lines), "utf-8")
    (ROOT / "Tools/Disasm/Reports/ManualBasic.json").write_text(
        json.dumps(records, ensure_ascii=False, indent=2) + "\n", "utf-8")
    print("Manual BASIC: 8 lines, 751 bytes with preceding ENTER")


if __name__ == "__main__":
    main()
