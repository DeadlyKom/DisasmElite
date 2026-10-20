                module Circles
                module DrawCornerClippedArc
; -----------------------------------------
; дуга круга при одновременном вертикальном и боковом отсечении
; исходный диапазон #88B8..#893E
; смысловое имя DrawCornerClippedArc
; In: BC — расстояния от границ, D — радиус, E — признаки проекции
; Out: видимый участок дуги построен от строки 0 либо 127
; Corrupt: HL, DE, BC, AF, HL', DE', BC', AF'
; Вход #88C2 пропускает нормализацию X
; #8622 получает катет через #8ACD с учётом входного переноса, C'=-#8622 и E'=C задают исходную точку дуги
; Бит 0 выбирает видимый боковой край, бит 1 — движение вниз/вверх
; Для контура выбираются одиночные маски через #8FB8/#8FCC, для заливки граничный край заполнен
; Если рассчитанный правый край левее 8, весь участок отклоняется
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #88B8
                ; нормализация углового отсечения
Entry:          LD A, B
                ADD A, #78
                LD (CircleState.ClipX), A
                LD B, A
                XOR A
                JR SaveCornerCut

                ; расчёт катета пересечения и начальных координат итератора
CornerCathetus: LD A, B
                SUB #77
SaveCornerCut:  EX AF, AF'
                LD DE, (CircleState.Flags)
                LD A, C
                CALL Game.Circles.IntegerCircleCathetus.Entry
                LD (CircleState.Cathetus), A
                LD A, C
                EXX
                LD E, A
                LD A, (CircleState.Cathetus)
                NEG
                LD C, A
                EXX
                BIT CIRC_RIGHT_BIT, E
                JR Z, MoveRightEdge                                             ; переход, если признак правого положения центра сброшен, вычислить правую подвижную границу

                ; расчёт движущегося левого края и выбор граничной строки
                LD A, (CircleState.Cathetus)
                CPL
                ADD A, #81
                ADD A, B
                LD C, #00
                BIT CIRC_UP_BIT, E
                JR NZ, PrepareLeft                                              ; переход, если признак верхнего положения центра установлен, начать на строке 0

                LD C, #7F
                ; подготовка левой маски и выбор заливки либо контура
PrepareLeft:    CALL Game.Circles.ComputeLeftEdgeMask.Entry
                LD A, (CircleState.OutlineOnly)
                AND A
                JP NZ, Game.Circles.DrawCornerRightContour.Entry                ; переход, если выбран контур, использовать одиночную фиксированную маску

                LD A, E
                AND #1F
                CP #1F
                RET Z                                                           ; выход, если левый край уже находится в последнем столбце, видимой ширины нет

                LD A, E
                OR #1F
                LD L, A
                LD C, #00
                LD A, (CircleState.Flags)
                BIT CIRC_UP_BIT, A
                CALL NZ, Game.Screen.RightArcDown.Entry                         ; вызов, если признак верхнего положения центра установлен, двигаться от границы вниз
                CALL Z, Game.Screen.RightArcUp.Entry                            ; вызов, если признак верхнего положения центра сброшен, двигаться от границы вверх
                RET

                ; расчёт движущегося правого края и проверка минимальной координаты 8
MoveRightEdge:  LD A, (CircleState.Cathetus)
                ADD A, #80
                SUB B
                CP #08
                RET C                                                           ; выход, если правая координата меньше 8, круг не достигает видимого столбца

                LD C, #00
                BIT CIRC_UP_BIT, E
                JR NZ, PrepareRight                                             ; переход, если признак верхнего положения центра установлен, начать на строке 0

                LD C, #7F
                ; подготовка правой маски и фиксированного левого края
PrepareRight:   CALL Game.Circles.ComputeRightEdgeMask.Entry
                LD A, L
                AND #E0
                OR #01
                LD E, A
                LD A, (CircleState.OutlineOnly)
                AND A
                JP NZ, Game.Circles.DrawCornerLeftContour.Entry                 ; переход, если выбран контур, использовать одиночный левый пиксель

                LD B, #FF
                LD A, (CircleState.Flags)
                BIT CIRC_UP_BIT, A
                CALL NZ, Game.Screen.LeftArcDown.Entry                          ; вызов, если признак верхнего положения центра установлен, двигаться вниз с левым отсечением
                CALL Z, Game.Screen.LeftArcUp.Entry                             ; вызов, если признак верхнего положения центра сброшен, двигаться вверх с левым отсечением
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #893F
                endmodule
                endmodule
