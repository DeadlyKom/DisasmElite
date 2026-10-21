                module Wireframe
                module SumCachedVertexProducts
; -----------------------------------------
; пересчёт компоненты вершины по сохранённым произведениям и новым знакам
; исходный диапазон #ABC0..#AC00
; In:
;   IY, строка матрицы и её кэш произведений
;   память VertexFlags/VertexFlags.Current, предыдущие и текущие признаки знаков
; Out:
;   HL, знако-модульная компонента суммы
;   IY, следующая строка матрицы, прибавлено 6
; Corrupt:
;   DE, BC, AF
; Note:
; XOR текущего и предыдущего байта показывает, у каких координат изменился знак.
; Модули произведений остаются прежними, обновляются их знаки в IY + FMatrix3 + FAxis.X/Y/Z + FSignWord.SignHigh.
; Три обновлённых слагаемых складываются Game.Wireframe.AddSignedByteMagnitudes.Entry.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #ABC0
                ; расчёт маски изменившихся знаков симметричной вершины
Entry:          LD HL, VertexFlags.Current
                LD A, (HL)
                DEC HL
                XOR (HL)
                LD B, A
                LD L, (IY + FMatrix3 + FAxis.X + FSignWord.Low)
                LD H, (IY + FMatrix3 + FAxis.X + FSignWord.SignHigh)
                LD E, (IY + FMatrix3 + FAxis.Y + FSignWord.Low)
                LD D, (IY + FMatrix3 + FAxis.Y + FSignWord.SignHigh)
                XOR H
                AND #80
                LD H, A
                LD (IY + FMatrix3 + FAxis.X + FSignWord.SignHigh), H
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
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #AC01
                endmodule
                endmodule
