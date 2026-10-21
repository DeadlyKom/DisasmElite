                module Trade
                module PrintMarketRow
; -----------------------------------------
; Печать строки товара на рынке
; исходный диапазон #E212..#E224
; In:
;   MarketWork = индекс 0..16, MarketWork.PriceCursor/MarketWork.StockCursor = предыдущие указатели
; Out:
;   Строка выведена, указатели продвинуты
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Печатает токен D0+индекс, единицу при X=13, затем задаёт X=15 и продолжает Game.Trade.PrintMarketPriceAndStock.Entry
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E212
                ; печать имени товара с последующим переходом к цене и запасу станции
Entry:          LD A, (MarketWork.Commodity)
                ADD A, #D0
                CALL Game.Text.PrintMainToken.Entry
                CALL Game.Trade.SetInlineTextColumn.Entry
                DB #0D                                                          ; аргумент вызываемой процедуры из потока команд
                CALL Game.Trade.PrintCommodityUnit.Entry
                CALL Game.Trade.SetInlineTextColumn.Entry
                DB #0F                                                          ; аргумент вызываемой процедуры из потока команд
                ; проверка исходного конца фрагмента
                ASSERT $ == #E225
                endmodule
                endmodule
