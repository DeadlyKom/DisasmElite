                module Missions
                module CompleteThirdMission
; -----------------------------------------
; выдача награды за третью миссию, Game.Missions.CompleteThirdMission.Entry
; исходный диапазон #D14D..#D161
; In:
;   регистровых параметров нет, состояние командира задано
;   прерывания включены, обработчик клавиатуры обновляет InputState.LastKey
; Out:
;   старший байт State.Rating увеличен на 1 по модулю 256
;   State.Mission3=0, бит 3 State.MissionFlags установлен
;   сообщение #0A выведено, после клавиши окно очищено
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   это прямое INC старшего байта, обработчик переноса рейтинга Game.Extensions.UpdateInvasionOnRatingOverflow.Entry не вызывается
;   остальные биты MissionFlags, включая бит 7, этой процедурой не очищаются
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D14D
                ; миссия 3, завершение задания и фиксация награды
                ; описание в Docs/Manual.md, раздел mission-3
                ; зачисление награды третьей миссии и вывод завершающего сообщения
Entry:          LD HL, State.RankState
                INC (HL)
                XOR A
                LD (State.Mission3), A
                LD HL, State.MissionFlags
                SET MS_MARK4_BIT, (HL)
                LD DE, #0A0F
                LD HL, #0300
                JR Game.Missions.OfferThirdMission.ShowAndWait

                ; проверка исходного конца фрагмента
                ASSERT $ == #D162
                endmodule
                endmodule
