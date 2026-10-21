                module Text
                module PrintDescriptionByte
; -----------------------------------------
; Выбор способа интерпретации байта описания
; исходный диапазон #D470..#D48D
; In:
;   AF, A = байт строки, TextDecodeMode = режим декодирования
; Out:
;   Символ или вложенное описание обработаны
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   При TextDecodeMode=0 используется Game.Text.PrintMainToken.Entry, иначе коды<20 управляющие, 20..5A символы, 5B..D6 токены
;   второй таблицы, D7..FF слоги TextSyllables, пять NOP сохраняют патч исходной версии
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D470
                ; текущий режим TextDecodeMode выбирает основную либо специальную интерпретацию байта
Entry:          LD B, A
                LD A, (TextDecodeMode)
                CP #00
                LD A, B
                JR Z, Game.Text.PrintMainToken.Entry                            ; переход, если режим второй таблицы выключен, использовать основной принтер

                CP #20
                JP C, Game.Text.DrawProjectedSunAndTextDispatch.DescCommand     ; переход, если код описания меньше 20, вызвать команду форматирования

                CP #5B
                JR C, Game.Text.ApplyTextCase.Entry                             ; переход, если код описания находится в диапазоне 20..5A, рисовать символ

                NOP
                NOP
                NOP
                NOP
                NOP
                CP #D7
                JR C, Game.Text.PrintDescriptionToken.Entry                     ; переход, если код описания меньше D7, раскрыть токен второй таблицы

                JP Game.Text.PrintTwoLetterSyllable.Entry

                ; проверка исходного конца фрагмента
                ASSERT $ == #D48E
                endmodule
                endmodule
