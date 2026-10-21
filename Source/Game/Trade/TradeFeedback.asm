                module Trade
                module TradeFeedback
; -----------------------------------------
; Звуковое подтверждение торговли
; исходный диапазон #E7D7..#E7D9
; In:
;   Нет параметров
; Out:
;   A=1 и CY=1 после Game.Trade.TradeBeepAndPause.Entry
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Безусловно передаёт управление в Game.Trade.TradeBeepAndPause.Entry
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E7D7
                ; краткий сигнал сопровождает завершённую торговую операцию
Entry:          JP Game.Trade.TradeBeepAndPause.Entry

                ; проверка исходного конца фрагмента
                ASSERT $ == #E7DA
                endmodule
                endmodule
