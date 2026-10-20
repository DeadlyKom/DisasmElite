                module Screen
                module CompassNearAxis
; -----------------------------------------
; нормирование координаты близкого объекта для компаса
; In:
;   DE, длина вектора
;   IX, адрес младших двух байтов координаты
; Out:
;   AF, A содержит нормированную координату со знаком в бите 7
; Corrupt:
;   HL, BC, AF
; Note:
;   вход #8271 использует два младших байта координаты, дробный вход A обнуляется
;   общий хвост вычисления находится по #82BB
;   вход #827A является независимым продолжением дальнего компаса
;   он рассчитывает длину по старшим словам, затем нормирует X и Y
;   X сохраняется в #81A6, Y в #81A7, признак задней полусферы в #81A8
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #8271
                ; подготовка близкой координаты для деления
Entry:          XOR A
                LD L, (IX + FCoordinate.Fraction)
                LD H, (IX + FCoordinate.Low)
                JR Game.Screen.CompassFarAxis.ScaleAxis

                ; общий вход дальнего компаса из проверки близости планеты
FarCompass:     NOP
                CALL Game.Input.ToggleSecondaryCoordinateObject.Entry
                ; расчёт длины по старшим словам координат
HighWordLength: INC IX
                CALL Game.Screen.LengthHighWords.Entry
                LD A, H
                OR L
                JR NZ, NormalizeFar                                             ; переход, если длина для нормирования ненулевая

                DEC HL
NormalizeFar:   EX DE, HL
                DEC IX
                PUSH DE
                CALL Game.Screen.CompassFarAxis.Entry
                LD (CompassState.X), A
                INC IX
                INC IX
                INC IX
                POP DE
                CALL Game.Screen.CompassFarAxis.Entry
                ; сохранение Y и признака передней или задней полусферы
StoreCompassY:  LD (CompassState.Y), A
                LD A, (IX + FCoordinate + FCoordinate.SignHigh)
                AND #80
                LD A, #00
                JR Z, StoreSide                                                 ; переход, если объект находится в передней полусфере

                LD A, #01
StoreSide:      LD (CompassState.Behind), A
                JP Game.Screen.VectorLength.DrawCompass
                ASSERT $ == #82B0
                endmodule
                endmodule
