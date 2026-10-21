                module Text
                module PrintTwoLetterSyllable
; -----------------------------------------
; Печать одного или двух символов слоговой таблицы
; исходный диапазон #D595..#D5B3
; In:
;   AF, A=D7..FF для TextSyllables либо 80..9F при входе Game.Text.PrintTwoLetterSyllable.MainSyllable для NameSyllables
; Out:
;   Слог напечатан с текущими правилами регистра
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Индекс умножается на 2, второй байт 3F является заполнителем и не печатается, первый символ
;   печатается всегда
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D595
                ; поиск двух букв слога, символ ? означает отсутствующую вторую букву
Entry:          SUB #D7
                LD HL, TextSyllables
                JR FindPair

MainSyllable:   SUB #80
                LD HL, NameSyllables
FindPair:       ADD A, A
                LD D, #00
                LD E, A
                ADD HL, DE
                LD A, (HL)
                PUSH HL
                CALL Game.Text.ApplyTextCase.Entry
                POP HL
                INC HL
                LD A, (HL)
                CP #3F
                RET Z                                                           ; выход, если вторая буква слога равна заполнителю ?, не печатать её

                JP Game.Text.ApplyTextCase.Entry

                ; проверка исходного конца фрагмента
                ASSERT $ == #D5B4
                endmodule
                endmodule
