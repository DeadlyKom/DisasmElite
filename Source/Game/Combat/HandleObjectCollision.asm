                module Combat
                module HandleObjectCollision
; -----------------------------------------
; столкновение, захват груза и проверка стыковки
; исходный диапазон #B4D8..#B5DE
; In:
;   IX, объект
;   IY, модель
;   память 711F, признак гибели
; Out:
;   обновлены энергия объекта, груз, урон или запрос стыковки
; Corrupt:
;   HL, DE, BC, AF
; Note:
; Близость проверяется отдельно по модулям X/Y/Z, это прямоугольная область.
; Порог задаёт IY+1, ракета на игрока получает старший байт 1, захватываемый груз младший порог B4.
; IX+26.1 допускает захват совком D088 только со стороны отрицательного Y и при свободном месте D07C.
; Тип груза берётся из старшей тетрады IY+0, иначе определяется миссионным состоянием либо случайно.
; Для станции IX+26.2 проверяются направление и точность совмещения осей, успех ставит 9C9A=1.
; Неудачная мягкая стыковка добавляет к переднему урону 12+2*скорость.
; Обычное столкновение удаляет объект, а урон формируется OR размера IY+1 и байта IY+15.
; Знак Z выбирает переднюю либо заднюю защиту, общий хвост B5DF снимает ракетные цели.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #B4D8
                ; проверка гибели и расчёт порога столкновения
Entry:          LD A, (FlightState.PlayerDead)
                AND A
                RET NZ                                                          ; выход, если игрок уже погиб

                LD D, #00
                LD E, (IY+FModel.Collision)
                BIT OBJ_MISSILE_BIT, (IX+FSpaceObject.Flags2)
                JR Z, CheckCargo                                                ; переход, если объект не является ракетой

                LD A, (IX+FSpaceObject.Target)
                AND A
                JR NZ, CheckCargo                                               ; переход, если ракета направлена не на игрока

                LD D, #01
CheckCargo:     BIT OBJ_SCOOP_BIT, (IX+FSpaceObject.Flags2)
                JR Z, CheckDistance                                             ; переход, если объект не относится к захватываемому грузу

                LD E, #B4
                ; проверка трёх координат относительно порога
CheckDistance:  LD L, (IX+FSpaceObject.X.Fraction)
                LD H, (IX+FSpaceObject.X.Low)
                SBC HL, DE
                RET NC                                                          ; выход, если модуль X не меньше порога столкновения

                AND A
                LD L, (IX+FSpaceObject.Y.Fraction)
                LD H, (IX+FSpaceObject.Y.Low)
                SBC HL, DE
                RET NC                                                          ; выход, если модуль Y не меньше порога столкновения

                AND A
                LD L, (IX+FSpaceObject.Z.Fraction)
                LD H, (IX+FSpaceObject.Z.Low)
                SBC HL, DE
                RET NC                                                          ; выход, если модуль Z не меньше порога столкновения

                ; проверка возможности захвата совком
                LD A, (IX+FSpaceObject.Z.SignHigh)
                ADD A, A
                RET NZ                                                          ; выход, если старшая часть модуля Z ненулевая

                BIT OBJ_SCOOP_BIT, (IX+FSpaceObject.Flags2)
                JR Z, CheckStation                                              ; переход, если объект не захватываемый и проверяется станция либо удар

                BIT 7, (IX+FSpaceObject.Y.SignHigh)
                JP Z, DestroyImpact                                             ; переход, если объект не под совком со стороны отрицательного Y

                LD A, (State.FuelScoops)
                AND A
                JR Z, DestroyImpact                                             ; переход, если совок не установлен

                XOR A
                LD (IX+FSpaceObject.Energy), A
                CALL Game.Combat.MarkRemovedAndReleaseTargets.Entry
                LD A, (State.FreeCargo)
                AND A
                JR Z, DestroyImpact                                             ; переход, если в трюме нет свободного места

                LD A, (IY+FModel.Cargo)
                AND #F0
                JR Z, MissionCargo                                              ; переход, если модель не задаёт явный тип груза

                RRCA
                RRCA
                RRCA
                RRCA
                INC A
                JR ScoopCargo

MissionCargo:   LD A, (MissionPhase)
                SUB #03
                JR NZ, RandomCargo                                              ; переход, если миссия не находится в состоянии специального груза 3

                LD (MissionPhase), A
                DEC A
                JR ScoopCargo

RandomCargo:    CALL Game.Combat.NextRandomByte.Entry
                AND #07
ScoopCargo:     JP Game.Missions.DispatchMissionEvents.ScoopItem

                ; проверка допуска стыковки со станцией
CheckStation:   BIT OBJ_SPECIAL_BIT, (IX+FSpaceObject.Flags2)
                JR Z, DestroyImpact                                             ; переход, если объект не является станционным типом

                BIT 7, (IX+FSpaceObject.AxisX.Z+FSignWord.SignHigh)
                JR Z, FatalImpact                                               ; переход, если продольная ось станции направлена несовместимо со стыковкой

                CALL Game.Screen.CheckDockingAlignment.Entry
                JP C, DockDamage                                                ; переход, если проверка проёма обнаружила смещение или активный туннель

                BIT OBJ_HOSTILE_BIT, (IX+FSpaceObject.Hostility)
                JR NZ, FatalImpact                                              ; переход, если станция враждебна и стыковка завершается аварией

                LD A, (IX+FSpaceObject.AxisX.X+FSignWord.SignHigh)
                ADD A, A
                CP #DC
                JR NC, FatalImpact                                              ; переход, если первая компонента оси выходит за допустимый предел DC

                LD B, A
                LD A, (IX+FSpaceObject.AxisX.Y+FSignWord.SignHigh)
                ADD A, A
                CP #DC
                JR NC, FatalImpact                                              ; переход, если вторая компонента оси выходит за допустимый предел DC

                CP #3C
                JR NC, DockDamage                                               ; переход, если вторая компонента ещё не совмещена достаточно точно

                LD A, B
                CP #3C
                JR NC, DockDamage                                               ; переход, если первая компонента ещё не совмещена достаточно точно

                LD A, #01
                LD (CombatState.DockRequest), A
                RET

                ; начисление урона при неполном совмещении
DockDamage:     LD HL, FlightState.SoundRequests
                SET SND_HIT_BIT, (HL)
                LD HL, FlightState.Speed
                LD A, (CombatState.FrontDamage)
                ADD A, #0C
                ADD A, (HL)
                ADD A, (HL)
                LD (CombatState.FrontDamage), A
                RET

                ; удаление объекта при обычном ударе
DestroyImpact:  XOR A
                CALL Game.Combat.SetObjectEnergyAndDrawMissedLaser.Entry
                LD B, (IY+FModel.Collision)
                BIT OBJ_MISSION_BIT, (IX+FSpaceObject.Flags2)
                JR Z, DamageSide                                                ; переход, если объект не помечен миссионным битом 6

                LD A, (MissionPhase)
                AND A
                JR Z, DamageSide                                                ; переход, если миссионное состояние уже нулевое

                XOR A
                LD (MissionPhase), A
                ; выбор передней либо задней защиты для урона
DamageSide:     LD HL, FlightState.SoundRequests
                SET SND_BLAST_BIT, (HL)
                BIT 7, (IX+FSpaceObject.Z.SignHigh)
                JR Z, FrontImpact                                               ; переход, если объект находится впереди и повреждает переднюю защиту

                LD A, (IY+FModel.Rating)
                OR B
                LD (CombatState.RearDamage), A
                JR Game.Combat.ReleaseMissileTargets.Entry

                ; установка признака смертельного столкновения
FatalImpact:    INC A
                LD (FlightState.PlayerDead), A
                RET

FrontImpact:    LD A, (IY+FModel.Rating)
                OR B
                LD (CombatState.FrontDamage), A
                ; проверка исходного конца фрагмента
                ASSERT $ == #B5DF
                endmodule
                endmodule
