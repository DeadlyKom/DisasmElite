                module Galaxy
                module LoadGalaxySeed
; -----------------------------------------
; Копирование базового семени галактики в рабочее
; исходный диапазон #E126..#E12D
; In:
;   D090..D095 = исходное семя
; Out:
;   DEC0..DEC5 обновлены, BC=0
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Настраивает указатели и использует общий 6 байтный LDIR по E13C
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E126
                ; копирование шести байтов базовой галактики в рабочий генератор
Entry:          LD HL, State.GalaxySeed
                LD DE, GalaxyState.WorkingSeed
                JR @Game.Galaxy.RestoreWorkingSystemSeed.CopySeed
                ; проверка исходного конца фрагмента
                ASSERT $ == #E12E
                endmodule
                endmodule
