                module Circles
                module DispatchClippedCircle
; -----------------------------------------
; выбор участка круга по четырём границам области обзора
; исходный диапазон #86EE..#87BE
; смысловое имя DispatchClippedCircle
; In:
;   CircleState.OffsetY/OffsetX, модули смещения центра
;   CircleState.Flags, признаки знаков и диапазона
;   CircleState.Radius, радиус окружности
; Out: видимая часть круга передана подходящему обработчику, полностью внешние случаи отброшены
; Corrupt: HL, DE, BC, AF, HL', DE', BC', AF'
; #8620 получает 64±Y, #8621 получает 128±X, рабочие модули сохраняются в #861E/#861F
; Бит 0 признаков выбирает знак X, бит 1 выбирает знак Y, биты 2/3 участвуют в проверках допустимости проекции
; Узкая область обзора имеет полуширину 120 и полувысоту 64, патчер карты меняет эти пределы
; Внешние углы проверяются по r²-dy²-dx² без вычисления квадратного корня
; #8736 — центр внутри, #874B — снаружи по X, #875E — снаружи по Y, #878E — снаружи по обеим осям
; Флаги вертикального сравнения временно хранятся в AF', BIT сохраняет перенос от CP
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #86EE
                ; сохранение модулей центра и расчёт экранной координаты Y
Entry:          LD BC, (CircleState.OffsetY)
                LD (CircleState.ClipY), BC
                LD DE, (CircleState.Flags)
                LD A, #40
                BIT CIRC_UP_BIT, E
                JR NZ, FinishCenterY                                            ; переход, если признак верхнего положения центра установлен, использовать 64-Y

                ADD A, C
                ADD A, C
FinishCenterY:  SUB C
                LD (CircleState.ScreenY), A
                LD A, #80
                BIT CIRC_RIGHT_BIT, E
                JR Z, FinishCenterX                                             ; переход, если признак правого положения центра сброшен, использовать 128-X

                ADD A, B
                ADD A, B
FinishCenterX:  SUB B
                LD (CircleState.ScreenX), A
                LD A, C
                CP #40
                BIT CIRC_YRANGE_BIT, E
                ; проверка горизонтальной границы и выбор сочетания отсечений
                EX AF, AF'
                LD A, B
                CP #78
                BIT CIRC_XRANGE_BIT, E
                JR Z, CheckOuterX                                               ; переход, если бит 2 признаков сброшен, проверить особый горизонтальный случай

                JR NC, OuterX                                                   ; переход, если модуль X не меньше 120, перейти к внешнему горизонтальному случаю

                EX AF, AF'
                JR Z, CheckOuterY                                               ; переход, если бит 3 вертикальных признаков сброшен, проверить особый вертикальный случай

                JR NC, OuterY                                                   ; переход, если модуль Y не меньше 64, центр находится за вертикальной границей

                JR InnerCenter

CheckOuterY:    RET NC                                                          ; выход, если при сброшенном бите 3 модуль Y не меньше 64, допустимого участка нет

                JR OuterY

CheckOuterX:    RET NC                                                          ; выход, если при сброшенном бите 2 модуль X не меньше 120, допустимого участка нет

OuterX:         EX AF, AF'
                JR Z, OuterYCorner                                              ; переход, если бит 3 вертикальных признаков сброшен, проверить вторую внешнюю границу

                JR NC, OuterCorner                                              ; переход, если модуль Y не меньше 64, обработать внешний угол

                JR MeasureSideGap

OuterYCorner:   RET NC                                                          ; выход, если при сброшенном бите 3 модуль Y не меньше 64, допустимого участка нет

                JR OuterCorner

                ; проверка полного диаметра при центре внутри области
InnerCenter:    LD A, B
                ADD A, D
                JR C, CheckHalfWidth                                            ; переход, если X+r переполнило байт, круг пересекает боковую границу

                CP #78
                JP C, Game.Circles.DrawUnclippedCircle.Entry                    ; переход, если X+r меньше 120, обе боковые границы круга помещаются

CheckHalfWidth: LD A, D
                SUB B
                JR C, SelectSideClip                                            ; переход, если радиус меньше смещения X, вычитание дало заём

                CP #78
SelectSideClip: JP C, Game.Circles.DrawOneSideClippedCircle.SideLimit           ; переход, если внутренняя полуширина меньше 120 либо вычитание дало заём, достаточно одного отсечения

                JP Game.Circles.DrawWideCircleAcrossBothSides.FarSideLimit

                ; расчёт расстояния от внешнего центра до боковой границы
MeasureSideGap: LD A, B
                SUB #78
                LD B, A
                LD (CircleState.ClipX), A
                LD A, D
                SUB B
                RET C                                                           ; выход, если радиус меньше расстояния центра от боковой границы

                RET Z                                                           ; выход, если радиус равен расстоянию до боковой границы, ненулевой дуги нет

                SUB #F0
                JP NC, Game.Circles.DrawWideCircleAcrossBothSides.Entry         ; переход, если оставшаяся ширина не меньше 240, круг покрывает обе боковые границы

                JP Game.Circles.DrawOneSideClippedCircle.Entry

                ; проверка пересечения с вертикальной границей по квадратам расстояний
OuterY:         LD A, C
                SUB #40
                LD C, A
                LD (CircleState.ClipY), A
                LD A, D
                SUB C
                RET C                                                           ; выход, если радиус меньше расстояния до вертикальной границы

                LD A, D
                CALL Game.Math.Square
                LD H, D
                LD L, E
                LD A, C
                CALL Game.Math.Square
                SBC HL, DE
                LD A, #78
                SUB B
                CALL Game.Math.Square
                SBC HL, DE
                JP C, Game.Circles.DrawVerticalClippedCircle.Entry              ; переход, если r²-dy² меньше квадрата расстояния до ближней боковой границы

                ADD HL, DE
                LD A, #78
                ADD A, B
                CALL Game.Math.Square
                SBC HL, DE
                JP NC, Game.Circles.DrawCornerWideCircle.CrossingHeight         ; переход, если r²-dy² не меньше квадрата расстояния до дальней боковой границы

                JP Game.Circles.DrawCornerClippedArc.CornerCathetus

                ; проверка пересечения внешнего угла по r²-dy²-dx²
OuterCorner:    LD A, B
                SUB #78
                LD B, A
                LD A, C
                SUB #40
                LD C, A
                LD (CircleState.ClipY), BC
                LD A, D
                CALL Game.Math.Square
                LD H, D
                LD L, E
                LD A, C
                CALL Game.Math.Square
                SBC HL, DE
                RET C                                                           ; выход, если r² меньше dy², круг не достигает строки экрана

                LD A, B
                CALL Game.Math.Square
                SBC HL, DE
                RET C                                                           ; выход, если r²-dy² меньше dx², круг не достигает угла экрана

                ADD HL, DE
                LD A, B
                ADD A, #F8
                JR C, NarrowCorner                                              ; переход, если расстояние до дальней стороны не помещается в байте

                CALL Game.Math.Square
                SBC HL, DE
                JP NC, Game.Circles.DrawCornerWideCircle.Entry                  ; переход, если круг достигает дальней боковой границы, нужен широкий угловой вариант

NarrowCorner:   JP Game.Circles.DrawCornerClippedArc.Entry
                ; проверка исходного конца фрагмента
                ASSERT $ == #87BF
                endmodule
                endmodule
