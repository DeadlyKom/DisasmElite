                module Trade
                module ShowTradeSuccess
; -----------------------------------------
; Подтверждение торговой операции
; исходный диапазон #E7CF..#E7D6
; In:
;   Нет параметров
; Out:
;   Напечатан токен 7 при X=3, затем сигнал и пауза
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   После встроенного байта следует общий хвост Game.Trade.TradeFeedback.Entry
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E7CF
                ; показ подтверждения и общий путь звуковой обратной связи
Entry:          CALL Game.Trade.SetInlineTextColumn.Entry
                DB #03                                                          ; аргумент вызываемой процедуры из потока команд
                CALL Game.Text.PrintInlineToken.Entry
                DB #07                                                          ; аргумент вызываемой процедуры из потока команд
                ; проверка исходного конца фрагмента
                ASSERT $ == #E7D7
                endmodule
                endmodule
