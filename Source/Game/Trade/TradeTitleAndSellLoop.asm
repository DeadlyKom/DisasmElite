                module Trade
                module TradeTitleAndSellLoop
; -----------------------------------------
; Заголовок торговли и цикл продажи груза
; исходный диапазон #E8E5..#E961
; In:
;   Для E8E5 нет параметров, для E8EA состояние трюма
; Out:
;   E8E5 печатает токен 96, E8EA обслуживает продажу 17 товаров
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   E935 делает снимок, вычитает количество из груза через 700F, возвращает тоннаж товаров,
;   затем для каждой единицы вызывает DE67 и D3D3, цена зависит от патча DE6A, служебные коды
;   обрабатываются как при покупке
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E8E5
                ; короткий вход заголовка печатает токен 96 второй таблицы
Entry:          LD A, #96
                JP Game.Text.PrintDescriptionToken.Entry

                ; подготовка экрана продажи, за CALL #D421 следует однобайтовый токен #CD
SellCargo:      CALL Game.Trade.PrepareTradeScreen.Entry
                CALL Game.Text.PrintInlineToken.Entry
                DB #CD                                                          ; параметр предыдущего вызова, не исполняется как инструкция
                LD A, #CE
                CALL Game.Trade.PrintScreenCaption.Entry
                ; сброс указателей и обход только непустых грузовых слотов
                CALL Game.Trade.ResetTradeIterators.Entry
NextCommodity:  LD HL, (MarketWork.PriceCursor)
                INC HL
                INC HL
                LD (MarketWork.PriceCursor), HL
                CALL Game.Trade.PrintNonemptyCargoRow.Entry
                JR C, AdvanceItem                                               ; переход, если текущий слот трюма пуст, перейти к следующему товару

                CALL Game.Trade.SaveTextPosition.Entry
PromptQuantity: CALL Game.Trade.PromptCargoQuantityAndRefugees.Entry
                LD HL, Game.Trade.TradeTitleAndSellLoop.SellQuantity
                CALL Game.Trade.InputTradeQuantity.Entry
                JR C, ServiceResult                                             ; переход, если ввод количества вернул служебный результат или ошибку

                CALL Game.Trade.ShowTradeSuccess.Entry
FinishRow:      CALL Game.Trade.RestoreTextPosition.Entry
                CALL Game.Trade.Newline.Entry
AdvanceItem:    LD HL, MarketWork.Commodity
                INC (HL)
                LD A, (HL)
                CP #11
                JP C, NextCommodity                                             ; переход, если индекс следующего товара меньше 17, продолжить продажу

                CALL Game.Trade.Wait36Interrupts.Entry
                JR ReturnCargo

ServiceResult:  DEC A
                JR Z, PromptQuantity                                            ; переход, если исходный служебный код равен 1, повторить приглашение количества

                DEC A
                JR Z, FinishRow                                                 ; переход, если исходный служебный код равен 2, завершить текущую строку продажи

ReturnCargo:    JP @Game.Menus.PrintStatusFieldAndCargoScreen.CargoScreen

                ; callback продажи, списание количества и возврат занятого тоннажа
SellQuantity:   CALL Game.Trade.SnapshotTrade.Entry
                LD A, (TradeSnapshot.Selection)
                LD B, A
                CALL Game.Extensions.AttributeVectorAndEnergyBomb.ReadCargoByte
                SUB B
                JP C, @Game.Trade.IndirectTradeCallbackAndBuy.NotEnoughStock    ; переход, если груза меньше количества либо запрещена малая партия MINERAL LIFE, отказать в продаже

                LD (HL), A
                CALL Game.Trade.PrintKilometreSuffix.UsesTonnes
                CALL Game.Text.NextDescriptionRandom.CheckWarSupply
                JR NC, PayUnit                                                  ; переход, если товар не занимает тоннаж, свободное место не увеличивать

                LD A, (State.FreeCargo)
                ADD A, B
                LD (State.FreeCargo), A
                ; цена продажи начисляется по одной единице, у MINERAL LIFE её подменяет DE6A
PayUnit:        PUSH BC
                LD HL, (MarketWork.PriceCursor)
                CALL Game.Travel.GetSalePriceAndMissionFlags.Entry
                CALL Game.Economy.AddCashLow.Entry
                POP BC
                DJNZ PayUnit

                AND A
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #E962
                endmodule
                endmodule
