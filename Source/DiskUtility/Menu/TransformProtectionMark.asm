KeyNext         EQU 1                                                           ; следующий элемент таблицы относительно IY
KeyAfterNext    EQU 2                                                           ; элемент таблицы через один относительно IY
; -----------------------------------------
; обратимое XOR-преобразование 256 байтов буфера защитного сектора
; исходный диапазон #C959..#C974
; In:
;   DE, два байта ключа
;   DiskMark.Value, преобразуемый буфер длиной 256 байтов
;   Game.Math.SquareLo, две страницы квадратов для индексных чтений
; Out:
;   HL=DiskMark.Value + #0100, DE сохранён, B=0, C сохранён
;   IY=Game.Math.SquareLo+исходный E
;   буфер преобразован на месте
; Corrupt:
;   HL, BC, AF, IY
; Note:
;   Для i=0..255 байт XOR-ится с D-i, E, (IY + KeyNext) и (IY + KeyAfterNext).
;   Младший IYL увеличивается с восьмибитным оборотом, старший IYH остаётся #BE.
;   Сами чтения (IY + KeyNext)/(IY + KeyAfterNext) могут захватывать Game.Math.SquareLo + #0100 и Game.Math.SquareLo + #0101.
;   B=0 задаёт 256 итераций, после них D и IYL возвращаются к исходным значениям.
;   Повтор с тем же DE и той же таблицей восстанавливает исходные байты.
; -----------------------------------------
                ; подготовка ключа и исходного адреса преобразования
XorMark:        LD IY, Game.Math.SquareLo
                LD HL, DiskMark.Value
                LD B, #00
                LD IYL, E
XorMarkByte:    LD A, (HL)
                XOR D
                XOR E
                XOR (IY + KeyNext)
                XOR (IY + KeyAfterNext)
                DEC D
                LD (HL), A
                INC HL
                INC IYL
                DJNZ XorMarkByte

                RET
