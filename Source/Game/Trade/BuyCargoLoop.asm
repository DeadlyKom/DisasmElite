                module Trade
                module BuyCargoLoop
; -----------------------------------------
; Последовательная покупка 17 товаров
; исходный диапазон #E711..#E775
; In:
;   Рынок и состояние трюма подготовлены
; Out:
;   Изменены деньги, запасы товаров и свободные тонны
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   Печатает товар, предлагает количество и вызывает E7DB, код возврата 1 повторяет ввод, 2
;   пропускает товар, другой код завершает в F0B8, E76E удаляет цифру и откатывает операцию
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E711
                ; инициализация прохода по 17 рыночным товарам и указателя груза
Entry:          LD A, #FF
                CALL Game.Trade.PrintTokenNewline.Entry
                LD DE, BuyAttributes
                CALL Game.Text.ApplyAttributeRuns.Entry
                CALL Game.Text.SetPromptAttributes.Entry
                CALL Game.Trade.ResetTradeIterators.Entry
                LD HL, State.Government
                LD (MarketWork.StockCursor), HL
                ; для очередного товара сначала печатается наличие, затем выполняется пробная покупка
NextCommodity:  LD HL, (MarketWork.CargoCursor)
                INC HL
                LD (MarketWork.CargoCursor), HL
                CALL Game.Trade.PrintMarketRow.Entry
                JR C, AdvanceItem                                               ; переход, если строка товара вернула перенос, пропустить ввод количества для неё

                CALL Game.Trade.SaveTextPosition.Entry
PromptQuantity: CALL Game.Trade.PromptCargoQuantityAndRefugees.Entry
                LD HL, Game.Trade.IndirectTradeCallbackAndBuy.BuyQuantity
                CALL Game.Trade.InputTradeQuantity.Entry
                JR NC, BuySuccess                                               ; переход, если ввод количества завершился без переноса, покупка выполнена

                CP #01
                JR Z, PromptQuantity                                            ; переход, если код служебного результата равен 1, повторить приглашение количества

                CP #02
                JR Z, RestoreCursor                                             ; переход, если код служебного результата равен 2, перейти к следующему товару

                JR ReturnCargo

BuySuccess:     CALL Game.Trade.ShowTradeSuccess.Entry
RestoreCursor:  CALL Game.Trade.RestoreTextPosition.Entry
AdvanceItem:    LD HL, MarketWork.Commodity
                INC (HL)
                LD A, (HL)
                CP #11
                JR C, NextCommodity                                             ; переход, если индекс следующего товара меньше 17, продолжить список покупок

ReturnCargo:    JP @Game.Menus.PrintStatusFieldAndCargoScreen.CargoScreen

                ; вход очистки двух областей атрибутов через общий хвост #E769
ClearTradeAttr: LD HL, Memory.Attributes + #0020                                ; атрибуты со второй символьной строки
                LD B, #E0
                CALL ClearAttrByte
                CALL ClearAttrByte
ClearAttrByte:  LD (HL), A
                INC HL
                DJNZ ClearAttrByte

                RET

UndoQuantity:   CALL Game.Trade.ErasePreviousCharacter.Entry
                CALL Game.Trade.RestoreTradeSnapshot.Entry
                JR @Game.Trade.InputTradeQuantity.ClearQuantity
                ; проверка исходного конца фрагмента
                ASSERT $ == #E776
                endmodule
                endmodule
