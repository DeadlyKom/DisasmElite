                module Trade
                module PrintMainTokenColon
; -----------------------------------------
; Основной токен с двоеточием
; исходный диапазон #E297..#E29D
; In:
;   AF, A = токен
; Out:
;   Текст и двоеточие выведены
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Символ 3A передаётся в общий хвост Game.Trade.PrintMainTokenSpace.PrintSuffix
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E297
                ; основной токен завершается двоеточием через общий принтер символа
Entry:          CALL Game.Text.PrintMainToken.Entry
PrintColon:     LD A, #3A
                JR @Game.Trade.PrintMainTokenSpace.PrintSuffix

                ; проверка исходного конца фрагмента
                ASSERT $ == #E29E
                endmodule
                endmodule
