                module Circles
                module DrawCornerWideCircle
; -----------------------------------------
; широкий круг с вертикальным и боковым отсечением
; исходный диапазон #8840..#888D
; смысловое имя DrawCornerWideCircle
; In: BC — смещения относительно края, D — радиус, CircleState.Flags — признаки
; Out: заполнены полные строки до пересечения и нарисована оставшаяся дуга
; Corrupt: HL, DE, BC, AF, HL', DE', BC', AF'
; Вход Game.Circles.DrawCornerWideCircle.CrossingHeight пропускает начальную нормализацию горизонтального смещения
; Высота пересечения вычисляется через Game.Circles.IntegerCircleCathetus.Entry с учётом переноса от ADD A,B, затем вычитается C
; Бит 1 выбирает верхнюю/нижнюю экранную границу, бит 0 — сторону отсечения
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #8840
                ; нормализация внешнего угла для широкого круга
Entry:          LD A, B
                ADD A, #78
                LD B, A
                LD (CircleState.ClipX), A
                XOR A
                JR SaveRowLimit

                ; расчёт высоты пересечения и числа полностью закрытых строк
CrossingHeight: LD A, B
                SUB #77
SaveRowLimit:   EX AF, AF'
                LD DE, (CircleState.Flags)
                LD A, #78
                ADD A, B
                CALL Game.Circles.IntegerCircleCathetus.Entry
                LD (CircleState.Cathetus), A
                SUB C
                LD B, A
                BIT CIRC_UP_BIT, E
                JR Z, FillUpward                                                ; переход, если признак верхнего положения центра сброшен, начать от нижней строки 127 и идти вверх

                ; вывод полных строк вниз и выбор бокового отсечения
                XOR A
                CALL Game.Screen.FillRowsDown.Entry
                CALL Game.Circles.PrepareBothClippedCoordinates.Entry
                CALL Game.Circles.PrepareBothClippedMasksAndFillRows.Entry
                LD A, (CircleState.Flags)
                BIT CIRC_RIGHT_BIT, A
                CALL Z, Game.Screen.LeftArcDown.Entry                           ; вызов, если признак правого положения центра сброшен, построить нижнюю дугу с левым отсечением
                CALL NZ, Game.Screen.RightArcDown.Entry                         ; вызов, если признак правого положения центра установлен, построить нижнюю дугу с правым отсечением
                RET

                ; вывод полных строк вверх и выбор бокового отсечения
FillUpward:     LD A, #7F
                CALL Game.Screen.FillRowsUp.Entry
                CALL Game.Circles.PrepareBothClippedCoordinates.Entry
                CALL Game.Circles.PrepareBothClippedMasksAndFillRows.Entry
                LD A, (CircleState.Flags)
                BIT CIRC_RIGHT_BIT, A
                CALL Z, Game.Screen.LeftArcUp.Entry                             ; вызов, если признак правого положения центра сброшен, построить верхнюю дугу с левым отсечением
                CALL NZ, Game.Screen.RightArcUp.Entry                           ; вызов, если признак правого положения центра установлен, построить верхнюю дугу с правым отсечением
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #888E
                endmodule
                endmodule
