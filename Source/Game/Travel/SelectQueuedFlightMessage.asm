                module Travel
                module SelectQueuedFlightMessage
; -----------------------------------------
; Выбор следующего события из очереди сообщений
; исходный диапазон #DAB4..#DAE5
; In:
;   FlightMessage.Frames = оставшееся время, FlightEvents = десять пар событий
; Out:
;   FlightMessage.Column = X сообщения, FlightMessage.Token = токен, FlightMessage.Frames=14 при выборе
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Сначала обновляет отсчёт прыжка, активное сообщение передаётся Game.Travel.SetMessageCoordinatesAndRender.TickMessage, при пустой строке
;   чередует обычные и вторичные сообщения по биту 0 FlightMessage.QueuePhase, ищет первый установленный бит 7 в
;   паре и снимает его
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #DAB4
                ; обновление таймера сообщения, затем выбор нового события из очереди
Entry:          CALL Game.Travel.TickJumpCountdown.Entry
                CALL Game.Flight.DispatchDangerIndicator.Entry
                LD HL, FlightMessage.Frames
                LD A, (HL)
                AND A
                JR NZ, @Game.Travel.SetMessageCoordinatesAndRender.TickMessage  ; переход, если таймер текущего сообщения ненулевой, продолжить его обслуживание

                LD HL, FlightMessage.QueuePhase
                INC (HL)
                BIT 0, (HL)
                JR NZ, Game.Travel.UpdateAmbientFlightMessage.Entry             ; переход, если счётчик очереди нечётный, проверить фоновые предупреждения

                ; поиск одного из десяти событий по установленному старшему биту
                LD B, #0A
                LD HL, FlightEvents
FindEvent:      BIT EVENT_WAIT_BIT, (HL)
                JR NZ, TakeEvent                                                ; переход, если у события установлен бит 7, выбрать его для вывода

                INC HL
                INC HL
                DJNZ FindEvent

                RET

TakeEvent:      RES EVENT_WAIT_BIT, (HL)
                LD C, (HL)
                INC HL
                LD B, (HL)
BeepMessage:    PUSH BC
                CALL Game.Trade.OptionalBeep.Entry
                POP BC
SetLifetime:    LD A, #0E
                LD (FlightMessage.Frames), A                                    ; далее Game.Travel.SetMessageCoordinatesAndRender.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #DAE6
                endmodule
                endmodule
