"""Однократное оформление статического разбора, не часть процесса сборки.

Не вызывает ассемблер. Не утверждает доказанность семантики всех найденных входов.
"""

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "Tools/Disasm"))
from InspectZ80 import memory_for

RANGES = [
    (0x5C00, "Extensions", "дополнения кладовской версии"),
    (0x70B0, "Flight", "состояние полёта и основной цикл"),
    (0x7584, "Universe", "планета, солнце и звёзды"),
    (0x7FBE, "Screen", "экран, кабина и приборы"),
    (0x86EE, "Circles", "окружности и заливка"),
    (0x928C, "Flight", "стыковка и переходы полёта"),
    (0x9527, "Sound", "звуковые эффекты"),
    (0x96D6, "Scanner", "сканер и индикаторы"),
    (0x9A40, "Combat", "вооружение и повреждения"),
    (0x9E73, "Motion", "координаты, скорости и повороты"),
    (0xA84D, "Wireframe", "проекция и каркасное изображение"),
    (0xB4D8, "Combat", "столкновения, лазер и ECM"),
    (0xB82C, "Objects", "создание и размещение объектов"),
    (0xBD95, "Motion", "нормали и векторные вычисления"),
    (0xC000, "Resources", "изображение кабины и сохранённая память"),
    (0xD000, "Interface", "таблица переходов и данные пилота"),
    (0xD0D7, "Missions", "миссии и рейтинг"),
    (0xD2DE, "Economy", "числа и денежный счёт"),
    (0xD421, "Text", "символы, сообщения и форматирование"),
    (0xD907, "Disk", "дисковые оверлеи и TR-DOS"),
    (0xDA7A, "Travel", "сообщения, гиперпереход и топливо"),
    (0xDF03, "Galaxy", "галактика, планеты и генератор"),
    (0xE142, "Trade", "товары, единицы и ввод"),
    (0xE398, "Charts", "поиск планеты и курсор карты"),
    (0xE6AE, "Trade", "покупка, продажа и оборудование"),
    (0xEB63, "Menus", "карты и информационные экраны"),
    (0xF0B8, "Extensions", "дополнительные экраны и обработчики"),
    (0xFC00, "Input", "клавиатура, управление и прерывания"),
]

KNOWN = {
    0x7394: ("Start", "начальный экран, выбор управления и переход к основному циклу"),
    0x7471: ("MainLoop", "главный цикл игры, обработка экрана, полёта и игровых объектов"),
    0x7461: ("SetAttributes", "заполнение двух блоков атрибутов по 240 байт значением 7"),
    0x7467: ("FillAttributes", "заполнение 240 атрибутов начиная с HL"),
    0xD61D: ("ClearView", "очистка окна, атрибутов и восстановление рамки"),
    0xD907: ("OpenDiskMenu", "загрузка первого оверлея cl.C и вызов меню LOAD/SAVE/DEMO"),
    0xD99B: ("LoadDemo", "загрузка сектора ROBOT и второго оверлея cl.C"),
    0xD421: ("PrintInline", "печать символа, код которого расположен сразу после CALL"),
    0xE2BC: ("SetInlineX", "чтение координаты печати X из байта сразу после CALL"),
    0xF068: ("PrintIfNonzero", "условная печать кода сообщения, расположенного после CALL"),
    0xFF25: ("Interrupt", "сохранение регистров, опрос управления и возврат из IM 2"),
    0xFEFE: ("InterruptGate", "исходный переход из вектора IM 2 к обработчику"),
    0xFF4C: ("EnableIM2", "установка I равным #FD и включение режима IM 2"),
    0xFF53: ("EnableIM1", "переключение процессора в режим прерываний IM 1"),
}

CONDITIONS = {
    "NZ": "флаг Z сброшен", "Z": "флаг Z установлен",
    "NC": "флаг переноса сброшен", "C": "флаг переноса установлен",
    "PO": "флаг P/V сброшен", "PE": "флаг P/V установлен",
    "P": "флаг знака сброшен", "M": "флаг знака установлен",
}


def category(address):
    found = ("Resources", "исходные данные")
    for start, name, title in RANGES:
        if address >= start:
            found = name, title
    return found


def operation_text(operation):
    return operation.replace("$", "#").replace("IXh", "IXH").replace(
        "IXl", "IXL").replace("IYh", "IYH").replace("IYl", "IYL")


def line(code, comment=None, label=None):
    text = (label + ":").ljust(16) + code if label else " " * 16 + code
    return text.ljust(80) + "; " + comment if comment else text


def main():
    memory = memory_for("decoded")
    cfg = json.loads((ROOT / "Tools/Disasm/Reports/ControlFlow.json").read_text("utf-8"))
    reference = json.loads((ROOT / "Tools/Disasm/Reports/ReferenceMatches.json").read_text("utf-8"))
    maths = json.loads((ROOT / "Tools/Disasm/Reports/MathRanges.json").read_text("utf-8"))
    instructions = {item["address"]: item for item in cfg["instructions"]}
    occupied = set()
    for address, item in instructions.items():
        occupied.update(range(address, address + item["length"]))
    matched = {}
    duplicates = set()
    for item in reference["routines"]:
        address = item["target"]
        if address in matched:
            duplicates.add(address)
        matched[address] = item
    # Поиск входов, у которых имеются прямой вызов или структурное сопоставление.
    entries = set(cfg["call_targets"]) | set(matched) | set(KNOWN)
    entries &= set(instructions)
    for item in maths:
        entries.difference_update(range(item["start"], item["end_exclusive"]))
    entries = sorted(entries)
    names = {}
    for address in entries:
        group, _ = category(address)
        ref = matched.get(address)
        title = ref["title"] if ref and address not in duplicates else ""
        if address in KNOWN:
            name = KNOWN[address][0]
        elif title and not title.startswith(("Routine at ", "nullsub")):
            name = re.sub("[^A-Za-z0-9_]", "_", title)
        else:
            name = f"Entry_{address:04X}"
        names[address] = f"Game.{group}.{name}_{address:04X}.Entry"
    for item in maths:
        for name, address in item["entries"].items():
            names[address] = f"Game.Math.{name}"
    # Перекрывающиеся исполнения сохраняются байтами с обоими вариантами декодирования.
    overlap = set()
    for first, second in cfg["overlaps"]:
        for address in (first, second):
            overlap.update(range(address, address + instructions[address]["length"]))
    # Выделение частей с ручным анализом и исходных ресурсных областей.
    boundaries = {0x4000, 0x5B00, 0x5C00, 0x6000, 0xBE00,
                  0xC000, 0xC800, 0xD000, 0x10000} | set(entries)
    for item in maths:
        boundaries.update((item["start"], item["end_exclusive"]))
    boundaries = sorted(boundaries)
    math_by_start = {item["start"]: item for item in maths}
    target_dir = ROOT / "Source/Game"
    target_dir.mkdir(parents=True, exist_ok=True)
    layout = [
        "                ifndef _ELITE_GAME_INCLUDE_",
        "                define _ELITE_GAME_INCLUDE_",
        "                module Game",
        "; -----------------------------------------",
        "; полный файловый диапазон #4000..#FFFF",
        "; инструкции представлены после восстановления XOR-кодирования",
        "; исходные семена генератора сохранены для штатного загрузчика",
        "; кодирование 244 файловых байтов выполняет упаковщик sjasmplus",
        "; автоматическая карта входов не доказывает семантику каждой процедуры",
        "; -----------------------------------------",
        "                ASSERT $ == #4000",
    ]
    manifest = []
    for index, start in enumerate(boundaries[:-1]):
        end = boundaries[index + 1]
        if any(item["start"] < start < item["end_exclusive"] for item in maths):
            continue
        if start in math_by_start:
            item = math_by_start[start]
            relative = str(Path(item["file"]).relative_to("Source/Game")).replace("\\", "/")
            layout.append(line(f'include "{relative}"'))
            manifest.append({"start": start, "end": item["end_exclusive"],
                             "file": item["file"], "status": "manual"})
            continue
        is_procedure = start in names
        group, group_title = category(start)
        if not is_procedure:
            group = "Data"
        file_name = (names[start].split(".")[-2] if is_procedure
                     else f"Block_{start:04X}")
        directory = target_dir / group
        directory.mkdir(exist_ok=True)
        path = directory / (file_name + ".asm")
        ref = matched.get(start)
        description = KNOWN.get(start, ("", ""))[1]
        if not description:
            description = f"адресный фрагмент модуля, {group_title}"
        status = "manual_entry" if start in KNOWN else (
            "matched_entry" if ref and ref["confidence"] == "supported"
            else "provisional" if is_procedure else "data")
        text = [
            f"                module {group}",
            f"                module {file_name}",
            "; -----------------------------------------",
            "; " + description,
            f"; исходный диапазон #{start:04X}..#{end - 1:04X}",
            "; граница файла задаёт порядок байтов, а не обещание выхода через RET",
        ]
        if ref and is_procedure:
            text += [f"; сопоставление со справочником, {ref['title']}",
                     "; назначение всех ветвей и контракт регистров требуют ручной проверки"]
        elif is_procedure and start not in KNOWN:
            text.append("; назначение входа и контракт регистров ещё уточняются")
        if not is_procedure:
            text.append("; сохранённые байты, принадлежность к коду проверяется по карте входов")
        text += ["; -----------------------------------------",
                 "                ; проверка исходного начала фрагмента",
                 line(f"ASSERT $ == #{start:04X}")]
        cursor = start
        first = True
        opcode_count = 0
        data_count = 0
        while cursor < end:
            ins = instructions.get(cursor)
            safe = (ins and cursor + ins["length"] <= end and
                    not overlap.intersection(range(cursor, cursor + ins["length"])))
            label = "Entry" if first else None
            first = False
            if safe:
                operation = operation_text(ins["operation"])
                # Именование прямых вызовов и переходов только к зарегистрированным входам.
                match = re.match(r"^(CALL|JP|JR|DJNZ) (?:([A-Z]+),)?#([0-9A-F]+)$", operation)
                comment = None
                if match:
                    kind, condition, operand = match.groups()
                    destination = int(operand, 16)
                    if destination in names:
                        operation = operation[:match.start(3) - 1] + names[destination]
                    if condition:
                        prefix = "переход" if kind in ("JP", "JR") else "вызов процедуры"
                        comment = f"{prefix}, если {CONDITIONS[condition]}"
                        if len(operation) > 62:
                            operation = operation_text(ins["operation"])
                elif operation.startswith("RET ") and operation[4:] in CONDITIONS:
                    comment = "выход, если " + CONDITIONS[operation[4:]]
                # Проверки и расчёты помечаются до исходной инструкции.
                if operation.startswith(("CP ", "BIT ")):
                    text.append("                ; проверка исходного условия по операндам инструкции")
                elif operation.startswith(("ADD ", "ADC ", "SUB ", "SBC ", "INC ", "DEC ")):
                    text.append("                ; расчёт исходного значения с сохранением семантики Z80")
                elif operation.startswith(("LDIR", "LDDR", "LDI", "LDD")):
                    text.append("                ; перенос исходной последовательности данных")
                text.append(line(operation, comment, label))
                cursor += ins["length"]
                opcode_count += 1
            else:
                limit = min(cursor + 8, end)
                for position in range(cursor + 1, limit):
                    if position in instructions and position not in overlap:
                        limit = position
                        break
                data = memory[cursor:limit]
                comment = f"исходные байты #{cursor:04X}..#{limit - 1:04X}"
                if cursor in cfg["inline_data"]:
                    comment = "аргумент вызываемой процедуры из потока команд"
                if overlap.intersection(range(cursor, limit)):
                    for position in range(cursor, limit):
                        if position in instructions:
                            text.append(f"; вариант исполнения #{position:04X}, "
                                        + operation_text(instructions[position]["operation"]))
                    comment = "перекрывающиеся команды, байты сохранены буквально"
                text.append(line("DB " + ", ".join(f"#{value:02X}" for value in data),
                                 comment, label))
                data_count += len(data)
                cursor = limit
        text += ["                ; проверка исходного конца фрагмента",
                 line(f"ASSERT $ == #{end:04X}"), "                endmodule",
                 "                endmodule", ""]
        # Сохранение результатов анализа, вручную оформленные Math-файлы не меняются.
        path.write_text("\n".join(text), encoding="utf-8")
        relative = path.relative_to(target_dir).as_posix()
        layout.append(line(f'include "{relative}"'))
        manifest.append({"start": start, "end": end,
                         "file": path.relative_to(ROOT).as_posix(), "status": status,
                         "instructions": opcode_count, "literal_bytes": data_count})
    layout += ["                ASSERT $ == #10000", "                endmodule",
               "                endif", ""]
    (target_dir / "Include.inc").write_text("\n".join(layout), encoding="utf-8")
    (ROOT / "Tools/Disasm/Reports/SourceCoverage.json").write_text(
        json.dumps({"warning": "Семантический разбор не завершён",
                    "source_length": 49152, "fragments": manifest},
                   ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Фрагментов {len(manifest)}, инструкций "
          f"{sum(item.get('instructions', 0) for item in manifest) + 110}")


if __name__ == "__main__":
    main()
