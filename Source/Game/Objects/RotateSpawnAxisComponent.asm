                module Objects
                module RotateSpawnAxisComponent
; -----------------------------------------
; перестановка старших компонент осей при создании объекта
; исходный диапазон #BA3F..#BA82
; In:
;   IX - слот плюс смещение компоненты 0,2 или 4
; Out:
;   IX увеличен на 2, старшие компоненты осей изменены
; Corrupt:
;   BC, AF, IX
; Note:
;   основной вход обменивает старшие байты FSpaceObject.AxisX.X и FSpaceObject.AxisY.X и меняет знак FSpaceObject.AxisZ.X, во всех трёх словах используется FSignWord.SignHigh
;   самостоятельный общий хвост Game.Objects.RotateSpawnAxisComponent.RotateAxes обрабатывает все три компоненты без изменения IX
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #BA3F
                ; перестановка старших компонент текущих осей X и Y
Entry:          LD A, (IX+FSpaceObject.AxisX.X+FSignWord.SignHigh)
                LD B, (IX+FSpaceObject.AxisY.X+FSignWord.SignHigh)
                LD (IX+FSpaceObject.AxisY.X+FSignWord.SignHigh), A
                LD (IX+FSpaceObject.AxisX.X+FSignWord.SignHigh), B
                ; инверсия знака соответствующей компоненты оси Z
                LD A, (IX+FSpaceObject.AxisZ.X+FSignWord.SignHigh)
                XOR #80
                LD (IX+FSpaceObject.AxisZ.X+FSignWord.SignHigh), A
                INC IX
                INC IX
                RET

                ; перестановка всех трёх пар старших компонент X/Y с инверсией знака
RotateAxes:     LD A, (IX+FSpaceObject.AxisY.X+FSignWord.SignHigh)
                XOR #80
                LD B, (IX+FSpaceObject.AxisX.X+FSignWord.SignHigh)
                LD (IX+FSpaceObject.AxisX.X+FSignWord.SignHigh), A
                LD (IX+FSpaceObject.AxisY.X+FSignWord.SignHigh), B
                LD A, (IX+FSpaceObject.AxisY.Y+FSignWord.SignHigh)
                XOR #80
                LD B, (IX+FSpaceObject.AxisX.Y+FSignWord.SignHigh)
                LD (IX+FSpaceObject.AxisX.Y+FSignWord.SignHigh), A
                LD (IX+FSpaceObject.AxisY.Y+FSignWord.SignHigh), B
                LD A, (IX+FSpaceObject.AxisY.Z+FSignWord.SignHigh)
                XOR #80
                LD B, (IX+FSpaceObject.AxisX.Z+FSignWord.SignHigh)
                LD (IX+FSpaceObject.AxisX.Z+FSignWord.SignHigh), A
                LD (IX+FSpaceObject.AxisY.Z+FSignWord.SignHigh), B
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #BA83
                endmodule
                endmodule
