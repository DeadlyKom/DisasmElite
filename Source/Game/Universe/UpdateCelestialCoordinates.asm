                module Universe
                module UpdateCelestialCoordinates
; -----------------------------------------
; пересчёт координат небесных тел по движению игрока
; исходный диапазон #7853..#7860
; In:
;   память FlightState.Sun/FlightState.Planet и дополнительные координаты DistantBodies/DistantBodies.Second
; Out:
;   координаты всех используемых тел обновлены
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
; Сначала преобразует первое тело FlightState.Sun, затем хвост Game.Combat.UpdateClockAndRotateDistantBodies.RotateBodies начинает со второго FlightState.Planet.
; Game.Combat.UpdateClockAndRotateDistantBodies.RotateBodies дополнительно вращает DistantBodies и DistantBodies.Second с временно отключённым поступательным переносом.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #7853
                ; преобразование первого тела и переход к оставшимся координатам
Entry:          LD IX, FlightState.Sun
                CALL Game.Combat.ApplyPlayerMotion.Entry
                LD IX, FlightState.Planet
                JP @Game.Combat.UpdateClockAndRotateDistantBodies.RotateBodies

                ; проверка исходного конца фрагмента
                ASSERT $ == #7861
                endmodule
                endmodule
