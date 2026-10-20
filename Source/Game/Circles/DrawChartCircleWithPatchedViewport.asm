                module Circles
                module DrawChartCircleWithPatchedViewport
; -----------------------------------------
; рисование окружности карты с временной заменой геометрии экрана
; исходный диапазон #8E29..#8E63
; смысловое имя DrawChartCircleWithPatchedViewport
; In: #D051=X, #D052=Y, #D053=радиус окружности карты
; Out: контур нарисован, стандартные патчи области обзора восстановлены
; Corrupt: HL, DE, BC, AF, HL', DE', BC', AF'
; X переводится в модуль относительно 128, Y относительно 96, знаки записываются в#861C
; Биты 2/3 признаков изначально установлены, координаты берутся из однобайтовых полей карты
; #8E77 применяет 32 байта таблицы карты #8E8D, #86DE рисует контур
; Затем #8E74 выбирает 32 штатных байта #8EAD и снова вызывает патчер
; Перед изменениями DI, патчер заканчивает EI, перед восстановлением снова DI
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #8E29
                ; расчёт модуля и знака X окружности карты относительно 128
Entry:          LD B, CIRC_RANGE_MASK
                LD A, (MapCircleX)
                LD C, A
                SUB #80
                JR C, NegativeX                                                 ; переход, если X карты меньше 128, вычислить отрицательное смещение

                SET CIRC_RIGHT_BIT, B
                JR StoreCenterX

NegativeX:      LD A, #80
                SUB C
StoreCenterX:   LD (CircleState.OffsetX), A
                ; расчёт модуля и знака Y окружности карты относительно 96
                LD A, (MapCircleY)
                LD C, A
                SUB #60
                JR NC, StoreGeometry                                            ; переход, если Y карты не меньше 96, отрицательный знак Y не нужен

                SET CIRC_UP_BIT, B
                LD A, #60
                SUB C
                ; сохранение параметров и применение геометрии полного экрана
StoreGeometry:  LD (CircleState.OffsetY), A
                LD A, B
                LD (CircleState.Flags), A
                LD A, (MapRadius)
                LD (CircleState.Radius), A
                DI
                LD HL, CircleViewport.Chart
                ; вывод контура и восстановление штатных параметров области обзора
                CALL Game.Circles.ApplyCircleViewportPatches.Entry
                CALL Game.Screen.DrawCircleOutline.Entry
                DI
                JR Game.Circles.CheckBodiesAndRestoreViewport.NormalViewport
                ; проверка исходного конца фрагмента
                ASSERT $ == #8E64
                endmodule
                endmodule
