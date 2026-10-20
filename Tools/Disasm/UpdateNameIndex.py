"""Обновление навигации по смысловым меткам из карт разбора и текущей сборки.

Ассемблер не запускается. Сборка и побайтовая проверка выполняются отдельно.
"""
import json
import re
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
REPORTS = ROOT / 'Tools/Disasm/Reports'


def main():
    symbols = {}
    for raw in (ROOT / 'Tmp/ELITE3HL.sym').read_text('utf-8-sig').splitlines():
        match = re.fullmatch(r'([\w.]+): EQU 0x([\dA-Fa-f]+)', raw)
        if match:
            symbols[match[1]] = int(match[2], 16)
    names_path = REPORTS / 'SourceNames.json'
    names = json.loads(names_path.read_text('utf-8'))
    names['symbols'] = symbols
    names['symbol_source'] = 'Tmp/ELITE3HL.sym'
    names_path.write_text(json.dumps(names, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    rows = []
    for path in sorted(REPORTS.glob('SemanticRename*.json')):
        report = json.loads(path.read_text('utf-8'))
        for item in report['new_labels']:
            name = item['symbol']
            source = item['file']
            for old, new in report.get('symbols', {}).items():
                if name == old or name.startswith(old + '.'):
                    name = new + name[len(old):]
                    break
            source = report.get('files', {}).get(source, source)
            address = item['address']
            if isinstance(address, str):
                address = int(address.lstrip('#$'), 16)
            if symbols.get(name) != address:
                raise ValueError(('Symbol address differs', name, address, symbols.get(name)))
            if not (ROOT / source).exists():
                raise ValueError(source)
            row = {**item, 'symbol': name, 'file': source, 'address': address}
            rows.append(row)
        # Данные передачи между участками сохраняются отдельно от текущего статуса.
        for key in ('remaining_targets', 'unresolved_external', 'unresolved_external_raw_targets'):
            if report.get(key):
                report[key + '_at_handoff'] = report[key]
                report[key] = []
        report['integrated'] = True
        report['current_name_audit'] = 'Tools/Disasm/Reports/SemanticNamingAudit.json'
        path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    rows.sort(key=lambda item: (item['file'], item['address'], item['symbol']))
    groups = defaultdict(list)
    for row in rows:
        groups[row['file']].append(row)
    index = {'scope': 'новые внутренние входы, циклы и ветви, именованные по инструкциям собственного образа',
             'symbol_source': 'Tmp/ELITE3HL.sym', 'labels': rows, 'count': len(rows)}
    (REPORTS / 'SemanticLabelIndex.json').write_text(json.dumps(index, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    lines = ['# Внутренние входы, циклы и ветви', '',
             f'Указатель {len(rows)} меток, добавленных при разборе числовых переходов и точек самомодификации.',
             'Каждый адрес сверяется с символами текущей сборки. В памяти код и данные остаются на исходных местах.',
             'Полный словарь, включая прежние входы, структуры и константы, находится в',
             '[SourceNames.json](../Tools/Disasm/Reports/SourceNames.json). Назначение файлов и контракты процедур',
             'описаны в [игровом указателе](Functions.md) и [указателе остальных файлов](Auxiliary.md).', '',
             'Внутри модуля переходы используют короткие имена, межмодульные ссылки содержат полный путь.',
             'Префикс `@` в части ссылок явно выбирает глобальную область имён sjasmplus.',
             'Перекрывающиеся входы задаются через `EQU` относительно команды, в чьи байты они входят.', '']
    for source, entries in groups.items():
        lines += [f'## [{Path(source).stem}](../{source})', '', '| Метка | Адрес | Назначение |', '|---|---|---|']
        for item in entries:
            lines.append(f"| `{item['symbol']}` | `#{item['address']:04X}` | {item['meaning'].replace('|', '/')} |")
        lines.append('')
    (ROOT / 'Docs/Labels.md').write_text('\n'.join(lines) + '\n', encoding='utf-8')
    print('Indexed semantic labels:', len(rows), 'source files:', len(groups), 'all symbols:', len(symbols))


if __name__ == '__main__':
    main()
