                module Trade
                module RollbackFailedTrade
; -----------------------------------------
; Откат неудачной операции и сигнал
; исходный диапазон #E82F..#E831
; In:
;   Рабочий снимок TradeSnapshot
; Out:
;   Деньги, груз, остаток и свободное место восстановлены
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   После Game.Trade.RestoreTradeSnapshot.Entry исполнение продолжается в Game.Trade.TradeBeepAndPause.Entry
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E82F
                ; общий откат возвращает деньги, товар и свободный тоннаж до пробной операции
Entry:          CALL Game.Trade.RestoreTradeSnapshot.Entry                      ; далее Game.Trade.TradeBeepAndPause.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #E832
                endmodule
                endmodule
