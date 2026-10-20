"""Объединение проверенных планов именования без перезаписи чужих изменений.

По умолчанию только проверяет планы. --apply применяет их один раз.
Каждая группа планов рассматривается относительно исходного текста отдельно,
поэтому вставка комментария не смещает номера строк другой группы.
"""
from pathlib import Path
import difflib
import hashlib
import json
import sys

ROOT = Path(__file__).resolve().parents[3]
NAMES = ['CommanderFlagEdits', 'ObjectFlagEdits', 'RuntimeFlagEdits',
         'GraphicsFlagEdits', 'DiskFlagEdits', 'MissionCommentEdits']
originals = {}
changes = {}
sizes = {}


def text(path):
    if path not in originals:
        originals[path] = path.read_bytes()
    return originals[path].decode('utf-8-sig').replace('\r\n', '\n')


for name in NAMES:
    plan = json.loads((ROOT / 'Tools/Disasm/Research' / (name+'.json')).read_text('utf-8-sig'))
    sizes[name] = len(plan)
    staged = {}
    for edit in plan:
        path = ROOT / edit['file']
        before = staged.setdefault(path, text(path))
        old, new = edit['old'], edit['new']
        # Однострочный old привязан к целой строке, а не к её подстроке.
        if '\n' not in old:
            rows = before.splitlines(keepends=True)
            hint = edit.get('line', 0)-1
            baseline = text(path).splitlines(keepends=True)
            if 0 <= hint < len(baseline) and baseline[hint].rstrip('\n') == old:
                for tag,a,b,c,d in difflib.SequenceMatcher(None, baseline, rows, autojunk=False).get_opcodes():
                    if tag == 'equal' and a <= hint < b:
                        hint = c + hint - a
                        break
            matches = [i for i,r in enumerate(rows) if r.rstrip('\n') == old]
            if hint in matches:
                at = hint
            else:
                assert len(matches) == 1, (name, edit['file'], old, matches)
                at = matches[0]
            rows[at] = new + ('\n' if rows[at].endswith('\n') else '')
            staged[path] = ''.join(rows)
        else:
            assert before.count(old) == 1, (name, edit['file'], old, before.count(old))
            staged[path] = before.replace(old, new, 1)
    for path, after in staged.items():
        old_lines = text(path).splitlines(keepends=True)
        new_lines = after.splitlines(keepends=True)
        for tag,a,b,c,d in difflib.SequenceMatcher(None, old_lines, new_lines, autojunk=False).get_opcodes():
            if tag != 'equal':
                changes.setdefault(path, []).append((a,b,new_lines[c:d],name))

outputs = {}
for path, edits in changes.items():
    edits.sort(key=lambda e:(e[0],e[1]))
    for left, right in zip(edits, edits[1:]):
        assert left[1] <= right[0], ('overlap',path,left,right)
        assert not (left[0] == left[1] == right[0] == right[1]), ('double insertion',path,left,right)
    original = originals[path]
    lines = original.decode('utf-8-sig').splitlines(keepends=True)
    newline = '\r\n' if b'\r\n' in original else '\n'
    for a,b,replacement,name in reversed(edits):
        lines[a:b] = [r.replace('\n',newline) for r in replacement]
    result = ''.join(lines).encode('utf-8')
    if original.startswith(b'\xef\xbb\xbf'):
        result = b'\xef\xbb\xbf'+result
    outputs[path] = result

report = {'plans':sizes, 'files':[]}
for path,result in outputs.items():
    assert path.read_bytes() == originals[path], ('changed while preparing',path)
    report['files'].append({'file':path.relative_to(ROOT).as_posix(),
        'before_sha256':hashlib.sha256(originals[path]).hexdigest(),
        'after_sha256':hashlib.sha256(result).hexdigest()})
if '--apply' in sys.argv:
    for path,result in outputs.items():
        path.write_bytes(result)
        assert path.read_bytes() == result, path
    (ROOT/'Tools/Disasm/Reports/FlagNamesApplied.json').write_text(
        json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('Применено' if '--apply' in sys.argv else 'Подготовлено',len(outputs),'файлов,',sum(sizes.values()),'плановых правок')
