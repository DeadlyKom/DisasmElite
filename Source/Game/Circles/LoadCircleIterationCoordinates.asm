                module Circles
                module LoadCircleIterationCoordinates
; -----------------------------------------
; загрузка исходных координат итератора дуги
; исходный диапазон #89C3..#89D3
; смысловое имя LoadCircleIterationCoordinates
; In: CircleState.ClipY/CircleState.ClipX — рабочие модули, CircleState.Flags/CircleState.Radius — признаки и радиус
; Out: BC и DE загружены из памяти, C'=-радиус, E'=0
; Corrupt: DE, BC, AF, BC' — C', DE' — E'
; HL и альтернативный HL сохраняются, старшие D'/B' задаются внешней обёрткой
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #89C3
                ; загрузка радиуса и настройка альтернативных координат
Entry:          LD BC, (CircleState.ClipY)
                LD DE, (CircleState.Flags)
                LD A, D
                NEG
                EXX
                LD C, A
                LD E, #00
                EXX
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #89D4
                endmodule
                endmodule
