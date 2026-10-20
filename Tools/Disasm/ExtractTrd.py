"""Извлечение TR-DOS-файлов без изменения исходного образа и без сборки."""

import argparse
import hashlib
import json
from pathlib import Path


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def extract(source, destination):
    # Проверка геометрии исходного диска.
    disk = source.read_bytes()
    if len(disk) != 655360:
        raise ValueError("Ожидался образ TRD размером 655360 байт")
    if disk[0x8E7] != 0x10:
        raise ValueError("Не найден служебный признак TR-DOS")
    records = []
    occupied = set(range(16))
    outputs = {"Disk/original.trd": disk,
               "Disk/track00.bin": disk[:4096]}
    # Поиск занятых записей каталога и сохранение исходных секторных данных.
    for index in range(128):
        entry = disk[index * 16:(index + 1) * 16]
        if entry[0] == 0:
            continue
        if entry[0] == 1:
            raise ValueError("Удалённая запись требует отдельного разбора")
        name = entry[:8].decode("ascii").rstrip()
        extension = chr(entry[8])
        if any(c not in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-"
               for c in name + extension):
            raise ValueError("Небезопасное имя в каталоге")
        length = int.from_bytes(entry[11:13], "little")
        count = entry[13]
        sector = entry[14]
        track = entry[15]
        # Расчёт абсолютного смещения из линейной дорожки и сектора.
        first = track * 16 + sector
        last = first + count
        if sector >= 16 or last > 2560 or length > count * 256:
            raise ValueError("Недопустимая область файла")
        if occupied.intersection(range(first, last)):
            raise ValueError("Области файлов пересекаются")
        occupied.update(range(first, last))
        allocated = disk[first * 256:last * 256]
        payload = allocated[:length]
        filename = f"{index:02d}_{name}.{extension}"
        outputs[f"Extracted/Active/{filename}"] = payload
        outputs[f"Extracted/Active/{filename}.sectors.bin"] = allocated
        outputs[f"Extracted/Active/{filename}.tail.bin"] = allocated[length:]
        records.append({
            "index": index, "filename": filename, "name": name,
            "extension": extension, "directory_hex": entry.hex(),
            "parameter": int.from_bytes(entry[9:11], "little"),
            "length": length, "allocated_length": len(allocated),
            "sector_count": count, "first_sector": sector, "first_track": track,
            "disk_offset": first * 256, "sha256": sha256(payload),
            "allocated_sha256": sha256(allocated),
            "tail_length": len(allocated) - length,
            "tail_prefix_hex": allocated[length:length + 16].hex(),
        })
    # Проверка согласованности служебного сектора и каталога.
    if len(records) != disk[0x8E4]:
        raise ValueError("Число файлов не совпадает со служебным сектором")
    first_free = disk[0x8E2] * 16 + disk[0x8E1]
    if occupied != set(range(first_free)):
        raise ValueError("Файлы образуют неплотную область, требуется отдельный разбор")
    outputs["Disk/unallocated.bin"] = disk[first_free * 256:]
    # Сохранение ссылки на исходный образ относительно папки манифеста Disk.
    manifest = {
        "source": "original.trd", "image_length": len(disk),
        "image_sha256": sha256(disk), "disk_type": disk[0x8E3],
        "disk_label": disk[0x8F5:0x8FD].decode("ascii"),
        "first_free_absolute_sector": first_free,
        "free_sector_count": int.from_bytes(disk[0x8E5:0x8E7], "little"),
        "files": records,
    }
    # Проверка существующих результатов до записи, чтобы сохранить ручные правки.
    for relative, data in outputs.items():
        path = destination / relative
        if path.exists() and path.read_bytes() != data:
            raise ValueError(f"Отказ от перезаписи изменённого файла {path}")
    # Сохранение точных копий и независимая проверка чтением с диска.
    for relative, data in outputs.items():
        path = destination / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        if not path.exists():
            path.write_bytes(data)
        if path.read_bytes() != data:
            raise ValueError(f"Ошибка проверки {path}")
    manifest_path = destination / "Disk/manifest.json"
    manifest_text = json.dumps(manifest, ensure_ascii=False, indent=2) + "\n"
    if manifest_path.exists() and manifest_path.read_text("utf-8") != manifest_text:
        raise ValueError("Отказ от перезаписи изменённого Manifest.json")
    manifest_path.write_text(manifest_text, encoding="utf-8")
    print(json.dumps(manifest, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("--output", type=Path, default=Path(__file__).resolve().parent)
    args = parser.parse_args()
    extract(args.source, args.output)
