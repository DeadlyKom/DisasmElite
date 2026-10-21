                module Circles
                module PrepareRightClippedCircle
; -----------------------------------------
; подготовка строки круга с отсечённым правым краем
; исходный диапазон #8985..#89A0
; смысловое имя PrepareRightClippedCircle
; In: BC — рабочие смещения, D — радиус через Game.Circles.LoadCircleIterationCoordinates.Entry
; Out: левый край вычислен, правый ограничен краем области
; Corrupt: HL, DE, BC, AF, BC', DE'
; Левая координата равна 128+B-r
; Для заливки правый адрес получает младшие биты 31 и C=0
; Для контура Game.Circles.SetRightContourBoundary.Entry ставит столбец 30 и маску C=1
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #8985
                ; расчёт левого движущегося края правого отсечения
Entry:          CALL Game.Circles.LoadCircleIterationCoordinates.Entry
                LD A, (CircleState.ScreenY)
                LD C, A
                LD A, #80
                ADD A, B
                SUB D
                CALL Game.Circles.ComputeLeftEdgeMask.Entry
                ; проверка режима перед установкой правой границы
                LD A, (CircleState.OutlineOnly)
                AND A
                JP NZ, Game.Circles.SetRightContourBoundary.Entry               ; переход, если выбран контур, ограничить правый край одиночным пикселем

                LD A, E
                OR #1F
                LD L, A
                LD C, #00
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #89A1
                endmodule
                endmodule
