                module Extensions
                module CreateMissileOrMissionCraft
; -----------------------------------------
; создание объекта с расходом ракеты либо специального груза
; исходный диапазон #5EC5..#5F10
; смысловое имя CreateMissileOrMissionCraft
; In: AF — тип для #B898, IX — свободный 39-байтовый слот
; Out: объект создан, A=0, Z=1, модель при необходимости заменена
; Corrupt: HL, DE, BC, AF, IY по контракту #B898, IX указывает на созданный слот
; Обычный путь уменьшает число ракет #D083 до всех последующих проверок
; При военном допуске снимается бит 5 #D0B0 и выбирается модель #633C без расхода ракеты
; Если #D086.0, груз #D07B и клавиша D активны, расход ракеты компенсируется
; Тогда единица #D07B переносится в #D07C и выбирается модель #636A
; Указатель модели записывается в IX+23/24, порт #FDFE и маска #04 проверяют именно D
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #5EC5
                ; создание объекта стандартным конструктором до выбора специальной модели
Entry:          CALL Game.Objects.InitializeObject.Entry
                LD HL, State.Missiles
                ; миссия 7+3, проверка допуска выпуска десантного Sidewinder
                ; описание в Docs/Manual.md, раздел mission-7-3
                ; проверка трёх условий военного варианта без расхода ракеты
                LD A, (State.Invasion)
                AND INV_ACTIVE_MASK
                JR Z, SpendMissile                                              ; переход, если активного военного состояния нет, расходовать ракету

                LD A, (State.MissionFlags)
                AND MS_CARGO_MASK
                JR Z, SpendMissile                                              ; переход, если бит 5 специального режима сброшен, расходовать ракету

                LD A, (State.RankState)
                CP RANK_CAPT_CODE
                JR C, SpendMissile                                              ; переход, если #D062 меньше #84, расходовать ракету

                ; пересчёт грузового ограничения и снятие использованного специального флага
                CALL Game.Screen.ResetCargoCapacity.Entry
                LD L, #B0
                RES MS_CARGO_BIT, (HL)
                LD HL, Blueprint.Sidewinder
                JR SetBlueprint

                ; миссия 5 ALIEN COMPUTER, проверка допуска запуска ALIEN ITEMS
                ; описание в Docs/Manual.md, раздел mission-5
                ; расход ракеты и проверка возможности заменить её специальным грузом
SpendMissile:   DEC (HL)
                LD A, (State.AlienComputer)
                AND ALIEN_OWN_MASK
                RET Z                                                           ; выход, если бит 0 #D086 сброшен, оставить обычную модель

                LD A, (State.Cargo + FGoods.AlienItems)
                AND A
                RET Z                                                           ; выход, если груз #D07B отсутствует, оставить обычную модель

                ; опрос клавиши D непосредственно через ряд #FDFE
DirectKeyRead   LD A, #FD                                                       ; начало прямого опроса D, установщик демо заменяет этот участок
                IN A, (#FE)
                CPL
                AND #04
                RET Z                                                           ; выход, если клавиша D не нажата, оставить обычную модель

                ; возврат ракеты и перенос единицы груза между соседними полями
                INC (HL)
                LD L, #7B
                DEC (HL)
                INC HL
                INC (HL)
                LD HL, Blueprint.Tharglet
                ; обновление указателя модели в уже созданном объекте
SetBlueprint:   LD (IX+FSpaceObject.Blueprint), L
                LD (IX+FSpaceObject.Blueprint+1), H
                XOR A
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #5F11
                endmodule
                endmodule
