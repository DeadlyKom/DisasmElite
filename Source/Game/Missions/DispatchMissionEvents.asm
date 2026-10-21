                module Missions
                module DispatchMissionEvents
; -----------------------------------------
; совместимый вход очистки очереди полётных сообщений, Game.Missions.DispatchMissionEvents.Entry
; исходный диапазон #D0DA..#D0E9
; In:
;   регистровых параметров нет, очередь содержит десять пар по FlightEvents
; Out:
;   HL, LetterCase
;   BC, B=0, C сохранён
;   AF, A=0, Z=1, C=0
;   бит 7 первого байта каждой пары сброшен, код текущего сообщения FlightMessage.Token обнулён
; Corrupt:
;   HL, BC, AF
; Note:
;   JP передаёт исходный адрес возврата в Game.Travel.ClearFlightEventsAndHandleJump.Entry, обработчик клавиш Game.Travel.ClearFlightEventsAndHandleJump.CheckJumpKeys этим входом не вызывается
;   следующие векторы имеют самостоятельные контракты, байт MissileTarget не исполняется
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D0DA
Entry:          JP Game.Travel.ClearFlightEventsAndHandleJump.Entry

; -----------------------------------------
; вектор предложения третьей миссии, Game.Missions.DispatchMissionEvents.OfferMission
; In:
;   прерывания включены, InputState.LastKey обновляется обработчиком клавиатуры
; Out:
;   при Y Mission3=3 и MissionFlags.7=1, иначе Mission3=0
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   передаёт управление OfferThirdMission.Entry без дополнительного адреса возврата
; -----------------------------------------
                ; миссия 3, вектор предложения третьей миссии передаёт ответ основному обработчику
                ; описание в Docs/Manual.md, раздел mission-3
OfferMission:   JP Game.Missions.OfferThirdMission.Entry

                ; вектор обнуления топлива с постановкой предупреждения
; -----------------------------------------
; вектор потери топлива с предупреждением, Game.Missions.DispatchMissionEvents.EmptyFuel
; In:
;   State.Fuel, текущий запас топлива
; Out:
;   нулевой запас сохраняется без нового события
;   ненулевой запас и указатель прибора обнулены, FlightEvents + 9 * FFlightEvent + FFlightEvent.ColumnFlags.7 установлен
; Corrupt:
;   HL, BC, AF
; Note:
;   передаёт управление EmptyFuelWithWarning, затем выполняется SetFuelAndGauge
; -----------------------------------------
EmptyFuel:      JP Game.Travel.EmptyFuelWithWarning.Entry

                ; индекс объекта для наведения ракеты
MissileTarget   DB #00                                                          ; код захваченной цели ракеты
; -----------------------------------------
; вектор обработки подобранного предмета, Game.Missions.DispatchMissionEvents.ScoopItem
; In:
;   AF, A содержит индекс товара 0..16 либо #FF для предмета второй миссии
;   IX, подобранный объект, Flags2.7 отличает контейнер ALIEN COMPUTER
;   обычный груз требует положительного State.FreeCargo
; Out:
;   обычный товар добавлен в трюм либо учтён специальный предмет, уведомление записано
;   DE, BC, IX, IY сохранены
; Corrupt:
;   HL, AF
; Note:
;   проверки ковша, положения объекта и свободного места выполнены вызывающим Game.Combat.HandleObjectCollision.Entry
; -----------------------------------------
                ; миссии 2, 4, 5, общий вектор подбора разделяет маскировку, компьютер и обычные минералы
                ; описание в Docs/Manual.md, раздел mission-2, mission-4, mission-5
ScoopItem:      JP Game.Missions.SpecialMessageAndScoopReward.ScoopItem

; -----------------------------------------
; вектор денежной награды, Game.Missions.DispatchMissionEvents.PayBounty
; In:
;   DE, сумма в десятых кредита, 0..9999
; Out:
;   ненулевая сумма прибавлена к деньгам, FlightMessage.Reward хранит сумму, FlightEvents + 4 * FFlightEvent + FFlightEvent.ColumnFlags.7 установлен
;   при DE=0 деньги и очередь не изменяются
; Corrupt:
;   HL, DE, AF
; Note:
;   рейтинг не изменяется, его отдельный вектор расположен по Game.Missions.DispatchRatingAndMissionEnd.Entry
; -----------------------------------------
PayBounty:      JP Game.Missions.RatingBountyDamageAndNewCommander.PayBounty

                ; проверка исходного конца фрагмента
                ASSERT $ == #D0EA
                endmodule
                endmodule
