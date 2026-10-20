                module Objects
                module GenerateSpaceTraffic
; -----------------------------------------
; генерация случайных встреч с учётом опасности системы и миссий
; исходный диапазон #BBBA..#BCD3
; In:
;   глобальные данные пилота, правительства и миссий, свободные слоты
; Out:
;   созданные корабли либо возврат без создания
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
;   начальный порог C вычисляется из байтов пилота #D06E,#D071,#D075
;   предусмотрена ветвь миссии 2 с моделями 13/15, отдельное появление модели 6
;   ветви миссии 3=4 и=1 принудительно выбирают модели 15 и 10
;   остальные ветви учитывают правительство #D09D и случайность, запускают одиночные корабли или группу 2..4
;   при любой неудаче FindFreeObjectSlot генерация завершается без повторного поиска
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #BBBA
                ; миссия 2 CLOAKING DEVICE, в начале генератора проверяется допуск особой встречи
                ; описание в Docs/Manual.md, раздел mission-2
                ; расчёт порога случайной встречи из данных пилота
Entry:          LD A, (State.Cargo + FGoods.Slaves)
                LD C, A
                LD A, (State.Cargo + FGoods.Narcotics)
                ADD A, C
                ADD A, A
                LD C, A
                LD A, (State.Cargo + FGoods.Firearms)
                ADD A, C
                LD C, A
                LD A, (MissionPhase)
                AND A
                JR NZ, PickEncounter                                            ; переход, если состояние миссии 2 уже ненулевое

                CALL Game.Combat.NextRandomByte.Entry
                CP #1E
                JR NC, PickEncounter                                            ; переход, если случайный байт не меньше 30

                LD A, (State.MissionFlags)
                AND MS_CLOAK_MASK | MS_MARK2_MASK
                CP MS_MARK2_MASK
                JR NZ, PickEncounter                                            ; переход, если комбинация битов оборудования не равна 2

                DEC A
                LD (MissionPhase), A
                LD A, #0F
                ; сохранение дополнительного продолжения миссии на стеке
                LD HL, Game.Objects.GenerateSpaceTraffic.MissionGroup
                PUSH HL
                PUSH AF
                CALL Game.Objects.FindFreeObjectSlot.Entry
                RET NZ                                                          ; выход, если слот для особой встречи не найден

                LD A, #0D
                JR InitEncounter

; -----------------------------------------
; установка особого признака корабля перед созданием группы сопровождения
; In:
;   IX, существующий корабль
; Out:
;   IX+26.6 и IX+20.2 установлены
;   далее общий генератор группы #BCAB
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   сохранённая процедура, прямые входящие переходы не найдены
;   бит 6 по IX+26 используется признаком особого миссионного корабля
;   бит 2 по IX+20 входит в младший трёхбитный счётчик запусков
;   #BCAB выбирает 2..4 корабля и создаёт модели 16 или 17 до заполнения доступных слотов
; -----------------------------------------
MissionGroup:   ; установка особого признака корабля перед созданием группы сопровождения
                SET OBJ_MISSION_BIT, (IX+FSpaceObject.Flags2)
                SET OBJ_LAUNCH4_BIT, (IX+FSpaceObject.Flags)
                JP GroupCount

PickEncounter:  CALL Game.Combat.NextRandomByte.Entry
                SUB C
                JR C, EncounterClass                                            ; переход, если случайное значение меньше вычисленного порога опасности

                CP #5A
                RET NC                                                          ; выход, если после вычитания порога значение не меньше 90 и встреча не создаётся

                CP #50
                JR C, EncounterClass                                            ; переход, если значение меньше 80 и выбирается обычная ветвь встреч

                CALL Game.Objects.FindFreeObjectSlot.Entry
                RET NZ                                                          ; выход, если нет слота для модели 6

                LD A, #06
                CALL Game.Objects.InitializeObject.Entry
                SET 7, (IX+FSpaceObject.AxisX.Z+FSignWord.SignHigh)
                RES OBJ_ACTIVE_BIT, (IX+FSpaceObject.Flags)
                LD A, #C0
                LD (IX+FSpaceObject.Roll), A
                RET

                ; выбор встречи по миссии, правительству и случайному классу
EncounterClass: LD B, A
                AND #07
                LD E, A
                LD A, (State.Mission3)
                CP #04
                LD D, A
                LD C, #0F
                JR Z, MissionShip                                               ; переход, если активен этап 4 миссии 3

                LD A, D
                CP #01
                LD C, #0A
                JR Z, MissionShip                                               ; переход, если активен этап 1 миссии 3

                LD A, (State.Government)
                AND #07
                JR Z, ChooseGroup                                               ; переход, если тип правительства равен 0

                INC E
                CP E
                RET NC                                                          ; выход, если правительство не меньше увеличенного случайного порога

ChooseGroup:    LD C, A
                BIT 3, B
                JP Z, ChooseTraffic                                             ; переход, если случайный бит 3 сброшен

                CALL Game.Objects.FindFreeObjectSlot.Entry
                RET NZ                                                          ; выход, если свободного слота нет

                CALL Game.Combat.NextRandomByte.Entry
                AND #3F
                LD B, #0F
                JR Z, ModelSelected                                             ; переход, если случайное шестибитное значение равно 0

                DEC B
                SUB #0C
                JR C, ModelSelected                                             ; переход, если остаток случайного значения меньше 12

                DEC B
                SUB #12
                JR C, ModelSelected                                             ; переход, если остаток случайного значения меньше 18

                DEC B
                SUB #10
                JR C, ModelSelected                                             ; переход, если остаток случайного значения меньше 16

                DEC B
ModelSelected:  LD A, B
SaveModel:      PUSH AF
InitEncounter:  CALL Game.Objects.InitializeObject.Entry
                POP AF
                CP #0F
                JR Z, EnableEcm                                                 ; переход, если создана модель 15, которой ECM назначается без проверки

                CALL Game.Combat.NextRandomByte.Entry
                CP #33
                RET NC                                                          ; выход, если случайное значение не меньше 51 и ECM не назначается

EnableEcm:      SET TARGET_ECM_BIT, (IX+FSpaceObject.Target)
                RET

MissionShip:    CALL Game.Objects.FindFreeObjectSlot.Entry
                RET NZ                                                          ; выход, если слот для выбранной миссией модели не найден

                LD A, C
                JR SaveModel

ChooseTraffic:  CALL Game.Combat.NextRandomByte.Entry
                LD B, A
                AND #07
                CP E
                JR NC, GroupCount                                               ; переход, если случайный трёхбитный индекс не меньше порога E

                RLC B
                RLC B
                RLC B
                LD C, B
                CALL Game.Objects.FindFreeObjectSlot.Entry
                RET NZ                                                          ; выход, если слот для обычного корабля не найден

                LD A, C
                AND #07
                CP #02
                JR C, SpecialPair                                               ; переход, если младшие три бита класса меньше 2

                DEC A
                SRL A
                SRL A
                ADD A, #09
                JR SaveModel

SpecialPair:    LD A, C
                RLCA
                AND #01
                ADD A, #07
                JR SaveModel

                ; размер группы 2..4, два случайных бита дают распределение 2,3,3,4
GroupCount:     CALL Game.Combat.NextRandomByte.Entry
                AND #03
                RRA
                ADC A, #02
                LD C, A
SpawnMember:    CALL Game.Objects.FindFreeObjectSlot.Entry
                RET NZ                                                          ; выход, если для очередного корабля группы нет слота

                PUSH BC
                CALL Game.Combat.NextRandomByte.Entry
                AND #01
                ADD A, #10
                CALL Game.Objects.InitializeObject.Entry
                POP BC
                DEC C
                JR NZ, SpawnMember                                              ; переход, если в группе остались корабли для создания

                RET
Object          DW #6159                                                        ; сохранённый адрес исходного объекта из IX
Scale           DB #00                                                          ; сдвиг нормали из FModel.NormalScale
PositionX       DW #8017                                                        ; знако-модульная координата X для скалярного произведения
PositionY       DW #802F                                                        ; знако-модульная координата Y для скалярного произведения
PositionZ       DB #F0                                                          ; знако-модульная координата Z для скалярного произведения
                DB #00                                                          ; продолжение данных #BCD0..#BCD0
NormalX         DB #97                                                          ; преобразованная знаковая компонента нормали X
NormalY         DB #AF                                                          ; преобразованная знаковая компонента нормали Y
NormalZ         DB #90                                                          ; преобразованная знаковая компонента нормали Z
                ; проверка исходного конца фрагмента
                ASSERT $ == #BCD4
                endmodule
                endmodule
