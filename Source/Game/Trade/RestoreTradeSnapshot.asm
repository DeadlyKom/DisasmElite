                module Trade
                module RestoreTradeSnapshot
; -----------------------------------------
; Восстановление состояния до операции
; исходный диапазон #E85D..#E87D
; In:
;   TradeSnapshot = снимок, текущие указатели неизменны
; Out:
;   Деньги, остаток станции, груз и свободные тонны восстановлены
; Corrupt:
;   HL, AF
; Note:
;   Нельзя менять MarketWork.CargoCursor/MarketWork.StockCursor между снимком и откатом, восстановление пишет через текущие
;   указатели
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E85D
                ; обратная запись снимка восстанавливает все изменённые поля пробной сделки
Entry:          LD HL, (TradeSnapshot.CashLow)
                LD (State.CashHigh), HL
                LD HL, (TradeSnapshot.CashHigh)
                LD (State.CashLow), HL
                LD HL, (MarketWork.StockCursor)
                LD A, (TradeSnapshot.StockCount)
                LD (HL), A
                LD HL, (MarketWork.CargoCursor)
                LD A, (TradeSnapshot.CargoCount)
                LD (HL), A
                LD A, (TradeSnapshot.FreeCargo)
                LD (State.FreeCargo), A
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #E87E
                endmodule
                endmodule
