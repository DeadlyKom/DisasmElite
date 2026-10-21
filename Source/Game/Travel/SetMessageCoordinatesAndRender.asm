                module Travel
                module SetMessageCoordinatesAndRender
; -----------------------------------------
; Установка сообщения и обслуживание его времени жизни
; исходный диапазон #DAE6..#DB2D
; In:
;   HL = FlightMessage.Frames для Game.Travel.SetMessageCoordinatesAndRender.TickMessage
;   BC, C = X, B = токен для Game.Travel.SetMessageCoordinatesAndRender.Entry
;   A = прежнее время для Game.Travel.SetMessageCoordinatesAndRender.TickMessage
; Out:
;   FlightMessage.Column/FlightMessage.Token записаны либо активное сообщение перерисовано
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Game.Travel.SetMessageCoordinatesAndRender.TickMessage уменьшает срок и скрывает вывод при прежнем времени<4 или экране>=4, токен FD добавляет
;   название повреждения FlightMessage.DamagedItem, токен E2 печатает сумму FlightMessage.Reward, остальные идут в общий текстовый
;   вывод
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #DAE6
                ; сохранение параметров нового сообщения и начало отсчёта времени показа
Entry:          LD A, C
                LD (FlightMessage.Column), A
                LD A, B
                LD (FlightMessage.Token), A
                RET

TickMessage:    DEC (HL)
                CP #04
                RET C                                                           ; выход, если номер экрана меньше 4, на этом входе печать не требуется

                LD A, (FlightState.View)
                CP #04
                RET NC                                                          ; выход, если текущий экран имеет номер от 4, не рисовать сообщение поверх меню

                LD A, (FlightMessage.Column)
                LD L, A
                LD H, #0D
                LD (TextColumn), HL
                LD A, (FlightMessage.Token)
                CP #FD
                JR Z, SpecialPrefix                                             ; переход, если сообщение имеет код FD, выбрать специальный текст

                CP #E2
                JR Z, PrintFuel                                                 ; переход, если сообщение имеет код E2, вывести текст заправки

PrintText:      LD A, (FlightMessage.Token)
                JP Game.Trade.PrintTokenNewline.Entry

SpecialPrefix:  LD A, (FlightMessage.DamagedItem)
                CP #73
                JR Z, PrintPrefix                                               ; переход, если параметр специального сообщения равен 73, выбрать второй вариант

                LD HL, TextColumn
                INC (HL)
                INC (HL)
                INC (HL)
PrintPrefix:    CALL Game.Text.PrintMainToken.Entry
                JR PrintText

PrintFuel:      LD HL, (FlightMessage.Reward)
                SCF
                CALL Game.Economy.PrintWordDecimal.Entry
                JR PrintText

                ; проверка исходного конца фрагмента
                ASSERT $ == #DB2E
                endmodule
                endmodule
