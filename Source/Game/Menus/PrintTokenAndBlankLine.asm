                module Menus
                module PrintTokenAndBlankLine
; -----------------------------------------
; Печать токена с пустой строкой после него
; исходный диапазон #EE9D..#EEA1
; In:
;   AF, A = токен
; Out:
;   Текст выведен, курсор увеличен на две строки
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   E2A6 выполняет первый перевод, общий хвост EEA5 второй
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #EE9D
                ; печать токена заканчивается пустой строкой через общий хвост EEA2
Entry:          CALL Game.Trade.PrintTokenNewline.Entry
                JR @Game.Menus.BlankLineAndEconomyText.SecondNewline
                ; проверка исходного конца фрагмента
                ASSERT $ == #EEA2
                endmodule
                endmodule
