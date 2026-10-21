                module Text
                module PrintDescriptionString
; -----------------------------------------
; Печать строки с нулевым завершителем и токенами
; исходный диапазон #D48E..#D498
; In:
;   HL = начало строки
; Out:
;   HL указывает на завершающий 0
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Каждый ненулевой байт передаётся Game.Text.PrintDescriptionByte.Entry, адрес очередного байта сохраняется вокруг
;   рекурсивного печатного вызова
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D48E
                ; цикл строки описания, вложенный токен может рекурсивно напечатать целую строку
Entry:          LD A, (HL)
                AND A
                RET Z                                                           ; выход, если прочитан нулевой завершитель строки описания

                PUSH HL
                CALL Game.Text.PrintDescriptionByte.Entry
                POP HL
                INC HL
                JR Game.Text.PrintDescriptionString.Entry

                ; проверка исходного конца фрагмента
                ASSERT $ == #D499
                endmodule
                endmodule
