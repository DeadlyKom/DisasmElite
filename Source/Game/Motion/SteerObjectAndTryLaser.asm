                module Motion
                module SteerObjectAndTryLaser
; -----------------------------------------
; расчёт команд наведения, ускорения и возможности лазерного выстрела
; исходный диапазон #A587..#A69C
; In:
;   IX, управляемый объект
;   IY, описание модели
;   память A2B8/A2BA/A2BC, ненормализованный вектор к выбранному направлению
; Out:
;   IX, исходный объект
;   IY, исходная модель
;   команды IX+1C/+1D/+1E и накопленный урон игроку обновлены
; Corrupt:
;   HL, DE, BC, AF
; Note:
; Нормализует направление, сохраняет длину A2BE и вычисляет три проекции на базис корабля.
; LR ограничен 15, DU рассчитывается при небольшом отклонении LR. Знак команды помещается в бит 6.
; IX+25.7 задаёт принудительное ускорение 2 и ранний выход.
; Обычный выбор ускорения зависит от расстояния и того, направлен ли корабль к цели. Для ракет пороги меньше.
; Лазер требует враждебности, правильного курса, случайного разрешения модели и допустимой дальности.
; FA84 проверяет окончательное наведение и устанавливает IX+20.3 для изображения луча.
; Попадание добавляет 7 к переднему либо заднему накопителю урона и ставит звуковой флаг #7128.6.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #A587
                ; нормализация вектора наведения с сохранением его длины
Entry:          PUSH IY
                LD IY, SteeringVector.X
                PUSH IX
                LD IX, SteeringVector.X
                CALL Game.Motion.NormalizeVector16.Entry
                POP IX
                LD (SteeringVector.Length), DE
                ; расчёт проекций направления на три оси корабля
                PUSH IX
                LD DE, #0009
                ADD IX, DE
                CALL Game.Motion.DotProductAxisHighBytes.Entry
                LD DE, #0006
                ADD IX, DE
                LD H, A
                PUSH HL
                CALL Game.Motion.DotProductAxisHighBytes.Entry
                POP HL
                LD L, A
                PUSH HL
                LD DE, #0006
                ADD IX, DE
                CALL Game.Motion.DotProductAxisHighBytes.Entry
                POP HL
                POP IX
                POP IY
                ; расчёт команды LR из бокового отклонения
                LD D, A
                AND #7F
                JR Z, CalculatePitch                                            ; переход, если проекция на третью ось нулевая и сразу рассчитывается DU

                LD C, A
                SRL C
                SRL C
                SRL C
                ADC A, C
                SRL A
                SRL A
                CP #0F
                JR C, PackRoll                                                  ; переход, если расчётная величина LR меньше предела 15

                LD A, #0F
PackRoll:       LD B, A
                LD A, D
                XOR L
                AND #80
                RRA
                OR B
                LD (IX + FSpaceObject.Roll), A
                AND #3F
                CP #04
                JR NC, CheckForced                                              ; переход, если команда LR не меньше 4 и DU в этом такте не пересчитывается

                ; расчёт команды DU при малом отклонении LR
CalculatePitch: LD A, H
                BIT 7, A
                JR Z, LimitPitch                                                ; переход, если первая проекция имеет положительный знак и выбирается предельный DU

                AND #7F
                ADD A, #50
                SRL A
                CPL
                ADD A, #68
                SRL A
                CP #40
                JR C, PackPitch                                                 ; переход, если расчёт DU меньше предела #40

LimitPitch:     LD A, #3F
PackPitch:      SLA L
                RRA
                SRL A
                LD (IX + FSpaceObject.Pitch), A
                ; проверка принудительного ускорения
CheckForced:    XOR A
                BIT TARGET_ACCL_BIT, (IX + FSpaceObject.Target)
                JR Z, StoreForced                                               ; переход, если принудительное ускорение IX+25.7 выключено

                LD A, #02
StoreForced:    LD (IX + FSpaceObject.Acceleration), A
                RET NZ                                                          ; выход, если принудительное ускорение установлено и остальные решения не нужны

                ; расчёт ускорения по дальности и направлению носа
                LD DE, (SteeringVector.Length)
                LD A, D
                SLA H
                JR NC, BrakeAway                                                ; переход, если направление требует торможения вместо сближения

                LD B, #0A
                BIT OBJ_MISSILE_BIT, (IX + FSpaceObject.Flags2)
                JR Z, CheckRange                                                ; переход, если объект не ракета и используется обычный порог расстояния

                LD B, #02
CheckRange:     CP B
                JR C, CheckLaser                                                ; переход, если дальность меньше порога начала разгона

                LD B, #01
                CP #10
                JR NC, StoreSpeedup                                             ; переход, если дальность не меньше #10 и достаточно ускорения 1

                INC B
StoreSpeedup:   LD (IX + FSpaceObject.Acceleration), B
                ; проверка враждебности, направления и вероятности выстрела
CheckLaser:     BIT OBJ_HOSTILE_BIT, (IX + FSpaceObject.Hostility)
                RET Z                                                           ; выход, если объект не враждебен и стрелять не должен

                LD A, (IX + FSpaceObject.Z.SignHigh)
                XOR (IX + FSpaceObject.AxisX.Z + FSignWord.SignHigh)
                AND #80
                RET Z                                                           ; выход, если глубина и направление оси не позволяют направить луч к игроку

                LD B, (IY + FModel.LaserChance)
                LD A, (State.RankState)
                AND A
                JR NZ, TryLaser                                                 ; переход, если боевой показатель D062 ненулевой и вероятность модели не уменьшается

                SRL B
TryLaser:       CALL Game.Combat.NextRandomByte.Entry
                CP B
                RET NC                                                          ; выход, если случайная проверка не разрешила выстрел

                ; проверка типа объекта, дальности и точности наведения
                LD A, (IX + FSpaceObject.Flags2)
                AND OBJ_CLASS_MASK
                RET NZ                                                          ; выход, если младшая тетрада IX+26 обозначает специальный объект без обычного лазера

                LD A, D
                CP #0C
                RET NC                                                          ; выход, если дальность не меньше #0C и лазер не достигает игрока

                SLA H
                RET NC                                                          ; выход, если первая проверка угла наведения не пройдена

                CALL Game.Extensions.ScheduleLinkedObjectLaser.Entry
                RET NC                                                          ; выход, если расширенная проверка FA84 не разрешила попадание

                LD A, D
                CP #04
                JR C, HitPlayer                                                 ; переход, если дальность меньше 4 и дополнительная проверка угла не нужна

                SLA H
                RET NC                                                          ; выход, если дальняя цель не проходит дополнительную проверку угла

                ; создание лазерного звука и накопление урона защите игрока
HitPlayer:      LD HL, FlightState.SoundRequests
                SET SND_HIT_BIT, (HL)
                BIT 7, (IX + FSpaceObject.Z.SignHigh)
                JR Z, DamageFront                                               ; переход, если корабль находится впереди игрока и повреждает переднюю защиту

                LD A, (CombatState.RearDamage)
                ADD A, #07
                LD (CombatState.RearDamage), A
                RET

DamageFront:    LD A, (CombatState.FrontDamage)
                ADD A, #07
                LD (CombatState.FrontDamage), A
                RET

                ; расчёт торможения для курса от цели
BrakeAway:      LD B, #0B
                BIT OBJ_MISSILE_BIT, (IX + FSpaceObject.Flags2)
                JR Z, CheckBrake                                                ; переход, если объект не ракета и действует обычный порог торможения

                LD B, #03
CheckBrake:     CP B
                RET C                                                           ; выход, если дальность ещё меньше порога торможения

                LD B, #FF
                CP #12
                JR C, StoreBrake                                                ; переход, если дальность меньше #12 и достаточно ускорения -1

                DEC B
StoreBrake:     LD (IX + FSpaceObject.Acceleration), B
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #A69D
                endmodule
                endmodule
