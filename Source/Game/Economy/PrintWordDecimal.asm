                module Economy
                module PrintWordDecimal
; -----------------------------------------
; Печать беззнакового HL в десятичной записи
; исходный диапазон #D2E5..#D31C
; In:
;   HL = число, AF, CY = разделить запись точкой перед последней цифрой, D0CE = ширина
; Out:
;   Число выведено, D0CE=0 и D0CC=1 после общего хвоста
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Сохраняет выбор дробного формата, выводит разряды 10000, 1000, 100, 10 повторными
;   вычитаниями, подавляет ведущие нули, для значения меньше 10 в денежном режиме печатает 0
;   перед точкой, последний разряд выводит D31D
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D2E5
                ; сохранение формата и подготовка ширины печатаемого числа
Entry:          PUSH AF
                PUSH HL
                CALL Game.Economy.PrintNumberPadding.Entry
                POP HL
                LD A, #01
                LD (ZeroSuppress), A
                LD (DecimalRest), HL
                LD DE, #2710
                CALL Game.Economy.PrintDecimalPlace.Entry
                LD DE, #03E8
                CALL Game.Economy.PrintDecimalPlace.Entry
                LD DE, #0064
                CALL Game.Economy.PrintDecimalPlace.Entry
                LD DE, #000A
                CALL Game.Economy.PrintDecimalPlace.Entry
                POP AF
                JR NC, Game.Economy.FinishWordDecimal.Entry                     ; переход, если режим не требует десятичной точки, сразу вывести единицы

                LD A, (ZeroSuppress)
                AND A
                JP Z, PrintPoint                                                ; переход, если значащие цифры уже напечатаны, дополнительный ноль перед точкой не нужен

                XOR A
                CALL Game.Economy.PrintDigitOrLeadingZero.Entry
PrintPoint:     CALL Game.Text.PrintInlineToken.Entry
                DB #2E                                                          ; аргумент вызываемой процедуры из потока команд
                ; проверка исходного конца фрагмента
                ASSERT $ == #D31D
                endmodule
                endmodule
