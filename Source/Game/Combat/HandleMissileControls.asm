                module Combat
                module HandleMissileControls
; -----------------------------------------
; захват цели, постановка ракеты на боевой взвод и пуск
; исходный диапазон #9BA7..#9C17
; In:
;   память D083, запас ракет
;   память D047, состояние 0/1/2
;   память D0E3, номер захваченной цели
;   память FC0B, события управления
; Out:
;   обновлены состояние ракеты, цель и очередь сообщений
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
; Состояния D047 означают выключено, поиск и захват. При поиске ненулевой 9C97 запоминается как цель.
; Захват сопровождается ROM-звуком #03B5. Биты 1/2/3 FC0B означают взвод, пуск и снятие взвода.
; Пуск передаёт диспетчеру действие 2 и номер цели в старшей тетраде.
; Неудача устанавливает сообщение D0BD.7, успех сбрасывает D047 и ставит звуковой запрос 7128.1.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #9BA7
                ; проверка запаса и возможности нового захвата
Entry:          LD A, (State.Missiles)
                AND A
                RET Z                                                           ; выход, если ракет нет

                LD A, (AimState)
                CP #01
                JR NZ, ReadCommands                                             ; переход, если ракета не находится в режиме поиска

                LD HL, MissileTarget
                LD A, (HL)
                AND A
                JR NZ, ReadCommands                                             ; переход, если номер цели уже установлен

                LD A, (CombatState.CrosshairTarget)
                AND A
                JR Z, ReadCommands                                              ; переход, если в прицеле нет доступной цели

                LD (HL), A
                LD HL, AimState
                LD (HL), #02
                LD HL, #0070
                LD DE, #0060
                CALL Rom.Beeper
                ; чтение трёх команд управления ракетой
ReadCommands:   LD HL, InputState.DeviceKeys
                LD A, (HL)
                LD HL, AimState
                SRL A
                SRL A
                JR C, ArmMissile                                                ; переход, если получена команда постановки на взвод

                SRL A
                JR C, FireMissile                                               ; переход, если получена команда пуска

                SRL A
                JR C, DisarmMissile                                             ; переход, если получена команда снятия взвода

                RET

                ; постановка на взвод и сброс прежней цели
ArmMissile:     LD A, (HL)
                CP #02
                RET Z                                                           ; выход, если цель уже захвачена и повторный взвод не нужен

                LD (HL), #01
                XOR A
                LD (MissileTarget), A
                RET

DisarmMissile:  LD (HL), #00
                RET

                ; формирование команды пуска с упакованным номером цели
FireMissile:    LD A, (HL)
                CP #02
                RET NZ                                                          ; выход, если цель ещё не захвачена и пуск невозможен

                LD A, (MissileTarget)
                ADD A, A
                ADD A, A
                ADD A, A
                ADD A, A
                OR #02
                PUSH HL
                CALL Game.Combat.DispatchObjectAction.Entry
                POP HL
                JR Z, FinishLaunch                                              ; переход, если диспетчер успешно создал ракету

                LD HL, FlightEvents
                SET EVENT_WAIT_BIT, (HL)
                RET

                ; завершение успешного пуска
FinishLaunch:   LD (HL), #00
                LD HL, FlightState.SoundRequests
                SET SND_MISSILE_BIT, (HL)
                NOP
                NOP
                NOP
                NOP
                ; проверка исходного конца фрагмента
                ASSERT $ == #9C18
                endmodule
                endmodule
