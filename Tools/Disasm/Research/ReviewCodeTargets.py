"""Фиксация вручную проверенных перекрывающихся входов.

Основания проверены по байтам и вызывающим участкам именно ELITE3HL.
Этот инструмент оформляет результаты проверки, а не выводит смысл из адреса.
"""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
EXPLANATIONS = {
    0x83FE: (
        "Байты 21 10 2E образуют LD HL,#2E10. Продолжение #8401 исполняет "
        "07 как RLCA, затем LD H,#71 выбирает координаты планеты #7110. "
        "RLCA не влияет на дальнейший результат, A затем загружается заново."),
    0x8400: (
        "Байты 2E 07 образуют LD L,#07. Вместе с LD H,#71 по #8402 выбирается "
        "солнце #7107. Байт 2E одновременно входит в операнд команды по #83FE."),
    0x733E: (
        "Старший байт DF команды CALL #DFEE по #733C исполняется как RST #18. "
        "Это путь команды перестановки лазеров без Mk4. ROM GET_CHAR возвращает "
        "текущий символ, LD (HL),A по #733F записывает его обратно. Параметр #FC0E "
        "на этом пути не переключается."),
    0xFB31: (
        "Байты 3E AF образуют LD A,#AF и выбирают альтернативный профиль. "
        "Следующий EX AF,AF' сохраняет выбор для общего рендера."),
    0xFB32: (
        "Байт AF выполняется как XOR A при прямом входе и выбирает обычный профиль. "
        "При входе #FB31 тот же байт является операндом LD A,#AF."),
    0xB29C: (
        "Байт 7A является LD A,D при обычном завершении умножения. При переполнении "
        "предыдущий FE читает его как операнд CP #7A, сохраняя насыщенное A=#FF."),
    0xB2BA: (
        "Байт A7 является AND A при входе из условных ветвей деления. При "
        "последовательном исполнении от #B2B9 он служит операндом LD A,#A7."),
    0xD7E2: (
        "LD HL,#2EF2, затем NOP и DEC L/LD H,#D7 выбирают базу #D7F1. "
        "Код управляющего символа прибавляется к ней, байт таблицы задаёт "
        "младшую часть адреса обработчика в странице #D8."),
    0xD7E4: (
        "LD L,#00 перекрывает старший операнд LD HL по #D7E2. Следующие "
        "DEC L/LD H,#D7 задают базу второй таблицы #D7FF."),
    0xE6F2: (
        "Байты 6A D0 внутри LD A,(#D06A) выполняются как LD L,D и RET NC. "
        "Переход #E6B3 запрещает покупку при занятом миссией трюме. Диспетчер "
        "#813E входит с C=0, поэтому этот путь возвращается через RET NC."),
}


def main():
    targets = json.loads((ROOT / "Tools/Disasm/Reports/CodeTargets.json").read_text("utf-8"))
    observed = {item["target"] for item in targets["review_required"]}
    assert observed == set(EXPLANATIONS), (observed - set(EXPLANATIONS),
                                          set(EXPLANATIONS) - observed)
    reviewed = []
    for item in targets["review_required"]:
        reviewed.append({
            "source": item["address"],
            "target": item["target"],
            "file": item["file"],
            "destination_file": item["destination"]["file"],
            "status": "reviewed",
            "explanation": EXPLANATIONS[item["target"]],
        })
    result = {
        "scope": "все прямые переходы из актуального CodeTargets в DB либо внутрь инструкции",
        "reviewed_transfers": len(reviewed),
        "distinct_targets": len(observed),
        "unresolved": [],
        "reviews": reviewed,
    }
    (ROOT / "Tools/Disasm/Reports/CodeTargetReview.json").write_text(
        json.dumps(result, ensure_ascii=False, indent=2) + "\n", "utf-8")
    print(f"Reviewed {len(reviewed)} transfers to {len(observed)} overlapping entries")


if __name__ == "__main__":
    main()
