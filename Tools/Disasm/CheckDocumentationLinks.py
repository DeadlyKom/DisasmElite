"""Проверка локальных ссылок рабочей документации без сетевых запросов."""
import json
import re
from pathlib import Path
from urllib.parse import unquote

ROOT = Path(__file__).resolve().parents[2]


def anchors(path):
    text = path.read_text('utf-8-sig')
    result = set(re.findall(r'<a\s+(?:id|name)=[\"\x27]([^\"\x27]+)', text))
    occurrences = {}
    for title in re.findall(r'^#+\s+(.+)$', text, re.M):
        slug = re.sub(r'[^\w\s-]', '', title.lower()).replace(' ', '-')
        number = occurrences.get(slug, 0)
        occurrences[slug] = number + 1
        result.add(slug + (f'-{number}' if number else ''))
    return result


def main():
    paths = [ROOT / 'README.md', ROOT / 'Tools/Disasm/README.md', ROOT / 'Tools/Disasm/Research/README.md']
    paths += sorted((ROOT / 'Docs').glob('*.md')) + sorted((ROOT / 'Source').rglob('README.md'))
    broken = []
    checked = 0
    for path in paths:
        text = path.read_text('utf-8-sig')
        for match in re.finditer(r'\]\(([^)]+)\)', text):
            target = match[1].strip()
            if re.match(r'[A-Za-z][\w+.-]*://', target) or target.startswith('mailto:'):
                continue
            target = target.strip('<>')
            file_part, _, anchor = unquote(target).partition('#')
            resolved = path.parent / file_part if file_part else path
            checked += 1
            reason = None
            if not resolved.exists():
                reason = 'файл или папка отсутствует'
            elif anchor and (resolved.suffix.lower() != '.md' or anchor not in anchors(resolved)):
                reason = 'якорь отсутствует'
            if reason:
                broken.append({'file': path.relative_to(ROOT).as_posix(),
                               'line': text.count('\n', 0, match.start()) + 1,
                               'target': target, 'reason': reason})
    report = {'scope': 'README, Docs, инструкции Source и Tools/Disasm, без исторических/vendor документов',
              'documents': len(paths), 'local_links_checked': checked, 'broken_links': broken,
              'external_links_checked': False, 'passed': not broken}
    (ROOT / 'Tools/Disasm/Reports/DocumentationLinks.json').write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(f'Documentation: {len(paths)} files, {checked} local links, {len(broken)} broken')
    if broken:
        for item in broken:
            print(item)
        raise SystemExit(1)


if __name__ == '__main__':
    main()
