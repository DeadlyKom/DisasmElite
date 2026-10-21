                module Wireframe
                module SavePreviousVertexFlags
; -----------------------------------------
; сохранение предыдущего байта признаков вершины
; исходный диапазон #AA2B..#AA30
; In:
;   память VertexFlags.Current, текущий байт признаков
; Out:
;   память VertexFlags, копия предыдущего байта
; Corrupt:
;   HL, AF
; Note:
; Фрагмент без RET продолжается в Game.Wireframe.ReadVertexFlags.Entry и читает признаки следующей записи.
; VertexFlags/VertexFlags.Current позволяют переиспользовать произведения симметричных вершин с другими знаками.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #AA2B
                ; сохранение предыдущих знаков перед чтением следующей вершины
Entry:          LD HL, VertexFlags.Current
                LD A, (HL)
                DEC HL
                LD (HL), A                                                      ; далее Game.Wireframe.ReadVertexFlags.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #AA31
                endmodule
                endmodule
