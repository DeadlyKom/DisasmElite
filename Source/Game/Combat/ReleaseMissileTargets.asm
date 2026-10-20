                module Combat
                module ReleaseMissileTargets
; -----------------------------------------
; снятие ракетных целей при удалении объекта
; исходный диапазон #B5DF..#B617
; In:
;   IX, удаляемый объект
;   память 9CB4, его обратный номер
; Out:
;   IY, исходное значение
;   связанные объекты и захват игрока обновлены
; Corrupt:
;   HL, DE, BC, AF
; Note:
; Просматривает семь слотов после станции, сравнивая IX+25 каждого живого объекта с удаляемым номером.
; 8C29 либо ставит запрос уничтожения, либо переводит связанный объект в тип 3 и сбрасывает цель.
; 8AA3 дополнительно обслуживает специальный тип удаляемого объекта, вызов выполняется в каждой итерации.
; Если ракета игрока захватила именно удалённый номер, D047 сбрасывается и ставится сообщение D0C1.7.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #B5DF
                ; поиск связанных целей в семи слотах после станции
Entry:          LD A, (ObjectIndex)
                LD H, A
                PUSH IY
                LD IY, Memory.Station
                LD DE, FSpaceObject
                LD B, #07
                ; проверка живого слота и совпадения кода цели
CheckTarget:    ADD IY, DE
                LD A, (IY+FSpaceObject.Energy)
                AND A
                JR Z, NextMissile                                               ; переход, если проверяемый слот пуст

                LD A, (IY+FSpaceObject.Target)
                XOR H
                CALL Z, Game.Circles.DetachMissileTarget.Entry                  ; вызов процедуры, если код цели проверяемого объекта совпал с удаляемым номером
                CALL Game.Circles.UpdateThargoidAndBodyCoords.Entry
NextMissile:    DJNZ CheckTarget

                POP IY
                LD A, (AimState)
                CP #02
                RET NZ                                                          ; выход, если ракета игрока не находится в состоянии захвата

                LD A, (MissileTarget)
                SUB H
                RET NZ                                                          ; выход, если захвачена другая цель

                LD (AimState), A
                LD HL, FlightEvents + 2 * FFlightEvent
                SET EVENT_WAIT_BIT, (HL)
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #B618
                endmodule
                endmodule
