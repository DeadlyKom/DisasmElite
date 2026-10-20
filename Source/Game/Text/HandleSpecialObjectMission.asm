                module Text
                module HandleSpecialObjectMission
; -----------------------------------------
; Изменение миссионных флагов при событии объекта
; исходный диапазон #D6AA..#D6F8
; In:
;   HL, State.Mission3, этап задания с отметкой попадания
;   IX, летящий объект, младший байт адреса модели по FSpaceObject.Blueprint
; Out:
;   Обновлены legalstatus и состояние миссии, A/CY задают результат
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   Обычный тип меняет биты 2/3 и законность, тип 3C обнуляет IX+22, повторяет проверку области
;   D67A и уменьшает D08F, завершение очищает D0AF и начисляет FFFF рейтинга, NOP после CALL
;   является встроенным нулевым порогом
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D6AA
                ; миссия 7+3, ветвь Sidewinder обрабатывает попадание десанта и освобождение системы
                ; описание в Docs/Manual.md, раздел mission-7-3
                ; событие особого объекта отмечает выполненное военное задание и изменяет ход вторжения
Entry:          LD A, (IX+FSpaceObject.Blueprint)
                CP #3C
                JR Z, DestroyStation                                            ; переход, если тип объекта равен 3C, выполнить обработку специальной станции

                XOR A
                SET M3_HIT_BIT, (HL)
                BIT M3_STAGE_BIT, (HL)
                JR NZ, CheckPermit                                              ; переход, если бит 2 этапа Mission3 установлен, сохранить отметку попадания

                LD (HL), A
                DEC A
                LD (State.LegalStatus), A
CheckPermit:    INC HL
                BIT MS_ACCEPT_BIT, (HL)
                JR NZ, ReturnCarry                                              ; переход, если предложение третьей миссии принято, сохранить перенос

                SCF
ReturnCarry:    SBC A, A
                RET

DestroyStation: XOR A
                LD (IX+FSpaceObject.Energy), A
                CALL Game.Text.CheckMissionRegion.Entry
                NOP
                LD HL, State.Mission3
                INC L
                RET NC                                                          ; выход, если проверка области не дала переноса, событие вне оккупированной части

                SET MS_MARK3_BIT, (HL)
                ; уменьшение области вторжения до выхода текущей системы из занятой области
ShrinkFront:    LD HL, State.Invasion
                RES INV_ATTACK_BIT, (HL)
                DEC (HL)
                CALL Game.Text.CheckMissionRegion.Entry
                NOP
                JR C, ShrinkFront                                               ; переход, если система остаётся внутри фронта после уменьшения состояния, уменьшать дальше

                LD HL, Memory.Station + FSpaceObject.Hostility
                XOR A
                LD (HL), A
                LD (ObjectEffects.Flags), A
                LD HL, State.Mission3
                LD (HL), A
                LD L, #8F
                RES INV_ATTACK_BIT, (HL)
                LD DE, #FFFF
                CALL Game.Missions.RatingBountyDamageAndNewCommander.Entry
                XOR A
                INC A
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #D6F9
                endmodule
                endmodule
