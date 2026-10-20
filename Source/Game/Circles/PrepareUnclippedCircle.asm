                module Circles
                module PrepareUnclippedCircle
; -----------------------------------------
; адреса и маски строки диаметра неотсечённого круга
; исходный диапазон #87D4..#87F3
; смысловое имя PrepareUnclippedCircle
; In: #8620/#8621 — экранный центр, #861D — радиус
; Out: H/E — адрес левого края, HL — адрес правого, B/C — краевые маски
; Corrupt: HL, DE, BC, AF, BC', DE'
; C'=-радиус, E'=0 являются начальными координатами итерационного построителя
; Левая координата равна X-r, правая X+r, обе переводятся через ROM #22B0
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #87D4
                ; расчёт начального X'=-r и двух экранных концов диаметра
Entry:          LD BC, (CircleState.ScreenY)
                LD DE, (CircleState.Flags)
                LD A, D
                NEG
                EXX
                LD C, A
                LD E, #00
                EXX
                LD A, B
                SUB D
                CALL Game.Circles.ComputeLeftEdgeMask.Entry
                LD A, (CircleState.ScreenY)
                LD C, A
                LD A, (CircleState.ScreenX)
                ADD A, D
                JP Game.Circles.ComputeRightEdgeMask.Entry
                ; проверка исходного конца фрагмента
                ASSERT $ == #87F4
                endmodule
                endmodule
