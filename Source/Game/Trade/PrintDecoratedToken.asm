                module Trade
                module PrintDecoratedToken
; -----------------------------------------
; Печать токена между управляющими кодами 6 и 8
; исходный диапазон #E2F8..#E305
; In:
;   AF, A = токен
; Out:
;   Выполнены команда 6, токен A, команда 8
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   AF сохраняется вокруг первой команды, команды интерпретируются диспетчером D7E2
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E2F8
                ; управляющие токены 6 и 8 временно обрамляют печать заданного сообщения
Entry:          PUSH AF
                CALL Game.Text.PrintInlineToken.Entry
                DB #06                                                          ; аргумент вызываемой процедуры из потока команд
                POP AF
                CALL Game.Text.PrintMainToken.Entry
                LD A, #08
                JP Game.Text.PrintMainToken.Entry
                ; проверка исходного конца фрагмента
                ASSERT $ == #E306
                endmodule
                endmodule
