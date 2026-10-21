                module Motion
                module CallObjectActionPreservingPointers
; -----------------------------------------
; вызов расширенного действия объекта с сохранением указателей
; исходный диапазон #A403..#A40E
; In:
;   AF, A содержит код действия и параметр в старшей тетраде
;   IX, текущий объект
;   IY, модель объекта
; Out:
;   AF, результат и флаги обработчика
;   IX, исходный объект
;   IY, исходная модель
; Corrupt:
;   HL, DE, BC
; Note:
; Диспетчер Game.Universe.DispatchLinkedObjectAction.Entry выбирает штатное действие либо расширение.
; Z/NZ возвращается без изменения и проверяется при запуске ракеты или отделении капсулы.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #A403
                ; сохранение указателей родителя на время действия
Entry:          PUSH IY
                PUSH IX
                CALL Game.Universe.DispatchLinkedObjectAction.Entry
                POP IX
                POP IY
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #A40F
                endmodule
                endmodule
