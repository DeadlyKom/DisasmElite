                module Text
                module OfferRegionDependentMission
; -----------------------------------------
; Проверка условий выдачи специальных миссионных сообщений
; исходный диапазон #D6F9..#D754
; In:
;   Рейтинг State.RankState, State.Invasion, State.MissionFlags и координаты системы
; Out:
;   Возможен показ предложения или установка State.Mission3=4
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   Для State.Invasion=1 проверяет высокий рейтинг и бит 6, в остальных случаях сопоставляет регион Game.Menus.CheckMissionRegionBand.Entry и
;   младшие биты рейтинга с флагами наград, предложение AC подтверждается только Y и использует
;   общий экран Game.Missions.OfferThirdMission.MessageLayout
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D6F9
                ; миссия 7 INVASION, проверка места выдачи задания и готовности повышения
                ; описание в Docs/Manual.md, раздел mission-7-invasion
                ; после окончания войны выдаётся повышение, во время войны проверяется очередное задание
Entry:          CALL Game.Text.CheckMissionRegion.Entry
                NOP
                JR C, OccupiedSystem                                            ; переход, если система внутри оккупированной области, установить специальное состояние миссии

                LD A, (State.Invasion)
                DEC A
                JR NZ, WartimeTask                                              ; переход, если состояние вторжения не равно 1, проверить задания во время войны

                LD L, LOW State.RankState
                BIT RANK_RSV_BIT, (HL)
                RET NZ                                                          ; выход, если военный статус уже помечен битом отставки, сообщение повторять не нужно

                LD A, (HL)
                CP RANK_LT_CODE
                RET C                                                           ; выход, если военный код меньше 82, основания для повышения отсутствуют

                SET RANK_RSV_BIT, (HL)
                INC (HL)
                LD D, #B8
                JR ShowTask

                ; в полосе сопротивления военный этап выбирается младшими битами кода State.RankState
WartimeTask:    CALL Game.Menus.CheckMissionRegionBand.Entry
                RET NC                                                          ; выход, если система вне полосы сопротивления, выдавать военное задание нельзя

                LD HL, State.RankState
                LD A, (HL)
                RRCA
                RET NC                                                          ; выход, если младший бит кода военного допуска сброшен, задание не выдаётся

                AND RANK_NUM_MASK >> 1
                JR Z, OfferVolunteer                                            ; переход, если номер военного этапа нулевой, предложить поступление добровольцем

                LD B, A
                LD D, #B4
                LD A, (State.MissionFlags)
FindRewardBit:  RRCA
                INC D
                DJNZ FindRewardBit

                RET NC                                                          ; выход, если соответствующий текущему этапу бит выполненного задания отсутствует

                JR AdvanceRank

                ; первое поступление добровольцем требует свободного миссионного трюма и ответа Y
OfferVolunteer: LD A, (State.MissionFlags)
                BIT MS_CARGO_BIT, A
                RET NZ                                                          ; выход, если трюм уже занят беженцами или десантом, новое задание не предлагается

                PUSH HL
                LD DE, #AC1F                                                    ; D токен предложения #AC, E атрибут #1F
                LD HL, #0405
                CALL Game.Missions.SpecialMessageAndScoopReward.Entry
                CALL Game.Trade.WaitForKeyCode.Entry
                POP HL
                CP #59
                RET NZ                                                          ; выход, если ответ на предложение отличается от Y

                LD D, #AD
AdvanceRank:    INC (HL)
ShowTask:       LD E, #17
                JP Game.Missions.OfferThirdMission.MessageLayout

OccupiedSystem: LD A, #04
                LD (State.Mission3), A
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #D755
                endmodule
                endmodule
