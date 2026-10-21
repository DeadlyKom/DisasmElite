                module Interface
                module DispatchJumpKey
; -----------------------------------------
; Вектор обработки запроса гиперперехода
; исходный диапазон #D042..#D047
; In:
;   Биты 4 и 5 байта InputState.ViewJumpKeys задают запрос
; Out:
;   Переход в Game.Travel.ClearFlightEventsAndHandleJump.CheckJumpKeys
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   После JP лежат TextPosition X печати, TextRow Y печати и AimState состояние прицела
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D042
Entry:          JP @Game.Travel.ClearFlightEventsAndHandleJump.CheckJumpKeys

                ; колонка текстового курсора, штатно 0..31
TextColumn      DB #00                                                          ; столбец печати текста
                ; строка текстового курсора, штатно 0..23
TextRow         DB #01                                                          ; строка печати текста
                ; сохранённый байт состояния прицела
AimState        DB #00                                                          ; состояние прицела и выбранной цели
                ; проверка исходного конца фрагмента
                ASSERT $ == #D048
                endmodule
                endmodule
