                module Motion
                module RotateAxisByPlayer
; -----------------------------------------
; поворот одной оси объекта вслед за управлением игрока
; исходный диапазон #A0AB..#A0FC
; In:
;   IX, адрес трёх слов оси
; Out:
;   IX, адрес следующей оси, прибавлено 6
; Corrupt:
;   HL, DE, BC, AF
; Note:
; Углы берутся из #9F80/#9F81, меняются только старшие байты компонент.
; Четыре малых поворота связывают пары X/Y и Y/Z. Угол DU дополнительно делится пополам.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #A0AB
                ; расчёт первого малого поворота по углам игрока
Entry:          LD A, (RotationState.Pitch)
                XOR #80
                SRA A
                RES 6, A
                LD C, A
                LD B, (IX + FAxis.Y + FSignWord.SignHigh)
                LD D, (IX + FAxis.Z + FSignWord.SignHigh)
                CALL Game.Motion.AddSignedAngularProduct.Entry
                LD (IX + FAxis.Z + FSignWord.SignHigh), A
                LD A, (RotationState.Roll)
                ; обновление сопряжённых компонент с обратным знаком угла
                XOR #80
                LD C, A
                LD B, (IX + FAxis.Y + FSignWord.SignHigh)
                LD D, (IX + FAxis.X + FSignWord.SignHigh)
                CALL Game.Motion.AddSignedAngularProduct.Entry
                LD (IX + FAxis.X + FSignWord.SignHigh), A
                LD A, (RotationState.Roll)
                LD C, A
                LD B, (IX + FAxis.X + FSignWord.SignHigh)
                LD D, (IX + FAxis.Y + FSignWord.SignHigh)
                CALL Game.Motion.AddSignedAngularProduct.Entry
                LD (IX + FAxis.Y + FSignWord.SignHigh), A
                LD A, (RotationState.Pitch)
                SRA A
                RES 6, A
                LD C, A
                LD B, (IX + FAxis.Z + FSignWord.SignHigh)
                LD D, (IX + FAxis.Y + FSignWord.SignHigh)
                CALL Game.Motion.AddSignedAngularProduct.Entry
                LD (IX + FAxis.Y + FSignWord.SignHigh), A
                LD DE, #0006
                ADD IX, DE
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #A0FD
                endmodule
                endmodule
