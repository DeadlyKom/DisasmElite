                module Circles
                module SetRightContourBoundary
; -----------------------------------------
; правая фиксированная граница контура
; исходный диапазон #8FDA..#8FE2
; смысловое имя SetRightContourBoundary
; In: E — младший байт левого края строки
; Out: L=(E AND #E0) OR #1E, C=1
; Corrupt: HL — L, BC — C, AF
; Для карты операнд #1E заменяется на #1F, H остаётся прежним
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #8FDA
                ; расчёт граничного столбца правого края
Entry:          LD A, E
                AND #E0
                OR #1E
                LD L, A
                LD C, #01
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #8FE3
                endmodule
                endmodule
