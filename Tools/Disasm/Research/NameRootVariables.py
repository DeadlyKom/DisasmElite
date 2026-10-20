"""Именование проверенных данных Text/Extensions без изменения их размещения.

Однократное преобразование исходных DB и операндов. Таблица bindings используется
при общей проверке ссылок, числовые непосредственные значения не заменяются вслепую.
"""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]


def line(label, code, comment=""):
    text = label.ljust(16) + code
    return text.ljust(80) + "; " + comment if comment else text


def write(path, text):
    (ROOT / path).write_text(text.rstrip() + "\n", "utf-8")


def include(path, body):
    guard = "_" + path.removeprefix("Includes/").removesuffix(".inc").replace("/", "_").upper() + "_"
    write(path, f"                ifndef {guard}\n                define {guard}\n\n" + body +
          f"\n\n                endif ; ~{guard}")


def diagram(bits, descriptions):
    return "\n".join([
        "; -----------------------------------------",
        ";      7    6    5    4    3    2    1    0",
        ";   +----+----+----+----+----+----+----+----+",
        ";   | " + " | ".join(f"{b:2}" for b in bits) + " |",
        ";   +----+----+----+----+----+----+----+----+",
        ";", *[";   " + d for d in descriptions],
        "; -----------------------------------------"])


fields = [
    ("SystemKeys", "#00", "маска клавиш Y, 0, I, O, P, K, L, ENTER",
     ["Y", "0", "I", "O", "P", "K", "L", "EN"],
     ["Y / 0 / I / O / P / K / L / EN [7..0] - соответствующая клавиша нажата",
      "EN      [0]     - ENTER", "биты устанавливает таблица KeyboardMap, нажатия накапливаются до обработки потребителем"]),
    ("FlightKeys", "#00", "нормализованные направления и изменение скорости",
     ["..", "..", "SS", "SP", "S", "X", "M", "N"],
     ["SS      [5]     - SYMBOL SHIFT, уменьшение скорости", "SP      [4]     - SPACE, увеличение скорости",
      "S / X   [3..2]  - положительный / отрицательный тангаж",
      "M / N   [1..0]  - положительный / отрицательный крен",
      "биты 0..3 после нормализации содержат команды выбранного источника управления",
      "биты 6..7 не назначены таблицей опроса"]),
    ("ViewJumpKeys", "#00", "виды кабины, переходы и CAPS SHIFT",
     ["CS", "J", "G", "H", "4", "3", "2", "1"],
     ["CS      [7]     - CAPS SHIFT, запрос паузы", "J / G / H [6..4] - клавиши J, G, H",
      "4 / 3 / 2 / 1 [3..0] - выбор вида кабины"]),
    ("DeviceKeys", "#00", "маска команд C, Q, W, E, U, F, T, A",
     ["C", "Q", "W", "E", "U", "F", "T", "A"],
     ["C       [7]     - запрос автоматической стыковки", "W       [5]     - запрос энергетической бомбы",
      "Q / E / U / F / T / A [6,4..0] - соответствующая клавиша нажата",
      "в цифровом режиме клавиша 0 дополнительно устанавливает команду A"]),
    ("ChartKeys", "#00", "маска клавиш R, D, B",
     ["..", "R", "D", "B", "..", "..", "..", ".."],
     ["R / D / B [6..4] - соответствующая клавиша нажата", "остальные биты не назначены таблицей опроса"]),
    ("LastKey", "#FF", "последний символ, #FF нет клавиши, #FE сочетание 0 и CAPS SHIFT", None, None),
    ("Config", "#8C", "режим источника, настройки направлений и звук",
     ["SN", "MJ", "VY", "RV", "BR", "ST", "MD", "MD"],
     ["SN      [7]     - флаг, разрешён звук", "MJ      [6]     - флаг, принудительный выход гиперперехода в межзвёздное пространство",
      "VY      [5]     - флаг, поменять местами направления тангажа",
      "RV      [4]     - флаг, поменять местами направления обеих осей",
      "BR      [3]     - флаг, тормозить отпущенную ось управления",
      "ST      [2]     - флаг, обнулить угол при противоположной команде",
      "MD      [1..0]  - номер источника направлений, это двухбитовое поле",
      "                  0 - буквенная клавиатура, 1..3 - варианты цифрового управления"]),
    ("NumberKeys", "#00", "цифровые направления до нормализации",
     ["..", "..", "..", "7", "6", "8", "5", "9"],
     ["7 / 6 / 8 / 5 / 9 [4..0] - соответствующая цифровая клавиша нажата",
      "биты 5..7 не назначены таблицей опроса"]),
]
body = ["; исходный блок #FC08..#FC0F, обновляется обработчиком клавиатуры",
        "; это маски игровых команд, полуряды аппаратной клавиатуры описаны FKeyboardRows",
        line("", "struct FInputState", "состояние игрового ввода [8 байт]")]
for name, default, description, bits, details in fields:
    if bits:
        body.append(diagram(bits, details))
    body.append(line(name, "DB " + default, description))
body += ["                ends", "                ASSERT FInputState == 8"]
include("Includes/Structs/InputState.inc", "\n".join(body))

body = [line("InputState", "EQU Game.Extensions.CompareObjectCoordinateDepth.KeyEvents", "адрес состояния игрового ввода")]
for name, _, description, _, _ in fields:
    body.append(line("." + name, "EQU InputState + FInputState." + name, description))
include("Includes/Variables/InputState.inc", "\n".join(body))

controls = [
    ("INPUT_SND_BIT", "7", "флаг, разрешён звук"),
    ("INPUT_MJ_BIT", "6", "флаг, выход в межзвёздное пространство"),
    ("INPUT_INVY_BIT", "5", "флаг, перестановка направлений тангажа"),
    ("INPUT_INV_BIT", "4", "флаг, перестановка направлений обеих осей"),
    ("INPUT_BRAKE_BIT", "3", "флаг, торможение отпущенной оси"),
    ("INPUT_STOP_BIT", "2", "флаг, остановка при противоположной команде"),
    ("INPUT_MODE_MASK", "#03", "двухбитовый номер источника направлений"),
    ("INPUT_NO_KEY", "#FF", "нет нажатой клавиши"),
    ("INPUT_ZERO_KEY", "#FE", "сочетание клавиши 0 и CAPS SHIFT"),
]
# Длинные имена констант соответствуют Const/Input HoMM, EQU следует после имени.
include("Includes/Const/Control.inc", "\n".join(
    (name + " EQU " + value).ljust(80) + "; " + comment for name, value, comment in controls))

path = "Source/Game/Extensions/CompareObjectCoordinateDepth.asm"
text = (ROOT / path).read_text("utf-8-sig")
begin = text.index("                ; пять регистров масок команд")
end = text.index("                ; проверка исходного конца фрагмента", begin)
physical = ["                ; состояние опроса клавиатуры, структура FInputState"]
for n, (name, default, description, _, _) in enumerate(fields):
    physical.append(line("KeyEvents" if n == 0 else "." + name, "DB " + default, description))
text = text[:begin] + "\n".join(physical) + "\n" + text[end:]
write(path, text)

body = [line("", "struct FMarketEntry", "исходные параметры одного товара [4 байта]"),
        line("Price", "DB #00", "базовая цена, GenerateMarket масштабирует результат в четыре раза"),
        diagram(["NG", "..", "..", "EC", "EC", "EC", "EC", "EC"],
                ["NG      [7]     - флаг, отрицательный коэффициент экономики",
                 "EC      [4..0]  - модуль коэффициента экономики", "биты 5..6 генератор рынка не использует"]),
        line("Economy", "DB #00", "знак и модуль коэффициента экономики"),
        line("Stock", "DB #00", "базовый запас до случайной и экономической поправок"),
        line("RandomMask", "DB #00", "маска случайного параметра системы"),
        "                ends", "                ASSERT FMarketEntry == 4", "",
        line("", "struct FEquipmentPrice", "стоимость оборудования [3 байта]"),
        line("High", "DB #00", "старшая денежная группа"),
        line("Low", "DW #0000", "младшая часть цены, две десятичные пары в принятом игрой формате"),
        "                ends", "                ASSERT FEquipmentPrice == 3"]
include("Includes/Structs/Market.inc", "\n".join(body))
body = [line("MarketTable", "EQU Game.Extensions.AttributeVectorAndEnergyBomb.MarketParams", "17 записей FMarketEntry"),
        line(".Base", "EQU MarketTable", "первый товар, продовольствие"),
        line(".FirearmPrice", "EQU MarketTable + FGoods.Firearms * FMarketEntry + FMarketEntry.Price", "изменяемая базовая цена оружия"),
        line(".FirearmEconomy", "EQU MarketTable + FGoods.Firearms * FMarketEntry + FMarketEntry.Economy", "изменяемый коэффициент экономики оружия"),
        line("EquipmentTable", "EQU Game.Extensions.AttributeVectorAndEnergyBomb.EquipmentPrices", "14 записей FEquipmentPrice"),
        line(".Base", "EQU EquipmentTable", "первый пункт, топливо"),
        line(".FuelPrice", "EQU EquipmentTable + FEquipmentPrice.Low", "стоимость недостающего топлива, вычисляется перед показом рынка"),
        line("MessageTable", "EQU Game.Extensions.PrintCargoAndMessageBanks.MainTable", "два указателя на банки сообщений"),
        line(".Main", "EQU MessageTable", "указатель на основной банк токенов"),
        line(".Description", "EQU Game.Extensions.PrintCargoAndMessageBanks.DescTable", "указатель на банк описаний систем")]
include("Includes/Variables/Tables.inc", "\n".join(body))

# Метки размещаются на уже существующих строках, количество байтов не меняется.
replacements = {
    "Source/Game/Extensions/AttributeVectorAndEnergyBomb.asm": [
        ("DB #13, #82, #06, #01", "MarketParams", "DB #13, #82, #06, #01", "продовольствие, запись FMarketEntry"),
        ("DB #7C, #0D, #1D, #07", ".Firearms", "DB #7C, #0D, #1D, #07", "оружие, цена и коэффициент изменяются кодом событий"),
        ("DB #00, #00, #00", "EquipmentPrices", "DB #00, #00, #00", "топливо, запись FEquipmentPrice"),
    ],
    "Source/Game/Extensions/PrintCargoAndMessageBanks.asm": [
        ("DB #1E, #F1", "MainTable", "DW MainBank", "указатель на основной банк сообщений"),
        ("DB #D0, #F4", "DescTable", "DW DescBank", "указатель на банк описаний систем"),
        ("DB #6F, #10, #00", "MainBank", "DB #6F, #10, #00", "основной банк, сообщение 0"),
    ],
}
for path, edits in replacements.items():
    text = (ROOT / path).read_text("utf-8-sig")
    for old, label, code, comment in edits:
        pattern = r"^                " + re.escape(old) + r"\s*;[^\n]*$"
        text, count = re.subn(pattern, lambda m: line(label, code, comment), text, count=1, flags=re.M)
        assert count == 1, (path, old)
    if path.endswith("PrintCargoAndMessageBanks.asm"):
        text, count = re.subn(r"^                DB #00\s*; данные #F4D0\.\.#F4D0$",
                             line("DescBank", "DB #00", "банк описаний, пустое сообщение 0"), text, flags=re.M)
        assert count == 1
        text = text.replace("LD (#F8CC),SP", "LD (SavedSP), SP")
        text = text.replace("RestoreStack:   LD SP,#0000", line("SavedSP", "EQU $ + 1", "операнд восстановления исходного SP") + "\nRestoreStack:   LD SP,#0000")
    write(path, text)

path = "Source/Game/Extensions/DrawCompressedEdges.asm"
text = (ROOT / path).read_text("utf-8-sig")
text = text.replace("Entry:          LD A,#FF", line("FrameCounter", "EQU $ + 1", "операнд счётчика, оборачивается через 256 вызовов") + "\nEntry:          LD A,#FF")
text = text.replace("LD (#6F42),A", "LD (FrameCounter), A")
write(path, text)

path = "Source/Game/Extensions/DrawCircleAndProtectScratchStack.asm"
text = (ROOT / path).read_text("utf-8-sig")
text = text.replace("LD (#F90A),SP", "LD (SavedSP), SP")
text = text.replace("                LD SP,#0000", line("SavedSP", "EQU $ + 1", "операнд восстановления исходного SP") + "\n                LD SP,#0000")
write(path, text)

path = "Source/Game/Text/XorCharacterScanlines.asm"
text = (ROOT / path).read_text("utf-8-sig").replace("                XOR C", line("XorOpcode", "XOR C", "XOR C либо NOP, способ переноса глифа на экран"))
write(path, text)

bindings = []
def binding(address, symbol, file, kind, meaning, evidence):
    bindings.append(dict(address=address, symbol=symbol, file=file, kind=kind, meaning=meaning, evidence=evidence))
for n, (name, _, description, _, _) in enumerate(fields):
    binding(0xFC08 + n, "InputState." + name, "Source/Game/Extensions/CompareObjectCoordinateDepth.asm",
            "data", description, "EnableInterruptMode1AndKeyboardMap, SetPressedKeyAssignment, ResetDemoAndNormalizeControls")
for address, symbol, filename, kind, meaning, evidence in [
    (0x701B, "MarketTable.Base", "AttributeVectorAndEnergyBomb", "data", "17 записей параметров товаров", "GenerateMarket"),
    (0x7043, "MarketTable.FirearmPrice", "AttributeVectorAndEnergyBomb", "data", "базовая цена оружия", "GenerateMarket и обработчики событий"),
    (0x7044, "MarketTable.FirearmEconomy", "AttributeVectorAndEnergyBomb", "data", "коэффициент экономики оружия", "GenerateMarket и обработчики событий"),
    (0x705F, "EquipmentTable.Base", "AttributeVectorAndEnergyBomb", "data", "14 цен оборудования", "GetEquipmentPriceAddress"),
    (0x7060, "EquipmentTable.FuelPrice", "AttributeVectorAndEnergyBomb", "data", "цена недостающего топлива", "CalculateFuelPurchasePrice"),
    (0xF11A, "MessageTable.Main", "PrintCargoAndMessageBanks", "pointer", "указатель основного банка", "PrintMainToken"),
    (0xF11C, "MessageTable.Description", "PrintCargoAndMessageBanks", "pointer", "указатель банка описаний", "PrintDescriptionToken"),
    (0x6F42, "Game.Extensions.DrawCompressedEdges.FrameCounter", "DrawCompressedEdges", "operand", "счётчик вызовов в операнде LD A", "DrawCompressedEdges"),
    (0xF8CC, "Game.Extensions.PrintCargoAndMessageBanks.SavedSP", "PrintCargoAndMessageBanks", "operand", "сохранённый SP в операнде LD SP", "ProjectSafely/RestoreStack"),
    (0xF90A, "Game.Extensions.DrawCircleAndProtectScratchStack.SavedSP", "DrawCircleAndProtectScratchStack", "operand", "сохранённый SP в операнде LD SP", "NextOrFinish"),
]:
    binding(address, symbol, "Source/Game/Extensions/" + filename + ".asm", kind, meaning, evidence)
binding(0xD548, "Game.Text.XorCharacterScanlines.XorOpcode", "Source/Game/Text/XorCharacterScanlines.asm",
        "opcode", "XOR C либо NOP при выводе глифа", "DiskUtility/Menu, Text/XorCharacterScanlines")
write("Tools/Disasm/Reports/VariableNamesRoot.json", json.dumps({"bindings": bindings}, ensure_ascii=False, indent=2))
print("Именованы поля ввода, таблицы рынка/сообщений и проверенные операнды Text/Extensions")
