                module Menus
                module PrintSystemRadius
; -----------------------------------------
; вычисление и печать радиуса планеты
; исходный диапазон #EF21..#EF36
; In:
;   значения полей FSystemSeed.Syllable и FSystemSeed.X целевого семени GalaxyState.TargetSeed
; Out:
;   напечатан радиус планеты в километрах, без дробной части и с шириной поля 5
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   радиус = 256 * ((Syllable AND #0F) + 11) + X
;   Syllable и X в формуле обозначают значения одноимённых байтов FSystemSeed в GalaxyState.TargetSeed
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
