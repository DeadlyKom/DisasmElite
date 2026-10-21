                module Combat
                module ReleaseMissileTargets
; -----------------------------------------
; снятие ракетных целей при удалении объекта
; исходный диапазон #B5DF..#B617
; In:
;   IX, удаляемый объект
;   ObjectIndex, обратный номер удаляемого объекта
; Out:
;   IY, исходное значение
;   связанные объекты и захват игрока обновлены
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Обычный обход проверяет семь слотов после станции, IY указывает на проверяемый слот
;   FSpaceObject.Target сравнивается с ObjectIndex удаляемого объекта IX
;   DetachMissileTarget.Entry меняет признаки и цель связанного объекта IY
;   Для каждого непустого слота вызывается UpdateThargoidAndBodyCoords.Entry с тем же IX
;   Поэтому State.AlienComputer может увеличиться несколько раз за одно удаление
;   Если счётчик обнулился, InitializeObject.Entry заменяет объект IX контейнером
;   На этом пути меняются HL, DE, BC и IY, вызывающий цикл их не сохраняет
;   Параметры обычного семислотового обхода после создания контейнера не восстанавливаются
;   Исходный IY восстанавливается при выходе из всей процедуры
;   При совпадении MissileTarget с ObjectIndex сбрасывается AimState
;   Затем EVENT_WAIT_BIT устанавливается в третьей записи FlightEvents
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
                ; счётчик удаляемой модели обновляется для текущего непустого слота
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
