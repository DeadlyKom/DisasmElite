                module Flight
                module HandlePauseMenu
; -----------------------------------------
; Меню паузы с изменением настроек и возвратом в игру
; исходный диапазон #72A3..#72D3
; In:
;   InputState.ViewJumpKeys bit7 запрос паузы,InputState.LastKey код символа,InputState.Config настройки
; Out:
;   без запроса C=0, SPACE возобновляет с C=0, Q возвращает C=1 для перезапуска
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Сначала ждёт отпускания клавиши, затем ROM INDEXER ищет символ в таблице битовых настроек PauseKeyMap и
;   второй таблице IndexPauseCommandAndHandlers, которая находится сразу после PauseKeyMap
;   Первая таблица переключает маску XOR, вторая заменяет адрес возврата на обработчик страницы 73
;   через EX(SP),HL
; -----------------------------------------
                ASSERT $ == #72A3
                ; проверка запроса паузы перед остановкой основного цикла
Entry:          LD A, (InputState.ViewJumpKeys)
                AND 1 << VIEW_PAUSE_BIT
                RET Z                                                           ; выход, если запрос паузы отсутствует

                LD HL, InputState.Config
                ; ожидание отпускания клавиши, FF означает отсутствие символа
WaitRelease:    HALT
                LD A, (InputState.LastKey)
                INC A
                JR NZ, WaitRelease                                              ; переход, если предыдущая клавиша ещё удерживается, ждать её отпускания

                ; поиск новой команды сначала среди переключателей настроек
ReadPauseKey:   HALT
                LD HL, InputState.LastKey
                LD A, (HL)
                INC HL
                PUSH HL
                LD HL, PauseKeyMap
                CALL Game.Flight.IndexPauseCommandAndHandlers.Entry
                JR C, ToggleOption                                              ; переход, если найдена клавиша настройки, инвертировать её маску

                CALL Game.Flight.IndexNextPauseTable.Entry
                JR C, RunPauseAction                                            ; переход, если найдена команда паузы, передать управление её обработчику

                POP HL
                JR ReadPauseKey

                ; инверсия маски выбранной настройки в InputState.Config
ToggleOption:   LD A, (HL)
                POP HL
                XOR (HL)
                LD (HL), A
                JR @Game.Flight.IndexPauseCommandAndHandlers.StoreOption

                ; подмена адреса возврата обработчиком в странице 73
RunPauseAction: LD L, (HL)
                EX (SP), HL
                LD A, (HL)
                RET

                ASSERT $ == #72D4
                endmodule
                endmodule
