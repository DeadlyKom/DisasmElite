                module Galaxy
                module AdvanceSystemSeed
; -----------------------------------------
; Переход к семени следующей планеты
; исходный диапазон #DFC4..#DFCD
; In:
;   GalaxyState.WorkingSeed = текущее семя
; Out:
;   Семя продвинуто четырьмя шагами NextRandom
; Corrupt:
;   HL, DE, AF
; Note:
;   BC сохраняется через PUSH/POP вокруг каждого шага, регистровый выход последнего шага не
;   сохраняется
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #DFC4
                ; переход к следующей системе четырьмя шагами шестибайтового генератора
Entry:          LD B, #04
AdvanceSeed:    PUSH BC
                CALL Game.Math.NextRandom
                POP BC
                DJNZ AdvanceSeed

                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #DFCE
                endmodule
                endmodule
