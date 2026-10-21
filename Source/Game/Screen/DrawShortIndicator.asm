                module Screen
                module DrawShortIndicator
; -----------------------------------------
; рисование шкалы, целиком помещающейся в первом байте
; In:
;   HL, экранный адрес
;   BC, C содержит маску первого байта
; Out:
;   пять строк шкалы записаны
; Corrupt:
;   HL, BC, AF
; Note:
;   в каждой строке выводится C, затем три нулевых байта и правая граница #01
;   пять соседних пиксельных строк достигаются увеличением H
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #85CC
Entry:          LD B, #05
DrawShortRow:   LD A, C
                PUSH HL
                LD (HL), A
                INC L
                XOR A
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
                DJNZ DrawShortRow

                RET

                ASSERT $ == #85E1
                endmodule
                endmodule
