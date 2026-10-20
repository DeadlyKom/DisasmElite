                module Circles
                module BuildLeftContourPixelMask
; -----------------------------------------
; однобитовая маска левого пикселя
; исходный диапазон #8FE3..#8FEC
; смысловое имя BuildLeftContourPixelMask
; In: HL — адрес из ROM, AF — A содержит внутрибитовый сдвиг 0..7
; Out: B=ROR(1,A+1), E=L, A=0
; Corrupt: DE — E, BC — B, AF
; Циклический сдвиг оставляет ровно один установленный бит
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #8FE3
                ; расчёт однобитовой маски левого пикселя
Entry:          LD B, #01
                INC A
RotatePixel:    RRC B
                DEC A
                JR NZ, RotatePixel                                              ; переход, если остались вращения левой однобитовой маски

                LD E, L
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #8FED
                endmodule
                endmodule
