                module Objects
                module SpawnEscapePod
; -----------------------------------------
; создание спасательной капсулы либо оставленного корабля игрока
; исходный диапазон #BAFA..#BB2E
; In:
;   BC - C bit0 выбирает игрока
;   IX - исходный объект для капсулы
; Out:
;   дочерняя капсула либо объект модели 9 в фиксированном слоте Game.Data.ObjectPool.Ship6
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
;   для обычного объекта модель 2 передаётся Game.Objects.SpawnShipCargoOrPod.Entry
;   для игрока слот Game.Data.ObjectPool.Ship6 создаётся напрямую без поиска, направление случайно
;   задаются отрицательный Y, дробные Y=28,Z=76, угол DU=#C0 и прибавляется скорость игрока
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #BAFA
Entry:          BIT 0, C
                LD A, #02
                JR Z, Game.Objects.SpawnShipCargoOrPod.Entry                    ; переход, если спасательную капсулу выпускает исходный объект

                LD A, #09
                LD IX, Memory.Objects + 5 * FSpaceObject
                CALL Game.Objects.InitializeAtPlayer.Entry
                CALL Game.Objects.RandomizeSpawnDirection.Entry
                LD A, #80
                LD (IX+FSpaceObject.Y.SignHigh), A
                LD A, #1C
                LD (IX+FSpaceObject.Y.Fraction), A
                RES OBJ_ACTIVE_BIT, (IX+FSpaceObject.Flags)
                LD A, #4C
                LD (IX+FSpaceObject.Z.Fraction), A
                LD A, #C0
                LD (IX+FSpaceObject.Pitch), A
                LD A, (FlightState.Speed)
                ADD A, (IX+FSpaceObject.Speed)
                LD (IX+FSpaceObject.Speed), A
                XOR A
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #BB2F
                endmodule
                endmodule
