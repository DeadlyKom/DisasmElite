                module Trade
                module PrintEmptyStockOrQuantity
; -----------------------------------------
; Окончание строки рыночного остатка
; исходный диапазон #E24D..#E267
; In:
;   Для E24D нет параметров, для E254 указатель E1E4
; Out:
;   CY=1 после прочерка, CY=0 после количества
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   E254 является входом ненулевого количества, все пути завершают строку
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E24D
                ; нулевой запас печатается специальным текстом, ненулевой числом с единицей измерения
Entry:          LD A, #2D
                CALL Game.Trade.PrintTokenNewline.Entry
                SCF
                RET

PrintStock:     LD A, #02
                LD (NumberWidth), A
                LD HL, (MarketWork.StockCursor)
                LD A, (HL)
                CALL Game.Economy.PrintByteInteger.Entry
                CALL Game.Trade.PrintCommodityUnit.Entry
                CALL Game.Trade.Newline.Entry
                AND A
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #E268
                endmodule
                endmodule
