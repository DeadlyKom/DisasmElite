                module Circles
                module DrawCornerRightContour
; -----------------------------------------
; контур угловой дуги с отсечённым правым краем
; исходный диапазон #8FB8..#8FCB
; смысловое имя DrawCornerRightContour
; In: H/E — левый край, CircleState.Flags — направление половины
; Out: правая граница ограничена столбцом 30 с одиночной маской 1
; Corrupt: HL, DE, BC, AF, HL', DE', BC', AF'
; Бит 1 выбирает движение вниз или вверх, при карте столбец 30 патчится в 31
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #8FB8
                ; подготовка фиксированного правого края контурной дуги
Entry:          LD A, E
                AND #E0
                OR #1E
                LD L, A
                LD C, #01
                LD A, (CircleState.Flags)
                BIT CIRC_UP_BIT, A
                CALL NZ, Game.Screen.RightArcDown.Entry                         ; вызов, если признак верхнего положения центра установлен, рисовать дугу вниз
                CALL Z, Game.Screen.RightArcUp.Entry                            ; вызов, если признак верхнего положения центра сброшен, рисовать дугу вверх
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #8FCC
                endmodule
                endmodule
