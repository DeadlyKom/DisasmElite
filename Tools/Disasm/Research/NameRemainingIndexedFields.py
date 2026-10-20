"""Имена оставшихся индексных полей по контрактам целевого TRD.

Материал разбора, не часть сборки. Не переносит имена из другой версии игры.
Регистр связывается с форматом лишь в перечисленных проверенных потребителях.
"""

import hashlib
import json
import re
from pathlib import Path

from NameIndexedFields import ROOT, SYMBOLS, COORD, OBJECT, MODEL, EFFECT


OBJECT = dict(OBJECT) | {0x24: "FSpaceObject.Blueprint+1"}
MODEL = dict(MODEL) | {offset + 1: MODEL[offset] + "+1" for offset in (8, 12, 14, 16, 21)}
POSITION = {axis * 3 + offset: "+".join(["FCoordinate"] * axis + [field])
            for axis in range(3) for offset, field in COORD.items()}
MAPPINGS = {}
LOCALS = {}
EVIDENCE = {}


def files(category, names, ix=None, iy=None, reason=""):
    for name in names.split():
        relative = f"Source/Game/{category}/{name}.asm"
        MAPPINGS[relative] = {"IX": ix or {}, "IY": iy or {}}
        EVIDENCE[relative] = reason


def local(category, name, definitions):
    LOCALS[f"Source/Game/{category}/{name}.asm"] = definitions


# IX остаётся основным слотом, источником служат обходы восьми объектов.
files("Universe", "AdvanceCircularObjectEffect ApplyEcmToStandardMissile SetStationEnergy "
      "SpawnDestructionContentsAndEffects UpdateStationCoordinates", OBJECT,
      reason="IX передаётся из обхода основного пула либо явно установлен в #6048")
files("Universe", "DispatchLinkedObjectAction FindInteractingObject UpdateExtendedObjectEffects",
      OBJECT, EFFECT, "IX проходит основной пул, IY указывает в десятибайтовый параллельный пул")
files("Universe", "InitializeExtendedObjectMetadata", OBJECT, MODEL,
      "основной вход читает указатель модели из IX, отдельный #7B15 получает IY модели")
files("Universe", "TryObjectInteraction", OBJECT,
      {0: EFFECT[0], 8: EFFECT[8], 0x20: OBJECT[0x20], 0x22: OBJECT[0x22]},
      "IY+0/+8 читаются из метаданных, EX (SP),IY перед уроном выбирает основной слот цели для +20/+22")
files("Universe", "MoveCoordinateDepthBy32", POSITION,
      reason="#7EDE передаёт солнце, планету и станцию, общим является только девятибайтовое положение")
files("Universe", "CompareObjectAxisDistance", {-1: "PrevSign", -2: "PrevLow"},
      {-1: "PrevSign", -2: "PrevLow"},
      "перед чтением оба указателя увеличены на три, отрицательные отступы относятся к прежней координате")
local("Universe", "CompareObjectAxisDistance", [
    ("PrevSign", "FCoordinate-FCoordinate.SignHigh", 1, "отступ назад к знаку и старшему модулю предыдущей координаты"),
    ("PrevLow", "FCoordinate-FCoordinate.Low", 2, "отступ назад к целому младшему байту предыдущей координаты")])

files("Extensions", "ChooseLinkedObjectTarget CreateMissileOrMissionCraft FindLiveTrackedObject "
      "MarkObjectEventAndUpdateMetadata SetObjectAggressionFlag", OBJECT,
      reason="IX сохраняет адрес основного слота, изменение слота выполняется штатными конструкторами")
files("Extensions", "ResolveSpecialObjectCollision", OBJECT, OBJECT,
      "IX и IY переданы как два основных слота столкновения")
files("Extensions", "ScheduleLinkedObjectLaser", OBJECT, EFFECT,
      "IY сохраняется и загружается из #B452, затем восстанавливается до работы с IX объекта")
files("Extensions", "CompareObjectCoordinateDepth", COORD, COORD,
      "IY сначала увеличен на три, +1/+2 относятся уже к выбранной следующей координате")
files("Extensions", "OfferUpgradeAndCorrectPosition", POSITION,
      reason="отдельный вход #5FD5 проверяет Z тройки координат, в частности IX=#7110 для планеты")
files("Extensions", "AllocateVariantObjectSlot", EFFECT,
      reason="перед RES GetObjectMetadataAddress возвращает в IX десятибайтовую запись, POP IX восстанавливает слот")
files("Extensions", "UpdateStationAndSpecialShips",
      OBJECT | {0x49: "FSpaceObject+FSpaceObject.Energy"},
      reason="IX=#6048, +49 есть #27+Energy, энергия следующего слота, а не поле станции")
files("Extensions", "DrawCompressedEdges",
      {0x26: OBJECT[0x26], 0: "ThresholdPtr", 1: "ThresholdPtr+1",
       2: "VertexPtr", 3: "VertexPtr+1", 4: "FaceStream", 5: "FaceStream+1"}, MODEL,
      "первый IX+26 относится к объекту, EX (SP),IX и ADD IX,DE выбирают блок рёбер, в цикле IX движется по потоку граней")
local("Extensions", "DrawCompressedEdges", [
    ("ThresholdPtr", "0", 0, "первое слово блока, адрес потока порогов, читается до продвижения IX"),
    ("VertexPtr", "2", 2, "второе слово блока, адрес упакованных пар вершин, читается до продвижения IX"),
    ("FaceStream", "4", 4, "поток граней после двух слов, в цикле IX уже содержит смещение текущей записи")])
files("Extensions", "DrawSmallSilhouette", {0: "ProfileByte"},
      reason="IX временно загружен адресом #A8FA и проходит байты профиля вперёд, затем назад")
local("Extensions", "DrawSmallSilhouette", [
    ("ProfileByte", "0", 0, "текущий байт контура, индекс IX проходит профиль от #A8FA")])

files("Scanner", "DrawScannerObjects", OBJECT,
      reason="IX начинается с #6048 и продвигается общим хвостом сканера на размер слота")
files("Screen", "CheckDockingAlignment", OBJECT,
      reason="вызывающий HandleObjectCollision передаёт основной объект станции")
files("Screen", "SunDistanceHint UpdateCelestialProximity", POSITION,
      reason="IX явно выбирает девятибайтовое положение солнца либо планеты")
files("Screen", "CompassFarAxis", COORD,
      reason="IX указывает на начало текущей трёхбайтовой координаты, сохраняется общим делителем")
files("Screen", "CompassNearAxis", COORD | {5: "FCoordinate+FCoordinate.SignHigh"},
      reason="в первом входе IX=текущая координата, перед последним чтением указатель уже продвинут к Y, +5 даёт знак Z")
files("Screen", "LoadVectorWords", {0: "FirstLow", 1: "FirstHigh", 3: "SecondLow",
      4: "SecondHigh", 6: "ThirdLow", 7: "ThirdHigh"},
      reason="IX выбирает младшее либо старшее слово первой координаты, поэтому части координаты нельзя именовать одинаково")
local("Screen", "LoadVectorWords", [
    ("FirstLow", "0", 0, "младший байт выбранного слова первой координаты"),
    ("FirstHigh", "1", 1, "старший байт выбранного слова первой координаты"),
    ("SecondLow", "FCoordinate", 3, "младший байт выбранного слова второй координаты"),
    ("SecondHigh", "FCoordinate+1", 4, "старший байт выбранного слова второй координаты"),
    ("ThirdLow", "FCoordinate+FCoordinate", 6, "младший байт выбранного слова третьей координаты"),
    ("ThirdHigh", "FCoordinate+FCoordinate+1", 7, "старший байт выбранного слова третьей координаты")])

files("Flight", "AnimateTransitionTunnel ClearNearbyShipSlots LaunchOrDockShip", OBJECT,
      reason="IX явно устанавливается в станционный слот #6048, очистка проходит последующие слоты")
files("Flight", "HalfCoordinateDifference", COORD, COORD,
      "RebaseSunAgainstStation передаёт координаты станции и солнца, RebaseCoordinateAxis продвигает обе базы на три")
files("Flight", "RebaseCoordinateAxis", iy=COORD,
      reason="запись производится до продвижения IY к следующей координате")
files("Circles", "DetachMissileTarget", iy=OBJECT,
      reason="ReleaseMissileTargets передаёт IY основного слота зависимой ракеты")
files("Circles", "UpdateThargoidAndBodyCoords", OBJECT,
      reason="IX сохраняет слот поражённого объекта и затем создаваемого в том же месте контейнера")
files("Circles", "DrawPendingObjectExplosions",
      {0x20: OBJECT[0x20], 0x1C: "ExplodeX", 0x1D: "ExplodeY", 0x1E: "SignPhase", 0x1F: "Radius"},
      reason="StartObjectExplosion заменяет смысл полей движения экранными параметрами взрыва")
local("Circles", "DrawPendingObjectExplosions", [
    ("ExplodeX", "FSpaceObject.Acceleration", 0x1C, "экранный X взрыва вместо ускорения, записывает StartObjectExplosion"),
    ("ExplodeY", "FSpaceObject.Roll", 0x1D, "экранный Y взрыва вместо крена"),
    ("SignPhase", "FSpaceObject.Pitch", 0x1E, "знаки центра и фаза вместо команды тангажа"),
    ("Radius", "FSpaceObject.Payload", 0x1F, "радиус взрыва вместо обычной нагрузки объекта")])

files("Text", "HandleSpecialObjectMission", OBJECT,
      reason="#D6AA получает основной слот, сравнивает младший адрес Blueprint и меняет Energy")
files("Text", "CheckObjectRandomGate", {0x27: "FSpaceObject"}, MODEL,
      "InitializeObject передаёт IX=слот и IY=заголовок модели, +27 является байтом сразу за слотом, не полем структуры")
files("Text", "DrawViewFrame", {0: "LeftColumn", 0x1F: "RightColumn"},
      reason="IX временно получает адрес начала пиксельной строки, +0/+31 её крайние байты")
local("Text", "DrawViewFrame", [
    ("LeftColumn", "0", 0, "левый байт текущей 32-байтовой строки растра"),
    ("RightColumn", "31", 31, "правый байт той же строки растра")])


def evaluate(expression, values):
    parts = re.findall(r"[+-]?[^+-]+", expression)
    return sum((-1 if part.startswith("-") else 1) *
               (values[part.lstrip("+-")] if part.lstrip("+-") in values
                else int(part.lstrip("+-"), 0)) for part in parts)


def instruction_text(source):
    lines = []
    for line in source.splitlines():
        code = line.partition(";")[0].strip()
        if code and not re.search(r"\bEQU\b", code, re.I):
            lines.append(re.sub(r"\s+", " ", code))
    return "\n".join(lines)


def main():
    changes, proofs = [], []
    for relative, registers in MAPPINGS.items():
        path = ROOT / relative
        before = path.read_text("utf-8-sig")
        values = dict(SYMBOLS)
        for name, expression, expected, _ in LOCALS.get(relative, []):
            assert evaluate(expression, values) == expected
            values[name] = expected
        output, replacements = [], []
        for number, line in enumerate(before.splitlines(), 1):
            code, separator, comment = line.partition(";")
            def replace(match):
                register, sign, hex_offset = match.groups()
                offset = int(hex_offset, 16) * (-1 if sign == "-" else 1)
                field = registers[register].get(offset)
                if field is None:
                    return match[0]
                assert evaluate(field, values) == abs(offset), (relative, offset, field)
                result = f"({register}{sign}{field})"
                replacements.append((result, match[0]))
                changes.append({"file": relative, "line": number, "before": match[0],
                                "after": result, "offset": offset, "evidence": EVIDENCE[relative]})
                return result
            named = re.sub(r"\((IX|IY)([+-])#([0-9A-Fa-f]+)\)", replace, code)
            if named != code:
                assert len(named.rstrip()) < 80, (relative, named)
                line = named.rstrip().ljust(80) + ";" + comment if separator else named.rstrip()
            output.append(line)
        after = "\n".join(output) + "\n"
        if relative in LOCALS:
            rows = ["                ; смещения описывают исходные данные, память не выделяется"]
            for name, expression, _, comment in LOCALS[relative]:
                if re.search(r"^" + name + r":\s*EQU\b", after, re.M):
                    continue
                code = (name + ":").ljust(16) + "EQU " + expression
                rows.append(code.ljust(80) + "; " + comment)
            if len(rows) > 1:
                # Новые EQU не изменяют позиции уже существующих инструкций.
                after = after.replace("                ; проверка исходного", "\n".join(rows) +
                                      "\n\n                ; проверка исходного", 1)
        if relative.endswith("Text/CheckObjectRandomGate.asm"):
            after = after.replace(";   IX и IY = записи объектов, D061 = часть рейтинга",
                                  ";   IX, основной слот объекта\n;   IY, заголовок модели, переданный InitializeObject\n;   D061, часть рейтинга")
            after = after.replace(";   AND[IY+0A], D61B/D61C отдельное слово CFF8",
                                  ";   AND[IY+0A], где IY+0A содержит маску запусков модели\n;   IX+FSpaceObject читает байт за границей слота, его смысл зависит от положения слота\n;   D61B/D61C отдельное слово CFF8")
        if relative.endswith("Extensions/DrawCompressedEdges.asm"):
            after = after.replace("; EX (SP),IX меняет объект на указатель модели, POP IX восстанавливает объект",
                                  "; EX (SP),IX меняет объект на заголовок модели, ADD IX,DE выбирает блок рёбер\n; До цикла IX+0..3 читаются как два указателя, в цикле IX продвигается по потоку граней\n; IX+4 задаёт текущие грани, IX+5 проверяет следующий байт, FF удерживает указатель\n; POP IX восстанавливает основной объект")
        recovered = after
        for new, old in sorted(set(replacements), key=lambda pair: -len(pair[0])):
            recovered = recovered.replace(new, old)
        before_hash = hashlib.sha256(instruction_text(before).encode()).hexdigest()
        after_hash = hashlib.sha256(instruction_text(recovered).encode()).hexdigest()
        assert before_hash == after_hash, relative
        proofs.append({"file": relative, "before_sha256": before_hash,
                       "after_sha256": after_hash, "equal": True})
        if after != before:
            path.write_text(after, "utf-8")
    report_path = ROOT / "Tools/Disasm/Reports/IndexedFieldNames.json"
    report = json.loads(report_path.read_text("utf-8"))
    report["changes"].extend(changes)
    report["count"] = len(report["changes"])
    report["remaining_phase_proof"] = proofs
    report["remaining_phase_basis"] = "только инструкции и вызывающие участки целевого TRD"
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", "utf-8")
    print(f"Added {len(changes)} indexed names in {len(proofs)} files, total {report['count']}")


if __name__ == "__main__":
    main()
