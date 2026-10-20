"""Проверка сохранённого пути копирования на байтах конкретного ELITE3HL.TRD.

Ассемблер и генераторы исходников не вызываются. Исполняются инструкции из
03_cl.C и GameCode.bin. Внешние операции печати, ожидания клавиши и TR-DOS ROM
заменяются явно ограниченными моделями. Это проверка адресации и преобразования,
а не проверка контроллера, защиты физической дискеты или рабочего копировщика.
"""

import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "Tools/Disasm/Research/vendor/skoolkit-10.1"))
sys.path.insert(0, str(ROOT / "Tools/Disasm"))
from skoolkit.simulator import Simulator
from skoolkit.simutils import A, F, B, C, D, E, H, L, IYh, SP, PC, IFF
from InspectZ80 import decoder


def sha(data):
    return hashlib.sha256(bytes(data)).hexdigest()


def word(registers, high):
    return registers[high] * 256 + registers[high + 1]


def set_word(registers, high, value):
    registers[high], registers[high + 1] = value >> 8, value & 255


def pop(simulator):
    registers, memory = simulator.registers, simulator.memory
    stack = registers[SP]
    value = memory[stack] + 256 * memory[(stack + 1) & 65535]
    registers[SP] = (stack + 2) & 65535
    return value


def snapshot(simulator):
    registers = simulator.registers
    return {
        "HL": f"{word(registers, H):04X}",
        "DE": f"{word(registers, D):04X}",
        "BC": f"{word(registers, B):04X}",
        "AF": f"{word(registers, A):04X}",
        "IY": f"{word(registers, IYh):04X}",
        "SP": f"{registers[SP]:04X}",
        "PC": f"{registers[PC]:04X}",
        "IFF": registers[IFF],
    }


def execute(game, overlay, disk, key, entry=0xCF9C, measurement=None):
    memory = [0] * 0x4000 + list(game)
    memory[0xC800:0xD000] = overlay[:0x800]
    simulator = Simulator(memory)
    registers = simulator.registers
    registers[SP], registers[PC] = 0x411A, entry
    memory[0x411A:0x411C] = [0, 0x40]
    set_word(registers, D, 0x1234)
    set_word(registers, B, 0xABCD)
    ports, reads, rom_calls = [], [], []
    control, cylinder, sector, pending = None, None, None, None
    for count in range(50000):
        address = registers[PC]
        # Подмена печати и ввода не касается памяти загрузчика и буфера секторов.
        if address in (0xD48E, 0xCC26):
            if address == 0xCC26:
                registers[A] = key
            registers[PC] = pop(simulator)
            continue
        # Для отдельной проверки CheckMark перебирается весь выходной байт
        # измерителя. SPACE считается отпущенной, звуковой сигнал пропускается.
        if measurement is not None and address in (0xC92A, 0xCA2D, 0xCC30):
            if address == 0xC92A:
                set_word(registers, D, measurement * 256)
            registers[PC] = pop(simulator)
            continue
        # Исполнены настоящие D956/D964/D967 вплоть до переключения ПЗУ.
        # С вершины стека берётся фактический адрес процедуры TR-DOS.
        if address == 0x3D2F:
            target = pop(simulator)
            rom_calls.append(f"{target:04X}")
            if target == 0x20B8:
                port, value = registers[C], registers[D]
                ports.append({"port": f"{port:02X}", "value": f"{value:02X}"})
                if port == 0xFF:
                    control = value
                elif port == 0x7F:
                    cylinder = value
                elif port == 0x5F:
                    sector = value
                elif port == 0x1F:
                    pending = value
                else:
                    raise AssertionError(f"Непредусмотренный порт {port:02X}")
                registers[B] = 0
            elif target == 0x3FE5:
                if pending == 0x84:
                    assert control is not None and cylinder is not None
                    assert control & 3 == 0 and sector in (1, 2, 3)
                    # Обратное отображение исходного SelectTrack.
                    # Значение #3C выбирает чётную логическую дорожку.
                    track = cylinder * 2 + (0 if control & 0x10 else 1)
                    source = (track * 16 + sector - 1) * 256
                    destination = word(registers, H)
                    block = disk[source:source + 256]
                    assert len(block) == 256
                    memory[destination:destination + 256] = block
                    reads.append({
                        "logical_track": f"{track:02X}",
                        "sector_id": sector,
                        "trd_offset": f"{source:05X}",
                        "destination": f"{destination:04X}",
                        "length": 256,
                        "sha256": sha(block),
                    })
                    set_word(registers, H, destination + 256)
                else:
                    assert pending in (0x18, 0x58) and word(registers, H) == 0
                pending = None
            else:
                raise AssertionError(f"Непредусмотренный адрес ROM {target:04X}")
            registers[PC] = pop(simulator)
            continue
        if address in (0x4000, 0xC500):
            break
        simulator.run()
    else:
        raise AssertionError("Путь подтверждения не завершился за 50000 шагов")
    return simulator, {
        "key": chr(key),
        "instructions_and_hooks": count,
        "state": snapshot(simulator),
        "port_writes": ports,
        "rom_calls": rom_calls,
        "reads": reads,
    }


def main():
    manifest = json.loads((ROOT / "Tools/Disasm/Disk/manifest.json").read_text("utf-8"))
    disk = Path(manifest["source"]).read_bytes()
    game = (ROOT / "Tools/Disasm/Research/GameCode.bin").read_bytes()
    overlay = (ROOT / "Tools/Disasm/Extracted/Active/03_cl.C").read_bytes()
    assert sha(disk) == manifest["image_sha256"]
    game_entry = next(item for item in manifest["files"]
                      if item["filename"] == "02_ELITE3.C")
    raw = disk[0xE000:0xE300]
    source_offset = 0xE000 - game_entry["disk_offset"]
    assert source_offset == 0x8C00
    assert raw == (ROOT / "Tools/Disasm/Extracted/Active/02_ELITE3.C").read_bytes()[0x8C00:0x8F00]
    table = game[0xBE00 - 0x4000:0xBF00 - 0x4000]
    assert table == bytes((index * index) & 255 for index in range(256))
    expected = bytes(
        ((((value + table[2 * index & 255]) & 255)
          ^ table[(2 * index + 1) & 255])
         - table[(2 * index + 2) & 255]) & 255
        for index, value in enumerate(raw)
    )
    cases = []
    for key in (ord("N"), ord(" ")):
        simulator, report = execute(game, overlay, disk, key)
        assert simulator.registers[PC] == 0x4000 and not report["reads"]
        cases.append(report)
    simulator, report = execute(game, overlay, disk, ord("Y"))
    assert simulator.registers[PC] == 0xC500
    assert bytes(simulator.memory[0xC500:0xC800]) == expected
    assert [item["sector_id"] for item in report["reads"]] == [3, 2, 1]
    assert bytes(simulator.memory[0xCF9A:0xCF9C]) == b"\x34\x12"
    assert simulator.memory[0xCA34] == simulator.memory[0xD975] == 0xC9
    assert bytes(simulator.memory[0xCDB7:0xCDB9]) == b"\xCE\x00"
    assert word(simulator.registers, H) == 0xE000
    assert word(simulator.registers, D) == 0xC800
    assert word(simulator.registers, IYh) == 0x5900
    cases.append(report)
    existing = ROOT / "Tools/Disasm/Research/DiskUtilityCopyStage.bin"
    assert existing.read_bytes() == expected

    # Наблюдение первых инструкций фактически полученного буфера до первого
    # выхода из него. Это не классификация этих байтов как самостоятельного кода.
    trace = []
    for _ in range(64):
        address = simulator.registers[PC]
        if not 0xC500 <= address < 0xC800:
            break
        instruction = decoder(simulator.memory).disassemble(address, address + 1, "h")[0]
        trace.append({
            "address": f"{address:04X}",
            "hex": instruction.bytes.hex(),
            "instruction": instruction.operation,
        })
        simulator.run()
    assert simulator.registers[PC] == 0xDF00

    # Проверка служебного сектора не зависит от неизвестного физического
    # измерения, если уже первое контрольное равенство отвергает его данные.
    # Перебор D исчерпывающий, оба прохода используют одно и то же значение.
    mark_results = []
    for measurement in range(256):
        mark_simulator, mark_report = execute(
            game, overlay, disk, 0, entry=0xC9D8, measurement=measurement)
        assert mark_simulator.registers[PC] == 0x4000
        assert word(mark_simulator.registers, D) == 0
        assert mark_simulator.registers[F] & 1
        assert len(mark_report["reads"]) == 2
        assert all(item["trd_offset"] == "0D000" for item in mark_report["reads"])
        if measurement == 0x7E:
            assert bytes(mark_simulator.memory[0x606F:0x6073]) == b"\x90\x3A\x19\xF6"
        mark_results.append(measurement)

    # Прямые CALL/JP на CF1E проверяются по всем байтовым позициям образов.
    # Отсутствие этих последовательностей не исключает косвенного вызова.
    byte_scan = []
    jump_opcodes = (0xC3, 0xC2, 0xCA, 0xD2, 0xDA, 0xE2, 0xEA, 0xF2, 0xFA,
                    0xCD, 0xC4, 0xCC, 0xD4, 0xDC, 0xE4, 0xEC, 0xF4, 0xFC)
    for name, data in (("GameCode.bin", game), ("03_cl.C", overlay),
                       ("01_ELITE3.B", (ROOT / "Tools/Disasm/Extracted/Active/01_ELITE3.B").read_bytes()),
                       ("00_ELITE3HL.B", (ROOT / "Tools/Disasm/Extracted/Active/00_ELITE3HL.B").read_bytes())):
        for index in range(len(data) - 2):
            if data[index] in jump_opcodes and data[index + 1:index + 3] == b"\x1E\xCF":
                byte_scan.append({"file": name, "offset": f"{index:04X}",
                                  "hex": data[index:index + 3].hex()})
    static_map = json.loads((ROOT / "Tools/Disasm/Reports/DiskUtilityStaticMap.json").read_text("utf-8"))
    relative_scan = []
    for segment in static_map:
        for item in segment["records"]:
            instruction = item.get("instruction") or ""
            if re.match(r"^(JR|DJNZ) (?:[A-Z]+,)?#CF1E$", instruction):
                relative_scan.append(item)
    assert byte_scan == [] and relative_scan == []
    result = {
        "subject": "Сохранённый маршрут CF9C, фактические сектора ELITE3HL.TRD",
        "source_sha256": {"trd": sha(disk), "game": sha(game), "cl": sha(overlay)},
        "method": "SkoolKit 10.1 Simulator, исходные инструкции до RET→C500",
        "limitations": [
            "D48E печать и CC26 ввод клавиши заменены возвратом и заданной клавишей",
            "ПЗУ 20B8 и 3FE5 заменено моделью портов и успешной передачи 256 байт",
            "Проверка физической защиты, ПЗУ, FDC, прерывания и контенция не исполнялись",
            "CF9C запущен непосредственно, достижимость из обычного меню не утверждается",
            "Не устанавливается содержимое иного диска, который мог быть вставлен пользователем",
            "В проверке C9D8 измерение C92A задано явно, SPACE отпущена, звук пропущен",
        ],
        "cases": cases,
        "source_mapping": {
            "trd": "E000..E2FF",
            "file": "02_ELITE3.C",
            "file_offset": "8C00..8EFF",
            "game_snapshot_addresses": "CC00..CEFF",
            "destination": "C500..C7FF",
            "controller_select_byte": "3C",
            "drive_select_bits_1_0": 0,
            "cylinder": 7,
            "side_select_bit_4": 1,
        },
        "transform": {
            "count": 768,
            "table": "BE00..BEFF, T[j] = j*j mod 256",
            "formula": "out[i] = (((raw[i] + T[2*i mod 256]) mod 256) XOR T[(2*i+1) mod 256]) - T[(2*i+2) mod 256] mod 256",
            "raw_sha256": sha(raw),
            "decoded_sha256": sha(expected),
            "raw_prefix": raw[:32].hex(" "),
            "decoded_prefix": expected[:32].hex(" "),
            "matches_independent_formula": True,
            "matches_DiskUtilityCopyStage_bin": True,
        },
        "entry_search": {
            "target": "CF1E",
            "absolute_CALL_JP_byte_pattern_matches": byte_scan,
            "relative_JR_DJNZ_in_overlay_map": relative_scan,
            "normal_menu": "CB1E выбирает LOAD/SAVE/DEMO, прямого перехода к CF1E нет",
            "limit": "косвенный либо внешний вход не исключён",
        },
        "copy_menu_context": {
            "CF1E": "Вызывает C9D8, сохраняет возвращённый DE на стеке, печатает поля служебной метки",
            "CF7A": "POP AF восстанавливает сохранённый BC в AF, POP DE возвращает результат C9D8",
            "CF7D": "JP Z,CD9A обрабатывает сохранённый B=0",
            "CF80": "LD A,D и OR A проверяют старший байт возвращённой метки",
            "CF82": "JR NZ,CF9C открывает подтверждение только при D != 0",
            "current_image": "C9D8 возвращает DE=0, поэтому CF82 не передаёт управление CF9C",
            "carrier": "SelectTrack всегда устанавливает младшие биты порта FF в 0, носитель выбирается устройством A",
            "limit": "Пользователь мог физически заменить дискету, её содержимое данным TRD не задано",
        },
        "service_mark_check": {
            "source": "TRD D000..D0FF, логическая дорожка 0D, сектор 1",
            "entry": "C9D8",
            "measurement_values_tested": len(mark_results),
            "all_returned": "DE=0000, C=1, две попытки",
            "stored_measurement": "7E по адресу 6161 после чтения",
            "timing_gate": "Только D=7C..80 проходит модульную проверку |7E-D|<3",
            "decode_parameters": "После допуска D=E=7E независимо от измерителя",
            "first_two_decoded_words": ["3A90", "F619"],
            "first_check_difference": "3A90+1-F619 = 4478 mod 65536",
            "conclusion": "Исходные данные этого TRD отвергаются независимо от измерения D",
        },
        "self_modification": [
            {"address": "CF9A..CF9B", "action": "Сохранение входного DE"},
            {"address": "CA34", "action": "LD SP,nn заменяется RET, отмена по SPACE больше не разворачивает стек"},
            {"address": "D975", "action": "Начало очистки атрибутов заменяется RET"},
            {"address": "CDB7..CDB8", "action": "LD A,01 заменяется ADC A,00 после LD A,10, номер проверочного сектора становится 10 либо 11 по C"},
        ],
        "candidate_initial_execution": {
            "trace": trace,
            "state_after_first_exit": snapshot(simulator),
            "observation": "По C514 выполняется RETI, снимающий DF00 с вершины стека",
            "meaning": "Это наблюдение не подтверждает существование работоспособного копировщика",
        },
        "conclusion": (
            "Адреса чтения, порядок секторов, 768 преобразований и RET→C500 подтверждены. "
            "В этих секторах данного TRD самостоятельная программа копирования не установлена. "
            "Новый исходник HiddenCopier не создаётся, оригинальные данные сохраняются."
        ),
        "hardware_reference": {
            "url": "https://k1.spdns.de/Develop/Projects/zxsp/Info/nocash%20Sinclair%20ZX%20Specs.html",
            "section": "FFh - Beta Disk Control",
            "used_claim": "Биты 1..0 выбирают устройство 0..3, соответствующее A..D",
            "source_facts": "SelectTrack пишет 3C либо 2C, оба значения выбирают устройство 0",
        },
    }
    (ROOT / "Tools/Disasm/Reports/HiddenCopyPath.json").write_text(
        json.dumps(result, ensure_ascii=False, indent=2) + "\n", "utf-8")
    print(json.dumps({
        "cases": len(cases), "transformed_bytes": len(expected),
        "reads": report["reads"], "payload_first_exit": snapshot(simulator),
        "absolute_calls_to_CF1E": len(byte_scan),
        "service_mark_measurements_rejected": len(mark_results),
    }, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
