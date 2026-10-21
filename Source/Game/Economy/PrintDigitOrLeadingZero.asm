                module Economy
                module PrintDigitOrLeadingZero
; -----------------------------------------
; Печать цифры и условное подавление ведущего нуля
; исходный диапазон #D371..#D37C
; In:
;   AF, A = цифра 0..9 для Game.Economy.PrintDigitOrLeadingZero.Entry
; Out:
;   Печатается ASCII30+A
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Дополнительный вход Game.Economy.PrintDigitOrLeadingZero.LeadingZero читает ZeroSuppress и возвращается без печати пока ведущие нули запрещены
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D371
                ; перевод цифры 0..9 в ASCII, дополнительный вход Game.Economy.PrintDigitOrLeadingZero.LeadingZero подавляет нули при ZeroSuppress!=0
Entry:          ADD A, #30
                JP Game.Text.PrintMainToken.Entry

LeadingZero:    LD A, (ZeroSuppress)
                AND A
                JR Z, Game.Economy.PrintDigitOrLeadingZero.Entry                ; переход, если подавление ведущих нулей снято, вывести нулевую цифру

                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #D37D
                endmodule
                endmodule
