                module Charts
                module FindSystemNameDialog
; -----------------------------------------
; Диалог поиска планеты по введённому имени
; исходный диапазон #E398..#E3CB
; In:
;   Нет регистровых параметров
; Out:
;   Найдена система либо показано сообщение об отсутствии
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Вводит до восьми символов в GalaxyState.InputBuffer, пустой ввод только очищает приглашение, при успехе
;   выбирает систему через Game.Galaxy.FindSystemByExactName.Entry и показывает имя/расстояние, PromptToken и InputBuffer задают параметры диалога
;   ввода
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E398
                ; приглашение имени системы, ограниченный ввод и полный поиск по 256 планетам
Entry:          LD A, #0E
                LD B, #08
                LD HL, GalaxyState.InputBuffer
                CALL Game.Charts.BeginTextInput.Entry
                LD A, (TextInput.Length)
                AND A
                JP Z, Game.Trade.ClearPromptRows.Entry                          ; переход, если введённое имя пустое, очистить строку приглашения

                CALL Game.Galaxy.FindSystemByExactName.Entry
                JR NC, SearchFailed                                             ; переход, если поиск нашёл точное название системы, установить выбранную цель

                LD HL, GalaxyState.InputBuffer
                CALL Game.Trade.PrintZeroTerminatedString.Entry
                CALL Game.Text.PrintInlineToken.Entry
                DB #08                                                          ; аргумент вызываемой процедуры из потока команд
                CALL Game.Text.PrintInlineToken.Entry
                DB #E1                                                          ; аргумент вызываемой процедуры из потока команд
                CALL Game.Trade.OptionalBeep.Entry
                JP Game.Trade.ClearPressedKeyBits.Entry

SearchFailed:   CALL Game.Text.PrintInlineToken.Entry
                DB #08                                                          ; аргумент вызываемой процедуры из потока команд
                JP @Game.Charts.TextInputLoop.ShowSelection

                ; сохранённые нулевые байты между поиском и редактором строки
PromptToken     DB #00                                                          ; токен приглашения строкового редактора
InputBuffer     DW #0000                                                        ; адрес начала редактируемой строки
                ; проверка исходного конца фрагмента
                ASSERT $ == #E3CC
                endmodule
                endmodule
