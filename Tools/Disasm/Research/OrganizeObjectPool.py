"""Оформление кода #6000 и исходного пула объектов без изменения байтов."""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
memory = bytes(0x4000) + (ROOT / "Tools/Disasm/Research/GameCode.bin").read_bytes()


def line(code, comment=None, label=None):
    text = (label + ":").ljust(16) + code if label else " " * 16 + code
    return text.ljust(80) + "; " + comment if comment else text


def main():
    lines = [
        line("module Data"), line("module SystemBoundary"),
        "; -----------------------------------------",
        "; продолжение выхода за дальнюю границу координаты Z, начало по #5FD5",
        "; In:",
        ";   HL, адрес X или Y текущей системы, выбранный предшествующей ветвью",
        ";   AF, перенос от удвоения старшей компоненты направления",
        "; Out:",
        ";   обновлены координаты системы, положение солнца, планеты и станции",
        "; Corrupt:",
        ";   HL, DE, BC, AF, IX",
        "; Note:",
        ";   обычный объект завершается отдельной ветвью #6043 с Z_high = #DF",
        ";   планета при переполнении инициирует смену координат текущей системы",
        ";   INC/DEC не меняют входной перенос от ADD A,A по #5FFF",
        "; -----------------------------------------",
        "                ; проверка исходной границы продолжения",
        line("ASSERT $ == #6000"),
        "                ; изменение выбранной координаты системы на +1 или -1",
        line("INC (HL)", label="Continue"),
        line("JR C,#6005", "переход, если исходное направление требует приращения"),
        line("DEC (HL)"), line("DEC (HL)"),
        "                ; поиск планеты в новой точке карты",
        line("LD HL,(#D099)"), line("LD A,(#D097)"), line("LD H,A"),
        line("LD (#D0BB),HL"), line("CALL Game.Galaxy.SearchPlanetNearCursor_DF74.Entry"),
        line("LD HL,(#DF5E)"), line("LD A,H"), line("OR L"), line("LD (#7103),A"),
        line("JR NZ,#6028", "переход, если точка не совпадает с планетой, остаётся свободное пространство"),
        "                ; временная замена окончания гиперперехода на RET",
        line("LD HL,#DDFB"), line("LD (HL),#C9"), line("PUSH HL"),
        line("CALL Game.Travel.DoHyperjump_DCE9.Entry"), line("POP HL"),
        line("LD (HL),#28", "восстановление исходного кода JR Z"),
        "                ; завершение миссионной обработки и размещение небесных тел",
        line("CALL Game.Universe.Entry_7F64_7F64.Entry"),
        line("LD A,#48"), line("LD DE,#0003"), line("LD HL,#7109"),
        line("CALL Game.Screen.Entry_8217_8217.Entry"),
        "                ; расчёт положения планеты, после первого вызова L равен #12",
        line("SUB L"), line("CALL Game.Screen.Entry_8217_8217.Entry"),
        line("LD HL,#604A"), line("CALL Game.Screen.Entry_8217_8217.Entry"),
        line("JP Game.Menus.Entry_EEDB_EEDB.Entry"),
        "                ; ограничение дальнего обычного объекта отрицательной координатой Z",
        line("LD (IX+#08),#DF", label="ClampZ"), line("RET"),
        line("ASSERT $ == #6048"), line("endmodule"), line("module ObjectPool"),
        "; -----------------------------------------",
        "; восемь исходных слотов по 39 байтов, структура FSpaceObject",
        "; первый слот принадлежит станции, следующие шесть общим объектам",
        "; последний слот по #6159 выделен ракете игрока",
        "; исходный первый слот содержит сохранённое состояние снимка",
        "; штатные процедуры инициализации устанавливают действующие координаты и ориентацию",
        "; нулевая Energy по смещению #22 обозначает свободный слот",
        "; -----------------------------------------",
    ]
    fields = [
        (0, 3, "X, дробный байт, средний байт, старший байт со знаком"),
        (3, 3, "Y в том же трёхбайтном формате"),
        (6, 3, "Z в том же трёхбайтном формате"),
        (9, 6, "первая ось ориентации, три знаковых слова"),
        (15, 6, "вторая ось ориентации"),
        (21, 6, "третья ось ориентации"),
        (27, 5, "скорость, ускорение, два поворота и контекстное поле"),
        (32, 3, "основные флаги, враждебность и энергия"),
        (35, 2, "адрес описания модели, младший байт первым"),
        (37, 2, "цель или оборудование и дополнительные флаги"),
    ]
    for slot in range(8):
        start = 0x6048 + slot * 39
        name = "Station" if slot == 0 else "Missile" if slot == 7 else f"Ship{slot}"
        lines.append("                ; исходное содержимое слота " + name)
        for field, count, description in fields:
            data = memory[start + field:start + field + count]
            lines.append(line("DB " + ", ".join(f"#{b:02X}" for b in data),
                              description, name if field == 0 else None))
    lines += [
        line("ASSERT $ == #6180"), line("endmodule"), line("module ModelIndex"),
        "; -----------------------------------------",
        "; 23 четырёхбайтные записи индекса моделей и нулевой терминатор",
        "; байт 0 задаёт исходные свойства объекта, слово 1 адрес описания модели",
        "; байт 3 содержит класс, используемый при выборе случайного объекта",
        "; #7ABA ищет запись по адресу модели и читает её первый байт как набор свойств",
        "; первый байт этой версии не является неиспользуемым кодом JP из старого Elite",
        "; заголовки моделей находятся в области #61E3..#63F3",
        "; -----------------------------------------",
    ]
    for index in range(23):
        start = 0x6180 + index * 4
        data = memory[start:start + 4]
        address = int.from_bytes(data[1:3], "little")
        lines.append(line("DB " + ", ".join(f"#{b:02X}" for b in data),
                          f"модель {index}, свойства #{data[0]:02X}, описание #{address:04X}, класс {data[3]}",
                          "Entry" if index == 0 else None))
    lines += [line("DB #00", "конец поиска по адресу модели", "Terminator"),
              line("ASSERT $ == #61DD"), line("endmodule"), line("endmodule")]
    (ROOT / "Source/Game/Data/Block_6000.asm").write_text("\n".join(lines) + "\n", "utf-8")
    report = {
        "start": 0x6000, "end": 0x61DD, "file": "Source/Game/Data/Block_6000.asm",
        "semantic_name": "SystemBoundaryAndObjects", "status": "reviewed",
        "summary": "продолжение смены системы, восемь объектов и индекс 23 моделей",
        "evidence": ["потребители #5FD5, #B936, #B99F, #7ABA и #B89C"],
        "unresolved": [],
    }
    (ROOT / "Tools/Disasm/Reports/Semantics/ObjectPool.json").write_text(
        json.dumps([report], ensure_ascii=False, indent=2) + "\n", "utf-8")


if __name__ == "__main__":
    main()
