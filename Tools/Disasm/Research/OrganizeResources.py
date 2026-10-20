"""Однократное выделение доказанных двоичных ресурсов из снимка игры.

Не участвует в сборке. Диапазоны взяты из загрузчика и потребителей ресурсов.
"""

import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
IMAGE = (ROOT / "Tools/Disasm/Research/GameCode.bin").read_bytes()

RESOURCES = [
    (0x4000, 0x5B00, "LoadingScreen", "Loading.scr", [
        "загрузочный экран ZX Spectrum, 6144 байта пикселей и 768 атрибутов",
        "пиксели используют стандартную перестановку строк видеопамяти Spectrum",
        "адрес пиксельного байта равен #4000 + ((y & #C0) << 5)",
        "  + ((y & 7) << 8) + ((y & #38) << 2) + (x >> 3)",
        "атрибут ячейки равен #5800 + (y >> 3) * 32 + (x >> 3)",
        "после запуска область становится рабочим экраном и стеком",
        "загрузчик устанавливает SP = #4120, начало изображения не является кодом",
    ]),
    (0x5B00, 0x5C00, "CockpitAttrs", "CockpitAttributes.bin", [
        "буфер 256 атрибутов нижней трети экрана, восемь строк по 32 ячейки",
        "PrnCockpit по #804B копирует буфер в видеопамять #5A00",
        "SaveCockpitInBuffer по #817E сохраняет текущие атрибуты обратно сюда",
        "поэтому это одновременно исходный ресурс и изменяемый буфер кабины",
        "бит 7 задаёт FLASH, бит 6 BRIGHT, биты 5..3 PAPER, биты 2..0 INK",
    ]),
    (0x5C00, 0x5D70, "SystemShadow", "SystemShadow.bin", [
        "сохранённый участок низкой памяти игры, загружаемый через временную область",
        "загрузчик читает #5C00..#5FFF во временную область #CC00..#CFFF",
        "ExchangeState обменивает обе области перед входом в игру и вызовами TR-DOS",
        "внутри игры эти байты не являются действующими системными переменными BASIC",
        "при входе в TR-DOS обмен возвращает системную область, сохранённую загрузчиком",
        "начальные байты этого участка сохраняются буквально для совпадения образа",
    ]),
    (0xC000, 0xC800, "CockpitPixels", "CockpitPixels.bin", [
        "буфер 2048 пиксельных байтов нижней трети экрана, строки 128..191",
        "это копия страницы видеопамяти #5000..#57FF в порядке строк Spectrum",
        "PrnCockpit переносит сохранённую кабину в экран через LDIR",
        "SaveCockpitInBuffer обновляет копию после изменения приборной панели",
        "атрибуты этой же панели находятся отдельно по адресу #5B00",
        "во время полёта #C000..#CFDF используется уже как буфер вида",
        "ClearScrBuffer создаёт рамку, CopyBuf2Screen выводит 120 строк этого буфера",
    ]),
    (0xC800, 0xD000, "SkippedSectors", "SkippedSectors.bin", [
        "2048 байтов исходного игрового файла, пропускаемых штатным загрузчиком",
        "соответствуют файловым смещениям #8800..#8FFF, это восемь секторов",
        "эти байты не выполняются по адресам #C800..#CFFF",
        "в живой памяти здесь находятся загрузчик, оверлей cl.C и обменная область",
        "ресурс сохраняет содержимое пропущенных секторов для точного возврата в TRD",
    ]),
]


def line(code, comment=None, label=None):
    result = (label + ":").ljust(16) + code if label else " " * 16 + code
    return result.ljust(80) + "; " + comment if comment else result


def main():
    folder = ROOT / "Source/Game/Resources"
    folder.mkdir(exist_ok=True)
    manifest = []
    coverage_path = ROOT / "Tools/Disasm/Reports/SourceCoverage.json"
    coverage = json.loads(coverage_path.read_text("utf-8"))
    include_path = ROOT / "Source/Game/Include.inc"
    includes = include_path.read_text("utf-8")
    for start, end, name, filename, description in RESOURCES:
        data = IMAGE[start - 0x4000:end - 0x4000]
        (folder / filename).write_bytes(data)
        source = [
            line("module Resources"),
            "; -----------------------------------------",
            *(f"; {text}" for text in description),
            "; -----------------------------------------",
            "                ; проверка исходного размещения ресурса",
            line(f"ASSERT $ == #{start:04X}"),
            line(f'INCBIN "{filename}"', label=name),
            "                ; проверка размера ресурса и следующего адреса",
            line(f"ASSERT $ == #{end:04X}"),
            line("endmodule"),
        ]
        (folder / f"{name}.asm").write_text("\n".join(source) + "\n", "utf-8")
        old = f"Data/Block_{start:04X}.asm"
        new = f"Resources/{name}.asm"
        includes = includes.replace(f'"{old}"', f'"{new}"')
        # Удаление только заменённого файла внутри проверенного каталога проекта.
        old_path = ROOT / "Source/Game" / old
        if old_path.exists():
            old_path.unlink()
        for fragment in coverage["fragments"]:
            if fragment["start"] == start:
                fragment["file"] = "Source/Game/" + new
                fragment["status"] = "resource"
                fragment["description"] = description[0]
        manifest.append({
            "start": start, "end": end, "name": name,
            "file": "Source/Game/Resources/" + filename,
            "size": len(data), "sha256": hashlib.sha256(data).hexdigest(),
            "description": description,
        })
    include_path.write_text(includes, "utf-8")
    coverage_path.write_text(json.dumps(coverage, ensure_ascii=False, indent=2) + "\n", "utf-8")
    (ROOT / "Tools/Disasm/Reports/Resources.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", "utf-8")
    print(f"Выделено ресурсов {len(manifest)}, байтов {sum(r['size'] for r in manifest)}")


if __name__ == "__main__":
    main()
