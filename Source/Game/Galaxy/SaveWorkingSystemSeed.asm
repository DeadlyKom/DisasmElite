                module Galaxy
                module SaveWorkingSystemSeed
; -----------------------------------------
; Сохранение рабочего семени планеты
; исходный диапазон #E12E..#E135
; In:
;   DEC0..DEC5 = рабочее семя
; Out:
;   DEC6..DECB = копия, BC=0
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Буфер позволяет восстановить семя после генерации имени, использует общий хвост E13C
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E12E
                ; сохранение шести байтов рабочего семени перед разрушительным перебором
Entry:          LD HL, GalaxyState.WorkingSeed
                LD DE, GalaxyState.SavedSeed
                JR @Game.Galaxy.RestoreWorkingSystemSeed.CopySeed
                ; проверка исходного конца фрагмента
                ASSERT $ == #E136
                endmodule
                endmodule
