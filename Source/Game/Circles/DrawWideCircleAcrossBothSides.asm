                module Circles
                module DrawWideCircleAcrossBothSides
; -----------------------------------------
; широкий круг с обеими боковыми границами внутри круга
; исходный диапазон #87F4..#883F
; смысловое имя DrawWideCircleAcrossBothSides
; In: BC — смещения центра, D — радиус, состояние отсечения в CircleState.Flags
; Out: средние полные строки и видимая дуга сверху и снизу обработаны
; Corrupt: HL, DE, BC, AF, HL', DE', BC', AF'
; Вход Game.Circles.DrawWideCircleAcrossBothSides.FarSideLimit обслуживает вариант, где центр уже нормализован
; Game.Circles.IntegerCircleCathetus.Entry вычисляет высоту пересечения с дальней боковой границей
; Сначала Game.Screen.FillRowsUp.Entry/Game.Screen.FillRowsDown.Entry заполняют или пропускают полные строки, затем строятся отсечённые дуги
; AF' сохраняет горизонтальный предел, бит 0 CircleState.Flags выбирает левый либо правый обработчик
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #87F4
                ; нормализация широкой внешней дуги относительно боковой границы
Entry:          LD A, B
                ADD A, #78
                LD B, A
                LD (CircleState.ClipX), A
                XOR A
                JR SaveFarLimit

                ; расчёт катета для дальней стороны и предела в AF'
FarSideLimit:   LD A, #88
                ADD A, B
                INC A
SaveFarLimit:   EX AF, AF'
                LD A, #78
                ADD A, B
                CALL Game.Circles.IntegerCircleCathetus.Entry
                LD (CircleState.Cathetus), A
                ; заполнение верхних полных строк перед началом дуги
                LD B, A
                LD A, (CircleState.ScreenY)
                CALL Game.Screen.FillRowsUp.Entry
                CALL Game.Circles.PrepareBothClippedCoordinates.Entry
                CALL Game.Circles.PrepareBothClippedMasksAndFillRows.Entry
                LD A, (CircleState.Flags)
                BIT CIRC_RIGHT_BIT, A
                CALL Z, Game.Screen.LeftArcUp.Entry                             ; вызов, если признак правого положения центра сброшен, построить верхнюю дугу с левым отсечением
                CALL NZ, Game.Screen.RightArcUp.Entry                           ; вызов, если признак правого положения центра установлен, построить верхнюю дугу с правым отсечением
                ; заполнение нижних полных строк перед началом дуги
                LD A, (CircleState.Cathetus)
                LD B, A
                LD A, (CircleState.ScreenY)
                CALL Game.Screen.FillRowsDown.Entry
                CALL Game.Circles.PrepareBothClippedCoordinates.Entry
                CALL Game.Circles.PrepareBothClippedMasksAndFillRows.Entry
                LD A, (CircleState.Flags)
                BIT CIRC_RIGHT_BIT, A
                CALL Z, Game.Screen.LeftArcDown.Entry                           ; вызов, если признак правого положения центра сброшен, построить нижнюю дугу с левым отсечением
                CALL NZ, Game.Screen.RightArcDown.Entry                         ; вызов, если признак правого положения центра установлен, построить нижнюю дугу с правым отсечением
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #8840
                endmodule
                endmodule
