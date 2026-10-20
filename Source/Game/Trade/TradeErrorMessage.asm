                module Trade
                module TradeErrorMessage
; -----------------------------------------
; Сообщение ошибки торговли перед откатом
; исходный диапазон #E81C..#E82E
; In:
;   E81C выбирает C5, E820 выбирает CE, E822 принимает токен A
; Out:
;   Состояние восстановлено, A=1 и CY=1
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Печатает при X=3 сообщение ошибки и токен 3F, затем продолжает E82F
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E81C
                ; выбор сообщения недостатка денег с переходом к общему откату
Entry:          LD A, #C5
                JR ShowError

                ; код сообщения о переполнении трюма
NoCargoSpace:   LD A, #CE
                ; сообщение ошибки печатается перед восстановлением снимка и паузой
ShowError:      PUSH AF
                CALL Game.Trade.SetInlineTextColumn.Entry
                DB #03                                                          ; аргумент вызываемой процедуры из потока команд
                POP AF
                CALL Game.Text.PrintMainToken.Entry
                CALL Game.Text.PrintInlineToken.Entry
                DB #3F                                                          ; аргумент вызываемой процедуры из потока команд
                ; проверка исходного конца фрагмента
                ASSERT $ == #E82F
                endmodule
                endmodule
