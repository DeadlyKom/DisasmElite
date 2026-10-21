                module Trade
                module PrepareTradeScreen
; -----------------------------------------
; Подготовка торгового экрана
; исходный диапазон #E8D9..#E8E4
; In:
;   Нет параметров
; Out:
;   Напечатан токен 96, атрибуты настроены
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Использует таблицу TradeAttrs и строку приглашения Game.Text.SetPromptAttributes.Entry
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E8D9
                ; общая очистка и подготовка экрана перед покупкой или продажей
Entry:          CALL Game.Trade.TradeTitleAndSellLoop.Entry
                LD DE, TradeAttrs
                CALL Game.Text.ApplyAttributeRuns.Entry
                JP Game.Text.SetPromptAttributes.Entry

                ; проверка исходного конца фрагмента
                ASSERT $ == #E8E5
                endmodule
                endmodule
