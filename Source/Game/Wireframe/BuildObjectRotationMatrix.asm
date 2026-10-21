                module Wireframe
                module BuildObjectRotationMatrix
; -----------------------------------------
; восстановление оси Z и построение матрицы поворота объекта
; исходный диапазон #AECC..#AF21
; In:
;   IX, объект с осями X и Y
; Out:
;   IX, исходный объект, старшие байты оси Z восстановлены
;   IY, матрица ObjectMatrix
; Corrupt:
;   HL, DE, BC, AF
; Note:
; Три компоненты Z вычисляются как векторное произведение X и Y.
; Матрица из девяти слов получает старшие байты X/Y/Z в порядке, используемом преобразованием вершин.
; Младшие байты матрицы не меняются, арифметика последующих преобразований использует нечётные позиции.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #AECC
                ; расчёт первой компоненты векторного произведения X и Y
Entry:          LD IY, ObjectMatrix
                LD B, (IX + FSpaceObject.AxisX.Y + FSignWord.SignHigh)
                LD C, (IX + FSpaceObject.AxisY.Z + FSignWord.SignHigh)
                LD D, (IX + FSpaceObject.AxisX.Z + FSignWord.SignHigh)
                LD E, (IX + FSpaceObject.AxisY.Y + FSignWord.SignHigh)
                CALL Game.Wireframe.CrossProductComponent.Entry
                LD (IX + FSpaceObject.AxisZ.X + FSignWord.SignHigh), H
                LD (IY + FMatrix3.X.X + FSignWord.SignHigh), H
                LD B, (IX + FSpaceObject.AxisX.Z + FSignWord.SignHigh)
                LD (IY + FMatrix3.Z.Z + FSignWord.SignHigh), B
                LD C, (IX + FSpaceObject.AxisY.X + FSignWord.SignHigh)
                LD (IY + FMatrix3.X.Y + FSignWord.SignHigh), C
                LD D, (IX + FSpaceObject.AxisX.X + FSignWord.SignHigh)
                LD E, (IX + FSpaceObject.AxisY.Z + FSignWord.SignHigh)
                LD (IY + FMatrix3.Z.Y + FSignWord.SignHigh), E
                CALL Game.Wireframe.CrossProductComponent.Entry
                LD (IX + FSpaceObject.AxisZ.Y + FSignWord.SignHigh), H
                LD (IY + FMatrix3.Y.X + FSignWord.SignHigh), H
                LD B, (IX + FSpaceObject.AxisX.X + FSignWord.SignHigh)
                LD (IY + FMatrix3.X.Z + FSignWord.SignHigh), B
                LD C, (IX + FSpaceObject.AxisY.Y + FSignWord.SignHigh)
                LD (IY + FMatrix3.Y.Y + FSignWord.SignHigh), C
                LD D, (IX + FSpaceObject.AxisX.Y + FSignWord.SignHigh)
                LD (IY + FMatrix3.Y.Z + FSignWord.SignHigh), D
                LD E, (IX + FSpaceObject.AxisY.X + FSignWord.SignHigh)
                CALL Game.Wireframe.CrossProductComponent.Entry
                LD (IX + FSpaceObject.AxisZ.Z + FSignWord.SignHigh), H
                LD (IY + FMatrix3.Z.X + FSignWord.SignHigh), H
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #AF22
                endmodule
                endmodule
