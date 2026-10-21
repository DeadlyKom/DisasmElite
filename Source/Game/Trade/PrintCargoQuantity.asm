                module Trade
                module PrintCargoQuantity
; -----------------------------------------
; Печать количества в текущем слоте трюма
; исходный диапазон #E27F..#E291
; In:
;   MarketWork.CargoCursor = указатель слота, MarketWork = индекс товара
; Out:
;   Количество выведено шириной 3, CY=0
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Game.Trade.PrintCargoQuantity.EmptyCargo является общим возвратом SCF/RET для пропуска пустой строки
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E27F
                ; печать количества текущего груза с единицей и переводом строки
Entry:          LD A, #03
                LD (NumberWidth), A
                LD HL, (MarketWork.CargoCursor)
                LD A, (HL)
                CALL Game.Economy.PrintByteInteger.Entry
                CALL Game.Trade.PrintCommodityUnit.Entry
                AND A
                RET

EmptyCargo:     SCF
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #E292
                endmodule
                endmodule
