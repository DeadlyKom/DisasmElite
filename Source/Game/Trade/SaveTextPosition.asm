                module Trade
                module SaveTextPosition
; -----------------------------------------
; Сохранение координат печати
; исходный диапазон #E364..#E36A
; In:
;   TextPosition/TextRow = текущая позиция
; Out:
;   MarketWork.TextPosition/MarketWork.TextPosition + 1 = копия позиции, HL = позиция
; Corrupt:
;   HL
; Note:
;   X и Y сохраняются одним словом
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E364
                ; текущие X и Y сохраняются одним словом для временного приглашения
Entry:          LD HL, (TextColumn)
                LD (MarketWork.TextPosition), HL
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #E36B
                endmodule
                endmodule
