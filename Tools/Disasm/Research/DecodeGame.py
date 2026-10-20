"""Статическое воспроизведение XOR-преобразования исходного загрузчика.

Не эмулятор, не сборка. Формирует материал для анализа, а не снимок запущенной игры.
"""

import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]


def decode(data):
    memory = bytearray(0x4000) + bytearray(data)
    original_rng_code = bytes(memory[0xE063:0xE07A])
    original_seed = bytes(memory[0xDEC0:0xDEC6])
    mutations = []
    attempts = 0
    skipped = []
    mask = 1
    # Восстановление 256 итераций, B изначально равен нулю.
    for iteration in range(256):
        while True:
            attempts += 1
            # Проверка неизменности процедуры, которую моделирует следующий расчёт.
            if bytes(memory[0xE063:0xE07A]) != original_rng_code:
                raise ValueError("Изменён код PRNG, статическая модель более неприменима")
            mask = ((mask >> 1) | (mask << 7)) & 255
            a = int.from_bytes(memory[0xDEC0:0xDEC2], "little")
            b = int.from_bytes(memory[0xDEC2:0xDEC4], "little")
            c = int.from_bytes(memory[0xDEC4:0xDEC6], "little")
            # Расчёт трёхсловного рекуррентного генератора по коду $E063.
            value = (a + b + c) & 0xFFFF
            memory[0xDEC0:0xDEC6] = (b.to_bytes(2, "little") +
                                    c.to_bytes(2, "little") +
                                    value.to_bytes(2, "little"))
            address = value + 0x5B00
            if address < 0x10000:
                break
        # Проверка области работающего загрузчика и временного блока состояния.
        if 0xC800 <= address < 0xD000:
            skipped.append({"iteration": iteration, "address": address})
            continue
        before = memory[address]
        memory[address] ^= mask
        mutations.append({"iteration": iteration, "address": address,
                          "file_offset": address - 0x4000,
                          "mask": mask, "original": before,
                          "decoded": memory[address]})
    final_seed = bytes(memory[0xDEC0:0xDEC6])
    # Восстановление исходных данных PRNG для будущей упаковки исходного файла.
    memory[0xDEC0:0xDEC6] = original_seed
    decoded = bytes(memory[0x4000:])
    # Проверка обратимости всех XOR-операций без вызова ассемблера.
    restored = bytearray(decoded)
    disk_patches = [item for item in mutations
                    if not 0xDEC0 <= item["address"] < 0xDEC6]
    for item in reversed(disk_patches):
        restored[item["file_offset"]] ^= item["mask"]
    if restored != data:
        raise ValueError("Побайтовая обратимость не подтверждена")
    report = {
        "description": "Код после XOR, исходные семена PRNG сохранены. Не снимок RAM.",
        "source_sha256": hashlib.sha256(data).hexdigest(),
        "decoded_sha256": hashlib.sha256(decoded).hexdigest(),
        "accepted_iterations": 256, "prng_calls": attempts,
        "mutation_count": len(mutations),
        "original_seed_hex": original_seed.hex(),
        "runtime_final_seed_hex": final_seed.hex(),
        "skipped": skipped, "mutations": mutations,
        "disk_patches": disk_patches,
    }
    return decoded, report


if __name__ == "__main__":
    source = ROOT / "Tools/Disasm/Extracted/Active/02_ELITE3.C"
    decoded, report = decode(source.read_bytes())
    # Сохранение только материала анализа, исходные файлы образа не изменяются.
    research = ROOT / "Tools/Disasm/Research"
    reports = ROOT / "Tools/Disasm/Reports"
    research.mkdir(exist_ok=True)
    reports.mkdir(exist_ok=True)
    (research / "GameCode.bin").write_bytes(decoded)
    (reports / "GameEncoding.json").write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({key: value for key, value in report.items()
                      if key not in ("mutations", "skipped", "disk_patches")},
                     ensure_ascii=False, indent=2))
