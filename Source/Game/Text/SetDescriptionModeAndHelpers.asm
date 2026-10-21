                module Text
                module SetDescriptionModeAndHelpers
; -----------------------------------------
; Выбор режима второй текстовой таблицы
; исходный диапазон #D8E5..#D906
; In:
;   Нет параметров для Game.Text.SetDescriptionModeAndHelpers.Entry/Game.Text.SetDescriptionModeAndHelpers.Disable
; Out:
;   TextDecodeMode=1 для Game.Text.SetDescriptionModeAndHelpers.Entry, TextDecodeMode=0 для Game.Text.SetDescriptionModeAndHelpers.Disable
; Corrupt:
;   AF
; Note:
;   RowSix и вход непосредственно перед SetRow устанавливают Y=6 либо 10, Game.Text.SetDescriptionModeAndHelpers.PrintLetter печатает байт(HL) кроме 3F, после PrintLetter сохранены восемь байтов, это
;   отдельные данные
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D8E5
                ; включение второй таблицы описаний, дополнительный вход Game.Text.SetDescriptionModeAndHelpers.Disable выключает этот режим
Entry:          LD A, #01
                JR StoreMode

                ; вход сброса режима второй таблицы описаний
Disable:        LD A, #00
StoreMode:      LD (TextDecodeMode), A
                RET

                ; команды выбора строки печати и пропуска заполнителя слога
RowSix:         LD A, #06
                JR SetRow

                LD A, #0A
SetRow:         JP Game.Trade.SetTextRow.Entry

PrintLetter:    LD A, (HL)
                CP #3F
                RET Z                                                           ; выход, если символ слога является заполнителем ?, пропустить его

                JP Game.Text.PrintMainToken.Entry

                ; сохранённые восемь байтов между текстовыми обработчиками и дисковым меню
                DB #00, #00, #00, #0C, #12, #12, #13, #80                       ; #D8FF..#D906
                ; проверка исходного конца фрагмента
                ASSERT $ == #D907
                endmodule
                endmodule
