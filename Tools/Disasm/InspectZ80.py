"""Статическое чтение Z80-инструкций, не выполняет и не собирает программу."""

import argparse
import sys
from pathlib import Path
from types import SimpleNamespace

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "Tools/Disasm/Research/vendor/skoolkit-10.1"))
from skoolkit.disassembler import Disassembler


class Instruction:
    def __init__(self, address, operation, data):
        self.address = address
        self.operation = operation
        self.bytes = bytes(data)
        self.variant = 0


def decoder(memory):
    return Disassembler(list(memory), SimpleNamespace(
        asm_hex=True, asm_lower=False, defb_size=16, defm_size=64,
        defw_size=8, handle_rst=False, imaker=Instruction, opcodes="", wrap=False))


def memory_for(region):
    memory = bytearray(65536)
    if region in ("game", "decoded"):
        # Размещение исходных файловых байтов по сохранённым адресам снимка.
        path = ("Tools/Disasm/Research/GameCode.bin" if region == "decoded"
                else "Tools/Disasm/Extracted/Active/02_ELITE3.C")
        memory[0x4000:] = (ROOT / path).read_bytes()
    elif region == "loader":
        data = (ROOT / "Tools/Disasm/Extracted/Active/01_ELITE3.B").read_bytes()
        memory[0xC800:0xC90A] = data[0x14:0x11E]
    elif region == "manual":
        data = (ROOT / "Tools/Disasm/Extracted/Active/00_ELITE3HL.B").read_bytes()
        memory[0x9648:0x9B5A] = data[0x2D:0x53F]
    elif region == "cl":
        data = (ROOT / "Tools/Disasm/Extracted/Active/03_cl.C").read_bytes()
        memory[0x6000:0x7100] = data
    else:
        raise ValueError(region)
    return memory


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("region", choices=("game", "decoded", "loader", "manual", "cl"))
    parser.add_argument("start", type=lambda value: int(value, 0))
    parser.add_argument("end", type=lambda value: int(value, 0))
    args = parser.parse_args()
    for instruction in decoder(memory_for(args.region)).disassemble(
            args.start, args.end, "h"):
        print(f"{instruction.address:04X}  {instruction.bytes.hex(' '):12}  "
              f"{instruction.operation}")
