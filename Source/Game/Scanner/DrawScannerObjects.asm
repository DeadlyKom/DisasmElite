                module Scanner
                module DrawScannerObjects
; -----------------------------------------
; Вывод восьми объектов на плоскость сканера
; исходный диапазон #96D9..#9869
; In:
;   таблица объектов 6048, переключатель проекции 972F, флаг вывода 9C96
; Out:
;   нанесены вертикальные маркеры, 96C4=1 при наличии подходящего объекта
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   Пропускаются пустые слоты, модули старших координат >=64 и x²+z²>=0x1600
;   Обычная проекция даёт X через сумму половины и четверти координаты, Y/Z через четверть и
;   шестнадцатую, берётся старший байт результата
;   972F переключается 7A84 между AND A и SCF, второй режим передаёт объект B2EF
;   Маркер состоит из вертикальной ножки и трёхбитной головки, 986A/987C обрезают ножку с удалением
;   своего адреса возврата
;   После восьми слотов очищаются 7 строк по 13 байт начиная с 5009
; -----------------------------------------
                ASSERT $ == #96D9
                ; подготовка слоя сканера и проверка разрешения вывода
Entry:          CALL Game.Wireframe.RefreshScannerBackground.Entry
                LD A, (CombatState.ObjectsPresent)
                AND A
                RET Z                                                           ; выход, если вывод объектов сканера отключён

                ; индикатор станции перед обходом восьми объектов
                CALL Game.Scanner.SetYellowFlightStatus.Entry
                LD A, #08
                LD (ScannerState.ObjectIndex), A
                LD IX, Memory.Station
                ; проверка пустого слота и предельных координат
CheckSlot:      LD A, (IX + FSpaceObject.Energy)
                AND A
                JR Z, Game.Scanner.AdvanceScannerObject.Entry                   ; переход, если слот объекта пуст, перейти к следующему

                LD A, (IX + FSpaceObject.X.Low)
                CP #40
                JR NC, Game.Scanner.AdvanceScannerObject.Entry                  ; переход, если модуль старшего байта X не меньше 64, пропустить далёкий объект

                LD A, (IX + FSpaceObject.Y.Low)
                CP #40
                JR NC, Game.Scanner.AdvanceScannerObject.Entry                  ; переход, если модуль старшего байта Y не меньше 64, пропустить далёкий объект

                LD A, (IX + FSpaceObject.Z.Low)
                CP #40
                JR NC, Game.Scanner.AdvanceScannerObject.Entry                  ; переход, если модуль старшего байта Z не меньше 64, пропустить далёкий объект

                ; квадрат удаления в плоскости XZ через два целочисленных квадрата
                LD A, (IX + FSpaceObject.X.Low)
                CALL Game.Math.Square
                EX DE, HL
                LD A, (IX + FSpaceObject.Z.Low)
                CALL Game.Math.Square
                ADD HL, DE
                JR C, Game.Scanner.AdvanceScannerObject.Entry                   ; переход, если сумма квадратов координат переполнилась, пропустить объект

                ; проверка границы видимости по квадрату расстояния 5632
                LD DE, #1600
                AND A
                SBC HL, DE
                JR NC, Game.Scanner.AdvanceScannerObject.Entry                  ; переход, если квадрат расстояния в плоскости XZ не меньше 5632, пропустить объект

                ; пометка изменённого фона и делитель 4000 для проекции
                LD A, #01
                LD (ScannerState.Redraw), A
                LD DE, #4000
                XOR A
                LD L, (IX + FSpaceObject.X.Fraction)
                LD H, (IX + FSpaceObject.X.Low)
                ; SMC,7A84 заменяет AND A на SCF для проекции B2EF
ModeOpcode      EQU $                                                           ; код AND A либо SCF, выбор обычной или альтернативной проекции
                AND A
                JP C, Game.Wireframe.DivideSlopeAndDrawScanner.DrawMarker       ; переход, если переключатель 972F заменён на SCF, использовать альтернативную проекцию

                ; масштаб X через сумму половины и четверти модуля
                CALL Game.Combat.DivideAndCombatState.Entry
                CALL Game.Sound.DivideBC8.Entry
                LD H, B
                LD L, C
                CALL Game.Sound.DivideBC2.Entry
                ADD HL, BC
                LD A, (IX + FSpaceObject.X.SignHigh)
                AND #80
                OR H
                LD (ScannerState.ScaledX), A
                XOR A
                LD L, (IX + FSpaceObject.Y.Fraction)
                LD H, (IX + FSpaceObject.Y.Low)
                CALL Game.Combat.DivideAndCombatState.Entry
                CALL Game.Sound.DivideBC16.Entry
                LD H, B
                LD L, C
                CALL Game.Sound.DivideBC4.Entry
                ADD HL, BC
                LD A, (IX + FSpaceObject.Y.SignHigh)
                AND #80
                LD A, H
                JR Z, StoreHeight                                               ; переход, если координата Y положительна, сохранить положительную высоту

                OR #80
StoreHeight:    LD (ScannerState.ScaledY), A
                ; масштаб Z через сумму четверти и шестнадцатой модуля
                XOR A
                LD L, (IX + FSpaceObject.Z.Fraction)
                LD H, (IX + FSpaceObject.Z.Low)
                CALL Game.Combat.DivideAndCombatState.Entry
                CALL Game.Sound.DivideBC16.Entry
                LD H, B
                LD L, C
                CALL Game.Sound.DivideBC4.Entry
                ADD HL, BC
                LD A, (IX + FSpaceObject.Z.SignHigh)
                AND #80
                LD A, H
                JR Z, StoreDepth                                                ; переход, если координата Z положительна, сохранить положительную глубину

                OR #80
StoreDepth:     LD (ScannerState.ScaledZ), A
                ; расчёт байта и бита основания относительно центра 558F
                LD HL, Memory.Screen + #158F                                    ; основание отметки сканера, строка 165, байт 15
                LD A, (ScannerState.ScaledX)
                AND #7F
                SUB #04
                LD C, A
                JP C, CentralByte                                               ; переход, если модуль X меньше 4, обработать центральный байт сетки

                ; деление модуля смещения на 8 и округление числа байтов вверх
                RRA
                RRA
                RRA
                AND #1F
                LD B, A
                LD A, C
                AND #07
                LD C, A
                JR Z, CheckSide                                                 ; переход, если остаток пиксельного смещения нулевой, не округлять число байтов вверх

                INC B
                ; проверка знака X для выбора стороны сканера
CheckSide:      LD A, (ScannerState.ScaledX)
                AND #80
                JR NZ, MoveLeftByte                                             ; переход, если координата X отрицательна, смещаться влево от центра

MoveRightByte:  INC HL
                DJNZ MoveRightByte

                ; расчёт однобитной маски правой стороны
RightMask:      LD A, C
                AND A
                LD B, A
                LD A, #01
                JR Z, OffsetDepth                                               ; переход, если остаток смещения равен нулю, использовать правый край байта

                XOR A
                SCF
RotateRight:    RRA
                DJNZ RotateRight

                JR OffsetDepth

                ; поправка центрального байта для модулей X меньше 4
CentralByte:    ADD A, #08
                LD C, A
                LD A, (ScannerState.ScaledX)
                AND #80
                JR NZ, LeftMask                                                 ; переход, если координата X отрицательна, сформировать левую маску без смещения байта

                JR RightMask

MoveLeftByte:   DEC HL
                DJNZ MoveLeftByte

                ; расчёт однобитной маски левой стороны
LeftMask:       LD A, C
                AND A
                LD B, A
                LD A, #80
                JR Z, OffsetDepth                                               ; переход, если остаток смещения равен нулю, использовать левый край байта

                XOR A
                SCF
RotateLeft:     RLA
                DJNZ RotateLeft

                ; смещение основания по глубине Z в нелинейной памяти экрана
OffsetDepth:    LD C, A
                LD A, (ScannerState.ScaledZ)
                LD D, A
                AND #7F
                LD B, A
                JR Z, CheckHeight                                               ; переход, если глубина Z нулевая, оставить исходную строку сетки

                LD A, D
                AND #80
                JR NZ, MoveBaseDown                                             ; переход, если глубина Z отрицательна, двигать основание вниз

                ; проход вверх по пиксельным строкам до нужной глубины
MoveBaseUp:     LD A, H
                DEC H
                AND #07
                CALL Z, Game.Screen.PreviousCharacterRow.Entry                  ; вызов процедуры, если пересечена верхняя граница знакоместа, скорректировать экранный адрес
                DJNZ MoveBaseUp

                JR CheckHeight

                ; проход вниз по пиксельным строкам до нужной глубины
MoveBaseDown:   INC H
                LD A, H
                AND #07
                CALL Z, Game.Screen.NextCharacterRow.Entry                      ; вызов процедуры, если пересечена нижняя граница знакоместа, скорректировать экранный адрес
                DJNZ MoveBaseDown

                ; проверка высоты Y для ножки маркера
CheckHeight:    LD A, (ScannerState.ScaledY)
                LD D, A
                AND #7F
                LD B, A
                JR Z, DrawHead                                                  ; переход, если высота Y нулевая, рисовать только головку маркера

                LD A, D
                AND #80
                JR NZ, DrawStemDown                                             ; переход, если высота Y отрицательна, провести ножку вниз

                ; восходящая ножка рисуется OR, край обрезает 987C
DrawStemUp:     LD A, (HL)
                OR C
                LD (HL), A
                LD A, H
                DEC H
                AND #07
                CALL Z, Game.Scanner.StepScannerStemUp.Entry                    ; вызов процедуры, если пересечена верхняя граница знакоместа, проверить отсечение ножки
                DJNZ DrawStemUp

                JR DrawHead

                ; нисходящая ножка рисуется OR, край обрезает 986A
DrawStemDown:   LD A, (HL)
                OR C
                LD (HL), A
                INC H
                LD A, H
                AND #07
                CALL Z, Game.Scanner.StepScannerStemDown.Entry                  ; вызов процедуры, если пересечена нижняя граница знакоместа, проверить отсечение ножки
                DJNZ DrawStemDown

                ; расширение головки до трёх пикселей с учётом границы байта
DrawHead:       LD A, C
                ADD A, A
                JR C, HeadAcrossBit7                                            ; переход, если первый сдвиг головки вышел за байт, нанести маски 03 и 80

                OR C
                ADD A, A
                JR C, HeadAcrossBit6                                            ; переход, если второй сдвиг головки вышел за байт, нанести маски 01 и C0

                OR C
                LD E, A
                LD A, (HL)
                OR E
                LD (HL), A
                ; переход к следующей структуре 39 байтов после уменьшения счётчика
NextObject:     LD A, (ScannerState.ObjectIndex)
                DEC A
                JR Z, ClearTop                                                  ; переход, если все восемь объектов обработаны, очистить верхний край сканера

                LD (ScannerState.ObjectIndex), A
                LD DE, #0027
                ADD IX, DE
                JP CheckSlot

                ; очистка семи строк по 13 байт над маркерами
ClearTop:       XOR A
                LD C, #07
                LD HL, Memory.Screen + #1009                                    ; начало очистки сканера, строка 128, байт 9
ClearTopRow:    LD B, #0D
                PUSH HL
ClearTopByte:   LD (HL), A
                INC L
                DJNZ ClearTopByte

                POP HL
                INC H
                DEC C
                JR NZ, ClearTopRow                                              ; переход, если не все семь строк края очищены, продолжить очистку

                RET

                ; головка первого переноса занимает маски 03/80 в соседних байтах
HeadAcrossBit7: DEC L
                LD A, (HL)
                OR #03
                LD (HL), A
                INC L
                LD A, (HL)
                OR #80
                LD (HL), A
                JR NextObject

                ; головка второго переноса занимает маски 01/C0 в соседних байтах
HeadAcrossBit6: DEC L
                LD A, (HL)
                OR #01
                LD (HL), A
                INC L
                LD A, (HL)
                OR #C0
                LD (HL), A
                JR NextObject
                ASSERT $ == #986A
                endmodule
                endmodule
