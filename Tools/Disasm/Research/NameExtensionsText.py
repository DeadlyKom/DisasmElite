"""Применение вручную разобранных имён к неизменным адресам исходной сборки.

Исторический шаг разметки, не участвует в сборке и не запускается повторно.
"""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MAP = json.loads(Path(__file__).with_name('ExtensionsTextLabelMap.json').read_text('utf-8'))
locations = {}
for raw in (ROOT / 'Tmp/ELITE3HL.sld').read_text('utf-8-sig').splitlines():
    parts = raw.split('|')
    if len(parts) > 7 and parts[6] == 'T':
        locations[(parts[0], int(parts[5]))] = int(parts[1])


def main():
    import argparse
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply', action='store_true')
    args = parser.parse_args()
    symbols = {}
    for raw in (ROOT / 'Tmp/ELITE3HL.sym').read_text('utf-8-sig').splitlines():
        found = re.fullmatch(r'(Game\.[\w.]+|Rom\.[\w.]+): EQU 0x([\dA-Fa-f]+)', raw)
        if found and (found[1].endswith('.Entry') or found[1].startswith('Rom.')):
            symbols.setdefault(int(found[2], 16), found[1])
    report = {'files': {}, 'symbols': {}, 'new_labels': [], 'unresolved_external': []}
    files = list((ROOT / 'Source/Game/Extensions').glob('*.asm')) + list((ROOT / 'Source/Game/Text').glob('*.asm'))
    edits = {}
    for path in files:
        rel = path.relative_to(ROOT).as_posix()
        scope = 'Game.' + path.parent.name + '.' + path.stem
        lines = path.read_text('utf-8-sig').splitlines()
        for address, (name, meaning) in MAP.get(path.stem, {}).items():
            address = int(address)
            line = locations.get((rel, address))
            if line is None and address == 0xD7E2:
                line = next(i + 1 for i, s in enumerate(lines) if 'DB #21, #F2, #2E, #00' in s)
            if line is None:
                raise ValueError((rel, hex(address), name))
            old = lines[line - 1]
            if old and not old[0].isspace():
                raise ValueError(('existing label', rel, line, old))
            if len(name) > 14:
                raise ValueError(('long label', name))
            print(f'{address:04X} {name:14} {old.strip()}')
            symbol = scope + '.' + name
            symbols[address] = symbol
            report['new_labels'].append({'address': address, 'symbol': symbol, 'file': rel, 'meaning': meaning})
            code, sep, comment = old.partition(';')
            lines[line - 1] = (name + ':').ljust(16) + code.strip()
            if sep:
                lines[line - 1] = lines[line - 1].ljust(80) + ';' + comment
        if path.stem == 'DrawProjectedSunAndTextDispatch':
            # Второй вход находится внутри операнда LD HL и не добавляет байты.
            lines.insert(2, 'DescCommand:    EQU MainCommand+2' .ljust(80) + '; перекрывающийся вход LD L,0 для таблицы описаний')
            symbols[0xD7E4] = scope + '.DescCommand'
            report['new_labels'].append({'address': 0xD7E4, 'symbol': symbols[0xD7E4], 'file': rel, 'meaning': 'перекрывающийся вход второй таблицы текстовых команд'})
        edits[path] = lines
    for path, lines in edits.items():
        scope = 'Game.' + path.parent.name + '.' + path.stem
        for number, line in enumerate(lines):
            code, sep, comment = line.partition(';')
            found = re.search(r'\b(?:JP|JR|CALL|DJNZ)\s+(?:(?:NZ|Z|NC|C|PO|PE|P|M)\s*,\s*)?#([\dA-Fa-f]{4})\b', code)
            if not found:
                continue
            address = int(found[1], 16)
            if address not in symbols:
                report['unresolved_external'].append({'file': path.relative_to(ROOT).as_posix(), 'address': address})
                continue
            name = symbols[address]
            if name.startswith(scope + '.'):
                name = name[len(scope) + 1:]
            code = code[:found.start(1) - 1] + name + code[found.end(1):]
            lines[number] = code.rstrip().ljust(80) + ';' + comment if sep else code.rstrip()
        if args.apply:
            path.write_text('\n'.join(lines) + '\n', encoding='utf-8')
    if args.apply:
        (ROOT / 'Tools/Disasm/Reports/SemanticRenameExtensionsText.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print('Labels', len(report['new_labels']), 'unresolved', report['unresolved_external'])


if __name__ == '__main__':
    main()
