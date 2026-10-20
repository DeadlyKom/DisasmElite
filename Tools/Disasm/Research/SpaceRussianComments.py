"""Исправление пропущенных пробелов между русским словом и числом в комментариях.

Операнды, метки, строки данных и машинные инструкции не изменяются.
"""

import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RUSSIAN = "а-яА-ЯёЁ"


def spaced(text):
    text = re.sub(rf"(?<=[{RUSSIAN}])(?=[0-9])", " ", text)
    text = re.sub(rf"(?<=[0-9])(?=[{RUSSIAN}])", " ", text)
    text = re.sub(rf"(?<=[{RUSSIAN}])(?=[A-Za-z])", " ", text)
    return re.sub(rf"(?<=[A-Za-z])(?=[{RUSSIAN}])", " ", text)


def code_hash(text):
    return hashlib.sha256("\n".join(
        line.partition(";")[0].rstrip() for line in text.splitlines()).encode()).hexdigest()


def main():
    changed = []
    for path in sorted((ROOT / "Source").rglob("*.asm")):
        before = path.read_text("utf-8-sig")
        after = "\n".join(
            code + separator + spaced(comment)
            for line in before.splitlines()
            for code, separator, comment in [line.partition(";")]) + "\n"
        assert code_hash(before) == code_hash(after)
        if before != after:
            path.write_text(after, "utf-8")
            changed.append(path.relative_to(ROOT).as_posix())

    # Согласование русских пояснений реестра с исправленной пунктуацией исходников.
    def normalize(value):
        if isinstance(value, str):
            return spaced(value)
        if isinstance(value, list):
            return [normalize(item) for item in value]
        if isinstance(value, dict):
            return {key: normalize(item) for key, item in value.items()}
        return value

    manifests = list((ROOT / "Tools/Disasm/Reports/Semantics").glob("*.json")) + [
        ROOT / "Tools/Disasm/Reports/DiskUtilityMenuSemantics.json",
        ROOT / "Tools/Disasm/Reports/DiskUtilityDemoSemantics.json",
    ]
    for path in manifests:
        value = json.loads(path.read_text("utf-8-sig"))
        updated = normalize(value)
        if updated != value:
            path.write_text(json.dumps(updated, ensure_ascii=False, indent=2) + "\n", "utf-8")
    print(f"Исправлены пробелы в комментариях {len(changed)} файлов, кодовые строки неизменны")


if __name__ == "__main__":
    main()
