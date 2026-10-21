                module Galaxy
                module RestoreWorkingSystemSeed
; -----------------------------------------
; Восстановление рабочего семени планеты
; исходный диапазон #E136..#E141
; In:
;   GalaxyState.SavedSeed = сохранённое семя
; Out:
;   GalaxyState.WorkingSeed обновлены, HL=GalaxyState.TextSeed, DE=GalaxyState.SavedSeed, BC=0
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Game.Galaxy.RestoreWorkingSystemSeed.CopySeed общий вход копирования ровно 6 байт для трёх процедур
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
