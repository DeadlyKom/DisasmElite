                module Wireframe
                module RotateNearVertexComponent
; -----------------------------------------
; поворот компоненты ближней вершины с повышенной точностью
; исходный диапазон #AA3D..#AAFA
; In:
;   IX, модули координат
;   IY, строка матрицы
;   память ProjectionState.Scale, число сдвигов
;   память VertexFlags/VertexFlags.Current, признаки вершин
; Out:
;   HL, целая часть знако-модульной компоненты
;   AF, A содержит дополнительные дробные разряды
;   IY, следующая строка, прибавлено 6
; Corrupt:
;   DE, BC
; Note:
; Если предыдущая вершина обработана и bit0 текущих признаков нулевой, меняются только знаки кэша.
; Иначе увеличенные компоненты умножаются на строку матрицы, произведения сохраняются.
; ProjectionState.Scale обратных сдвигов возвращают масштаб, последним переносом округляется HL.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #AA3D
                ; проверка возможности использовать кэш
Entry:          LD A, (ProjectionState.NoCache)
                AND A
                JR NZ, RebuildCache                                             ; переход, если предыдущая вершина пропущена и кэш нужно пересчитать

                LD A, (VertexFlags.Current)
                RRCA
                JR C, RebuildCache                                              ; переход, если текущий признак требует новые модули координат

                LD HL, VertexFlags.Current
                LD A, (HL)
                DEC HL
                XOR (HL)
                LD B, A
                LD L, (IY + FMatrix3 + FSignWord.Low)
                LD H, (IY + FMatrix3 + FSignWord.SignHigh)
                LD E, (IY + FMatrix3 + FAxis.Y + FSignWord.Low)
                LD D, (IY + FMatrix3 + FAxis.Y + FSignWord.SignHigh)
                XOR H
                AND #80
                LD H, A
                LD (IY + FMatrix3 + FSignWord.SignHigh), H
                RL B
                LD A, B
                XOR D
                AND #80
                LD D, A
                LD (IY + FMatrix3 + FAxis.Y + FSignWord.SignHigh), D
                CALL Game.Wireframe.AddSignedByteMagnitudes.Entry
                LD L, A
                LD E, (IY + FMatrix3 + FAxis.Z + FSignWord.Low)
                LD D, (IY + FMatrix3 + FAxis.Z + FSignWord.SignHigh)
                LD A, B
                RLA
                XOR D
                AND #80
                LD D, A
                LD (IY + FMatrix3 + FAxis.Z + FSignWord.SignHigh), D
                CALL Game.Wireframe.AddSignedByteMagnitudes.Entry
                LD L, A
                LD DE, #0006
                ADD IY, DE
                JR RestoreScale

                ; расчёт трёх новых произведений
RebuildCache:   LD B, (IX + FVector3.X)
                CALL Game.Wireframe.MultiplyScaledVertexComponent.Entry
                LD A, (VertexFlags.Current)
                XOR (IY + FSignWord.SignHigh)
                RLA
                RR H
                LD (IY + FMatrix3 + FSignWord.Low), L
                LD (IY + FMatrix3 + FSignWord.SignHigh), H
                EX DE, HL
                INC IY
                INC IY
                LD B, (IX + FVector3.Y)
                CALL Game.Wireframe.MultiplyScaledVertexComponent.Entry
                LD A, (VertexFlags.Current)
                RLA
                XOR (IY + FSignWord.SignHigh)
                RLA
                RR H
                LD (IY + FMatrix3 + FSignWord.Low), L
                LD (IY + FMatrix3 + FSignWord.SignHigh), H
                CALL Game.Wireframe.AddSignedByteMagnitudes.Entry
                LD L, A
                EX DE, HL
                INC IY
                INC IY
                LD B, (IX + FVector3.Z)
                CALL Game.Wireframe.MultiplyScaledVertexComponent.Entry
                LD A, (VertexFlags.Current)
                RLA
                RLA
                XOR (IY + FSignWord.SignHigh)
                RLA
                RR H
                LD (IY + FMatrix3 + FSignWord.Low), L
                LD (IY + FMatrix3 + FSignWord.SignHigh), H
                CALL Game.Wireframe.AddSignedByteMagnitudes.Entry
                LD L, A
                INC IY
                INC IY
                ; обратное масштабирование с сохранением дробных разрядов
RestoreScale:   LD A, (ProjectionState.Scale)
                LD B, A
                XOR A
                LD C, H
                RES 7, H
ShiftFraction:  SRL H
                RR L
                RRA
                DJNZ ShiftFraction

                JR NC, RestoreSign                                              ; переход, если последний отброшенный бит нулевой и округление не требуется

                INC HL
                ; восстановление знака компоненты
RestoreSign:    BIT 7, C
                RET Z                                                           ; выход, если результирующая компонента неотрицательна

                SET 7, H
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #AAFB
                endmodule
                endmodule
