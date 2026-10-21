                module Trade
                module Newline
; -----------------------------------------
; Перевод текстового курсора на новую строку
; исходный диапазон #E2A9..#E2B0
; In:
;   TextPosition/TextRow = координаты
; Out:
;   X=0, Y увеличен с переходом 24→1, WordStart=1
; Corrupt:
;   AF
; Note:
;   После сброса X исполнение продолжается в Game.Trade.IncrementTextRow.Entry
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E2A9
                ; общий хвост нового абзаца увеличивает Y и сбрасывает X
Entry:          LD A, #01
                LD (WordStart), A
                CALL Game.Trade.ResetTextColumn.Entry                           ; далее Game.Trade.IncrementTextRow.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #E2B1
                endmodule
                endmodule
