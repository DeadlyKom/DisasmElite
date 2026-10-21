                module Flight
                module ClearBytes
; -----------------------------------------
; Обнуление заданного диапазона
; исходный диапазон #9503..#9508
; In:
;   HL начало, BC, B длина 1..255,0 означает 256
; Out:
;   HL увеличен на число записей, B=0,A=0,Z=1,C=0
; Corrupt:
;   HL, BC только B, AF
; Note:
;   XOR A задаёт нуль и флаги, LD/INC HL/DJNZ не меняют флаги внутри цикла
; -----------------------------------------
                ASSERT $ == #9503
                ; заполнение B байтов нулями, B=0 означает 256 итераций
Entry:          XOR A
ClearByte:      LD (HL), A
                INC HL
                DJNZ ClearByte

                RET

                ASSERT $ == #9509
                endmodule
                endmodule
