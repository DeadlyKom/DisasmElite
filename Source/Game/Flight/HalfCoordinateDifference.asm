                module Flight
                module HalfCoordinateDifference
; -----------------------------------------
; Половина разности старших слов координат
; исходный диапазон #71E4..#71F2
; In:
;   IX/IY адреса координат, используются смещения 1/2
; Out:
;   HL знако-модульная половина IY-IX
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Младшие дробные байты координат не участвуют, хвост 9CA5 ведёт в Math.HalfDelta
; -----------------------------------------
                ASSERT $ == #71E4
                ; чтение старших слов координат для общей операции полуразности
Entry:          LD H, (IY+FCoordinate.SignHigh)
                LD L, (IY+FCoordinate.Low)
                LD D, (IX+FCoordinate.SignHigh)
                LD E, (IX+FCoordinate.Low)
                JP @Game.Combat.CreateWreckAndDamageState.SignedDelta
                ASSERT $ == #71F3
                endmodule
                endmodule
