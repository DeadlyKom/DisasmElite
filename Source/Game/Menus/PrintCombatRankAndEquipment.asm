                module Menus
                module PrintCombatRankAndEquipment
; -----------------------------------------
; Печать боевого звания и установленного оборудования
; исходный диапазон #EFE0..#F067
; In:
;   State.Rating и State.RankState содержат рейтинг, далее используются поля оборудования пилота
; Out:
;   Показаны звание, устройства, четыре лазера и расширения
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   При State.RankState=0 сравнивает State.Rating + 1 с порогами 08, 10, 20, 40, 80, FF, иначе State.RankState с 02, 0A, 19, FF,
;   DeviceFields задаёт шесть младших байтов адресов устройств, дополнительно проверяются State.AlienComputer и бит 6 State.MissionFlags
;   проверяются отдельно, завершает рамкой Game.Text.DrawViewFrame.Entry
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #EFE0
                ; старший байт рейтинга выбирает нужную половину таблицы порогов боевого звания
                ; общие поля миссий и обычного полёта, обычный боевой рейтинг использует тот же старший байт, что и военное состояние
                ; описание в Docs/Manual.md, раздел mission-shared-state
Entry:          LD HL, State.RankState
                LD A, (HL)
                AND A
                JR NZ, HighRank                                                 ; переход, если старший байт рейтинга ненулевой, использовать высшую ветку звания

                DEC HL
                LD DE, RankLowLimits
                LD B, #15
                JR FindRank

HighRank:       LD DE, RankHighLimits
                LD B, #1A
FindRank:       LD A, (DE)
                CP (HL)
                JR NC, PrintRank                                                ; переход, если очередной порог рейтинга не меньше значения пилота, выбрать соответствующее звание

                INC B
                INC DE
                JR FindRank

PrintRank:      LD A, B
                CALL Game.Text.PrintRankWithMissionSuffix.Entry
                LD A, #11
                CALL Game.Menus.PrintEquipmentLine.Entry
                ; шесть адресов устройств читаются из таблицы младших байтов в DeviceFields
                LD BC, #06FE
                LD HL, DeviceFields - 1                                         ; позиция перед первым адресом устройства, цикл начинает с INC HL
                ; миссия 3, MS_ACCEPT_BIT выбирает специальное имя первого устройства, поля State.ECM
                ; описание в Docs/Manual.md, раздел mission-3
NextEquipment:  INC C
                INC HL
                PUSH BC
                PUSH HL
                LD L, (HL)
                LD H, #D0
                LD A, (State.MissionFlags)
                AND C
                RLCA
                LD A, L
                PUSH AF
                LD A, (HL)
                AND A
                JR Z, RestoreItem                                               ; переход, если текущий предмет оборудования отсутствует, пропустить его название

                LD A, (State.ShipUpgrade)
                AND A
                JR Z, SpecialName                                               ; переход, если корабль не улучшен до Mk4, дополнительное описание состояния не нужно

                LD B, (HL)
                SET 7, B
                LD A, #30
                SUB B
                CALL Game.Trade.PrintMainTokenSpace.Entry
                ; специальная подпись устройства зависит от сохранённого бита 7 маски State.MissionFlags&C
SpecialName:    POP AF
                PUSH AF
                JR NC, StandardName                                             ; переход, если сохранённый бит 7 маски State.MissionFlags&C сброшен, не печатать специальную подпись

                LD A, #CF
                CALL Game.Text.PrintDescriptionToken.Entry
                CALL Game.Menus.NextEquipmentLine.Entry
                ; после особой подписи XOR A обеспечивает заём в SUB19 и подавляет обычное имя устройства
                XOR A
StandardName:   SUB #19
                CALL NC, Game.Menus.PrintEquipmentLine.Entry                    ; вызов, если код поля после вычитания 19 не дал заёма, напечатать штатное имя устройства
RestoreItem:    POP AF
                POP HL
                POP BC
                DJNZ NextEquipment

                ; четыре направления лазеров перечисляются независимо от шести устройств
                LD HL, State.FrontLaser
                ; миссии 2, 5, после лазеров отдельно выводятся ALIEN COMPUTER и CLOAKING DEVICE
                ; описание в Docs/Manual.md, раздел mission-2, mission-5
NextLaser:      PUSH BC
                PUSH HL
                CALL Game.Menus.PrintDirectionalLaser.Entry
                POP HL
                POP BC
                INC HL
                DEC C
                JR NZ, NextLaser                                                ; переход, если остались поля установленного оборудования, продолжить перебор

                ; отдельно выводятся ALIEN COMPUTER и дополнительный предмет по биту 6 State.MissionFlags
                LD A, (State.AlienComputer)
                RRCA                                                            ; перенос получает ALIEN_OWN_BIT
                LD A, #F3
                CALL C, Game.Menus.PrintEquipmentLine.Entry                     ; вызов, если младший бит AlienComputer установлен, вывести ALIEN COMPUTER
                LD A, (State.MissionFlags)
                AND MS_CLOAK_MASK
                CALL Game.Menus.PrintInlineTokenIfNonzero.Entry
                DB #7D                                                          ; аргумент вызываемой процедуры из потока команд
                JP Game.Text.DrawViewFrame.Entry

                ; остаточное слово Game.Text.DrawViewFrame.Entry после перехода к рисованию рамки
                DB #46, #D6                                                     ; #F066..#F067
                ; проверка исходного конца фрагмента
                ASSERT $ == #F068
                endmodule
                endmodule
