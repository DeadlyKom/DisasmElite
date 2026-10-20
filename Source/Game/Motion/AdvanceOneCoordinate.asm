                module Motion
                module AdvanceOneCoordinate
; -----------------------------------------
; прибавление смещения от скорости к одной координате объекта
; исходный диапазон #A04B..#A075
; In:
;   BC, C содержит скорость
;   IX, компонента направления берётся из IX+9/+10
;   IY, адрес трёхбайтовой координаты
; Out:
;   BC, исходное значение
;   IX, следующая компонента направления
;   IY, следующая координата
; Corrupt:
;   HL, DE, AF
; Note:
; Координата хранит дробный байт, младший целый байт и старший целый байт со знаком.
; Три последовательных вызова обновляют X, Y и Z. IX увеличивается на 2, IY на 3.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #A04B
                ; расчёт смещения от скорости вдоль выбранной оси
Entry:          PUSH BC
                LD D, (IX + FSpaceObject.AxisX + FSignWord.SignHigh)
                LD E, (IX + FSpaceObject.AxisX + FSignWord.Low)
                CALL Game.Motion.VelocityComponentDelta.Entry
                LD A, (IY + FCoordinate.SignHigh)
                LD H, (IY + FCoordinate.Low)
                LD L, (IY + FCoordinate.Fraction)
                CALL Game.Motion.AddCoordinateDelta.Entry
                LD (IY + FCoordinate.SignHigh), B
                LD (IY + FCoordinate.Low), H
                LD (IY + FCoordinate.Fraction), L
                INC IY
                INC IY
                INC IY
                INC IX
                INC IX
                POP BC
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #A076
                endmodule
                endmodule
