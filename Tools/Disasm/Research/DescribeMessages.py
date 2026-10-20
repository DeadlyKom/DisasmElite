"""Индексы двух банков исходных сообщений без запуска игрового интерпретатора."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
MEM=bytes(0x4000)+(ROOT/"Tools/Disasm/Research/GameCode.bin").read_bytes()

def raw_text(data):
    # Управляющие коды и рекурсивные токены сохраняются явно, без предположения о D420.
    return "".join(chr(v) if 32<=v<91 and v not in (58,59) else "{%02X}"%v for v in data)

def bank(start,end,first):
    result=[];cursor=start;index=first
    while cursor<end:
        stop=MEM.index(0,cursor,end)
        data=MEM[cursor:stop]
        result.append(dict(index=index,start=cursor,end=stop+1,bytes=data.hex(),encoded_text=raw_text(data)))
        cursor=stop+1;index+=1
    assert cursor==end
    return result

result=dict(
    notes=["Фигурные скобки означают исходный байт управляющего кода или токена",
           "Первый банк индексируется с0 через #D425, второй с1 через #D45F",
           "#D420 выбирает интерпретатор вложенных байтов, поэтому видимый текст не подменяет исходные токены"],
    primary=bank(0xF11E,0xF4D0,0),secondary=bank(0xF4D0,0xF8A8,1))
(ROOT/"Tools/Disasm/Reports/MessageBanks.json").write_text(json.dumps(result,ensure_ascii=False,indent=2)+"\n",encoding="utf8")
print("Сообщения",len(result["primary"]),len(result["secondary"]))
