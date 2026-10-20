                module Screen
                module DrawEmptyIndicator
; -----------------------------------------
; рисование пустой шкалы с правой границей
; In:
;   HL, экранный адрес
; Out:
;   пять строк по пять байтов, 00 00 00 00 01
; Corrupt:
;   HL, BC, AF
; Note:
;   левую и верхнюю рамки задаёт фон панели, здесь поддерживается правая граница
;   HL на выходе указывает на первый байт после пятой строки по вертикали
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #85E1
Entry:          LD B, #05
DrawEmptyRow:   XOR A
                PUSH HL
                LD (HL), A
                INC L
                LD (HL), A
                INC L
                LD (HL), A
                INC L
                LD (HL), A
                INC L
                OR #01
                LD (HL), A
                POP HL
                INC H
                DJNZ DrawEmptyRow

                RET
                ASSERT $ == #85F5
                endmodule
                endmodule
