                module Trade
                module SnapshotTrade
; -----------------------------------------
; Снимок изменяемых полей транзакции
; исходный диапазон #E83C..#E85C
; In:
;   MarketWork.CargoCursor/MarketWork.StockCursor = текущие слоты груза и остатка
; Out:
;   TradeSnapshot содержат деньги, груз, остаток и свободные тонны
; Corrupt:
;   HL, AF
; Note:
;   Два денежных слова сохраняются отдельно, затем три байта, указатели снимком не охватываются
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E83C
                ; снимок двух групп денег, количества товара у пилота и станции, свободного тоннажа
Entry:          LD HL, (State.CashHigh)
                LD (TradeSnapshot.CashLow), HL
                LD HL, (State.CashLow)
                LD (TradeSnapshot.CashHigh), HL
                LD HL, (MarketWork.StockCursor)
                LD A, (HL)
                LD (TradeSnapshot.StockCount), A
                LD HL, (MarketWork.CargoCursor)
                LD A, (HL)
                LD (TradeSnapshot.CargoCount), A
                LD A, (State.FreeCargo)
                LD (TradeSnapshot.FreeCargo), A
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #E85D
                endmodule
                endmodule
