                module Economy
                module PrintByteInteger
; -----------------------------------------
; Печать беззнакового байта без дробной части
; исходный диапазон #D2E1..#D2E4
; In:
;   AF, A = число
; Out:
;   Число выведено
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   AND A снимает перенос, затем H=0, L=A и исполнение продолжается в Game.Economy.PrintWordDecimal.Entry
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D2E1
                ; целый формат, A расширяется до слова без знака
Entry:          AND A
ExtendByte:     LD H, #00
                LD L, A                                                         ; далее Game.Economy.PrintWordDecimal.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #D2E5
                endmodule
                endmodule
