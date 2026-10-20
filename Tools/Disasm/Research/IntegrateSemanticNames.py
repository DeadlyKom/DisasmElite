"""Согласование ссылок и реестров после ручного именования блоков.

Не создаёт машинный код. Карты переименований сохраняются как история изменений.
"""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPORTS = ROOT / 'Tools/Disasm/Reports'


def main():
    reports = [json.loads(p.read_text('utf-8')) for p in REPORTS.glob('SemanticRename*.json')]
    paths = {old: new for report in reports for old, new in report.get('files', {}).items()}
    symbols = {old: new for report in reports for old, new in report.get('symbols', {}).items()}
    replacements = {**paths, **symbols}
    replacements.update({Path(old).name: Path(new).name for old, new in paths.items()})
    replacements.update({Path(old).stem: Path(new).stem for old, new in paths.items()})
    pattern = re.compile(r'(?<!\w)(?:' + '|'.join(re.escape(s) for s in sorted(replacements, key=len, reverse=True)) + r')(?!\w)')

    def replace(text):
        return pattern.sub(lambda m: replacements[m[0]], text)

    changed = []
    for folder in ('Source', 'Includes', 'Builder', 'Docs', 'Tools/Disasm'):
        for path in (ROOT / folder).rglob('*'):
            if not path.is_file() or path.suffix not in {'.asm', '.inc', '.json', '.md', '.py', '.ps1', '.lua'}:
                continue
            rel = path.relative_to(ROOT).as_posix()
            if '/vendor/' in rel or '/References/' in rel or path.name.startswith('SemanticRename'):
                continue
            if path.name in {'IntegrateSemanticNames.py', 'ExtensionsTextLabelMap.json', 'NameExtensionsText.py', 'CorrectExtensionsTextComments.py'}:
                continue
            original = path.read_text('utf-8-sig')
            if path.name == 'SourceNames.json':
                document = json.loads(original)
                document['file_moves'] = {old: replace(new) for old, new in document['file_moves'].items()}
                document['file_moves'].update(paths)
                # Полный словарь символов отдельно читает UpdateNameIndex из актуального .sym.
                current = json.dumps(document, ensure_ascii=False, indent=2) + '\n'
            else:
                current = replace(original)
            if current != original:
                path.write_text(current, encoding='utf-8')
                changed.append(rel)
    # Обновление смысловых записей из актуальных заголовков исправленных процедур.
    corrected = set()
    corrections = []
    for report in reports:
        for item in report.get('corrections', []) + report.get('comment_corrections', []) + report.get('corrected_descriptions', []):
            if isinstance(item, dict) and item.get('file'):
                corrected.add(replace(item['file']))
                old = item.get('old', item.get('before', ''))
                new = item.get('new', item.get('after', ''))
                if old and new:
                    corrections.append((replace(item['file']), old.replace('; ', ''), new.replace('; ', '')))
    corrected.update('Source/Game/Extensions/' + name + '.asm' for name in (
        'HandleSpecialMessageToken', 'ScheduleLinkedObjectLaser', 'MarkObjectEventAndUpdateMetadata',
        'OfferUpgradeAndCorrectPosition', 'ResetObjectMetadata', 'PrintEquipmentAndSelectIcon'))
    corrected.add('Source/Game/Text/ApplyAttributeRuns.asm')
    corrected.update(paths.values())
    for path in list((REPORTS / 'Semantics').glob('*.json')) + list(REPORTS.glob('DiskUtility*Semantics.json')):
        document = json.loads(path.read_text('utf-8'))
        if not isinstance(document, list):
            continue
        edited = False
        for item in document:
            if not isinstance(item, dict) or 'semantic_name' not in item or item.get('file') not in corrected:
                continue
            # Исправление повторов старой трактовки в полях in/out, ветвях и описаниях блоков.
            for target, old, new in corrections:
                if target != item['file']:
                    continue
                def update(value):
                    if isinstance(value, str):
                        return value.replace(old, new)
                    if isinstance(value, list):
                        return [update(x) for x in value]
                    if isinstance(value, dict):
                        return {key: update(x) for key, x in value.items()}
                    return value
                item.update(update(item))
            source = ROOT / item['file']
            if not source.exists():
                raise ValueError(source)
            header = []
            for line in source.read_text('utf-8-sig').splitlines():
                if line.startswith(';'):
                    text = line[1:].strip()
                    if text and set(text) != {'-'}:
                        header.append(text)
                elif header:
                    break
            if not header:
                continue
            item['summary'] = header[0]
            item['semantic_name'] = source.stem
            if 'details' in item:
                item['details'] = [x for x in header[1:] if not x.startswith(('исходный диапазон', 'смысловое имя'))]
            # Прежние пересказы заголовков заменяются, а не оставляются рядом с исправлением.
            if 'evidence' in item:
                origin = f"Байты исходного образа, диапазон #{item['start']:04X}..#{item['end']-1:04X}"
                item['evidence'] = [origin] + [x for x in header[1:] if not x.startswith(('исходный диапазон', 'смысловое имя'))]
            item['current_header'] = header
            edited = True
        if edited:
            path.write_text(json.dumps(document, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print('Updated reference files:', len(changed), 'renamed files:', len(paths), 'symbol replacements:', len(symbols))


if __name__ == '__main__':
    main()
