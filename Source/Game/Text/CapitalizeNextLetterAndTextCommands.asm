                module Text
                module CapitalizeNextLetterAndTextCommands
; -----------------------------------------
; Однократная заглавная буква и хвост таблицы текстовых команд
; исходный диапазон #D87F..#D8CD
; In:
;   Нет параметров для D87F
; Out:
;   D0D3=1, A=1
; Corrupt:
;   AF
; Note:
;   D885 генерирует случайное имя из слогов описания, D8A9/D8AE задают режим 2/1 в D0D1,
;   D8B4..D8CB переходят к новой строке, сигналу, очистке, сдвигу Y, ожиданию и позиционированию
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D87F
                ; одноразовый признак требует следующую букву сделать заглавной
Entry:          LD A, #01
                LD (CapitalNext), A
                RET

                ; генерация случайного имени и остальные управляющие команды текста
RandomName:     CALL Entry
                CALL Game.Text.NextDescriptionRandom.Entry
                AND #03
NextSyllable:   PUSH AF
                CALL Game.Text.NextDescriptionRandom.Entry
                AND #3E
                LD HL, TextSyllables + 2
                LD D, #00
                LD E, A
                ADD HL, DE
                PUSH HL
                CALL Game.Text.SetDescriptionModeAndHelpers.PrintLetter
                POP HL
                INC HL
                CALL Game.Text.SetDescriptionModeAndHelpers.PrintLetter
                POP AF
                AND A
                RET Z                                                           ; выход, если счётчик оставшихся слогов случайного имени обнулился

                DEC A
                JR NextSyllable

                LD A, #02
                JR StoreCaseMode

                RET

                LD A, #01
StoreCaseMode:  LD (LetterCase), A
                RET

                JP Game.Trade.Newline.Entry

                JP Game.Trade.OptionalBeep.Entry

                JP Game.Text.ClearViewAndFrame.Entry

                JP Game.Trade.IncrementTextRow.Entry

                JP Game.Text.FillInnerAttributeRow.IgnoreToken

                JP Game.Trade.ClearPromptRows.Entry

                JP Game.Trade.Wait20Interrupts.Entry

                LD A, #0B
                JP Game.Trade.ResetTextColumn.SetColumn
                ; проверка исходного конца фрагмента
                ASSERT $ == #D8CE
                endmodule
                endmodule
