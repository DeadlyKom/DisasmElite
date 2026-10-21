                module Trade
                module FillCharacterRowInterior
; -----------------------------------------
; Заполнение пикселей внутри символьной строки
; исходный диапазон #E37D..#E38C
; In:
;   HL = первый пиксельный байт, AF, A = заполнитель
; Out:
;   Заполнено восемь полос по 30 байт, H увеличен на 8
; Corrupt:
;   HL, BC
; Note:
;   L сохраняется между полосами, B=0 после внешнего цикла, DE и AF сохраняются
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E37D
                ; восемь растровых строк очищаются только между крайними ячейками рамки
Entry:          LD B, #08
RasterRow:      PUSH BC
                LD B, #1E
                PUSH HL
FillByte:       LD (HL), A
                INC HL
                DJNZ FillByte

                POP HL
                INC H
                POP BC
                DJNZ RasterRow

                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #E38D
                endmodule
                endmodule
