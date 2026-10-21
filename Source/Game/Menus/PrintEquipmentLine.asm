                module Menus
                module PrintEquipmentLine
; -----------------------------------------
; Печать токена отдельной строкой оборудования
; исходный диапазон #F06F..#F071
; In:
;   AF, A = токен
; Out:
;   После текста новая строка с X=5
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Продолжение в общий хвост Game.Menus.NextEquipmentLine.Entry
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #F06F
                ; печать установленного предмета и переход на следующую строку оборудования
Entry:          CALL Game.Text.PrintMainToken.Entry                             ; далее Game.Menus.NextEquipmentLine.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #F072
                endmodule
                endmodule
