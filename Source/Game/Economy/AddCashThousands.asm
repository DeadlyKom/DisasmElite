                module Economy
                module AddCashThousands
; -----------------------------------------
; Прибавление целых тысяч кредитов
; исходный диапазон #D3E7..#D3EE
; In:
;   DE = число тысяч
; Out:
;   D066 увеличено по модулю 65536
; Corrupt:
;   HL, AF
; Note:
;   Общий хвост AddCashLow, младшая группа не меняется
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D3E7
                ; прибавление DE к старшей группе, одна единица означает тысячу кредитов
Entry:          LD HL, (State.CashHigh)
                ADD HL, DE
                LD (State.CashHigh), HL
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #D3EF
                endmodule
                endmodule
