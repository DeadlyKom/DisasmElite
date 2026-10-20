"""Зафиксированные исправления смысла, проверенные по инструкциям ELITE3.C."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FIXES = {
    'DrawCompressedEdges': [('если тип объекта ненулевой', 'если дополнительные флаги Flags2 ненулевые')],
    'ChooseLinkedObjectTarget': [('проверка специального типа и активности объекта', 'проверка флага управляемой ракеты и активности объекта'), ('объект имеет бит 0 типа', 'у объекта установлен флаг управляемой ракеты')],
    'FindLiveTrackedObject': [('проверка типа, энергии и идентификатора', 'проверка флага ракеты, энергии и идентификатора'), ('бит 0 типа слота сброшен', 'флаг управляемой ракеты сброшен')],
    'ResetObjectMetadata': [('параметр сложности системы', 'правовой статус пилота'), ('проверка сложности', 'проверка правового статуса')],
    'ResolveSpecialObjectCollision': [('проверка специального типа первого участника', 'проверка флага управляемой ракеты первого участника'), ('объект имеет бит 0 типа', 'у объекта установлен флаг управляемой ракеты'), ('тип второго участника равен #0C', 'байт Flags2 второго участника равен #0C'), ('бит 1 типа второго участника сброшен', 'флаг захвата ковшом второго участника сброшен')],
    'SetObjectAggressionFlag': [('проверка защиты отдельного типа', 'проверка признака исключения из обычных кораблей'), ('объект имеет защитный бит 3 типа', 'у объекта установлен бит 3 дополнительных флагов Flags2')],
    'OfferUpgradeAndCorrectPosition': [('типе #6095=#0C', 'Flags2 второго слота #6095=#0C'), ('проверка ресурса, типа корабля', 'проверка денег, дополнительных флагов корабля'), ('ресурс #D067 исчерпан', 'старший байт CashHigh равен нулю, денег для улучшения недостаточно'), ('тип объекта #6095 отличается от #0C', 'Flags2 второго слота отличается от #0C'), ('запись улучшения и расход единицы ресурса', 'запись улучшения и вычитание 256000 кредитов через старший байт CashHigh')],
    'MarkObjectEventAndMaybeRemove': [('MarkObjectEventAndMaybeRemove', 'MarkObjectEventAndUpdateMetadata'), ('условная обработка его удаления', 'условная повторная инициализация его метаданных'), ('проверка двух флагов допуска удаления уже отмеченного объекта', 'проверка двух флагов допуска повторной инициализации метаданных'), ('бит 1 типа объекта сброшен', 'флаг захвата объекта ковшом сброшен'), ('вызвать #7A9E', 'переинициализировать метаданные')],
    'PrintEquipmentAndSelectIcon': [('обновление младшего байта координатного указателя для специального вида', 'включение чередования двух наборов координат через смещение JR Z')],
    'ClearViewAndFrame': [('перенос исходной последовательности данных', 'заполнение атрибутов окна значением 7 из первого байта')],
}


def main():
    report_path = ROOT / 'Tools/Disasm/Reports/SemanticRenameExtensionsText.json'
    report = json.loads(report_path.read_text('utf-8'))
    report['corrections'] = []
    for stem, pairs in FIXES.items():
        path = next((ROOT / 'Source/Game').glob('*/' + stem + '.asm'))
        text = path.read_text('utf-8-sig')
        for old, new in pairs:
            if old not in text:
                raise ValueError((path, old))
            text = text.replace(old, new)
            report['corrections'].append({'file': path.relative_to(ROOT).as_posix(), 'old': old, 'new': new})
        path.write_text(text, encoding='utf-8')
    old_path = ROOT / 'Source/Game/Extensions/MarkObjectEventAndMaybeRemove.asm'
    new_path = old_path.with_name('MarkObjectEventAndUpdateMetadata.asm')
    if new_path.exists() or not old_path.resolve().is_relative_to(ROOT):
        raise ValueError('Unsafe or conflicting rename')
    old_path.rename(new_path)
    report['files'][old_path.relative_to(ROOT).as_posix()] = new_path.relative_to(ROOT).as_posix()
    report['symbols']['Game.Extensions.MarkObjectEventAndMaybeRemove'] = 'Game.Extensions.MarkObjectEventAndUpdateMetadata'
    # Выравнивание затронутых правых комментариев без изменения текста инструкций.
    for folder in ('Extensions', 'Text'):
        for path in (ROOT / 'Source/Game' / folder).glob('*.asm'):
            lines = path.read_text('utf-8-sig').splitlines()
            for i, raw in enumerate(lines):
                code, sep, comment = raw.partition(';')
                if code.strip() and sep:
                    if len(code.rstrip()) > 79:
                        continue
                    lines[i] = code.rstrip().ljust(80) + ';' + comment
            path.write_text('\n'.join(lines) + '\n', encoding='utf-8')
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


if __name__ == '__main__':
    main()
