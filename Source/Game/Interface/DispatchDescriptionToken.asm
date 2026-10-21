                module Interface
                module DispatchDescriptionToken
; -----------------------------------------
; Вектор печати токена второй таблицы
; исходный диапазон #D039..#D03B
; In:
;   AF, A = номер сообщения от 1
; Out:
;   Печать выбранного описания
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Передаёт управление Game.Text.PrintDescriptionToken.Entry, базу таблицы задаёт слово MessageTable.Description
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D039
Entry:          JP Game.Text.PrintDescriptionToken.Entry

                ; проверка исходного конца фрагмента
                ASSERT $ == #D03C
                endmodule
                endmodule
