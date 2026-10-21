                module Circles
                module DrawVerticalClippedCircle
; -----------------------------------------
; дуга с вертикальным отсечением без бокового отсечения
; исходный диапазон #893F..#8984
; смысловое имя DrawVerticalClippedCircle
; In: C — расстояние центра от верхней/нижней границы, D — радиус
; Out: одна видимая половина круга нарисована начиная со строки 0 либо 127
; Corrupt: HL, DE, BC, AF, HL', DE', BC', AF'
; Катет по Game.Circles.IntegerCircleCathetus.Entry с учётом входного переноса задаёт начальную полуширину пересечения
; C'=-катет и E'=C передаются итератору, экранные края равны X±катет
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #893F
                ; расчёт катета на вертикальной границе
Entry:          LD DE, (CircleState.Flags)
                LD A, C
                CALL Game.Circles.IntegerCircleCathetus.Entry
                LD (CircleState.Cathetus), A
                LD A, C
                EXX
                LD E, A
                LD A, (CircleState.Cathetus)
                NEG
                LD C, A
                ; выбор исходной строки 0 либо 127
                EXX
                XOR A
                BIT CIRC_UP_BIT, E
                JR NZ, CrossingEnds                                             ; переход, если признак верхнего положения центра установлен, начать на строке 0

                LD A, #7F
                ; расчёт экранных концов пересечения X-катет и X+катет
CrossingEnds:   LD (CircleState.ScreenY), A
                LD C, A
                LD A, (CircleState.Cathetus)
                LD L, A
                LD A, (CircleState.ScreenX)
                SUB L
                CALL Game.Circles.ComputeLeftEdgeMask.Entry
                LD A, (CircleState.ScreenY)
                LD C, A
                LD A, (CircleState.Cathetus)
                LD L, A
                LD A, (CircleState.ScreenX)
                ADD A, L
                CALL Game.Circles.ComputeRightEdgeMask.Entry
                ; выбор верхней либо нижней неотсечённой половины
                LD A, (CircleState.Flags)
                BIT CIRC_UP_BIT, A
                CALL NZ, Game.Screen.UnclippedArcDown.Entry                     ; вызов, если признак верхнего положения центра установлен, построить нижнюю половину без бокового отсечения
                CALL Z, Game.Screen.UnclippedArcUp.Entry                        ; вызов, если признак верхнего положения центра сброшен, построить верхнюю половину без бокового отсечения
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #8985
                endmodule
                endmodule
