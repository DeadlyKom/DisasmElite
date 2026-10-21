                module Missions
                module DispatchRatingAndMissionEnd
; -----------------------------------------
; совместимый вход прибавления к 24-битовому рейтингу, Game.Missions.DispatchRatingAndMissionEnd.Entry
; исходный диапазон #D0EA..#D0F2
; In:
;   DE, приращение младших 16 бит рейтинга
; Out:
;   рейтинг State.Rating увеличен, переполнение младшего слова обрабатывает военные состояния
;   DE, BC, IX, IY сохранены
; Corrupt:
;   HL, AF
; Note:
;   только перенос из младшего слова запускает Game.Extensions.UpdateInvasionOnRatingOverflow.Entry и событие FlightEvents + 6 * FFlightEvent + FFlightEvent.ColumnFlags
;   соседний EndMission является независимым входом завершения третьей миссии
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D0EA
Entry:          JP Game.Missions.RatingBountyDamageAndNewCommander.Entry

; -----------------------------------------
; вектор награды за третью миссию, Game.Missions.DispatchRatingAndMissionEnd.EndMission
; In:
;   состояние командира задано, прерывания включены
; Out:
;   старший байт рейтинга увеличен на 1, Mission3=0, MissionFlags.3=1
;   после сообщения и клавиши окно очищено
; Corrupt:
;   HL, DE, BC, AF, IX
; -----------------------------------------
                ; миссия 3, вектор награды за третью миссию
                ; описание в Docs/Manual.md, раздел mission-3
EndMission:     JP Game.Missions.CompleteThirdMission.Entry

                ; сохранённые три нулевых байта между векторами
                DB #00, #00, #00                                                ; #D0F0..#D0F2
                ; проверка исходного конца фрагмента
                ASSERT $ == #D0F3
                endmodule
                endmodule
