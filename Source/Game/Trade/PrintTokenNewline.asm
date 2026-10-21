                module Trade
                module PrintTokenNewline
; -----------------------------------------
; Токен с переводом строки
; исходный диапазон #E2A6..#E2A8
; In:
;   AF, A = токен
; Out:
;   Курсор переведён на следующую строку
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   После печати исполнение продолжается в Game.Trade.Newline.Entry
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E2A6
                ; токен печатается перед общим переходом на следующую строку
Entry:          CALL Game.Text.PrintMainToken.Entry                             ; далее Game.Trade.Newline.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #E2A9
                endmodule
                endmodule
