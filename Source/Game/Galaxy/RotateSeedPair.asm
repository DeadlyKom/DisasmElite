                module Galaxy
                module RotateSeedPair
; -----------------------------------------
; Циклический поворот двух байтов семени
; исходный диапазон #DF1A..#DF23
; In:
;   HL = адрес пары
; Out:
;   HL указывает на второй байт, DE содержит изменённую пару
; Corrupt:
;   HL, DE, AF
; Note:
;   В отличие от Game.Travel.RotateTwoSeedBytesAdvance.Entry указатель после второго байта не увеличивается
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #DF1A
                ; поворот пары байтов семени с замыканием переноса через старший разряд
Entry:          LD E, (HL)
                RLC E
                LD (HL), E
                INC HL
                LD D, (HL)
                RLC D
                LD (HL), D
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #DF24
                endmodule
                endmodule
