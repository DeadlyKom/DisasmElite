"""Сверка физических F-инициализаторов игрового блока и символов их полей.

Работает с результатом последней сборки, ассемблер не запускает.
"""
import hashlib
import json
import re
from collections import Counter, defaultdict
from pathlib import Path
from AuditCodeTargets import source_map, source_statement, source_statements, structure_layouts
import VerifySourceMap
from VerifyCommanderRecords import compare_existing_symbols

ROOT = Path(__file__).resolve().parents[2]


def read_symbols(path):
    return {m[1]: int(m[2], 16) for m in re.finditer(
        r'^([\w.]+): EQU 0x([\dA-Fa-f]+)$', path.read_text('utf-8-sig'), re.M)}


def main():
    layouts = structure_layouts()
    symbols = read_symbols(ROOT / 'Tmp/ELITE3HL.sym')
    VerifySourceMap.SYMBOLS.clear()
    VerifySourceMap.SYMBOLS.update(symbols)
    original = (ROOT / 'Tools/Disasm/Research/GameCode.bin').read_bytes()
    occupied, _ = source_map()
    positions = defaultdict(list)
    for address, item in occupied.items():
        if item['kind'] == 'literal':
            positions[(item['file'], item['line'])].append(address)
    instances = []
    fields_checked = 0
    for path in sorted((ROOT / 'Source/Game').rglob('*.asm')):
        file = path.relative_to(ROOT).as_posix()
        text = path.read_text('utf-8-sig')
        if not any(re.match(r'F\w+\s*\{', source_statement(line)) for line in text.splitlines()):
            continue
        expanded = defaultdict(list)
        for number, raw, statement in source_statements(path):
            expanded[number].append(statement)
        scopes, anchor = ['Game'], ''
        for number, raw in enumerate(text.splitlines(), 1):
            statement = source_statement(raw)
            if re.match(r'module\s+', statement, re.I):
                scopes.append(statement.split()[1]); continue
            if re.fullmatch(r'endmodule', statement, re.I):
                scopes.pop(); continue
            label = re.match(r'^([@\w.]+):?(?:\s|$)', raw)
            symbol = None
            if label:
                name = label[1]
                if name.startswith('.'):
                    name = anchor + name
                elif not name.startswith('@'):
                    anchor = name
                symbol = name[1:] if name.startswith('@') else '.'.join(scopes + [name])
            match = re.match(r'(F\w+)\s*\{', statement)
            if not match:
                continue
            typ = match[1]
            if typ not in layouts:
                raise ValueError(('Неизвестный тип', file, number, typ))
            data = bytearray()
            for literal in expanded[number]:
                opcode, operands = literal.split(None, 1)
                if opcode not in ('DB', 'DW'):
                    raise ValueError(('Неожиданное раскрытие', file, number, literal))
                width = 2 if opcode == 'DW' else 1
                for token in operands.split(','):
                    value = int(VerifySourceMap.normalize(token.strip(), {}, '.'.join(scopes), anchor))
                    data.extend(value.to_bytes(width, 'little'))
            size = sum(field[2] for field in layouts[typ])
            addresses = sorted(positions[(file, number)])
            if len(data) != size or len(addresses) != size or addresses != list(range(addresses[0], addresses[0] + size)):
                raise ValueError(('Неверный размер или разрыв данных', file, number, size, len(data), addresses))
            address = addresses[0]
            if bytes(data) != original[address - 0x4000:address - 0x4000 + size]:
                raise ValueError(('Байты отличаются', file, number, typ))
            def verify_fields(type_name, prefix, base):
                nonlocal fields_checked
                cursor = base
                for field, kind, width in layouts[type_name]:
                    name = prefix + '.' + field
                    if symbols.get(name) != cursor:
                        raise ValueError(('Адрес поля', name, cursor, symbols.get(name)))
                    fields_checked += 1
                    if kind in layouts:
                        verify_fields(kind, name, cursor)
                    cursor += width
            if symbol:
                if symbols.get(symbol) != address:
                    raise ValueError(('Адрес экземпляра', symbol, address, symbols.get(symbol)))
                verify_fields(typ, symbol, address)
            instances.append({'file': file, 'line': number, 'type': typ, 'symbol': symbol,
                              'address': address, 'size': size, 'original_bytes_equal': True,
                              'sha256': hashlib.sha256(data).hexdigest()})
    baseline = json.loads((ROOT / 'Tools/Disasm/Reports/BeforeTypedDataSymbols.json').read_text('utf-8'))['symbols']
    differences, removed = compare_existing_symbols(baseline, symbols)
    if differences:
        raise ValueError(('Прежние символы изменились', differences))
    report = {'scope': 'все физические F-инициализаторы Source/Game, байты и реальные поля по .sym',
              'instance_count': len(instances), 'named_instances': sum(bool(i['symbol']) for i in instances),
              'bytes_checked': sum(i['size'] for i in instances), 'field_addresses_checked': fields_checked,
              'types': dict(Counter(i['type'] for i in instances)), 'instances': instances,
              'unchanged_existing_symbols': len(baseline) - len(removed), 'changed_existing_symbols': differences,
              'removed_lookup_placeholders': removed,
              'passed': True}
    (ROOT / 'Tools/Disasm/Reports/TypedDataVerification.json').write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(f"Typed data: {len(instances)} instances, {report['bytes_checked']} bytes, {fields_checked} field addresses, {len(baseline) - len(removed)} old symbols unchanged")


if __name__ == '__main__':
    main()
