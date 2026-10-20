"""Проверка исходных входов денежных наград и подбора груза.

Исполняются байты GameCode.bin, без сборки, ROM, прерываний и подмены
проверяемых обработчиков. Суммы наград соответствуют контракту DE < 10000.
"""

import hashlib
import json
from pathlib import Path

from ValidateMath import Simulator, A, F, B, D, H, SP, PC, set_word, word
from skoolkit.simutils import IXh, IYh

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD = (ROOT / "Tools/Disasm/Research/GameCode.bin").read_bytes()


def memory_word(memory, address):
    return memory[address] | memory[address + 1] << 8


def store_word(memory, address, value):
    memory[address:address + 2] = [value & 255, value >> 8]


def invoke(sim, entry, de=0, a=0):
    r = sim.registers
    # Подготовка различимых регистров и возврата вне исполняемого обработчика.
    set_word(r, H, 0x1357)
    set_word(r, D, de)
    set_word(r, B, 0x2468)
    set_word(r, IXh, 0x606F)
    set_word(r, IYh, 0x6180)
    r[A], r[F], r[SP], r[PC] = a, 0xA5, 0x411E, entry
    sim.memory[0x411E:0x4120] = [0, 0x40]
    for _ in range(10000):
        sim.run()
        if r[PC] == 0x4000:
            assert r[SP] == 0x4120
            return r
    raise AssertionError(f"Вход #{entry:04X} не вернулся")


def main():
    counts = {"bounty": 0, "illegal_goods": 0, "ordinary_scoop": 0, "special_scoop": 0,
              "message_attribute_fill": 0, "damage_selector": 0}
    # Проверка денежного счёта, события и сохранности рейтинга для всех младших ссылок.
    for link in range(16):
        for amount in (0, 1, 125, 9999):
            for low in (0, 1, 9998, 9999):
                sim = Simulator([0] * 0x4000 + list(PAYLOAD))
                m = sim.memory
                store_word(m, 0xB452, 0xB457)
                m[0xB45F] = 0xA0 | link
                m[0xD060:0xD063] = [0x34, 0x12, 0x56]
                store_word(m, 0xD066, 42)
                store_word(m, 0xD068, low)
                store_word(m, 0xDA77, 0x7654)
                m[0xD0C5] = 3
                r = invoke(sim, 0x7DA4, de=amount)
                paid = link == 0 and amount != 0
                total = low + amount if paid else low
                assert memory_word(m, 0xD066) == 42 + total // 10000
                assert memory_word(m, 0xD068) == total % 10000
                assert m[0xD060:0xD063] == [0x34, 0x12, 0x56]
                assert memory_word(m, 0xDA77) == (amount if paid else 0x7654)
                assert m[0xD0C5] == (0x83 if paid else 3)
                assert word(r, B) == 0x2468
                assert word(r, IXh) == 0x606F and word(r, IYh) == 0x6180
                assert word(r, D) == ((1 if total >= 10000 else 10000) if paid else amount)
                counts["bounty"] += 1

    # Проверка насыщения legal status только для рабов и наркотиков.
    for goods in range(17):
        for legal in (0, 1, 253, 254, 255):
            sim = Simulator([0] * 0x4000 + list(PAYLOAD))
            sim.memory[0xD05F] = legal
            r = invoke(sim, 0xD1B5, de=0x4567, a=goods)
            assert sim.memory[0xD05F] == (min(legal + 2, 255) if goods in (3, 6) else legal)
            assert word(r, D) == 0x4567 and word(r, B) == 0x2468
            counts["illegal_goods"] += 1

    # Проверка обычного подбора, включая минералы при уже заданной колонии.
    for goods in range(17):
        sim = Simulator([0] * 0x4000 + list(PAYLOAD))
        m = sim.memory
        m[0xD06B:0xD07C] = [2] * 17
        m[0xD07C], m[0xD087], m[0xD05F] = 20, 1, 0
        m[0x606F + 0x26] = 0
        r = invoke(sim, 0xD190, de=0x4567, a=goods)
        expected = [2] * 17
        expected[goods] += 1
        assert m[0xD06B:0xD07C] == expected and m[0xD07C] == 19
        assert m[0xD0C7:0xD0C9] == [0x8B, 0xD0 + goods]
        assert m[0xD05F] == (2 if goods in (3, 6) else 0)
        assert word(r, D) == 0x4567 and word(r, B) == 0x2468
        counts["ordinary_scoop"] += 1

    # Проверка двух специальных ветвей, которые не расходуют обычное место трюма.
    for item, flags, token in ((0xFF, 0, 0x7D), (0, 0x80, 0xF3)):
        sim = Simulator([0] * 0x4000 + list(PAYLOAD))
        m = sim.memory
        m[0xD06B:0xD07C] = [2] * 17
        m[0xD07C], m[0xD086], m[0xD0B0], m[0xD05F] = 20, 4, 1, 0
        m[0x606F + 0x26] = flags
        invoke(sim, 0xD190, a=item)
        assert m[0xD06B:0xD07C] == [2] * 17 and m[0xD07C] == 20
        assert m[0xD0C7:0xD0C9] == [0x8B, token] and m[0xD05F] == 0
        assert m[0xD086] == (4 if item == 0xFF else 5)
        assert m[0xD0B0] == (0x41 if item == 0xFF else 1)
        counts["special_scoop"] += 1

    # Проверка точного диапазона записи исходного цикла заполнения окна сообщения.
    sim = Simulator([0] * 0x4000 + list(PAYLOAD))
    sim.memory[0x5800:0x5B00] = [0xEE] * 768
    set_word(sim.registers, H, 0x5820)
    set_word(sim.registers, B, 0x02E0)
    set_word(sim.registers, D, 0x590F)
    sim.registers[PC] = 0xD177
    for _ in range(3000):
        sim.run()
        if sim.registers[PC] == 0xD17F:
            break
    else:
        raise AssertionError("Цикл атрибутов #D177 не завершился")
    assert sim.memory[0x5800:0x5820] == [0xEE] * 32
    assert sim.memory[0x5820:0x5A00] == [0x0F] * 480
    assert sim.memory[0x5A00:0x5B00] == [0xEE] * 256
    assert word(sim.registers, H) == 0x5A00 and word(sim.registers, B) == 0
    counts["message_attribute_fill"] = 1

    # Проверка всех значений параметра выбора повреждения на оборудованном корабле.
    devices = (0xD085, 0xD088, 0xD089, 0xD08A, 0xD08B, 0xD08C)
    for parameter in range(256):
        sim = Simulator([0] * 0x4000 + list(PAYLOAD))
        m = sim.memory
        m[0xDA76], m[0x7105], m[0x70E3], m[0xD082], m[0xD07C] = 0, parameter, 0, 70, 10
        m[0xD06B:0xD07C] = [5] * 17
        for address in devices:
            m[address] = 1
        m[0xD0C3], m[0xD0CF], m[0xDA79] = 0, 0, 0
        invoke(sim, 0xD1E9)
        index = parameter >> 2
        expected_cargo = [5] * 17
        expected_devices = [1] * 6
        if 1 <= index <= 6:
            expected_devices[index - 1] = 0x82
        if 7 <= index <= 16:
            expected_cargo[index - 5] -= 1
        assert m[0xD06B:0xD07C] == expected_cargo
        assert [m[a] for a in devices] == expected_devices
        assert m[0xD082] == (0 if index == 0 else 70)
        assert m[0xD07C] == (11 if 7 <= index <= 16 else 10)
        assert m[0xD0C3] == (0x80 if 1 <= index <= 16 else 0)
        assert m[0xD0CF] == (0x80 if index == 0 else 0)
        counts["damage_selector"] += 1

    report = {
        "source_sha256": hashlib.sha256(PAYLOAD).hexdigest(),
        "method": "SkoolKit 10.1 Simulator, исходные инструкции Z80 без подмены обработчиков",
        "scope": "#7DA4 -> #D0E7 -> #D1D9, #D190, #D1B5, #D1E9 и цикл #D177..#D17E, без ROM и прерываний",
        "passed": counts,
        "conclusions": [
            "#7DA4 начисляет денежную награду в десятых кредита, рейтинг не изменяется",
            "Выплата сохраняет BC, IX, IY, но меняет DE",
            "#D1AD только ставит уведомление, обычный слот груза увеличивается до этого входа",
            "Специальные предметы #FF и Flags2.7 не уменьшают FreeCargo",
            "Цикл #D177 записывает 480 атрибутов по #5820..#59FF",
            "#D1E9 выбирает категорию повреждения по #7105 >> 2, без вызова генератора"
        ]
    }
    (ROOT / "Tools/Disasm/Reports/MissionRewardsValidation.json").write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n", "utf-8")
    print(json.dumps(counts))


if __name__ == "__main__":
    main()
