                module Combat
                module FirePlayerLaser
; -----------------------------------------
; охлаждение лазера, проверка выстрела и нанесение урона цели
; исходный диапазон #B63C..#B70E
; In:
;   память LaserRaster.TriggerHeld, предыдущее состояние спуска
;   память InputState.DeviceKeys.0, команда огня
;   память GaugeState + FGaugeState.LaserHeat.Current, температура
;   память CombatState.CrosshairTarget, номер цели прицела
; Out:
;   обновлены температура, энергия, звуки и состояние цели
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
; Каждый вызов охлаждает лазер на 2 с нижним пределом 0. Выстрел запрещён при температуре от #90.
; Лазер выбирается из State.FrontLaser..State.RightLaser по виду. Тип 1 задаёт маску темпа 1, тип 4 маску 7, остальные 0.
; Повторное удержание проверяет маску по CombatState.SpawnCounter, новое нажатие стреляет сразу.
; Мощность равна 15 для типов ниже 3, 23 для типа 3 и 50 для остальных.
; Температура увеличивается на 8 либо 10 с пределом A0, расход энергии увеличивается на 1.
; Номер цели 8 обозначает станцию, 1 последний слот, адрес равен Memory.Station+(8-номер)*39.
; объекты с OBJ_SPECIAL_BIT в FSpaceObject.Flags2, с OBJ_EXPLODE_BIT в FSpaceObject.Flags либо с энергией #FF не получают обычного урона
; смертельный урон устанавливает OBJ_DESTROY_BIT в FSpaceObject.Flags и энергию #FF до завершения жизненного цикла
; При отсутствии цели и после попадания общий хвост Game.Combat.SetObjectEnergyAndDrawMissedLaser.MissedBeam рисует четыре линии луча.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #B63C
                ; сохранение состояния спуска и расчёт охлаждения
Entry:          LD A, (LaserRaster.TriggerHeld)
                LD C, A
                XOR A
                LD (LaserRaster.TriggerHeld), A
                LD A, (GaugeState + FGaugeState.LaserHeat.Current)
                CP #02
                JR NC, CoolLaser                                                ; переход, если температура не ниже 2 и можно вычесть полный шаг охлаждения

                LD A, #02
CoolLaser:      SUB #02
                LD (GaugeState + FGaugeState.LaserHeat.Current), A
                LD HL, InputState.DeviceKeys
                BIT DEV_FIRE_BIT, (HL)
                RET Z                                                           ; выход, если событие огня отсутствует

                RES DEV_FIRE_BIT, (HL)
                CP #90
                RET NC                                                          ; выход, если после охлаждения температура всё ещё не ниже #90

                LD B, A
                LD A, (FlightState.View)
                LD HL, State.FrontLaser
                LD D, #00
                LD E, A
                ADD HL, DE
                LD A, (HL)
                AND A
                RET Z                                                           ; выход, если в текущем направлении нет лазера

                LD E, C
                LD C, A
                DEC A
                JR NZ, CheckPulse                                               ; переход, если тип лазера отличается от 1

                LD D, #01
CheckPulse:     SUB #03
                JR NZ, CheckTrigger                                             ; переход, если тип лазера отличается от 4

                LD D, #07
                ; проверка нового нажатия либо допустимого кадра удержания
CheckTrigger:   LD A, E
                AND E
                LD A, #01
                LD (LaserRaster.TriggerHeld), A
                JR Z, StartShot                                                 ; переход, если предыдущее состояние спуска нулевое и новый выстрел разрешён сразу

                LD A, (CombatState.SpawnCounter)
                AND D
                RET NZ                                                          ; выход, если счётчик кадра не удовлетворяет маске темпа лазера

                ; начисление расхода энергии и звукового запроса
StartShot:      LD HL, CombatState.EnergyDrain
                INC (HL)
                CALL Game.Flight.RaiseLaserThreshold.Entry
                LD HL, FlightState.SoundRequests
                SET SND_HIT_BIT, (HL)
                LD A, C
                SUB #03
                LD A, #0F
                JR C, HeatStep                                                  ; переход, если тип лазера ниже 3 и мощность остаётся 15

                JR Z, AddPower                                                  ; переход, если тип лазера равен 3 и мощность становится 23

                ADD A, #1B
AddPower:       ADD A, #08
HeatStep:       LD C, A
                LD A, D
                DEC A
                AND #01
                RLA
                ADD A, #08
                ADD A, B
                CP #A0
                JR C, StoreHeat                                                 ; переход, если новая температура меньше предела A0

                LD A, #A0
StoreHeat:      LD (GaugeState + FGaugeState.LaserHeat.Current), A
                ; поиск выбранной цели по обратному номеру слота
                LD A, (CombatState.CrosshairTarget)
                AND A
                JP Z, @Game.Combat.SetObjectEnergyAndDrawMissedLaser.MissedBeam ; переход, если в прицеле нет цели и рисуется свободный луч

                DEC A
                SUB #09
                CPL
                LD IX, Memory.Station
                LD DE, FSpaceObject
FindTarget:     DEC A
                JR Z, HitTarget                                                 ; переход, если достигнут слот выбранной цели

                ADD IX, DE
                JR FindTarget

                ; обновление поведения поражённого объекта
HitTarget:      CALL Game.Extensions.SetAggressionThenContinue.Entry
                NOP
                LD HL, FlightState.SoundRequests
                SET SND_LASER_BIT, (HL)
                ; проверка специальных и взрывающихся целей
                BIT OBJ_SPECIAL_BIT, (IX+FSpaceObject.Flags2)
                JR NZ, @Game.Combat.SetObjectEnergyAndDrawMissedLaser.MissedBeam ; переход, если у цели установлен OBJ_SPECIAL_BIT в FSpaceObject.Flags2 и обычный лазерный урон запрещён

                BIT OBJ_EXPLODE_BIT, (IX+FSpaceObject.Flags)
                JR NZ, @Game.Combat.SetObjectEnergyAndDrawMissedLaser.MissedBeam ; переход, если цель уже находится в состоянии взрыва

                LD A, (IX+FSpaceObject.Target)
                LD B, A
                SUB #0E
                JR NC, PackTarget                                               ; переход, если параметр поведения цели не меньше #0E и не требует преобразования

                AND #01
                ADD A, #06
PackTarget:     RLA
                SLA B
                RRA
                LD (IX+FSpaceObject.Target), A
                ; проверка неуязвимости и расчёт урона
                LD A, (IX+FSpaceObject.Energy)
                CP #FF
                JR Z, @Game.Combat.SetObjectEnergyAndDrawMissedLaser.MissedBeam ; переход, если энергия цели равна FF и обычный лазер её не уменьшает

                SUB C
                LD (IX+FSpaceObject.Energy), A
                JR Z, KillTarget                                                ; переход, если урон точно исчерпал энергию цели

                JR NC, @Game.Combat.SetObjectEnergyAndDrawMissedLaser.MissedBeam ; переход, если после вычитания урона энергия остаётся положительной

                ; установка запроса уничтожения и создание содержимого цели
KillTarget:     XOR A
                DEC A
                SET OBJ_DESTROY_BIT, (IX+FSpaceObject.Flags)
                LD (IX+FSpaceObject.Energy), A
                CALL Game.Universe.SpawnDestructionContentsAndEffects.Entry
                JR @Game.Combat.SetObjectEnergyAndDrawMissedLaser.MissedBeam

                ; проверка исходного конца фрагмента
                ASSERT $ == #B70F
                endmodule
                endmodule
