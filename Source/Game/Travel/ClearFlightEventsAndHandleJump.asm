                module Travel
                module ClearFlightEventsAndHandleJump
; -----------------------------------------
; Очистка десяти событий и обработка клавиш гиперперехода
; исходный диапазон #DB91..#DC28
; In:
;   Нет параметров для Game.Travel.ClearFlightEventsAndHandleJump.Entry, биты 4/5 InputState.ViewJumpKeys для Game.Travel.ClearFlightEventsAndHandleJump.CheckJumpKeys
; Out:
;   Очередь очищена либо установлен отсчёт JumpCountdown=21
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Game.Travel.ClearFlightEventsAndHandleJump.Entry снимает бит 7 десяти пар и обнуляет FlightMessage.Token, Game.Travel.ClearFlightEventsAndHandleJump.CheckJumpKeys поглощает биты клавиш, запрещает
;   повторный запуск отсчёта, проверяет гиперпривод State.GalacticDrive или расстояние и запас топлива, JumpMode=2
;   означает галактический переход, JumpMode=1 обычный
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #DB91
                ; очистка десяти событий перед разбором запроса обычного или галактического перехода
Entry:          LD B, #0A
                LD HL, FlightEvents
ClearEvent:     RES EVENT_WAIT_BIT, (HL)
                INC HL
                INC HL
                DJNZ ClearEvent

                XOR A
                LD (FlightMessage.Token), A
                RET

                ; остаток отсчёта гиперперехода, ноль означает отсутствие отсчёта
JumpCountdown   DB #00                                                          ; остаток отсчёта гиперперехода, ноль означает отсутствие отсчёта
                ; клавиши перехода читаются из маски InputState.ViewJumpKeys и сразу погашаются после обработки
CheckJumpKeys:  LD HL, InputState.ViewJumpKeys
                LD A, (HL)
                AND VIEW_JUMP_MASK
                RET Z                                                           ; выход, если ни одна из двух клавиш гиперперехода не нажата

                LD B, A
                LD A, (HL)
                AND #FF - VIEW_JUMP_MASK
                LD (HL), A
                LD A, (JumpCountdown)
                AND A
                RET NZ                                                          ; выход, если отсчёт гиперперехода уже запущен

                LD A, (FlightState.FlightStatus)
                AND A
                JR Z, ShowCountdown                                             ; переход, если поле FlightState.FlightStatus нулевое, отменить или отклонить запрос перехода

                BIT VIEW_GALAX_BIT, B
                JR Z, CheckDistance                                             ; переход, если бит 5 клавиш не установлен, проверять обычный гиперпереход

                BIT VIEW_HYPER_BIT, B
                RET Z                                                           ; выход, если бит 4 клавиш не установлен, галактический переход не запрошен

                LD A, (State.GalacticDrive)
                AND A
                RET Z                                                           ; выход, если галактический гиперпривод отсутствует

                LD A, #02
                LD (JumpMode), A
                LD BC, #7406
                JR StartCountdown

                ; сверка ненулевого расстояния с остатком топлива перед запуском отсчёта
CheckDistance:  CALL Game.Galaxy.SelectNearestSystemWithCursor.Entry
                LD HL, (GalaxyState.Distance)
                LD A, H
                AND A
                JR NZ, JumpTooFar                                               ; переход, если расстояние не помещается в младший байт, переход слишком далёкий

                LD A, L
                AND A
                RET Z                                                           ; выход, если расстояние нулевое, текущая система уже выбрана

                LD B, A
                LD A, (State.Fuel)
                SUB B
                JR C, JumpTooFar                                                ; переход, если топлива меньше требуемого расстояния, отклонить переход

                LD A, #01
                LD (JumpMode), A
                LD BC, #C005
StartCountdown: LD A, #15
                LD (JumpCountdown), A
                LD (FlightMessage.Frames), A
                CALL Game.Travel.SetMessageCoordinatesAndRender.Entry
                CALL Game.Trade.OptionalBeep.Entry
                LD A, (FlightState.View)
                CP #04
                RET NC                                                          ; выход, если показано меню с номером от 4, не рисовать полётный отсчёт

                XOR A
                LD (FlightState.View), A
                RET

JumpTooFar:     LD BC, #C106
                JP @Game.Travel.SelectQueuedFlightMessage.BeepMessage

ShowCountdown:  CALL Game.Text.ClearViewAndFrame.Entry
                LD HL, #070B
                LD (TextColumn), HL
                LD A, #01
                LD (LetterCase), A
                LD A, #CD
                CALL Game.Text.PrintDescriptionToken.Entry
                CALL Game.Trade.OptionalBeep.Entry
                CALL Game.Trade.Wait36Interrupts.Entry
                CALL Game.Trade.ClearPressedKeyBits.Entry
                JP Game.Menus.OpenCommanderStatus.Entry

                ; проверка исходного конца фрагмента
                ASSERT $ == #DC29
                endmodule
                endmodule
