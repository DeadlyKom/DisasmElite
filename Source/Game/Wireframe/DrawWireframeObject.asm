                module Wireframe
                module DrawWireframeObject
; -----------------------------------------
; построение каркаса и вывод необязательного лазерного луча
; исходный диапазон #A84D..#A8AB
; In:
;   IX, объект
;   IY, модель
;   память A9B8, глубина
; Out:
;   IX, объект сохранён
;   IY, модель сохранена
;   каркас и луч добавлены в буфер
; Corrupt:
;   HL, DE, BC, AF
; Note:
; Восстанавливает ось Z, матрицу, видимость граней и экранные вершины.
; Уровень детализации равен max(0,min(31,HI(2*глубина))-2).
; 61DD рисует рёбра, затем при IX+20.3 выводится лазер.
; A884 общий вход луча, вершина задана IY+14, конечная точка берётся из 7B37.
; A89C..A8A6 содержит десять смещений атрибутов и завершающий FF.
; A8A7 сбрасывает одноразовый признак луча.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #A84D
                ; построение матрицы и расчёт детализации
Entry:          PUSH IY
                CALL Game.Wireframe.BuildObjectRotationMatrix.Entry
                POP IY
                LD HL, (ProjectionState.Depth)
                ADD HL, HL
                LD B, #1F
                JR C, SubtractDetail                                            ; переход, если удвоение глубины переполнилось и предел детализации равен 31

                LD A, H
                CP B
                JR NC, SubtractDetail                                           ; переход, если старший байт удвоенной глубины не меньше 31

                LD B, H
SubtractDetail: LD A, B
                SUB #02
                JR NC, StoreDetail                                              ; переход, если уровень детализации не меньше двух

                XOR A
StoreDetail:    LD (ProjectionState.Depth), A
                ; подготовка граней и экранных вершин
                LD A, #FD
                LD (ProjectionState.VertexOffset), A
                CALL Game.Objects.ComputeFaceVisibility.Entry
                CALL Game.Wireframe.BuildProjectedVertexTable.Entry
                CALL Game.Extensions.DrawModelAndResources.Entry
CheckLaser:     BIT OBJ_LASER_BIT, (IX + FSpaceObject.Flags)
                RET Z                                                           ; выход, если у объекта сброшен признак лазерного луча

                LD A, (IY + FModel.LaserVertex)
                CALL Game.Wireframe.ReadProjectedVertex.Entry
                LD C, A
                ; отдельный вход вывода лазерного луча
DrawLaser:      CALL Game.Universe.PrepareRandomLaserEndpoint.Entry
                LD L, A
                SUB #FF
                NEG
                LD H, A
                LD A, C
                CPL
                AND PROJ_SIGN_MASK
                SLA C
                SLA C
                OR C
                LD C, A
                CALL Game.Wireframe.DrawClippedLine.Entry
                JR ClearLaser
                ; данные смещений атрибутов индикатора
AttributeList   DB #68, #94, #95, #B4, #B5, #87, #88, #A7                       ; смещения изменяемых атрибутов сканера, #FF завершает таблицу
                DB #A8, #A8, #FF
                ; сброс одноразового запроса луча
ClearLaser:     RES OBJ_LASER_BIT, (IX + FSpaceObject.Flags)
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #A8AC
                endmodule
                endmodule
