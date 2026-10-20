                module Trade
                module PrintScreenCaption
; -----------------------------------------
; Печать заголовка с обновлением полос экрана
; исходный диапазон #E306..#E310
; In:
;   AF, A = токен заголовка
; Out:
;   Заголовок оформлен, затем выполнена команда 9
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Вызывает E2F8, обновляет полосы через DA2F и переходит к печати управляющего кода 9
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E306
                ; подготовка полос экрана и оформление заголовка в стандартной позиции
Entry:          CALL Game.Trade.PrintDecoratedToken.Entry
                CALL Game.Disk.DrawScreenStripsAndPrivateStack.Entry
                LD A, #09
                JP Game.Text.PrintMainToken.Entry
                ; проверка исходного конца фрагмента
                ASSERT $ == #E311
                endmodule
                endmodule
