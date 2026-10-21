                module Economy
                module FinishWordDecimal
; -----------------------------------------
; Вывод единиц и сброс режима числовой печати
; исходный диапазон #D31D..#D333
; In:
;   DecimalRest = остаток 0..9
; Out:
;   NumberWidth=0, ZeroSuppress=1, A=1
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   После RET в Game.Economy.FinishWordDecimal.PrintCash лежит отдельный вход загрузки HL=(State.CashHigh), DE=(State.CashLow) с продолжением в Game.Economy.PrintSplitCash.Entry
;   для печати денег
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D31D
                ; вывод последней десятичной цифры и сброс временного режима числовой печати
Entry:          LD HL, (DecimalRest)
                LD A, L
                CALL Game.Economy.PrintDigitOrLeadingZero.Entry
                XOR A
                LD (NumberWidth), A
                INC A
                LD (ZeroSuppress), A
                RET

                ; внутренний вход печати денег, загрузка обеих групп с основанием 10000
PrintCash:      LD HL, (State.CashHigh)
                LD DE, (State.CashLow)                                          ; далее Game.Economy.PrintSplitCash.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #D334
                endmodule
                endmodule
