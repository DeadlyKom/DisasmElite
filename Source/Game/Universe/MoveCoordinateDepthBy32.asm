                module Universe
                module MoveCoordinateDepthBy32
; -----------------------------------------
; перенос знако-модульной глубины на 32 единицы
; исходный диапазон #7F2D..#7F63
; In:
;   IX, трёхбайтовые координаты объекта
; Out:
;   глубина IX+6..8 уменьшена на 32 единицы
; Corrupt:
;   HL, DE, BC, AF
; Note:
; Для положительной глубины вычитает 32 из целого слова, для отрицательной увеличивает модуль.
; При переходе через ноль пересчитывает дробную пару как 2000-старое значение и устанавливает знак.
; Переполнение отрицательной глубины уходит в общий обработчик 5FD5.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #7F2D
                ; проверка знака и расчёт переноса глубины
Entry:          LD BC, #0020
                LD H, (IX+FCoordinate+FCoordinate+FCoordinate.SignHigh)
                LD L, (IX+FCoordinate+FCoordinate+FCoordinate.Low)
                LD D, L
                BIT 7, H
                JR NZ, MoveNegative                                             ; переход, если глубина отрицательна и её модуль увеличивается

                AND A
                SBC HL, BC
                JR C, CrossOrigin                                               ; переход, если положительная глубина пересекла ноль

                JR StoreDepth

MoveNegative:   ADD HL, BC
                JR C, DepthOverflow                                             ; переход, если увеличение отрицательного модуля переполнило слово

StoreDepth:     LD (IX+FCoordinate+FCoordinate+FCoordinate.SignHigh), H
                LD (IX+FCoordinate+FCoordinate+FCoordinate.Low), L
                RET

                ; расчёт отрицательной глубины после перехода через ноль
CrossOrigin:    LD HL, #2000
                LD E, (IX+FCoordinate+FCoordinate+FCoordinate.Fraction)
                AND A
                SBC HL, DE
                LD A, #80
                LD (IX+FCoordinate+FCoordinate+FCoordinate.SignHigh), A
                LD (IX+FCoordinate+FCoordinate+FCoordinate.Low), H
                LD (IX+FCoordinate+FCoordinate+FCoordinate.Fraction), L
                RET

                ; передача переполнения общему обработчику
DepthOverflow:  JP Game.Extensions.OfferUpgradeAndCorrectPosition.CorrectCentre
                ; проверка исходного конца фрагмента
                ASSERT $ == #7F64
                endmodule
                endmodule
