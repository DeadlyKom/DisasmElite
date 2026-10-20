                module Circles
                module PrepareBothClippedMasksAndFillRows
; -----------------------------------------
; маски двух отсечённых краёв и общий заполнитель полных строк
; исходный диапазон #8A25..#8AA2
; смысловое имя PrepareBothClippedMasksAndFillRows
; In: для #8A25 HL — строка, #8629 — режим, для #8A37/#8A4E A — Y и B — число строк
; Out: маски подготовлены либо заполнено до B строк по 30 байтов
; Corrupt: HL, DE, BC, AF, заполнитель сохраняет DE/BC/AF
; #8A37 задаёт движение вверх, #8A4E вниз записью четырёх двухбайтовых патчей
; #8A85 выбирает LD A,H/DEC H либо INC H/LD A,H
; #8A92 выбирает SUB32 либо ADD32, #8A98 — ADD8 либо SUB8
; #8A9E задаёт предел #C0/JR NC вверх либо #D0/JR C вниз
; Заполняются столбцы 1..30 через один байт #FF и LDDR длиной 29
; Исходные NOP в общем теле являются местами исполняемых патчей
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #8A25
                ; проверка режима и установка фиксированных масок области
Entry:          LD A, (CircleState.OutlineOnly)
                AND A
                JP NZ, Game.Circles.SetBothContourBoundaries.Entry              ; переход, если выбран контур, подготовить две одиночные граничные маски

                LD A, L
                AND #E0
                OR #01
                LD E, A
                LD C, #00
                LD B, #FF
                RET

                ; создание четырёх патчей прохода полных строк вверх
PatchUpward:    LD HL, #257C
                LD (CircleRaster.RowStep), HL
                LD HL, #20D6
                LD (CircleRaster.CellStep), HL
                LD HL, #08C6
                LD (CircleRaster.ThirdStep), HL
UpperLimit      EQU $ + 1                                                       ; верхний предел в младшем байте пары предела и кода JR
                LD HL, #30C0
                JR SaveContext

                ; создание четырёх патчей прохода полных строк вниз
PatchDownward:  LD HL, #7C24
                LD (CircleRaster.RowStep), HL
                LD HL, #20C6
                LD (CircleRaster.CellStep), HL
                LD HL, #08D6
                LD (CircleRaster.ThirdStep), HL
LowerLimit      EQU $ + 1                                                       ; нижний предел в младшем байте пары предела и кода JR
                LD HL, #38D0
                ; установка последнего патча и сохранение входных регистров
SaveContext:    LD (CircleRaster.LimitBranch), HL
                PUSH DE
                PUSH AF
                PUSH BC
                LD C, #F8
                ; вычисление адреса крайнего столбца стартовой строки
                CALL Rom.PixelFromA
BufferOpcode    EQU $                                                           ; двухбайтовый SET 7,H либо NOP/NOP для заполнения строк
                SET 7, H
                POP BC
                PUSH BC
                ; проверка числа строк без изменения B
                DEC B
                INC B
                JR Z, RestoreContext                                            ; переход, если число полных строк равно нулю

                ; заполнение тридцати байтов строки от правого края назад
FillRow:        PUSH HL
                DEC HL
                LD (HL), #FF
                LD D, H
                LD E, L
                DEC DE
                PUSH BC
                LD BC, #001D
                LDDR
                POP BC
                POP HL
                ; изменяемые команды шага по H для текущего направления
RowStep         EQU $                                                           ; пара LD A,H/DEC H либо INC H/LD A,H, направление обхода
                NOP
                NOP
                AND #07
                JR Z, CrossCharRow                                              ; переход, если достигнута граница восьмистрочного блока

CountRow:       DJNZ FillRow

RestoreContext: POP BC
                POP AF
                POP DE
                RET

                ; коррекция младшего байта на границе восьмистрочного блока
CrossCharRow:   LD A, L
CellStep        EQU $                                                           ; пара SUB #20 либо ADD A,#20, переход между знакоместами
                NOP
                NOP
                LD L, A
                LD A, H
                JR C, CheckViewport                                             ; переход, если изменение младшего байта адреса дало перенос или заём, проверить предел трети
ThirdStep       EQU $                                                           ; пара ADD A,#08 либо SUB #08, коррекция трети экрана
                ADD A, #08
                LD H, A
                JR CountRow
                ; проверка предела экрана с изменяемым сравнением и условием
LimitBranch     EQU $ + 1                                                       ; операнд CP и код следующего JR, предел и условие продолжения
CheckViewport:  CP #00
                JR NC, CountRow                                                 ; переход, если патч верхнего режима даёт H не ниже#C0, продолжить строки

                JR RestoreContext
                ; проверка исходного конца фрагмента
                ASSERT $ == #8AA3
                endmodule
                endmodule
