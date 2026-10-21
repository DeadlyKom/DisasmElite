                module Circles
                module PrepareBothClippedCoordinates
; -----------------------------------------
; координаты итератора для двух отсечённых боковых границ
; исходный диапазон #8A16..#8A24
; смысловое имя PrepareBothClippedCoordinates
; In: CircleState.ClipY/CircleState.ClipX — рабочие смещения, CircleState.Cathetus — вычисленный катет
; Out: BC — рабочие смещения, C'=136-B, E'=CircleState.Cathetus
; Corrupt: BC, AF, BC' — C', DE' — E'
; Операнд 136 меняется патчером карты на 128, режим экрана меняет систему отсчёта
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #8A16
                ; расчёт начальных альтернативных координат после двух отсечений
Entry:          LD BC, (CircleState.ClipY)
                LD A, #88
                SUB B
                EXX
                LD C, A
                LD A, (CircleState.Cathetus)
                LD E, A
                EXX
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #8A25
                endmodule
                endmodule
