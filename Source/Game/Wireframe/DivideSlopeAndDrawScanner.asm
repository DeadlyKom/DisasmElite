                module Wireframe
                module DivideSlopeAndDrawScanner
; -----------------------------------------
; деление разностей линии и альтернативная проекция сканерного маркера
; исходный диапазон #B2AA..#B3B1
; In:
;   HL, H содержит числитель, L ненулевой знаменатель
;   IX, объект при отдельном входе Game.Wireframe.DivideSlopeAndDrawScanner.DrawMarker
; Out:
;   HL, отношение в формате 8.8
;   DE, исходное значение для Game.Wireframe.DivideSlopeAndDrawScanner.Entry
;   при входе Game.Wireframe.DivideSlopeAndDrawScanner.DrawMarker выведен сканерный маркер
; Corrupt:
;   BC, AF
; Note:
; Entry строит целую и дробную части отношения
; CarryKeep содержит LD A,#A7, вход ClearCarry исполняет второй байт как AND A.
; LD сохраняет перенос нормирования, AND сбрасывает его перед очередным RR.
; за RET сохранены два байта старого перехода, DrawMarker начинает отдельную проекцию сканера
; Нормализованные X/Y отображаются около центра (124,35). Размер зависит от дальности, форма от знака Z.
; Младшие биты адреса слота немного разводят метки по строкам.
; ObjectRaster.PixelMode временно патчится на B6E4 для прямого экрана, затем восстанавливается AEFC.
; ScannerBlocks являются данными фонового рисунка для Game.Wireframe.RefreshScannerBackground.Entry.
; Меню паузы, клавиша L, вызывает Game.Universe.AddSignedStarCoordinate.ToggleScanner и заменяет AND A по ScannerRaster.Mode на SCF.
; Поэтому переход JP C,Game.Wireframe.DivideSlopeAndDrawScanner.DrawMarker действует в альтернативном режиме, а в обычном пропускается.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #B2AA
                ; расчёт целой части отношения
Entry:          PUSH DE
                LD BC, #0001
                LD A, H
                LD E, L
Normalize:      CP L
                JR C, ClearCarry                                                ; переход, если сдвинутый знаменатель больше числителя

                RL C
                RL L
                JR NC, Normalize                                                ; переход, если сдвиг знаменателя ещё не переполнил байт

                ; сохранение переноса после нормирования, второй байт даёт вход ClearCarry с AND A
CarryKeep:      LD A, #A7
ClearCarry      EQU CarryKeep + 1                                               ; вход AND A во второй байт инструкции LD A,#A7
DivideInteger:  RR L
                RR C
                JR C, DivideFraction                                            ; переход, если все разряды целой части обработаны

                LD A, H
                SUB L
                JR C, ClearCarry                                                ; переход, если знаменатель больше остатка и бит частного остаётся нулём

                LD H, A
                LD A, C
                OR B
                LD B, A
                JR DivideInteger

                ; расчёт дробных разрядов
DivideFraction: LD A, H
                LD C, #00
                AND A
                JR Z, RatioReady                                                ; переход, если остаток нулевой и дробной части нет

                LD C, #FE
                LD H, #00
FractionBit:    SLA H
                RLA
                JR C, SubtractDiv                                               ; переход, если удвоенный остаток переполнил байт

                CP E
                JR NC, SubtractDiv                                              ; переход, если остаток не меньше исходного знаменателя

                SLA C
                JR C, FractionBit                                               ; переход, если счётчик дробных разрядов ещё не исчерпан

                JR RatioReady

SubtractDiv:    SUB E
                SCF
                RL C
                JR C, FractionBit                                               ; переход, если счётчик дробных разрядов ещё не исчерпан

RatioReady:     LD H, B
                LD L, C
                POP DE
                RET

                ; сохранённые байты прежнего перехода
                DB #C1, #18
                ; отдельный вход альтернативного маркера сканера
DrawMarker:     PUSH IX
                CALL Game.Screen.VectorLength.Entry
                LD A, H
                OR L
                JR NZ, NormalizeAxes                                            ; переход, если длина вектора ненулевая

                DEC HL
                ; расчёт нормализованных X/Y
NormalizeAxes:  EX DE, HL
                PUSH DE
                CALL Game.Screen.CompassNearAxis.Entry
                POP DE
                PUSH AF
                INC IX
                INC IX
                INC IX
                PUSH DE
                CALL Game.Screen.CompassNearAxis.Entry
                POP DE
                ; расчёт экранной строки
                ADD A, A
                RR E
                LD B, A
                SRL B
                ADD A, B
                LD B, A
                RL E
                LD A, #20
                JR C, AddCenterY                                                ; переход, если вертикальная компонента требует добавления к центру

                SUB B
                JR StoreRow

AddCenterY:     ADD A, B
StoreRow:       ADD A, #03
                LD B, A
                ; расчёт экранного столбца
                POP AF
                ADD A, A
                RR E
                LD C, A
                SRL C
                ADD A, C
                LD C, A
                RL E
                LD A, #20
                JR C, SubtractX                                                 ; переход, если горизонтальная компонента требует вычитания из центра

                ADD A, C
                JR StoreColumn

SubtractX:      SUB C
StoreColumn:    ADD A, #5C
                LD C, A
                POP IX
                ; расчёт размера по дальности
                LD A, D
                AND #70
                LD E, #00
                JR NZ, CheckMidRange                                            ; переход, если старшие разряды дальности ненулевые и большой маркер не нужен

                DEC C
                LD E, #04
CheckMidRange:  LD A, D
                AND #0C
                JR NZ, CheckNearRange                                           ; переход, если средние разряды дальности ненулевые

                SET 1, E
CheckNearRange: LD A, D
                AND #03
                JR NZ, SpreadMarkers                                            ; переход, если младшие разряды дальности ненулевые

                INC E
SpreadMarkers:  INC E
                ; разведение меток по адресу слота
                LD A, IXL
                RRCA
                JR NC, DrawCenter                                               ; переход, если младший бит адреса слота нулевой и строку смещать не нужно

                DEC B
                RRCA
                JR NC, DrawCenter                                               ; переход, если следующий бит адреса слота нулевой и второго смещения не нужно

                DEC B
                ; изменение пиксельного обработчика для прямого экрана
DrawCenter:     LD HL, #B6E4
                LD (ObjectRaster.PixelMode), HL
                CALL Game.Motion.XorFarObjectPixel.Entry
                ; выбор формы по знаку глубины
                LD A, (IX + FSpaceObject.Z.SignHigh)
                RLCA
                LD HL, #0004
                JR C, RearMarker                                                ; переход, если объект находится позади игрока и форма маркера разворачивается

                CALL Game.Wireframe.DrawScannerMarkerSegment.Entry
                INC L
                CALL Game.Wireframe.DrawScannerMarkerSegment.Entry
                LD L, #0C
                CALL Game.Wireframe.DrawScannerMarkerSegment.Entry
                INC L
                JR LastSegment

RearMarker:     LD H, #0C
                CALL Game.Wireframe.DrawScannerMarkerSegment.Entry
                INC H
                CALL Game.Wireframe.DrawScannerMarkerSegment.Entry
                INC L
                CALL Game.Wireframe.DrawScannerMarkerSegment.Entry
                DEC H
LastSegment:    CALL Game.Wireframe.DrawScannerMarkerSegment.Entry
                ; восстановление обычного обработчика пикселей
                LD HL, #AEFC
                LD (ObjectRaster.PixelMode), HL
                JP Game.Scanner.DrawScannerObjects.NextObject

                ; данные фонового рисунка
BackdropBlocks  DB #00, #00, #80, #00, #00, #00, #00, #00                       ; блоки альтернативного фона сканера с шагом выбора 9 байтов
                DB #02, #00, #00, #80, #00, #FF, #FF, #FE
                DB #00, #02, #00, #00, #80, #00, #80, #00
                DB #02, #00, #02, #00, #00
                ; проверка исходного конца фрагмента
                ASSERT $ == #B3B2
                endmodule
                endmodule
