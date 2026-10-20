                module Wireframe
                module AnyPackedFaceVisible
; -----------------------------------------
; объединение видимости двух граней из упакованного байта
; исходный диапазон #AA10..#AA1F
; In:
;   AF, A содержит два четырёхбитных номера граней
; Out:
;   AF, A содержит OR двух флагов, Z если обе грани невидимы
; Corrupt:
;   BC
; Note:
; Сначала обрабатывается младшая тетрада, затем старшая.
; AA20 изменяет собственный адрес чтения таблицы видимости.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #AA10
                ; поиск видимости двух граней вершины и объединение результатов
Entry:          LD B, A
                CALL Game.Wireframe.ReadFaceVisibilityNibble.Entry
                PUSH BC
                LD B, A
                POP AF
                RRCA
                RRCA
                RRCA
                RRCA
                CALL Game.Wireframe.ReadFaceVisibilityNibble.Entry
FaceCombine     EQU $                                                           ; код OR B, объединение видимости двух граней
                OR B
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #AA20
                endmodule
                endmodule
