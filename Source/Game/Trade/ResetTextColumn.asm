                module Trade
                module ResetTextColumn
; -----------------------------------------
; Установка нулевой колонки печати
; исходный диапазон #E2B7..#E2BB
; In:
;   Нет параметров
; Out:
;   TextPosition=0, A=0, Z=1, CY=0
; Corrupt:
;   AF
; Note:
;   Возвращаемый вход также используется внутри перевода строки
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E2B7
                ; сброс колонки, вход Game.Trade.ResetTextColumn.SetColumn принимает заранее подготовленный A
Entry:          XOR A
SetColumn:      LD (TextColumn), A
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #E2BC
                endmodule
                endmodule
