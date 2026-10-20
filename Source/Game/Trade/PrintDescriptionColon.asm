                module Trade
                module PrintDescriptionColon
; -----------------------------------------
; Сообщение второй таблицы с двоеточием
; исходный диапазон #E292..#E296
; In:
;   AF, A = номер сообщения
; Out:
;   Текст и двоеточие выведены
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   После D45F переходит к общему хвосту E29A
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E292
                ; второй текстовый токен завершается общим хвостом печати двоеточия
Entry:          CALL Game.Text.PrintDescriptionToken.Entry
                JR @Game.Trade.PrintMainTokenColon.PrintColon
                ; проверка исходного конца фрагмента
                ASSERT $ == #E297
                endmodule
                endmodule
