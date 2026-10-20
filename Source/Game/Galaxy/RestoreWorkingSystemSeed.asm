                module Galaxy
                module RestoreWorkingSystemSeed
; -----------------------------------------
; Восстановление рабочего семени планеты
; исходный диапазон #E136..#E141
; In:
;   DEC6..DECB = сохранённое семя
; Out:
;   DEC0..DEC5 обновлены, HL=DECC, DE=DEC6, BC=0
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   E13C общий вход копирования ровно 6 байт для трёх процедур
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E136
                ; возврат сохранённого рабочего семени после временных вычислений
Entry:          LD HL, GalaxyState.SavedSeed
                LD DE, GalaxyState.WorkingSeed
CopySeed:       LD BC, #0006
                LDIR
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #E142
                endmodule
                endmodule
