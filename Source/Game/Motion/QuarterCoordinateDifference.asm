                module Motion
                module QuarterCoordinateDifference
; -----------------------------------------
; разность координат цели и ракеты в масштабе четверти
; исходный диапазон #A53F..#A567
; In:
;   IX, трёхбайтовая координата ракеты
;   IY, трёхбайтовая координата цели
; Out:
;   HL, знако-модульная четверть разности
;   IX, следующая координата ракеты
;   IY, следующая координата цели
; Corrupt:
;   DE, BC, AF
; Note:
; Обе координаты сначала делятся пополам и упаковываются в слова.
; HalfDelta ещё раз делит результат пополам при знаковом вычитании.
; Старшие биты модуля из третьего байта не учитываются, нужен ближний диапазон.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #A53F
                ; чтение координат и упаковка знаков перед уменьшением масштаба
Entry:          LD L, (IY + FCoordinate.Fraction)
                LD H, (IY + FCoordinate.Low)
                LD C, (IY + FCoordinate.SignHigh)
                LD E, (IX + FCoordinate.Fraction)
                LD D, (IX + FCoordinate.Low)
                LD B, (IX + FCoordinate.SignHigh)
                SLA C
                RR H
                RR L
                SLA B
                RR D
                RR E
                CALL Game.Math.HalfDelta
                LD DE, #0003
                ADD IX, DE
                ADD IY, DE
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #A568
                endmodule
                endmodule
