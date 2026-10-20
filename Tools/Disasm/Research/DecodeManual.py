"""Распаковка и контроль текста руководства исполнением его оригинального кода."""

import hashlib
import json
import struct
import sys
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "Tools/Disasm"))
sys.path.insert(0, str(ROOT / "Tools/Disasm/Research"))
from InspectZ80 import memory_for
from ValidateMath import Simulator, run


def unpack(data):
    output = bytearray()
    position = 0
    stream_end = len(data) - 128
    while position < stream_end:
        value = data[position]
        position += 1
        if value < 128:
            output.append(value)
        elif value >= 192:
            index = stream_end + (value - 192) * 2
            output.extend(data[index:index + 2])
        else:
            distance = (value & 7) * 256 + data[position]
            position += 1
            length = ((value >> 3) & 7) + 3
            assert 0 < distance <= len(output)
            for _ in range(length):
                output.append(output[-distance])
    assert position == stream_end
    return bytes(output)


def font_atlas(font):
    # Создание изображения исходных глифов без изменения шрифта.
    width, height, scale = 16 * 10 * 4, 6 * 10 * 4, 4
    rows = [bytearray([40] * width) for _ in range(height)]
    for index in range(96):
        x0, y0 = (index % 16) * 10 * scale, (index // 16) * 10 * scale
        for y, value in enumerate(font[index * 8:index * 8 + 8]):
            for x in range(8):
                color = 240 if value & (128 >> x) else 0
                for sy in range(scale):
                    rows[y0 + y * scale + sy][x0 + x * scale:x0 + (x + 1) * scale] = bytes([color]) * scale
    def chunk(kind, data):
        return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data))
    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 0, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(b"".join(b"\0" + row for row in rows)))
    png += chunk(b"IEND", b"")
    (ROOT / "Tools/Disasm/Research/ManualFont.png").write_bytes(png)


def main():
    packed = (ROOT / "Source/Manual/Resources/PackedText.bin").read_bytes()
    expected = unpack(packed)
    memory = memory_for("manual")
    memory[0xC9BC:] = packed
    simulator = Simulator(list(memory))
    result = run(simulator, 0x9B0C, hl=0xC9BC, limit=500000)
    finish = result[8] * 256 + result[9]
    actual = bytes(simulator.memory[0xA000:finish])
    assert actual == expected and finish == 0xFCBF
    (ROOT / "Tools/Disasm/Research/ManualDecoded.bin").write_bytes(actual)
    # Сопоставление подтверждено изображением исходных глифов ManualFont.png.
    # Русские буквы занимают #41..#5F, латинские прописные #61..#7A.
    alphabet = "АБЦДЕФГХИЙКЛМНОПЯРСТУЖВЬЫЗШЭЩЧЮ"
    text = "".join("\n" if value == 0 else " " * value if value < 32 else
                   alphabet[value - 65] if 65 <= value <= 95 else
                   chr(value - 32) if 97 <= value <= 122 else
                   "£" if value == 96 else chr(value)
                   for value in actual)
    (ROOT / "Tools/Disasm/Research/ManualReadable.txt").write_text(text, "utf-8")
    font_atlas((ROOT / "Source/Manual/Resources/Font.bin").read_bytes())
    (ROOT / "Tools/Disasm/Reports/ManualValidation.json").write_text(json.dumps({
        "method": "независимая распаковка и исполнение оригинала #9B0C",
        "bytes": len(actual), "end_address": finish,
        "sha256": hashlib.sha256(actual).hexdigest(),
        "encoding": "русские глифы #41..#5F, латинские #61..#7A, пробелы 1..31",
    }, ensure_ascii=False, indent=2) + "\n", "utf-8")
    print(json.dumps({"decoded_bytes": len(actual), "end": hex(finish)}))
    print(text[:1600])


if __name__ == "__main__":
    main()
