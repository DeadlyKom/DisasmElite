                module Missions
                module ShowBoardingMessage
; -----------------------------------------
; сообщение о захвате корабля с общим хвостом ожидания, #D0F6
; исходный диапазон #D0F6..#D122
; In:
;   AF, A содержит номер сообщения второй таблицы
;   прерывания включены, обработчик клавиатуры обновляет #FC0D
; Out:
;   сообщения #0B, входное A, #5D и #5A выведены последовательно
;   после новой клавиши окно очищено, биты нажатий #FC08..#FC0B сброшены
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   входное A сохраняется на время оформления окна
;   FinishMessage используется также подтверждением и завершением третьей миссии
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D0F6
                ; сохранение номера сообщения, очистка окна и подготовка восьмистрочного сообщения
Entry:          PUSH AF
                LD DE, #0B17
                LD HL, #0703
                CALL Game.Missions.SpecialMessageAndScoopReward.Entry
                POP AF
                CALL Game.Text.PrintDescriptionToken.Entry
                LD A, #5D
                CALL Game.Text.PrintDescriptionToken.Entry
                LD HL, #0B04
                LD (TextColumn), HL
                LD A, #5A
                CALL Game.Text.PrintDescriptionToken.Entry
; -----------------------------------------
; сигнал, ожидание новой клавиши и очистка сообщения, #D114
; In:
;   прерывания включены, #FC0D обновляется обработчиком клавиатуры
; Out:
;   сигнал выдан при разрешённом звуке, новая клавиша принята
;   окно очищено, после 36 HALT сброшены #FC08..#FC0B
;   HL, #FC0C
;   BC, B=0
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   WaitForKeyCode предварительно ждёт 20 HALT и очищает прежние нажатия
;   возвращается вызывающему общую процедуру сообщения, не основному игровому циклу
; -----------------------------------------
FinishMessage:  CALL Game.Trade.OptionalBeep.Entry
                CALL Game.Trade.WaitForKeyCode.Entry
                CALL Game.Text.ClearViewAndFrame.Entry
                CALL Game.Trade.Wait36Interrupts.Entry
                JP Game.Trade.ClearPressedKeyBits.Entry
                ; проверка исходного конца фрагмента
                ASSERT $ == #D123
                endmodule
                endmodule
