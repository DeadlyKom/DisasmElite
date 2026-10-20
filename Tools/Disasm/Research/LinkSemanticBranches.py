"""Однократное связывание оставшихся межмодульных прямых переходов."""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'Tools/Disasm'))
from AuditCodeTargets import source_map


def main():
    occupied, instructions = source_map()
    additions = {
        0xFB7B: ('DrawRaster', 'вывод готового профиля по экранному адресу HL и смещению пикселя A'),
        0x700F: ('ReadCargoByte', 'чтение текущей товарной строки с проверкой колонии'),
        0x6F29: ('SelectIcon', 'выбор значка специального пространства и режима координат'),
        0xF8E4: ('NextOrFinish', 'продолжение обхода объектов либо восстановление временного стека'),
    }
    report_path = ROOT / 'Tools/Disasm/Reports/SemanticRenameExtensionsText.json'
    report = json.loads(report_path.read_text('utf-8'))
    for address, (label, meaning) in additions.items():
        row = occupied[address]
        path = ROOT / row['file']
        lines = path.read_text('utf-8-sig').splitlines()
        line = lines[row['line'] - 1]
        if line and not line[0].isspace():
            raise ValueError(('Already labelled', address, line))
        lines[row['line'] - 1] = (label + ':').ljust(16) + line.lstrip()
        path.write_text('\n'.join(lines) + '\n', encoding='utf-8')
        report['new_labels'].append({'address': address, 'symbol': 'Game.' + path.parent.name + '.' + path.stem + '.' + label,
                                     'file': row['file'], 'meaning': meaning})
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    # Сборка словаря фактически размещённых меток и перекрывающихся входов.
    occupied, instructions = source_map()
    symbols = {}
    for address, row in occupied.items():
        if address != row['start']:
            continue
        path = ROOT / row['file']
        line = path.read_text('utf-8-sig').splitlines()[row['line'] - 1]
        match = re.match(r'^([\w.]+):', line)
        if match:
            symbols[address] = 'Game.' + path.parent.name + '.' + path.stem + '.' + match[1]
    rename = report['symbols']
    for path in (ROOT / 'Tools/Disasm/Reports').glob('SemanticRename*.json'):
        for item in json.loads(path.read_text('utf-8')).get('new_labels', []):
            if not item.get('symbol', '').startswith('Game.'):
                continue
            address = item['address']
            if isinstance(address, str):
                address = int(address.lstrip('#$'), 16)
            name = item['symbol']
            for old, new in rename.items():
                name = name.replace(old, new)
            symbols[address] = name
    symbols.update({0x03B5: 'Rom.Beeper', 0x16DC: 'Rom.FindKeyPair', 0x22AA: 'Rom.PlotAddress',
                    0x22B0: 'Rom.PixelFromA', 0x22B1: 'Rom.PixelAddress', 0x3D2F: 'Rom.CallDosStack'})
    changed = 0
    unresolved = []
    regex = re.compile(r'\b(?:JP|JR|CALL|DJNZ)\s+(?:(?:NZ|Z|NC|C|PO|PE|P|M)\s*,\s*)?#([\dA-Fa-f]{4})\b')
    for path in (ROOT / 'Source/Game').rglob('*.asm'):
        lines = path.read_text('utf-8-sig').splitlines()
        edited = False
        for n, line in enumerate(lines):
            code, sep, comment = line.partition(';')
            match = regex.search(code)
            if not match:
                continue
            address = int(match[1], 16)
            if address not in symbols:
                unresolved.append((path.relative_to(ROOT).as_posix(), hex(address)))
                continue
            code = code[:match.start(1)-1] + symbols[address] + code[match.end(1):]
            lines[n] = code.rstrip().ljust(80) + ';' + comment if sep else code.rstrip()
            changed += 1
            edited = True
        if edited:
            path.write_text('\n'.join(lines) + '\n', encoding='utf-8')
    print('Linked', changed, 'unresolved', unresolved)
    if unresolved:
        raise ValueError('Unresolved targets')


if __name__ == '__main__':
    main()
