                module Trade
                module PrintZeroTerminatedString
; -----------------------------------------
; Печать основной токенизированной строки
; исходный диапазон #E311..#E31D
; In:
;   HL = начало строки
; Out:
;   HL указывает на 0, CY=1
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Каждый байт раскрывает Game.Text.PrintMainToken.Entry, указатель сохраняется вокруг печати, CY устанавливается на
;   конечном нуле
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E311
                ; нулевой завершитель останавливает строку, остальные байты обрабатывает основной принтер
Entry:          LD A, (HL)
                CP #00
                SCF
                RET Z                                                           ; выход, если прочитан нулевой завершитель строки, вернуть установленный перенос

                INC HL
                PUSH HL
                CALL Game.Text.PrintMainToken.Entry
                POP HL
                JR Game.Trade.PrintZeroTerminatedString.Entry

                ; проверка исходного конца фрагмента
                ASSERT $ == #E31E
                endmodule
                endmodule
