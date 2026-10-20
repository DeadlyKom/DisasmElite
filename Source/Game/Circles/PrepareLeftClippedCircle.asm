                module Circles
                module PrepareLeftClippedCircle
; -----------------------------------------
; подготовка строки круга с отсечённым левым краем
; исходный диапазон #89A1..#89C2
; смысловое имя PrepareLeftClippedCircle
; In: рабочие смещения и радиус через #89C3
; Out: правый край вычислен, E задаёт столбец 1, B — маска левого края
; Corrupt: HL, DE, BC, AF, BC', DE'
; Правая координата равна 128+r-B
; Заливка использует B=#FF, контур использует B=#80
; Столбец 1 — исходная левая граница области, патчер карты меняет операнд на 0
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #89A1
                ; расчёт правого движущегося края левого отсечения
Entry:          CALL Game.Circles.LoadCircleIterationCoordinates.Entry
                LD A, (CircleState.ScreenY)
                LD C, A
                LD A, #80
                ADD A, D
                SUB B
                CALL Game.Circles.ComputeRightEdgeMask.Entry
                LD A, L
                AND #E0
                OR #01
                LD E, A
                LD B, A
                LD A, (CircleState.OutlineOnly)
                AND A
                LD A, B
                JR NZ, OutlineMask                                              ; переход, если выбран контур, заменить сплошную левую маску на#80

                LD B, #FF
                RET

OutlineMask:    LD B, #80
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #89C3
                endmodule
                endmodule
