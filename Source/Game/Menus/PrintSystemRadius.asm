                module Menus
                module PrintSystemRadius
; -----------------------------------------
; Вычисление и печать радиуса планеты
; исходный диапазон #EF21..#EF36
; In:
;   DEBE = последнее слово семени, DEBC = среднее
; Out:
;   Напечатано 256*((DEBF&15)+11)+DEBD
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Старший байт радиуса строится из младших 4 бит DEBF, младший равен DEBD, формат целый и
;   ширина 5
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #EF21
                ; радиус планеты вычисляется из двух байтов семени и печатается в километрах
Entry:          LD HL, (GalaxyState.TargetSeed + FSystemSeed.MixLow)
                LD A, H
                AND #0F
                ADD A, #0B
                LD HL, (GalaxyState.TargetSeed + FSystemSeed.GovBits)
                LD L, H
                LD H, A
                LD A, #05
                LD (NumberWidth), A
                AND A
                JP Game.Economy.PrintWordDecimal.Entry
                ; проверка исходного конца фрагмента
                ASSERT $ == #EF37
                endmodule
                endmodule
