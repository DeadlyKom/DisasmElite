                module Motion
                module RotateBasisByObject
; -----------------------------------------
; поворот одной компоненты трёх осей собственным вращением объекта
; исходный диапазон #A127..#A172
; In:
;   IX, текущая компонента координат объекта
; Out:
;   IX, следующая компонента, прибавлено 2
; Corrupt:
;   HL, DE, BC, AF
; Note:
; Обрабатываются байты IX+10,+16,+22, соответствующие компонентам осей X/Y/Z.
; Три вызова охватывают весь базис. Углы #9F80/#9F81 содержат команды объекта.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #A127
                ; чтение компонент базиса и собственных углов
Entry:          LD A, (RotationState.Pitch)
                XOR #80
                LD C, A
                LD A, C
                LD B, (IX + FSpaceObject.AxisY + FSignWord.SignHigh)
                LD D, (IX + FSpaceObject.AxisX + FSignWord.SignHigh)
                CALL Game.Motion.AddSignedAngularProduct.Entry
                LD (IX + FSpaceObject.AxisX + FSignWord.SignHigh), A
                LD A, (RotationState.Roll)
                XOR #80
                LD C, A
                LD A, C
                LD B, (IX + FSpaceObject.AxisY + FSignWord.SignHigh)
                LD D, (IX + FSpaceObject.AxisZ + FSignWord.SignHigh)
                CALL Game.Motion.AddSignedAngularProduct.Entry
                LD (IX + FSpaceObject.AxisZ + FSignWord.SignHigh), A
                LD A, (RotationState.Roll)
                LD C, A
                LD B, (IX + FSpaceObject.AxisZ + FSignWord.SignHigh)
                LD D, (IX + FSpaceObject.AxisY + FSignWord.SignHigh)
                CALL Game.Motion.AddSignedAngularProduct.Entry
                LD (IX + FSpaceObject.AxisY + FSignWord.SignHigh), A
                LD A, (RotationState.Pitch)
                LD C, A
                LD A, C
                LD B, (IX + FSpaceObject.AxisX + FSignWord.SignHigh)
                LD D, (IX + FSpaceObject.AxisY + FSignWord.SignHigh)
                CALL Game.Motion.AddSignedAngularProduct.Entry
                LD (IX + FSpaceObject.AxisY + FSignWord.SignHigh), A
                INC IX
                INC IX
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #A173
                endmodule
                endmodule
