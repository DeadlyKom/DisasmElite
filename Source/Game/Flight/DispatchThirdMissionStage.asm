                module Flight
                module DispatchThirdMissionStage
; -----------------------------------------
; Диспетчер экранов этапов третьей миссии
; исходный диапазон #7278..#728C
; In:
;   State.Mission3 номер этапа
; Out:
;   этапы 1/2 вызывают предложение Game.Missions.DispatchMissionEvents.OfferMission,5 завершение Game.Missions.DispatchRatingAndMissionEnd.EndMission,6 сообщение D4
; Corrupt:
;   HL, DE, BC, AF, IX по экранным обработчикам
; Note:
;   Последовательные DEC/SUB сохраняют различие этапов, прочие значения возвращаются без экрана
; -----------------------------------------
                ASSERT $ == #7278
                ; миссия 3, выбор обработчика предложения или завершения по этапу
                ; описание в Docs/Manual.md, раздел mission-3
                ; выбор экрана по состоянию третьей миссии,1 и 2 имеют общий вход
Entry:          LD A, (State.Mission3)
                DEC A
                JR Z, OfferStage                                                ; переход, если состояние третьей миссии равно 1, сохранить Z для обработчика предложения

                DEC A
OfferStage:     JP Z, Game.Missions.DispatchMissionEvents.OfferMission          ; переход, если состояние третьей миссии равно 1 или 2, обработать предложение

                ; проверка завершения 5 и сообщения состояния 6
                SUB #03
                JP Z, Game.Missions.DispatchRatingAndMissionEnd.EndMission      ; переход, если состояние третьей миссии равно 5, обработать завершение

                DEC A
                LD A, #D4
                JR Z, @Game.Flight.ReportBoardingAndReturnToTitle.RestartTitle  ; переход, если состояние третьей миссии равно 6, вывести сообщение D4

                RET

                ASSERT $ == #728D
                endmodule
                endmodule
