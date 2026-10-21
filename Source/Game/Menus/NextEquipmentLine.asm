                module Menus
                module NextEquipmentLine
; -----------------------------------------
; Следующая строка списка оборудования
; исходный диапазон #F072..#F079
; In:
;   Нет параметров
; Out:
;   Y увеличен с переносом, X=5
; Corrupt:
;   AF
; Note:
;   Сначала Game.Trade.Newline.Entry, затем установка колонки Game.Trade.SetTextColumn.Entry
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #F072
                ; общий хвост установки следующей строки и колонки списка оборудования
Entry:          CALL Game.Trade.Newline.Entry
                LD A, #05
                JP Game.Trade.SetTextColumn.Entry

                ; проверка исходного конца фрагмента
                ASSERT $ == #F07A
                endmodule
                endmodule
