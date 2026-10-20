"""Проверка адресных имён, неименованных прямых переходов и механических комментариев.

Не собирает проект. Семантика имён устанавливается ручным разбором, не этим поиском.
"""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ADDRESS_NAME = re.compile(r'(?:^|_)(?:[0-9A-Fa-f]{4})(?:_|$)|^(?:L|loc|sub|byte|word|unk)_?[0-9A-Fa-f]{4}$')
RAW_BRANCH = re.compile(r'\b(?:JP|JR|CALL|DJNZ)\s+(?:(?:NZ|Z|NC|C|PO|PE|P|M)\s*,\s*)?(?:#[0-9A-Fa-f]+|\$[0-9A-Fa-f]+|0x[0-9A-Fa-f]+|\d+)\b', re.I)
MECHANICAL = re.compile(r'расчёт следующего значения|расчёт следующего набора битов|проверка исходного условия|расчёт исходного значения|перенос исходной последовательности данных', re.I)


def main():
    report = {'scope': 'текущие Source и Includes, исторические карты и сторонний декодер исключены',
              'address_filenames': [], 'address_symbols': [], 'numeric_direct_branches': [], 'mechanical_comments': []}
    for folder in ('Source', 'Includes'):
        for path in sorted((ROOT / folder).rglob('*')):
            if not path.is_file() or path.suffix.lower() not in {'.asm', '.inc'}:
                continue
            rel = path.relative_to(ROOT).as_posix()
            if ADDRESS_NAME.search(path.stem):
                report['address_filenames'].append(rel)
            for number, raw in enumerate(path.read_text('utf-8-sig').splitlines(), 1):
                code = raw.partition(';')[0]
                label = re.match(r'^([\w.]+)(?::|\s)', code)
                module = re.match(r'\s*module\s+([\w.]+)', code, re.I)
                for match in (label, module):
                    if match and any(ADDRESS_NAME.search(x) for x in match[1].split('.')):
                        report['address_symbols'].append({'file': rel, 'line': number, 'name': match[1]})
                if RAW_BRANCH.search(code):
                    report['numeric_direct_branches'].append({'file': rel, 'line': number, 'code': code.strip()})
                if MECHANICAL.search(raw):
                    report['mechanical_comments'].append({'file': rel, 'line': number, 'text': raw.strip()})
    report['passed'] = not any(report[key] for key in ('address_filenames', 'address_symbols', 'numeric_direct_branches', 'mechanical_comments'))
    (ROOT / 'Tools/Disasm/Reports/SemanticNamingAudit.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(json.dumps({key: len(value) if isinstance(value, list) else value for key, value in report.items()}, ensure_ascii=False))


if __name__ == '__main__':
    main()
