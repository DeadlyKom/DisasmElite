ShapeIndex      EQU 0                                                           ; нулевое смещение текущего индекса фигуры, IX является курсором потока
; -----------------------------------------
; Рисование знака демо из сетки клеток и пяти фигур
; исходный диапазон #ECC7..#ED29
; In:
;   MarkCellMap ED2F, MarkShapes ED5C, ShapeMasks ED2A
; Out:
;   знак наложен XOR на экран от 405F, повторный вызов стирает
; Corrupt:
;   HL, DE, BC, AF, IX сохраняется
; Note:
;   Каждый бит карты выбирает заполненную клетку 8×8, для неё берётся один индекс фигуры 0..4
;   Фигуры 0/2 сужают FF сдвигом влево/вправо,1/3 наращивают 00 переносом 1,4 оставляет сплошной FF
;   Переход L через FF выбирает H=48, этим сохраняется разметка следующей трети экрана
;   FF в MarkCellMap является завершителем, поэтому полная строка из 8 занятых клеток этим форматом не
;   представляется
; -----------------------------------------
                ; после паузы этот же вход повторно стирает знак операцией XOR
XorDemoMark:    PUSH IX
                LD IX, MarkShapes
                LD DE, MarkCellMap
                LD HL, MarkOrigin
                ; чтение очередных восьми клеток и проверка терминатора FF
ReadMarkCells:  LD A, (DE)
                INC DE
                LD B, #08
                LD C, A
                CP #FF
                JR Z, FinishMark                                                ; переход, если прочитан терминатор FF, закончить рисование знака

                ; проверка старшего бита клетки после вращения, нуль пропускает фигуру
CheckMarkCell:  RLC C
                JR NC, NextMarkCell                                             ; переход, если бит клетки нулевой, пропустить пустую позицию

                PUSH BC
                PUSH HL
                ; выбор начальной маски по индексу фигуры 0..4
                PUSH DE
                LD E, (IX + ShapeIndex)
                LD D, #00
                LD HL, ShapeMasks
                ADD HL, DE
                LD C, (HL)
                POP DE
                POP HL
                PUSH HL
                PUSH BC
                LD B, #08
                ; восемь строк клетки накладываются XOR на экран
DrawCellRow:    LD A, (HL)
                XOR C
                LD (HL), A
                INC H
                ; индекс фигуры выбирает изменение маски следующей строки
                LD A, (IX + ShapeIndex)
                AND A
                JR Z, ShrinkLeft                                                ; переход, если индекс фигуры 0, сужать маску влево с нулевым переносом

                DEC A
                JR Z, GrowRight                                                 ; переход, если индекс фигуры 1, наращивать маску вправо с единичным переносом

                DEC A
                JR Z, ShrinkRight                                               ; переход, если индекс фигуры 2, сужать маску логическим сдвигом вправо

                DEC A
                JR NZ, NextCellRow                                              ; переход, если индекс фигуры не 3, оставить сплошную маску без изменения

                SCF
                RL C
                JR NextCellRow

                ; фигура 2 сужает маску сдвигом вправо
ShrinkRight:    SRL C
                JR NextCellRow

                ; фигура 1 заполняет маску справа при входящем переносе 1
GrowRight:      SCF
                RR C
                JR NextCellRow

                ; фигура 0 сужает маску сдвигом влево с входящим нулём
ShrinkLeft:     AND A
                RL C
                ; завершение клетки расходует один индекс MarkShapes
NextCellRow:    DJNZ DrawCellRow

                POP BC
                POP HL
                INC IX
                POP BC
                ; следующая клетка с переходом в экранную треть 48 при обнулении L
NextMarkCell:   INC L
                JR NZ, CountMarkCell                                            ; переход, если младший байт экранного адреса не обнулился, треть экрана не менять

                LD H, #48
CountMarkCell:  DJNZ CheckMarkCell

                JR ReadMarkCells

                ; завершение по FF восстанавливает исходный IX
FinishMark:     POP IX
                RET
