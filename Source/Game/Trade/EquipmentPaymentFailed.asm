                module Trade
                module EquipmentPaymentFailed
; -----------------------------------------
; Откат покупки при недостатке денег
; исходный диапазон #EB27..#EB2E
; In:
;   Снимок транзакции
; Out:
;   Сообщение ошибки и возврат к меню
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Game.Trade.EquipmentPaymentFailed.AcceptInput является отдельным обработчиком AND A, RET для ввода пункта без побочных действий
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #EB27
                ; неудачная покупка восстанавливает денежный снимок и возвращается в меню
Entry:          CALL Game.Trade.TradeErrorMessage.Entry
                JP @Game.Trade.PrintEquipmentPrice.SelectItem

                ; успешный возврат без переноса для общего пути покупки
AcceptInput:    AND A
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #EB2F
                endmodule
                endmodule
