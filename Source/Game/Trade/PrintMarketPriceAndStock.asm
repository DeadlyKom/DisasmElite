                module Trade
                module PrintMarketPriceAndStock
; -----------------------------------------
; Вывод цены и количества товара
; исходный диапазон #E225..#E24C
; In:
;   E1E2/E1E4 = предыдущая цена и остаток
; Out:
;   Указатели увеличены на 2 и 1, CY=1 при нулевом остатке
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Цена печатается в десятых с шириной 4, запас при X=23, ноль заменяется пробелом и знаком
;   минус, ненулевой запас печатается шириной 2 с единицей
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E225
                ; продвижение указателя двухбайтовых цен и однобайтовых остатков
Entry:          LD HL, (MarketWork.PriceCursor)
                INC HL
                INC HL
                LD (MarketWork.PriceCursor), HL
                LD E, (HL)
                INC HL
                LD D, (HL)
                EX DE, HL
                SCF
                LD A, #04
                LD (NumberWidth), A
                CALL Game.Economy.PrintWordDecimal.Entry
                CALL Game.Trade.SetInlineTextColumn.Entry
                DB #17                                                          ; аргумент вызываемой процедуры из потока команд
                LD HL, (MarketWork.StockCursor)
                INC HL
                LD A, (HL)
                LD (MarketWork.StockCursor), HL
                AND A
                JR NZ, @Game.Trade.PrintEmptyStockOrQuantity.PrintStock         ; переход, если остаток товара на станции ненулевой, напечатать количество

                CALL Game.Text.PrintInlineToken.Entry
                DB #20                                                          ; аргумент вызываемой процедуры из потока команд
                ; проверка исходного конца фрагмента
                ASSERT $ == #E24D
                endmodule
                endmodule
