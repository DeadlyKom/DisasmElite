                module Missions
                module OfferThirdMission
; -----------------------------------------
; предложение третьей миссии и обработка ответа, Game.Missions.OfferThirdMission.Entry
; исходный диапазон #D123..#D14C
; In:
;   регистровых параметров нет
;   прерывания включены, обработчик клавиатуры обновляет InputState.LastKey
; Out:
;   при ответе #59 состояние State.Mission3=3 и State.MissionFlags.7=1
;   при любом другом коде State.Mission3=0, остальные флаги сохраняются
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   первое окно содержит токен #58 и цвет #1F, согласие показывает #59 с цветом #17
;   после согласия общий хвост ждёт ещё одну клавишу и очищает окно
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D123
                ; миссия 3, предложение задания и подтверждение участия
                ; описание в Docs/Manual.md, раздел mission-3
                ; подготовка окна предложения третьей миссии и ожидание ответа Y
Entry:          LD DE, #581F                                                    ; D=#58 токен предложения миссии, E=#1F атрибут
                LD HL, #0405
                CALL Game.Missions.SpecialMessageAndScoopReward.Entry
                CALL Game.Trade.WaitForKeyCode.Entry
                CP #59
                JR Z, AcceptMission                                             ; переход, если ответ равен Y, принять третью миссию

                XOR A
                LD (State.Mission3), A
                RET

                ; принятие предложения, переход состояния миссии и общий экран подтверждения
AcceptMission:  LD HL, State.MissionFlags
                SET MS_ACCEPT_BIT, (HL)
                LD A, #03
                LD (State.Mission3), A
                LD DE, #5917                                                    ; D=#59 токен принятой миссии, E=#17 атрибут
MessageLayout:  LD HL, #0200
; -----------------------------------------
; показ заданного сообщения с последующим ожиданием, Game.Missions.OfferThirdMission.ShowAndWait
; In:
;   HL, H содержит строку, L содержит столбец печати
;   DE, D содержит токен второй таблицы, E содержит атрибут
;   прерывания включены, работает обработчик клавиатуры
; Out:
;   окно сообщения показано, после новой клавиши очищено
;   HL, InputState.ChartKeys
;   BC, B=0
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   общий вход для согласия на миссию, награды и высадки беженцев
; -----------------------------------------
ShowAndWait:    CALL Game.Missions.SpecialMessageAndScoopReward.Entry
                JR Game.Missions.ShowBoardingMessage.FinishMessage

                ; проверка исходного конца фрагмента
                ASSERT $ == #D14D
                endmodule
                endmodule
