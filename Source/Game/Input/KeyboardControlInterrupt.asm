                module Input
                module KeyboardControlInterrupt
; -----------------------------------------
; обработчик IM2 с отдельным стеком
; исходный диапазон #FF25..#FF4B
; смысловое имя KeyboardControlInterrupt
; In: аппаратное прерывание, адрес возврата лежит на прерванном стеке
; Out: клавиатура, управление и счётчик FlightState.SoundRequests обработаны, основной SP восстановлен
; Corrupt: основные HL, DE, BC, AF, IX, IY сохраняются явно
; SP записывается в InputStack, обработчик использует стек вниз от Memory.Screen + #0020
; Вызываются только Game.Input.ScanKeyboardMatrix.Entry, Game.Input.IntegrateFlightControls.Entry и Game.Flight.DispatchSoundEffect.Entry, альтернативные регистры отдельно не сохраняются
; EI непосредственно перед RET разрешает следующее прерывание после восстановления потока
; В оригинале применяется RET, заменять его на RETI нельзя
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #FF25
                ; сохранение прерванного SP и переключение на выделенный стек
Entry:          DI
                LD (InputStack), SP
                LD SP, Memory.Screen + #0020                                    ; временный стек в начале экранной памяти, исходный SP сохранён
                ; сохранение всех основных регистров обработчика
                PUSH HL
                PUSH DE
                PUSH BC
                PUSH AF
                PUSH IX
                PUSH IY
                ; опрос клавиатуры, интегрирование управления и обновление такта игры
KeyboardCall    EQU $ + 1                                                       ; операнд CALL опроса клавиатуры, демо подставляет обработчик кадра
                CALL Game.Input.ScanKeyboardMatrix.Entry
                CALL Game.Input.IntegrateFlightControls.Entry
                CALL Game.Flight.DispatchSoundEffect.Entry
                ; восстановление основных регистров и исходного стека
                POP IY
                POP IX
                POP AF
                POP BC
                POP DE
                POP HL
                LD SP, (InputStack)
                EI
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #FF4C
                endmodule
                endmodule
