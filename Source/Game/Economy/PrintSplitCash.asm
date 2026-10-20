                module Economy
                module PrintSplitCash
; -----------------------------------------
; Печать числа в двух группах с основанием 10000
; исходный диапазон #D334..#D356
; In:
;   HL = старшая группа, DE = младшая группа в десятых
; Out:
;   Напечатано значение HL*1000+DE/10
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Ненулевая старшая группа печатается целым, младшая дополняется нулями до четырёх цифр, при
;   нулевой старшей группе применяется ширина 7 с пробелами
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D334
                ; старшая группа печатается отдельно, младшая дополняется четырьмя позициями
Entry:          PUSH DE
                LD A, L
                OR H
                JR Z, OnlyLowGroup                                              ; переход, если старшая группа денежного числа равна нулю, печатать только младшую

                LD A, #03
                LD (NumberWidth), A
                AND A
                CALL Game.Economy.PrintWordDecimal.Entry
                XOR A
                LD (ZeroSuppress), A
                LD A, #04
                LD (NumberWidth), A
                JR PrintLowGroup

OnlyLowGroup:   LD A, #07
                LD (NumberWidth), A
PrintLowGroup:  POP HL
                SCF
                JP Game.Economy.PrintWordDecimal.Entry
                ; проверка исходного конца фрагмента
                ASSERT $ == #D357
                endmodule
                endmodule
