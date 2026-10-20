"""Проверка и документирование упакованной геометрии, не часть сборки."""
import argparse
import json
import re
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
MEM=bytes(0x4000)+(ROOT/"Tools/Disasm/Research/GameCode.bin").read_bytes()
NAMES=[
("Coriolis","станция Coriolis"),("Missile","ракета"),("EscapePod","спасательная капсула"),
("Alloys","обломки сплавов"),("Cargo","грузовой контейнер"),("Minerals","минеральный обломок"),
("Asteroid","обычный астероид"),("AsteroidArmed","особый астероид с запускаемыми объектами"),
("Viper","полицейский Viper"),("CobraTrader","торговая Cobra Mk III"),
("PythonTrader","торговый Python"),("PythonPirate","пиратский Python"),
("CobraPirate","пиратская Cobra Mk III"),("Asp","Asp Mk II"),("FerDeLance","Fer-de-Lance"),
("Thargoid","Thargoid"),("Sidewinder","Sidewinder"),("Adder","Adder"),
("Tharglet","малый Tharglet"),("Thargoid6","шестигранный Thargoid"),
("Fighter1","дополнительный истребитель 1"),("Fighter2","дополнительный истребитель 2"),
("Krait","Krait")]

def word(a):return int.from_bytes(MEM[a:a+2],"little")
def resource(start,end,kind,model,summary):
    return dict(start=start,end=end,kind=kind,model=model,summary=summary)

def vectors(base,count,stride,model,kind):
    result=[];start=base+count*stride;cursor=start
    for i in range(count):
        attr=base+i*stride;flags=MEM[attr]
        xyz=list(MEM[cursor:cursor+3])
        result.append(dict(index=i,attributes=attr,coordinate_address=cursor,flags=flags,
                           coordinates=xyz,signs=[bool(flags&m) for m in (128,64,32)],
                           faces=list(MEM[attr+1:attr+stride])))
        if i+1<count and MEM[attr+stride]&1:cursor+=3
    ranges=[]
    if count:
        ranges.append(resource(base,start,kind+"_attributes",model,
            f"{count} записей признаков по {stride} байт, бит 0 следующей записи выбирает новую тройку координат"))
        ranges.append(resource(start,cursor+3,kind+"_coordinates",model,
            f"{(cursor+3-start)//3} общих троек модулей X/Y/Z, знаки берутся из признаков"))
    return result,ranges

def edges(base,count,model):
    thresholds=word(base);pairs=word(base+2);fp=base+4;tp=thresholds;remaining=1;result=[]
    for i in range(count):
        if not MEM[tp]&32:
            remaining=MEM[tp];tp+=1
        flags=MEM[tp];remaining=(remaining-1)&255
        if not remaining:remaining=1;tp+=1
        pair=MEM[pairs+i]
        result.append(dict(index=i,threshold=flags&31,vertex1=(pair&15)+((flags&64)>>2),
            vertex2=(pair>>4)+((flags&128)>>3),faces=MEM[fp],face_address=fp))
        if MEM[fp+1]!=255:fp+=1
    ranges=[resource(base,base+4,"edge_pointers",model,
        f"два абсолютных указателя, пороги #{thresholds:04X}, пары вершин #{pairs:04X}"),
        resource(base+4,result[-1]["face_address"]+1,"edge_faces",model,"пары номеров граней, #FF после записи удерживает последнюю пару"),
        resource(thresholds,tp,"edge_thresholds",model,"порог в младших пяти битах, биты 6/7 дополняют номера вершин, префикс без бита5 задаёт повтор"),
        resource(pairs,pairs+count,"edge_pairs",model,"по одной паре младших тетрад номеров вершин на ребро")]
    last_face=result[-1]["face_address"]
    if MEM[last_face+1]==255:ranges[1]["end"]=last_face+2
    return result,ranges

def legacy_vertices(path):
    rows=[]
    for line in path.read_text(encoding="cp866").splitlines():
        m=re.match(r"\s*db\s+([^;]+)",line,re.I)
        if not m:continue
        try:v=[int(x.strip().replace("#","0x").replace("%","0b"),0) for x in m[1].strip().split(",")]
        except ValueError:continue
        if len(v)==6:rows.append(tuple(v[:3])+(v[3]&224,))
    return rows

def run(legacy=None):
    models=[];ranges=[]
    references={}
    # Необязательное сопоставление координат не меняет декодирование целевого TRD.
    if legacy is not None:
        if not legacy.is_dir():
            raise ValueError("Не найден явно указанный каталог исторических моделей")
        references={p.relative_to(legacy).as_posix():legacy_vertices(p)
                    for p in legacy.rglob("*.a80")}
    for index,(name,title) in enumerate(NAMES):
        p=word(0x6181+4*index)
        v=MEM[p:p+23]
        vb=p+word(p+12);eb=p+word(p+14);nb=p+word(p+16)
        vertices,vr=vectors(vb,v[3],3,name,"vertex")
        normals,nr=vectors(nb,v[5],1,name,"normal")
        edge_rows,er=edges(eb,v[4],name)
        signature=[tuple(x["coordinates"])+(x["flags"]&224,) for x in vertices]
        matches=[f for f,rows in references.items() if len(rows)>=len(signature) and rows[:len(signature)]==signature]
        models.append(dict(index=index,name=name,title=title,header=p,header_bytes=v.hex(),
            vertex_base=vb,edge_base=eb,normal_base=nb,vertices=vertices,edges=edge_rows,normals=normals,
            vertex_reference_matches=matches,reference_note="Геометрия, тарифы и свойства декодированы из текущих байтов. Необязательные совпадения координат указаны относительно явно заданного каталога"))
        ranges += vr+nr+er
    covered=set()
    for r in ranges:covered.update(range(r["start"],r["end"]))
    holes=[];cursor=0x63F4
    while cursor<0x6EBC:
        if cursor in covered:cursor+=1;continue
        start=cursor
        while cursor<0x6EBC and cursor not in covered:cursor+=1
        holes.append(dict(start=start,end=cursor,bytes=MEM[start:cursor].hex()))
    result=dict(format={
        "vertices":"N трёхбайтовых записей [знаки/порог, грани01, грани23], затем общие тройки модулей координат",
        "normals":"N однобайтовых записей знаков/порога, затем общие тройки модулей нормалей",
        "reuse":"#AE1D/#AE26 читают бит0 следующей записи, при нуле указатель модулей не сдвигается, при единице увеличивается на3",
        "edges":"Два абсолютных слова порогов/пар, затем пары граней с повтором через следующий #FF",
        "thresholds":"Если бит5 сброшен, байт задаёт число повторов следующего порога, биты6/7 порога задают старшие биты номеров вершин"},
        models=models,resources=sorted(ranges,key=lambda r:(r["start"],r["kind"],r["model"])),unclaimed_bytes=holes)
    (ROOT/"Tools/Disasm/Reports/ModelGeometry.json").write_text(json.dumps(result,ensure_ascii=False,indent=2)+"\n",encoding="utf8")
    print("Моделей",len(models),"ресурсных диапазонов",len(ranges),"непокрытых байтов",sum(h["end"]-h["start"]for h in holes))
    for m in models:print(f'{m["index"]:02X} {m["header"]:04X} {m["name"]}: совпадений координат {len(m["vertex_reference_matches"])}')

if __name__=="__main__":
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--legacy-ships",type=Path,
                        help="необязательный каталог исторических моделей для сравнения координат")
    run(parser.parse_args().legacy_ships)
