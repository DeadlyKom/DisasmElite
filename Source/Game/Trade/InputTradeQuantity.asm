                module Trade
                module InputTradeQuantity
; -----------------------------------------
; Ввод количества с пробной операцией
; исходный диапазон #E776..#E7CE
; In:
;   HL = адрес обработчика значения
; Out:
;   TradeSnapshot.Selection = количество, CY=0 при успехе, CY=1 при служебном выходе
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Сохраняет обработчик в TradeSnapshot.Validator, первая цифра 1..9 проверяется сразу, перед проверкой
;   двухзначного числа восстанавливает снимок, ENTER без цифр даёт A=2 и CY=1, FE удаляет первую
;   цифру через Game.Trade.BuyCargoLoop.UndoQuantity
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E776
                ; адрес callback сохраняется отдельно, количество до первой цифры равно нулю
Entry:          LD (TradeSnapshot.Validator), HL
ClearQuantity:  XOR A
                LD (TradeSnapshot.Selection), A
FirstDigit:     CALL Game.Trade.WaitForKeyCode.Entry
                CP #0D
                JR Z, SkipItem                                                  ; переход, если нажат ENTER до первой цифры, вернуть код пропуска товара

                CP #31
                JR C, FirstDigit                                                ; переход, если код первой клавиши меньше цифры 1, ждать допустимую цифру

                CP #FE
                JR Z, FirstDigit                                                ; переход, если до первой цифры нажато удаление FE, продолжить ожидание

                CP #3A
                JR NC, InputError                                               ; переход, если код первой клавиши не меньше 3A, вернуть служебное завершение

                ; первая цифра немедленно пробует операцию, поэтому снимок пригоден для последующего отката
                LD B, A
                SUB #30
                LD (TradeSnapshot.Selection), A
                LD A, B
                CALL Game.Text.PrintMainToken.Entry
                LD HL, (TradeSnapshot.Validator)
                CALL Game.Trade.IndirectTradeCallbackAndBuy.Entry
                JR C, InputError                                                ; переход, если пробная операция с первой цифрой завершилась ошибкой, вернуть перенос

SecondDigit:    CALL Game.Trade.WaitForKeyCode.Entry
                CP #0D
                RET Z                                                           ; выход, если после первой цифры нажат ENTER, подтвердить однозначное количество

                CP #30
                JR C, SecondDigit                                               ; переход, если код второй клавиши меньше цифры 0, продолжить ожидание

                CP #FE
                JR Z, @Game.Trade.BuyCargoLoop.UndoQuantity                     ; переход, если нажато удаление FE, откатить первую цифру и очистить её

                CP #3A
                JR NC, InputError                                               ; переход, если код второй клавиши не меньше 3A, завершить ввод служебным результатом

                ; вторая цифра формирует десятичное число, первая проба откатывается перед повторной операцией
                LD D, A
                SUB #30
                LD B, A
                LD HL, TradeSnapshot.Selection
                CALL Game.Flight.DispatchAppendDecimalDigit.Entry
                CALL Game.Trade.RestoreTradeSnapshot.Entry
                LD HL, (TradeSnapshot.Validator)
                CALL Game.Trade.IndirectTradeCallbackAndBuy.Entry
                JR C, InputError                                                ; переход, если операция с двухзначным количеством завершилась ошибкой, вернуть перенос

                AND A
                RET

SkipItem:       LD A, #02
InputError:     SCF
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #E7CF
                endmodule
                endmodule
