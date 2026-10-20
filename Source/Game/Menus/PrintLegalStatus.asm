                module Menus
                module PrintLegalStatus
; -----------------------------------------
; Печать правового состояния и подписи рейтинга
; исходный диапазон #EFC5..#EFDF
; In:
;   D05F = legalstatus
; Out:
;   Выбран токен 12 при 0, 13 при 1..49, 14 при>=50
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   После строки состояния печатает подпись 72 второй таблицы и пробел, продолжение в EFE0
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #EFC5
                ; правовой статус 0 означает CLEAN, 1..49 OFFENDER, от 50 FUGITIVE
Entry:          LD B, #12
                LD A, (State.LegalStatus)
                AND A
                JR Z, PrintStatus                                               ; переход, если правовой статус равен нулю, выбрать CLEAN

                CP #32
                JR C, Offender                                                  ; переход, если правовой статус меньше 50, выбрать OFFENDER

                INC B
Offender:       INC B
PrintStatus:    LD A, B
                CALL Game.Trade.PrintTokenNewline.Entry
                LD A, #72
                CALL Game.Trade.PrintDescriptionColon.Entry
                CALL Game.Text.PrintInlineToken.Entry
                DB #20                                                          ; аргумент вызываемой процедуры из потока команд
                ; проверка исходного конца фрагмента
                ASSERT $ == #EFE0
                endmodule
                endmodule
