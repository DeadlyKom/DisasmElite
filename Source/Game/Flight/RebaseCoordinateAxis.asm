                module Flight
                module RebaseCoordinateAxis
; -----------------------------------------
; Перевод одной оси относительно станции
; исходный диапазон #71CE..#71E3
; In:
;   IX/IY указывают трёхбайтовые координаты
; Out:
;   поля FCoordinate.Low и FCoordinate.SignHigh по IY получают удвоенную знако-модульную полуразность, IX и IY переходят к следующим координатам
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
;   Сначала Game.Flight.HalfCoordinateDifference.Entry вычисляет floor(abs(delta)/2), удвоение возвращает чётный модуль, исходный знак
;   восстанавливается через перенос
; -----------------------------------------
                ASSERT $ == #71CE
                ; расчёт чётного модуля разности через удвоение знако-модульной полуразности
Entry:          CALL Game.Flight.HalfCoordinateDifference.Entry
                ADD HL, HL
                JR NC, StoreAxis                                                ; переход, если знак половины разности положительный, оставить старший бит нулевым

                SET 7, H
                ; сохранение старших двух байтов и переход к следующей оси
StoreAxis:      LD (IY+FCoordinate.SignHigh), H
                LD (IY+FCoordinate.Low), L
                LD DE, #0003
                ADD IY, DE
                ADD IX, DE
                RET

                ASSERT $ == #71E4
                endmodule
                endmodule
