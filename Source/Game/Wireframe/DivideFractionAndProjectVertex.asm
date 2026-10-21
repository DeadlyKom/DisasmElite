                module Wireframe
                module DivideFractionAndProjectVertex
; -----------------------------------------
; дробное деление и общий расчёт экранной вершины
; исходный диапазон #AC8B..#AE00
; In:
;   DE, E содержит младшие разряды делимого
;   BC, B содержит делитель, C=FE
;   AF, A содержит остаток
;   IX, вершина при отдельном входе Game.Wireframe.DivideFractionAndProjectVertex.Project
;   IY, матрица при входе Game.Wireframe.DivideFractionAndProjectVertex.Project
; Out:
;   BC, C содержит дробное частное для Game.Wireframe.DivideFractionAndProjectVertex.Entry
;   при входе Game.Wireframe.DivideFractionAndProjectVertex.Project обновлена экранная запись и продолжен цикл вершин
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
; Entry строит восемь дробных разрядов, единицы C служат счётчиком
; VertexFraction.X, Y и Z являются дробными байтами повёрнутой вершины
; Game.Wireframe.DivideFractionAndProjectVertex.Project выбирает повышенную точность для глубины меньше 4.
; Game.Wireframe.DivideFractionAndProjectVertex.AddObjectPos извлекает указатель объекта из стека и складывает его положение с вершиной.
; проверка FlightState.View в AddObjectPos выбирает деление на Z либо ветвь ProjectSide с глубиной X, затем сохраняются проекции и знаки
; Закамерная вершина получает FF. Game.Wireframe.DivideFractionAndProjectVertex.NextVertex продвигает потоки и продолжает Game.Wireframe.BuildProjectedVertexTable.ProjectVertex.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #AC8B
                ; расчёт очередного разряда частного
Entry:          SLA E
                RLA
                JR C, SubtractDiv                                               ; переход, если удвоенный остаток переполнил байт

                CP B
                JR NC, SubtractDiv                                              ; переход, если остаток не меньше делителя

                SLA C
                RET NC                                                          ; выход, если все восемь разрядов частного обработаны

                JR Game.Wireframe.DivideFractionAndProjectVertex.Entry

SubtractDiv:    SUB B
                SCF
                RL C
                RET NC                                                          ; выход, если все восемь разрядов частного обработаны

                JR Game.Wireframe.DivideFractionAndProjectVertex.Entry

                ; данные дробных разрядов вершины
VertexFraction  EQU $                                                           ; начало сохранённых рабочих данных, исходное размещение
.X              DB #00                                                          ; дополнительные дробные разряды повёрнутой X-компоненты
.Y              DB #01                                                          ; дополнительные дробные разряды повёрнутой Y-компоненты
.Z              DB #00                                                          ; дополнительные дробные разряды повёрнутой Z-компоненты
                ; отдельный вход проекции, проверка ближнего режима
Project:        PUSH IY
                LD A, (ProjectionState.Depth)
                CP #04
                JP NC, Game.Wireframe.RotateDistantVertex.Entry                 ; переход, если глубина не меньше 4 и обычной точности достаточно

                LD A, (IX + FVector3.X)
                OR (IX + FVector3.Y)
                OR (IX + FVector3.Z)
                LD B, #FF
                SCF
FindScale:      RLA
                INC B
                JR NC, FindScale                                                ; переход, если ведущий бит модулей ещё не достиг старшего разряда

                LD A, B
                LD (ProjectionState.Scale), A
                AND A
                JP Z, Game.Wireframe.RotateDistantVertex.Entry                  ; переход, если модули уже используют старший бит и увеличивать их нельзя

                CALL Game.Wireframe.RotateNearVertexComponent.Entry
                LD (VertexFraction.X), A
                LD (ProjectionState.X), HL
                CALL Game.Wireframe.RotateNearVertexComponent.Entry
                LD (VertexFraction.Y), A
                LD (ProjectionState.Y), HL
                CALL Game.Wireframe.RotateNearVertexComponent.Entry
                LD (VertexFraction.Z), A
                LD (ProjectionState.Z), HL
                ; восстановление указателя объекта из стека
AddObjectPos:   XOR A
                LD (ProjectionState.NoCache), A
                POP IY
                POP HL
                ; сложение вершины с координатами объекта
                EX (SP), IX
                PUSH HL
                LD L, (IX + FSpaceObject.X.Fraction)
                LD H, (IX + FSpaceObject.X.Low)
                LD B, (IX + FSpaceObject.X.SignHigh)
                LD DE, (ProjectionState.X)
                LD A, (VertexFraction.X)
                RLA
                PUSH AF
                CALL Game.Wireframe.AddRotatedVertexCoordinate.Entry
                LD (ProjectionState.X), HL
                LD (ProjectionState.SignX), A
                POP AF
                LD (VertexFraction.X), A
                LD L, (IX + FSpaceObject.Y.Fraction)
                LD H, (IX + FSpaceObject.Y.Low)
                LD B, (IX + FSpaceObject.Y.SignHigh)
                LD DE, (ProjectionState.Y)
                LD A, (VertexFraction.Y)
                RLA
                PUSH AF
                CALL Game.Wireframe.AddRotatedVertexCoordinate.Entry
                LD (ProjectionState.Y), HL
                LD (ProjectionState.SignY), A
                POP AF
                LD (VertexFraction.Y), A
                LD L, (IX + FSpaceObject.Z.Fraction)
                LD H, (IX + FSpaceObject.Z.Low)
                LD B, (IX + FSpaceObject.Z.SignHigh)
                LD DE, (ProjectionState.Z)
                LD A, (VertexFraction.Z)
                RLA
                PUSH AF
                CALL Game.Wireframe.AddRotatedVertexCoordinate.Entry
                LD (ProjectionState.Z), HL
                LD (ProjectionState.SignZ), A
                POP AF
                LD (VertexFraction.Z), A
                LD A, (FlightState.View)
                BIT 1, A
                JR NZ, ProjectSide                                              ; переход, если выбран боковой вид и глубиной служит X

                LD DE, (ProjectionState.X)
                LD A, (VertexFraction.X)
                LD C, A
                LD A, (VertexFraction.Z)
                CALL Game.Wireframe.DivideProjectionRatio.Entry
                LD A, C
                LD (ProjectionState.ScreenX), A
                LD DE, (ProjectionState.Y)
                LD HL, (ProjectionState.Z)
                LD A, (VertexFraction.Y)
                LD C, A
                LD A, (VertexFraction.Z)
                CALL Game.Wireframe.DivideProjectionRatio.Entry
                LD A, C
                LD (ProjectionState.ScreenY), A
                LD A, (ProjectionState.SignX)
                RLA
                RL C
                LD A, (ProjectionState.SignZ)
                RLA
                RL B
                JR PackSigns

                ; расчёт боковой проекции
ProjectSide:    EX DE, HL
                LD HL, (ProjectionState.X)
                LD A, (VertexFraction.Z)
                LD C, A
                LD A, (VertexFraction.X)
                CALL Game.Wireframe.DivideProjectionRatio.Entry
                LD A, C
                LD (ProjectionState.ScreenX), A
                LD DE, (ProjectionState.Y)
                LD HL, (ProjectionState.X)
                LD A, (VertexFraction.Y)
                LD C, A
                LD A, (VertexFraction.X)
                CALL Game.Wireframe.DivideProjectionRatio.Entry
                LD A, C
                LD (ProjectionState.ScreenY), A
                LD A, (ProjectionState.SignX)
                RLA
                RL B
                LD A, (ProjectionState.SignZ)
                RLA
                RL C
                ; упаковка знаков и горизонтальное зеркалирование
PackSigns:      LD A, (ProjectionState.SignY)
                RLA
                RL C
                LD A, (FlightState.View)
                BIT 0, A
                LD A, C
                JR Z, StoreSigns                                                ; переход, если вид не требует горизонтального зеркалирования

                XOR PROJ_NEGX_MASK
StoreSigns:     AND PROJ_SIGN_MASK
                LD (ProjectionState.Flags), A
                LD A, (ProjectionState.VertexOffset)
                LD HL, ProjectedVerts
                ADD A, L
                JR NC, StorePosition                                            ; переход, если смещение записи не переносит единицу в старший байт

                INC H
StorePosition:  LD L, A
                LD A, (ProjectionState.ScreenX)
                LD (HL), A
                INC HL
                LD A, (ProjectionState.ScreenY)
                LD (HL), A
                ; проверка знака глубины относительно камеры
                INC HL
                LD A, (FlightState.View)
                LD C, A
                RRA
                XOR C
                XOR B
                RRA
                LD A, (ProjectionState.Flags)
                JR NC, StoreHidden                                              ; переход, если вершина находится перед выбранной камерой

                LD A, VERT_HIDDEN
StoreHidden:    LD (HL), A
                POP AF
                EX (SP), IX
                ; переход к следующей вершине или восстановление контекста
NextVertex:     CALL Game.Wireframe.AdvanceVertexFlags.Entry
                ADD IX, BC
                INC DE
                DEC A
                JP NZ, Game.Wireframe.BuildProjectedVertexTable.ProjectVertex   ; переход, если остались необработанные вершины

                POP IX
                POP IY
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #AE01
                endmodule
                endmodule
