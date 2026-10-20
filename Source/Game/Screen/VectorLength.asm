                module Screen
                module VectorLength
; -----------------------------------------
; приближённая длина трёхмерного вектора с нормированием
; In:
;   IX, адрес младших слов трёх координат с шагом 3
; Out:
;   HL, приближённая длина, 0 также означает переполнение удвоенного результата
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   координаты совместно сдвигаются влево до появления старшего бита
;   A хранит степень двоичного масштаба, B учитывает переносы суммы трёх квадратов
;   квадраты старших байтов берутся из таблицы #BE00/#BF00
;   сумма до 18 бит делится на 4 при переполнении слова, масштаб корня корректируется
;   #9C86 переходит к исходному приближённому SquareRoot, округления сохраняются
;   с #8390 начинается самостоятельная процедура рисования указателя компаса
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #8322
Entry:          CALL Game.Screen.LoadVectorWords.Entry
                LD A, #01
                ; нормирование трёх координат с общим коэффициентом
Normalize:      EX DE, HL
                ADD HL, HL
                EX DE, HL
                JR C, UndoFirstShift                                            ; переход, если старший бит первой координаты достиг границы нормирования

                SLA C
                RL B
                JR C, UndoTwoShifts                                             ; переход, если старший бит второй координаты достиг границы нормирования

                ADD HL, HL
                JR C, UndoAllShifts                                             ; переход, если старший бит третьей координаты достиг границы нормирования

                ADD A, A
                JR NC, Normalize                                                ; переход, если допустимо ещё одно удвоение масштаба

UndoFirstShift: RR D
                JR SumSquares

UndoTwoShifts:  RR B
                SRL D
                JR SumSquares

UndoAllShifts:  RR H
                SRL B
                SRL D
                ; расчёт суммы квадратов нормированных старших байтов
SumSquares:     LD C, D
                PUSH AF
                LD A, H
                CALL Game.Math.Square
                EX DE, HL
                LD A, B
                LD B, #00
                CALL Game.Math.Square
                ADD HL, DE
                JR NC, AddThirdSquare                                           ; переход, если сумма первых двух квадратов поместилась в слово

                INC B
AddThirdSquare: LD A, C
                CALL Game.Math.Square
                ADD HL, DE
                JR NC, CheckOverflow                                            ; переход, если добавление третьего квадрата не вызвало переноса

                INC B
                ; проверка переполнения шестнадцатибитной суммы квадратов
CheckOverflow:  LD A, B
                AND A
                JR Z, TakeRoot                                                  ; переход, если сумма квадратов не превышает 65535

                SRL B
                RR H
                RR L
                SRL B
                RR H
                RR L
                POP AF
                SRL A
                JR Z, DoubleRoot                                                ; переход, если деление суммы на четыре требует удвоить корень

                PUSH AF
                ; вычисление корня и восстановление масштаба
TakeRoot:       CALL Game.Combat.SquareRootVectorLength.Entry
                POP AF
RestoreScale:   SRL A
                JR Z, LengthReady                                               ; переход, если исходный масштаб уже восстановлен

                SRL H
                RR L
                JP RestoreScale

DoubleRoot:     CALL Game.Combat.SquareRootVectorLength.Entry
                ADD HL, HL
                JR NC, LengthReady                                              ; переход, если удвоенный корень поместился в слово

                LD HL, #0000
LengthReady:    RET

                ; рисование указателя компаса только на экранах полёта
DrawCompass:    LD A, (FlightState.View)
                CP #04
                RET NC                                                          ; выход, если открыт информационный экран

                CALL Game.Screen.RestoreCompassBackground.Entry
                CALL Game.Screen.CompassShape.Entry
                LD E, #04
                LD A, (CompassState.Behind)
                AND A
                JR Z, PositionY                                                 ; переход, если нужен спрайт передней полусферы

                ADD HL, DE
                ; расчёт вертикального положения спрайта относительно центра компаса
PositionY:      EX DE, HL
                LD HL, Memory.Screen + #1135                                    ; база вертикального сдвига указателя, строка 137, байт 21
                LD A, (CompassState.Y)
                LD B, A
                RLCA
                JR C, NegativeY                                                 ; переход, если Y имеет отрицательный знак

                LD A, #08
                SUB B
                JR SetRowCount

NegativeY:      LD A, #88
                ADD A, B
SetRowCount:    LD B, A
MoveDown:       INC H
                LD A, H
                AND #07
                CALL Z, Game.Screen.NextCharacterRow.Entry                      ; вызов, если вертикальное смещение пересекло границу знакоместа
                DJNZ MoveDown

                ; вывод четырёх строк указателя с побитовым смещением по X
                LD B, #04
DrawSpriteRow:  PUSH BC
                LD A, (DE)
                INC DE
                PUSH DE
                LD C, A
                LD DE, #0000
                LD A, (CompassState.X)
                LD B, A
                RES 7, B
                ADD A, A
                JR Z, MergeSprite                                               ; переход, если горизонтальное смещение равно нулю

                JR C, ShiftLeft                                                 ; переход, если указатель нужно сдвинуть влево

ShiftRight:     SRL C
                RR E
                DJNZ ShiftRight

                JR MergeSprite

ShiftLeft:      SLA C
                RL D
                DJNZ ShiftLeft

                ; наложение трёхбайтной строки указателя через OR
MergeSprite:    LD A, D
                OR (HL)
                LD (HL), A
                INC HL
                LD A, C
                OR (HL)
                LD (HL), A
                INC HL
                LD A, E
                OR (HL)
                LD (HL), A
                DEC HL
                DEC HL
                INC H
                LD A, H
                AND #07
                CALL Z, Game.Screen.NextCharacterRow.Entry                      ; вызов, если следующая строка указателя пересекла границу знакоместа
                POP DE
                POP BC
                DJNZ DrawSpriteRow

                RET
                ASSERT $ == #83FE
                endmodule
                endmodule
