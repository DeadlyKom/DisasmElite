                module Travel
                module UpdateFlightMessages
; -----------------------------------------
; Обновление сообщений поверх обзорного окна
; исходный диапазон #DA7A..#DAB3
; In:
;   FlightState.View = номер экрана
; Out:
;   Сообщения и отсчёт обновлены, временный режим рисования восстановлен
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   При экране>=4 временно заменяет XOR C в Game.Text.XorCharacterScanlines.XorOpcode на NOP, для видов 0..3 выставляет бит 7
;   операнда TextScreenHigh и печатает название направления FlightState.View+60, затем снимает этот бит
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #DA7A
                ; выбор экранного или буферного пути текста по номеру текущего вида
Entry:          XOR A
                LD (LetterCase), A
                LD A, (FlightState.View)
                CP #04
                JR C, RenderMessage                                             ; переход, если номер экрана меньше 4, выводить сообщения в полётном окне

                ; временная замена XOR C на NOP включает перезапись глифов в меню
                LD HL, Game.Text.XorCharacterScanlines.XorOpcode
                LD (HL), #00
                CALL Game.Travel.SelectQueuedFlightMessage.Entry
                LD HL, Game.Text.XorCharacterScanlines.XorOpcode
                LD (HL), #A9
                RET

                ; бит 7 старшего байта адреса экрана направляет печать в буфер Memory.Frame
RenderMessage:  LD HL, TextScreenHigh
                SET 7, (HL)
                LD HL, #010A
                LD (TextColumn), HL
                LD A, (FlightState.View)
                ADD A, #60
                CALL Game.Text.PrintMainToken.Entry
                LD A, #AF
                CALL Game.Trade.PrintTokenNewline.Entry
                CALL Game.Travel.SelectQueuedFlightMessage.Entry
                LD HL, TextScreenHigh
                RES 7, (HL)
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #DAB4
                endmodule
                endmodule
