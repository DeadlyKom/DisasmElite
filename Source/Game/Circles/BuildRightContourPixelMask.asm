                module Circles
                module BuildRightContourPixelMask
; -----------------------------------------
; однобитовая маска правого пикселя
; исходный диапазон #8FED..#8FF8
; смысловое имя BuildRightContourPixelMask
; In: AF — A содержит 8-смещение пикселя, #8627 — сохранённая левая маска
; Out: C=ROL(#80,A), B восстановлен из#8627
; Corrupt: BC, AF
; Вращение, в отличие от заливки, не накапливает сплошные единицы
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #8FED
                ; расчёт однобитовой маски правого пикселя
Entry:          LD C, #80
RotatePixel:    RLC C
                DEC A
                JR NZ, RotatePixel                                              ; переход, если остались вращения правой однобитовой маски

                LD A, (CircleState.LeftMask)
                LD B, A
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #8FF9
                endmodule
                endmodule
