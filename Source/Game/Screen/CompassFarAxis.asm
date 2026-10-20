                module Screen
                module CompassFarAxis
; -----------------------------------------
; нормирование дальней координаты и восстановление её знака
; In:
;   DE, ненулевая длина вектора
;   IX, адрес трёхбайтной координаты
; Out:
;   AF, A содержит координату указателя со знаком в бите 7
; Corrupt:
;   HL, BC, AF
; Note:
;   модуль координаты задаётся HL и дробным байтом A
;   #9C89 вызывает деление #AFA8, три пары RL B и RLA выделяют масштаб компаса
;   знак берётся из исходного старшего байта координаты IX+2
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #82B0
                ; получение модуля трёхбайтной координаты
Entry:          LD A, (IX + FCoordinate.Fraction)
                LD L, (IX + FCoordinate.Low)
                LD H, (IX + FCoordinate.SignHigh)
                RES 7, H
                ; деление на длину и перевод результата в масштаб указателя
ScaleAxis:      CALL Game.Combat.DivideAndCombatState.Entry
                RL B
                RLA
                RL B
                RLA
                RL B
                RLA
                ; восстановление знака исходной координаты
                LD H, (IX + FCoordinate.SignHigh)
                BIT 7, H
                JR Z, AxisReady                                                 ; переход, если координата положительна

                OR #80
AxisReady:      RET
                ASSERT $ == #82D1
                endmodule
                endmodule
