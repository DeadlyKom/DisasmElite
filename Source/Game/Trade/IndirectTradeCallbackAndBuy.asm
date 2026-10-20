                module Trade
                module IndirectTradeCallbackAndBuy
; -----------------------------------------
; Косвенный вызов и обработчик покупки груза
; исходный диапазон #E7DA..#E81B
; In:
;   HL = адрес обработчика для E7DA, E8AB = количество для E7DB
; Out:
;   CY=0 при покупке, CY=1 при обработанной ошибке
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   JP(HL) сохраняет возврат CALL, E7DB делает снимок, проверяет запас станции, списывает цену
;   каждой единицы, проверяет тоннаж и переполнение груза, D1B5 меняет legal status при
;   незаконном товаре
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E7DA
                ; JP(HL) вызывает сохранённый callback без дополнительного адреса возврата
Entry:          JP (HL)

                ; callback покупки, снимок состояния, проверка товара, денег и свободного места
BuyQuantity:    CALL Game.Trade.SnapshotTrade.Entry
                LD A, (TradeSnapshot.Selection)
                LD B, A
                LD HL, (MarketWork.StockCursor)
                LD A, (HL)
                SUB B
                JR C, NotEnoughStock                                            ; переход, если на станции меньше товара, чем запрошено, вывести отказ

                LD (HL), A
PayPrice:       LD HL, (MarketWork.PriceCursor)
                LD E, (HL)
                INC HL
                LD D, (HL)
                CALL Game.Economy.SubtractCashLow.Entry
                JR C, Game.Trade.TradeErrorMessage.Entry                        ; переход, если денег не хватило на очередную единицу товара, откатить всю покупку

                DJNZ PayPrice

                CALL Game.Trade.PrintKilometreSuffix.UsesTonnes
                LD A, (TradeSnapshot.Selection)
                LD B, A
                JR NC, AddCargo                                                 ; переход, если товар измеряется не тоннами, свободное место трюма не уменьшать

                LD HL, State.FreeCargo
                LD A, (HL)
                SUB B
                JR C, Game.Trade.TradeErrorMessage.NoCargoSpace                 ; переход, если свободного тоннажа меньше приобретаемого количества, отказать в покупке

                LD (HL), A
AddCargo:       LD HL, (MarketWork.CargoCursor)
                LD A, (HL)
                ADD A, B
                JR C, Game.Trade.TradeErrorMessage.NoCargoSpace                 ; переход, если количество данного груза превысило 255, отказать в покупке

                LD (HL), A
                LD A, (MarketWork.Commodity)
                CALL Game.Missions.SpecialMessageAndScoopReward.CheckIllegal
                AND A
                RET

NotEnoughStock: LD A, #B0
                JR @Game.Trade.TradeErrorMessage.ShowError
                ; проверка исходного конца фрагмента
                ASSERT $ == #E81C
                endmodule
                endmodule
