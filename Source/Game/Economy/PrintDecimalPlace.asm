                module Economy
                module PrintDecimalPlace
; -----------------------------------------
; Получение и печать одного десятичного разряда
; исходный диапазон #D357..#D370
; In:
;   DE = вес разряда, DecimalRest = текущий остаток
; Out:
;   DecimalRest уменьшен до остатка меньше DE, ненулевой разряд снимает подавление нулей
; Corrupt:
;   HL, BC, AF
; Note:
;   Цикл вычитает DE до заёма, восстанавливает последнее вычитание и передаёт цифру общему
;   хвосту Game.Economy.PrintDigitOrLeadingZero.Entry, нулевая цифра направляется в Game.Economy.PrintDigitOrLeadingZero.LeadingZero
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D357
                ; подбор цифры повторным вычитанием текущего разрядного веса
Entry:          LD HL, (DecimalRest)
                XOR A
                AND A
CountDigit:     SBC HL, DE
                JP C, RestoreRest                                               ; переход, если очередное вычитание разрядного веса дало заём, цифра найдена

                INC A
                JR CountDigit

                ; возврат последнего лишнего вычитания и сохранение остатка для следующего разряда
RestoreRest:    ADD HL, DE
                LD (DecimalRest), HL
                AND A
                JR Z, @Game.Economy.PrintDigitOrLeadingZero.LeadingZero         ; переход, если текущая цифра равна нулю, применить правило ведущих нулей

                LD B, A
                XOR A
                LD (ZeroSuppress), A
                LD A, B                                                         ; далее Game.Economy.PrintDigitOrLeadingZero.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #D371
                endmodule
                endmodule
