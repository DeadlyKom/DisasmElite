                module Motion
                module AdvanceObjectAlongLocalAxis
; -----------------------------------------
; собственное вращение объекта и перемещение по скорости
; исходный диапазон #9FFD..#A04A
; In:
;   AF, A содержит подготовленный угол DU
;   IX, объект
;   IY, описание модели
; Out:
;   IX, исходный объект
;   IY, исходная модель
;   базис, скорость и координаты обновлены
; Corrupt:
;   HL, DE, BC, AF
; Note:
; Общий хвост UpdateObjectCoordinatesAndRotation, также отдельный вход демонстрации.
; скорость ограничена снизу нулём, сверху FModel.MaxSpeed, OBJ_FAST_BIT в FSpaceObject.Hostility увеличивает верхний предел в четыре раза
; Отрицательный результат определяется по биту 7 восьмибитной суммы скорости и ускорения.
; три вызова Game.Motion.AdvanceOneCoordinate.Entry перемещают объект вдоль локальной оси FSpaceObject.AxisX
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #9FFD
                ; обновление базиса собственными углами объекта
Entry:          LD (RotationState.Pitch), A
                PUSH IX
                CALL Game.Motion.RotateBasisByObject.Entry
                CALL Game.Motion.RotateBasisByObject.Entry
                CALL Game.Motion.RotateBasisByObject.Entry
                POP IX
                LD A, (IX + FSpaceObject.Acceleration)
                AND A
                JR Z, AdvanceAxes                                               ; переход, если ускорение равно нулю и скорость остаётся прежней

                LD B, (IX + FSpaceObject.Speed)
                ADD A, B
                BIT 7, A
                JR Z, LimitSpeed                                                ; переход, если результат изменения скорости не имеет установленного бита 7

                XOR A
                JR StoreSpeed

                ; расчёт допустимого верхнего предела скорости
LimitSpeed:     LD C, (IY + FModel.MaxSpeed)
                BIT OBJ_FAST_BIT, (IX + FSpaceObject.Hostility)
                JR Z, ClampSpeed                                                ; переход, если для объекта действует обычный предел скорости модели

                SLA C
                SLA C
ClampSpeed:     CP C
                JR C, StoreSpeed                                                ; переход, если новая скорость меньше верхнего предела

                LD A, C
StoreSpeed:     LD (IX + FSpaceObject.Speed), A
                ; обновление трёх координат вдоль оси движения
AdvanceAxes:    PUSH IX
                PUSH IY
                LD C, (IX + FSpaceObject.Speed)
                PUSH IX
                POP IY
                CALL Game.Motion.AdvanceOneCoordinate.Entry
                CALL Game.Motion.AdvanceOneCoordinate.Entry
                CALL Game.Motion.AdvanceOneCoordinate.Entry
                POP IY
                POP IX
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #A04B
                endmodule
                endmodule
