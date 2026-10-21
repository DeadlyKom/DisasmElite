"""Сверка всех экземпляров FCommander с оригинальными байтами и символами сборки.

Ассемблер не запускается. Неявные значения полей запрещены source_statements.
"""
import hashlib
import json
import re
from pathlib import Path
from AuditCodeTargets import source_statements, structure_layouts

ROOT = Path(__file__).resolve().parents[2]
REPORT = ROOT / "Tools/Disasm/Reports/CommanderInitializers.json"
RECORDS = (
    ("Source/Game/Interface/DispatchDiskAndCommanderState.asm", "Game.Interface.DispatchDiskAndCommanderState.Commander", "Tools/Disasm/Research/GameCode.bin", 0x9054),
    ("Source/Game/Missions/RatingBountyDamageAndNewCommander.asm", "Game.Missions.RatingBountyDamageAndNewCommander.NewCommander", "Tools/Disasm/Research/GameCode.bin", 0x9232),
    ("Source/Commanders/QS1.asm", "CommanderQS1.Begin", "Tools/Disasm/Extracted/Active/05_QS1.C", 0),
    ("Source/Commanders/Deadly.asm", "CommanderDeadly.Begin", "Tools/Disasm/Extracted/Active/06_DEADLY.C", 0),
    ("Source/DiskUtility/Robot.asm", "DiskUtility.RobotState", "Tools/Disasm/Extracted/Active/03_cl.C", 0x800),
)


def read_symbols(path):
    return {m[1]: int(m[2], 16) for m in re.finditer(
        r"^([\w.]+): EQU 0x([\dA-Fa-f]+)$", path.read_text("utf-8-sig"), re.M)}


def compare_existing_symbols(previous, current):
    """Отдельно учитывается один прежний фиктивный кандидат локального поиска.

    Он не объявлен исходником, имеет значение 0 и возникал при поиске
    Game.Travel... внутри module Memory без глобального префикса @.
    Реальное поле и Memory.RandomSeed обязаны сохранить прежние значения.
    Другие нулевые символы не исключаются.
    """
    placeholder = "Memory.Game.Travel.SetFuelAndGauge.WorkingSeed"
    removed = {}
    differences = {}
    for name, value in previous.items():
        if current.get(name) == value:
            continue
        if name == placeholder and value == 0 and name not in current:
            removed[name] = "устранён неразрешённый локальный кандидат поиска, определения в Source/Includes нет"
        else:
            differences[name] = [value, current.get(name)]
    return differences, removed


def main():
    layouts = structure_layouts()
    symbols = read_symbols(ROOT / "Tmp/ELITE3HL.sym")
    detected = {}
    for path in (ROOT / "Source").rglob("*.asm"):
        for line, text in enumerate(path.read_text("utf-8-sig").splitlines(), 1):
            if re.match(r"^[@\w.]+:?\s+FCommander\s*\{", text):
                detected.setdefault(path.relative_to(ROOT).as_posix(), []).append(line)
    expected = {file for file, _, _, _ in RECORDS}
    if set(detected) != expected or any(len(lines) != 1 for lines in detected.values()):
        raise ValueError(("Набор экземпляров требует проверки", detected))
    instances = []
    nested_fields_checked = 0
    for file, symbol, original, offset in RECORDS:
        if symbol not in symbols and file.endswith("/Robot.asm"):
            candidates = [name for name in symbols if name.endswith(".RobotState")]
            if len(candidates) != 1:
                raise ValueError(("Неоднозначный ROBOT", candidates))
            symbol = candidates[0]
        line = detected[file][0]
        data = bytearray()
        for number, _, statement in source_statements(ROOT / file):
            if number != line:
                continue
            width = 2 if statement.startswith("DW ") else 1
            for value in statement[3:].split(","):
                token = value.strip()
                if not re.fullmatch(r"#[0-9A-Fa-f]+", token):
                    raise ValueError(("Ожидалось буквальное значение", file, token))
                data.extend(int(token[1:], 16).to_bytes(width, "little"))
        reference = (ROOT / original).read_bytes()[offset:offset + 102]
        if len(data) != 102 or data != reference:
            raise ValueError(("Байты записи отличаются от оригинала", file))
        base = symbols[symbol]
        def check_fields(type_name, prefix, address):
            nonlocal nested_fields_checked
            cursor = address
            for name, kind, size in layouts[type_name]:
                key = prefix + "." + name
                if symbols.get(key) != cursor:
                    raise ValueError(("Адрес поля не совпал", key, cursor, symbols.get(key)))
                nested_fields_checked += 1
                if kind in layouts:
                    check_fields(kind, key, cursor)
                cursor += size
            return cursor
        if check_fields("FCommander", symbol, base) != base + 102:
            raise ValueError(("Неверный размер", symbol))
        fields = []
        cursor = 0
        for field, kind, size in layouts["FCommander"]:
            fields.append({"field": field, "type": kind, "offset": cursor,
                           "size": size, "address": base + cursor})
            cursor += size
        instances.append({"file": file, "line": line, "symbol": symbol,
                          "address": base, "size": 102, "source": original,
                          "source_offset": offset, "byte_identical": True,
                          "sha256": hashlib.sha256(data).hexdigest(), "fields": fields})
    report = json.loads(REPORT.read_text("utf-8")) if REPORT.exists() else {}
    report.update({"scope": "пять экземпляров FCommander, включая изменяемый резерв NewCommander",
                   "initializer_count": len(instances), "nested_goods_initializers": 10,
                   "field_count": len(layouts["FCommander"]), "instances": instances,
                   "nested_field_addresses_checked": nested_fields_checked,
                   "literal_bytes_checked": 102 * len(instances)})
    baseline = ROOT / "Tools/Disasm/Reports/BeforeTypedDataSymbols.json"
    if baseline.exists():
        previous = json.loads(baseline.read_text("utf-8"))["symbols"]
        differences, removed = compare_existing_symbols(previous, symbols)
        if differences:
            raise ValueError(("Существующие символы изменились", differences))
        report["unchanged_existing_symbols"] = len(previous) - len(removed)
        report["removed_lookup_placeholders"] = removed
        report["changed_existing_symbol_values"] = differences
    trd = (ROOT / "ELITE3HL.TRD").read_bytes()
    if trd != (ROOT / "Tools/Disasm/Disk/original.trd").read_bytes():
        raise ValueError("TRD отличается от исходной копии")
    report.update({"state_address": symbols["State"], "cargo_address": symbols["State.Cargo"],
                   "market_stock_address": symbols["State.MarketStock"],
                   "original_trd_equal": True, "trd_bytes": len(trd),
                   "sha256": hashlib.sha256(trd).hexdigest()})
    REPORT.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Commander records {len(instances)}, bytes {102 * len(instances)}, field addresses {nested_fields_checked}, all identical")


if __name__ == "__main__":
    main()
