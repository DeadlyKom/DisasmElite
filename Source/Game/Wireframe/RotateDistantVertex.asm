                module Wireframe
                module RotateDistantVertex
; -----------------------------------------
; поворот обычной вершины без дополнительного увеличения точности
; исходный диапазон #AB73..#ABAE
; In:
;   IX, модули вершины
;   IY, матрица
;   стек, контекст итерации из Game.Wireframe.DivideFractionAndProjectVertex.Project
; Out:
;   память ProjectionState.X/ProjectionState.Y/ProjectionState.Z, повёрнутые координаты
;   память VertexFraction/VertexFraction.Y/VertexFraction.Z, нулевые дробные части
; Corrupt:
;   HL, DE, BC, AF, IY
; Note:
; Выбирает кэш либо три новых скалярных произведения.
; IY продвигается на 18 байт, затем хвост Game.Wireframe.DivideFractionAndProjectVertex.AddObjectPos восстанавливает контекст. Собственного RET нет.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #AB73
                ; проверка возможности использовать произведения симметричной вершины
Entry:          LD A, (ProjectionState.NoCache)
                AND A
                JR NZ, RebuildCache                                             ; переход, если предыдущая вершина пропущена и требуется полный расчёт

                LD A, (VertexFlags.Current)
                RRCA
                JR C, RebuildCache                                              ; переход, если текущий признак задаёт новые модули

                ; пересчёт трёх компонент по знакам кэша
                CALL Game.Wireframe.SumCachedVertexProducts.Entry
                LD (ProjectionState.X), HL
                CALL Game.Wireframe.SumCachedVertexProducts.Entry
                LD (ProjectionState.Y), HL
                CALL Game.Wireframe.SumCachedVertexProducts.Entry
                JR StoreZ

                ; расчёт трёх компонент новыми умножениями
RebuildCache:   CALL Game.Wireframe.RotateCoordinateAndCacheProducts.Entry
                LD (ProjectionState.X), HL
                CALL Game.Wireframe.RotateCoordinateAndCacheProducts.Entry
                LD (ProjectionState.Y), HL
                CALL Game.Wireframe.RotateCoordinateAndCacheProducts.Entry
StoreZ:         LD (ProjectionState.Z), HL
                ; обнуление дробных разрядов перед общим хвостом
                XOR A
                LD (VertexFraction.X), A
                LD (VertexFraction.Y), A
                LD (VertexFraction.Z), A
                JP Game.Wireframe.DivideFractionAndProjectVertex.AddObjectPos

                ; проверка исходного конца фрагмента
                ASSERT $ == #ABAF
                endmodule
                endmodule
