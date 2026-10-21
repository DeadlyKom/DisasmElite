                module Combat
                module DispatchObjectAction
; -----------------------------------------
; совместимый вход диспетчера действий объектов
; исходный диапазон #9C9C..#9C9E
; In:
;   AF, A содержит действие и параметр
; Out:
;   результат общего диспетчера объектов
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
; Хвостовой переход в Game.Objects.DispatchObjectAction.Entry, старшая тетрада задаёт параметр, младшая действие.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #9C9C
                ; переход к общему диспетчеру объектов
Entry:          JP Game.Objects.DispatchObjectAction.Entry

                ; проверка исходного конца фрагмента
                ASSERT $ == #9C9F
                endmodule
                endmodule
