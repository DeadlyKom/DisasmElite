                module Charts
                module BeginTextInput
; -----------------------------------------
; Подготовка строкового ввода с ограничением длины
; исходный диапазон #E3CC..#E3E6
; In:
;   HL = буфер, BC, B = предел, AF, A = номер приглашения второй таблицы
; Out:
;   InputPrompt = приглашение, InputBuffer = начало буфера, TextInput.Cursor = текущий указатель
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Предел B записывается в операнд CP по InputLimit, счётчик TextInput обнуляется, после очистки и команды
;   6 продолжает цикл Game.Charts.TextInputLoop.Entry
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E3CC
                ; настройка буфера, длины строки и печатной позиции для общего редактора
Entry:          LD (InputPrompt), A
                LD A, B
                LD (InputLimit), A
                LD (InputBuffer), HL
                LD HL, (InputBuffer)
                LD (TextInput.Cursor), HL
                XOR A
                LD (TextInput.Length), A
                CALL Game.Trade.ClearPromptRows.Entry
                CALL Game.Text.PrintInlineToken.Entry
                DB #06                                                          ; аргумент вызываемой процедуры из потока команд
                ; проверка исходного конца фрагмента
                ASSERT $ == #E3E7
                endmodule
                endmodule
