"""Привязка проверенных индексных обращений к структурам исходного образа.

Это материал разбора, сборка его не запускает. Для каждого файла и регистра
основание указателя проверяется отдельно. Числовое смещение сверяется перед
заменой, сами инструкции, размещение памяти и значения байтов не изменяются.
"""

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SYMBOLS = {}
for line in (ROOT / "Tmp/ELITE3HL.sym").read_text().splitlines():
    match = re.fullmatch(r"([^:]+): EQU 0x([0-9a-fA-F]+)", line)
    if match:
        SYMBOLS[match[1]] = int(match[2], 16)
SYMBOLS.update({"FSignWord": 2, "FSignWord.Low": 0, "FSignWord.SignHigh": 1,
                "FVector3": 3, "FVector3.X": 0, "FVector3.Y": 1, "FVector3.Z": 2,
                "FMatrix3": 18})
for row, axis in enumerate("XYZ"):
    for column, component in enumerate("XYZ"):
        SYMBOLS[f"FMatrix3.{axis}.{component}"] = 6 * row + 2 * column


def layout(prefix, fields):
    """Имена подтверждённых байтов одного формата, включая старшие байты слов."""
    return {offset: prefix + "." + name for offset, name in fields.items()}


COORD = layout("FCoordinate", {0: "Fraction", 1: "Low", 2: "SignHigh"})
WORD = layout("FSignWord", {0: "Low", 1: "SignHigh"})
VECTOR = layout("FVector3", dict(enumerate(("X", "Y", "Z"))))
AXIS = {offset: "FAxis." + "XYZ"[offset // 2] + "+FSignWord." +
        ("SignHigh" if offset % 2 else "Low") for offset in range(6)}
OBJECT = {}
for axis_number, axis_name in enumerate("XYZ"):
    for offset, field in COORD.items():
        OBJECT[3 * axis_number + offset] = "FSpaceObject." + axis_name + "." + field.split(".")[1]
    for offset, field in AXIS.items():
        OBJECT[9 + 6 * axis_number + offset] = "FSpaceObject.Axis" + axis_name + "." + field[6:]
OBJECT.update(layout("FSpaceObject", {
    0x1B: "Speed", 0x1C: "Acceleration", 0x1D: "Roll", 0x1E: "Pitch",
    0x1F: "Payload", 0x20: "Flags", 0x21: "Hostility", 0x22: "Energy",
    0x23: "Blueprint", 0x24: "Blueprint+FSignWord.SignHigh", 0x25: "Target", 0x26: "Flags2"}))
MODEL = layout("FModel", {0: "Cargo", 1: "Collision", 2: "LaserChance", 3: "VertexCount",
    4: "EdgeCount", 5: "NormalCount", 6: "MaxSpeed", 7: "MaxEnergy", 8: "Bounty",
    9: "Bounty+FSignWord.SignHigh", 10: "LaunchMask", 11: "DotDistance", 12: "Vertices",
    13: "Vertices+FSignWord.SignHigh", 14: "Edges", 15: "Edges+FSignWord.SignHigh",
    16: "Normals", 17: "Normals+FSignWord.SignHigh", 18: "Flags", 19: "NormalScale",
    20: "LaserVertex", 21: "Rating", 22: "Rating+FSignWord.SignHigh"})
EFFECT = layout("FEffectRecord10", dict(enumerate(("TypeFlags", "FirstFlags", "FirstX", "FirstY",
    "SecondFlags", "SecondX", "SecondY", "Timer", "Links", "Fallback"))))
MATRIX = {6 * row + offset: "FMatrix3." + axis + "." + field[6:]
          for row, axis in enumerate("XYZ") for offset, field in AXIS.items()}
CACHE = {18 + offset: "FMatrix3+" + field for offset, field in AXIS.items()}
MAPPINGS = {}


def files(category, names, ix=None, iy=None):
    for name in names.split():
        MAPPINGS[f"Source/Game/{category}/{name}.asm"] = {"IX": ix or {}, "IY": iy or {}}


# В этих боевых процедурах IX сохраняет начало текущего объектного слота.
files("Combat", "CreatePlayerWreckScene FirePlayerLaser HandleObjectCollision "
      "InitializeSpawnedObjectLinks SetObjectEnergyAndDrawMissedLaser UpdateAllSpaceObjects", OBJECT, MODEL)
files("Combat", "ReleaseMissileTargets", iy=OBJECT)

# Общие процедуры движения различают объект, отдельную координату и слово оси.
files("Motion", "AdvanceObjectAlongLocalAxis AnimateIntroObject CheckObjectBoxAndChooseCourse "
      "ProcessObjectEnergyAndTactics ProjectObjectAndSelectDetail SteerObjectAndTryLaser "
      "UpdateObjectCoordinatesAndRotation ApplyPlayerMotionToObject", OBJECT, MODEL)
files("Motion", "GuideMissileAndCheckImpact", OBJECT, OBJECT)
files("Motion", "AddScaledCoordinate QuarterCoordinateDifference", COORD, COORD)
files("Motion", "NegatedQuarterCoordinate QuarterCoordinate TransformNormalWithObjectCoordinate", COORD)
files("Motion", "DotProductAxisHighBytes", AXIS, AXIS)
files("Motion", "RenormalizeAxisHighBytes RotateAxisByPlayer", AXIS)
files("Motion", "DivideVectorComponent ScaleAxisHighByte SquareVectorComponent", WORD)
files("Motion", "AdvanceOneCoordinate", {
    9: "FSpaceObject.AxisX+FSignWord.Low", 10: "FSpaceObject.AxisX+FSignWord.SignHigh"}, COORD)
files("Motion", "RotateBasisByObject", {
    10: "FSpaceObject.AxisX+FSignWord.SignHigh", 16: "FSpaceObject.AxisY+FSignWord.SignHigh",
    22: "FSpaceObject.AxisZ+FSignWord.SignHigh"})

# Создание и обход объектов сохраняют объектную базу даже при выборе нового слота.
files("Objects", "FindFreeObjectSlot GenerateSpaceTraffic InitializeAtPlayer InitializeIntroModel "
      "InitializeObject RandomizeSpawnDirection RotateSpawnAxisComponent SpawnEscapePod SpawnMissile "
      "SpawnPlayerDebris SpawnShipCargoOrPod SpawnShipDebris SpawnThargonWave", OBJECT, MODEL)
files("Objects", "SpawnShipClass", OBJECT, OBJECT)
files("Objects", "ComputeFaceVisibility", MODEL, MODEL)
files("Objects", "DotProduct16By8", VECTOR, AXIS)

# В преобразовании различаются матрица целиком, её строка и кэш этой строки.
files("Wireframe", "BuildObjectRotationMatrix", OBJECT, MATRIX)
files("Wireframe", "BuildProjectedVertexTable LocateFaceNormalData LocateVertexCoordinateData", MODEL, MODEL)
files("Wireframe", "CorrectYAxisComponent", WORD, WORD)
files("Wireframe", "DivideFractionAndProjectVertex", OBJECT)
files("Wireframe", "DivideSlopeAndDrawScanner DrawWireframeObject FinishObjectAndDrawLaser "
      "ReadObjectTacticsGates StartObjectExplosion", OBJECT, MODEL)
files("Wireframe", "MultiplyScaledVertexComponent", iy=WORD)
files("Wireframe", "RotateCoordinateAndCacheProducts", VECTOR, AXIS | CACHE)
files("Wireframe", "SumCachedVertexProducts", iy=CACHE)
files("Wireframe", "RotateNearVertexComponent", VECTOR,
      WORD | CACHE | {18: "FMatrix3+FSignWord.Low", 19: "FMatrix3+FSignWord.SignHigh"})


def evaluate(expression):
    return sum(SYMBOLS[part] if part in SYMBOLS else int(part, 0) for part in expression.split("+"))


def main():
    # Проверка числового равенства всех выбранных имён до изменения исходников.
    for registers in MAPPINGS.values():
        for fields in registers.values():
            for offset, field in fields.items():
                assert evaluate(field) == offset, (offset, field)
    report_path = ROOT / "Tools/Disasm/Reports/IndexedFieldNames.json"
    report = json.loads(report_path.read_text("utf-8")) if report_path.exists() else {"changes": []}
    changes = []
    for relative, registers in MAPPINGS.items():
        path = ROOT / relative
        before = path.read_text("utf-8")
        output = []
        for number, line in enumerate(before.splitlines(), 1):
            code, separator, comment = line.partition(";")
            def replace(match):
                register, hex_offset = match.groups()
                offset = int(hex_offset, 16)
                fields = registers[register]
                # Проверка смены основания IX, до извлечения со стека это вершина.
                if relative.endswith("/DivideFractionAndProjectVertex.asm") and register == "IX":
                    first_object_line = next(i for i, value in enumerate(before.splitlines(), 1)
                                             if "EX (SP),IX" in value.split(";")[0])
                    fields = VECTOR if number < first_object_line else OBJECT
                field = fields.get(offset)
                if field is None:
                    return match[0]
                result = f"({register}+{field})"
                changes.append({"file": relative, "line": number, "before": match[0], "after": result,
                                "offset": offset})
                return result
            named = re.sub(r"\((IX|IY)\+#([0-9A-Fa-f]+)\)", replace, code)
            if named != code:
                line = named.rstrip().ljust(80) + ";" + comment if separator else named.rstrip()
            output.append(line)
        after = "\n".join(output) + "\n"
        if after != before:
            path.write_text(after, "utf-8")
    report["changes"].extend(changes)
    report["count"] = len(report["changes"])
    report["purpose"] = "проверенные базы IX/IY и равные числовые смещения, без перемещения памяти"
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", "utf-8")
    print(f"New indexed names: {len(changes)}, total: {report['count']}")


if __name__ == "__main__":
    main()
