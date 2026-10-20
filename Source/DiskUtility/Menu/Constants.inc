
; исходные указатели, размещение памяти не изменяется
ROM_FDC_WRITE   EQU #3FCA                                                       ; обработчик вывода потока TR-DOS, вызывается через шлюз и стек
ROM_SEED_BASE   EQU DiskUtility.ResetRom                                        ; начало ПЗУ, откуда в защитный сектор копируются #F2 исходных байта
CopyEntry       EQU Memory.Frame + #0500                                        ; первый из трёх секторов копировщика, адрес последующего RET
CopyReadPage    EQU CopyEntry + #0200                                           ; адрес первого прочитанного сектора 3, далее страницы #C600/#C500
CopyAttributes  EQU Memory.Attributes + 8 * 32                                  ; адрес в IY при передаче копировщику, атрибутная строка 8
CopyEntryHL     EQU #E000                                                       ; значение HL при RET в CopyEntry, последующее использование не подтверждено
ListAttributes  EQU Memory.Attributes + 32                                      ; вторая символьная строка, начало заливки рамки каталога
