                module Wireframe
                module MultiplyBytesApprox
; -----------------------------------------
; приближённое 16-битное произведение байтов по четверть-квадратам
; исходный диапазон #AB34..#AB4E
; In:
;   BC, B и C содержат беззнаковые множители
; Out:
;   HL, приближённое произведение
;   BC, исходные множители
; Corrupt:
;   DE, AF
; Note:
; Результат равен Q[floor((B+C)/2)]-Q[floor(abs(B-C)/2)], Q[n]=n*n.
; При одинаковой чётности это B*C, при разной B*C-min(B,C).
; Таблицы #BE00/#BF00 разделяют младшие и старшие байты квадратов.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #AB34
                ; расчёт табличного квадрата половины разности
Entry:          LD A, B
                SUB C
                JR NC, HalfDifference                                           ; переход, если B не меньше C и модуль разности уже положителен

                NEG
HalfDifference: SRL A
                LD H, #BE
                LD L, A
                LD E, (HL)
                INC H
                ; расчёт табличного квадрата половины суммы и их разности
                LD D, (HL)
                DEC H
                LD A, B
                ADD A, C
                RRA
                LD L, A
                LD A, (HL)
                INC H
                LD H, (HL)
                LD L, A
                AND A
                SBC HL, DE
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #AB4F
                endmodule
                endmodule
