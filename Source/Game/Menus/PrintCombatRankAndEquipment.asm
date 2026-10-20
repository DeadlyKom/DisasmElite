                module Menus
                module PrintCombatRankAndEquipment
; -----------------------------------------
; Печать боевого звания и установленного оборудования
; исходный диапазон #EFE0..#F067
; In:
;   D060..D062 = рейтинг, поля оборудования пилота
; Out:
;   Показаны звание, устройства, четыре лазера и расширения
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   При D062=0 сравнивает D061 с порогами 08, 10, 20, 40, 80, FF, иначе D062 с 02, 0A, 19, FF,
;   таблица F09B..F0A0 задаёт шесть адресов устройств, дополнительные D086 и бит 6 D0B0
;   проверяются отдельно, завершает рамкой D646
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #EFE0
                ; старший байт рейтинга выбирает нужную половину таблицы порогов боевого звания
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
                ; шесть адресов устройств читаются из таблицы младших байтов в F09B
                LD BC, #06FE
                LD HL, DeviceFields - 1                                         ; позиция перед первым адресом устройства, цикл начинает с INC HL
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
                ; специальная подпись устройства зависит от сохранённого бита 7 маски D0B0&C
SpecialName:    POP AF
                PUSH AF
                JR NC, StandardName                                             ; переход, если сохранённый бит 7 маски D0B0&C сброшен, не печатать специальную подпись

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
NextLaser:      PUSH BC
                PUSH HL
                CALL Game.Menus.PrintDirectionalLaser.Entry
                POP HL
                POP BC
                INC HL
                DEC C
                JR NZ, NextLaser                                                ; переход, если остались поля установленного оборудования, продолжить перебор

                ; отдельно выводятся ALIEN COMPUTER и дополнительный предмет по биту 6 D0B0
                LD A, (State.AlienComputer)
                RRCA                                                            ; перенос получает ALIEN_OWN_BIT
                LD A, #F3
                CALL C, Game.Menus.PrintEquipmentLine.Entry                     ; вызов, если младший бит AlienComputer установлен, вывести ALIEN COMPUTER
                LD A, (State.MissionFlags)
                AND MS_CLOAK_MASK
                CALL Game.Menus.PrintInlineTokenIfNonzero.Entry
                DB #7D                                                          ; аргумент вызываемой процедуры из потока команд
                JP Game.Text.DrawViewFrame.Entry
                ; остаточное слово D646 после перехода к рисованию рамки
                DB #46, #D6                                                     ; #F066..#F067
                ; проверка исходного конца фрагмента
                ASSERT $ == #F068
                endmodule
                endmodule
