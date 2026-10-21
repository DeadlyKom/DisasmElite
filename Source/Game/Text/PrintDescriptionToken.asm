                module Text
                module PrintDescriptionToken
; -----------------------------------------
; Раскрытие токена второй таблицы сообщений
; исходный диапазон #D45F..#D46F
; In:
;   AF, A = номер от 1, MessageTable.Description = база таблицы
; Out:
;   Строка обработана через Game.Text.PrintDescriptionString.Entry
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Пропускает A-1 строк с нулём, поэтому вход A=0 не означает пустую строку, текст
;   интерпретируется согласно режиму TextDecodeMode
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D45F
                ; поиск токена во второй таблице, её базовый адрес читается из MessageTable.Description
Entry:          LD HL, (MessageTable.Description)
                LD D, A
SkipToken:      DEC D
                JR Z, Game.Text.PrintDescriptionString.Entry                    ; переход, если выбран первый токен второй таблицы, поиск следующей строки не нужен

                LD BC, #FFFF
                LD A, #00
                CPIR
                JP SkipToken

                ; проверка исходного конца фрагмента
                ASSERT $ == #D470
                endmodule
                endmodule
