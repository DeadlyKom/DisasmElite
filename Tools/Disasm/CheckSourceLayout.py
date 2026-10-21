"""Пробелы после запятых и пустые строки после выходов и переходов.

Без --apply исходники не меняются. Проверка не запускает ассемблер.
Строковые литералы и альтернативные регистры AF' сохраняются.
"""
import argparse
import json
import re
from pathlib import Path
from AuditCodeTargets import source_statement

ROOT = Path(__file__).resolve().parents[2]


def parts(raw):
    """Символы строки с учётом литералов, комментарий отделён от кода."""
    quote = None
    escaped = False
    positions = []
    for i, char in enumerate(raw):
        if quote:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == quote:
                quote = None
            continue
        if char == ";":
            return raw[:i], raw[i:], positions
        if char == '"' or (char == "'" and (i == 0 or not (raw[i - 1].isalnum() or raw[i - 1] == '_'))):
            quote = char
        elif char == ',':
            positions.append(i)
    return raw, '', positions


def normalized(raw):
    code, _, _ = parts(raw)
    # Whitespace outside strings is the only permitted operand difference.
    return ''.join(re.findall(r'"(?:\\.|[^"\\])*"|\x27(?:\\.|[^\x27\\])*\x27|\S', code))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply', action='store_true')
    args = parser.parse_args()
    paths = sorted(path for folder in ('Source', 'Includes') for path in (ROOT / folder).rglob('*')
                   if path.suffix.lower() in ('.asm', '.inc'))
    issues = []
    changes = []
    for path in paths:
        before = path.read_text('utf-8-sig')
        original = before.splitlines()
        lines = []
        commas = blanks = 0
        for index, raw in enumerate(original):
            code, comment, positions = parts(raw)
            missing = [i for i in positions if i + 1 < len(code) and not code[i + 1].isspace()]
            if missing:
                issues.append({'file': path.relative_to(ROOT).as_posix(), 'line': index + 1,
                               'reason': 'нет пробела после запятой вне строкового литерала'})
                commas += len(missing)
                if args.apply:
                    for i in reversed(missing):
                        code = code[:i + 1] + ' ' + code[i + 1:]
                    if comment:
                        code = code.rstrip().ljust(max(80, len(code.rstrip()) + 1))
                    raw = code + comment
            lines.append(raw)
            instruction = source_statement(raw)
            transfer = re.match(r'^(?:RET|RETI|RETN|JP|JR)(?:\s|$)', instruction, re.I)
            if transfer and index + 1 < len(original) and original[index + 1].strip():
                issues.append({'file': path.relative_to(ROOT).as_posix(), 'line': index + 1,
                               'reason': 'нет пустой строки после перехода или выхода'})
                blanks += 1
                if args.apply:
                    lines.append('')
        after = '\n'.join(lines) + '\n'
        if args.apply and after != before:
            statements = lambda text: [normalized(line) for line in text.splitlines() if normalized(line)]
            if statements(before) != statements(after):
                raise ValueError(('Изменение вне пробелов и пустых строк', path))
            path.write_text(after, encoding='utf-8', newline='\r\n')
            changes.append({'file': path.relative_to(ROOT).as_posix(), 'spaces_after_commas': commas,
                            'blank_lines_after_transfers': blanks})
    report = {'scope': 'пробел после разделителя операндов и пустая строка после RET/JP/JR',
              'source_files': len(paths), 'applied': args.apply,
              'issues_before': issues if args.apply else [], 'remaining_issues': [] if args.apply else issues,
              'changes': changes, 'passed': args.apply or not issues}
    output = ROOT / 'Tools/Disasm/Reports/SourceLayout.json'
    if not args.apply and output.exists():
        previous = json.loads(output.read_text('utf-8'))
        report['changes'] = previous.get('changes', [])
        report['issues_before'] = previous.get('issues_before', [])
    output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(f"Layout: {len(paths)} files, {len(issues)} issues" + (f", fixed in {len(changes)} files" if args.apply else ''))
    if issues and not args.apply:
        raise SystemExit(1)


if __name__ == '__main__':
    main()
