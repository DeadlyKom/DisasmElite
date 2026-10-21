                ifndef _VARIABLES_TRADE_
                define _VARIABLES_TRADE_

MarketWork      EQU Game.Trade.GenerateMarket.MarketData                        ; адрес структуры FMarketWork
.Commodity      EQU MarketWork + FMarketWork.Commodity                          ; номер текущего товара, 0..16
.CargoCursor    EQU MarketWork + FMarketWork.CargoCursor                        ; адрес количества выбранного товара в трюме
.PriceCursor    EQU MarketWork + FMarketWork.PriceCursor                        ; адрес двухбайтовой цены выбранного товара
.StockCursor    EQU MarketWork + FMarketWork.StockCursor                        ; адрес остатка выбранного товара на станции
.TextPosition   EQU MarketWork + FMarketWork.TextPosition                       ; сохранённые столбец и строка печати
MarketPrices    EQU Game.Trade.GenerateMarket.MarketPrices                      ; семнадцать двухбайтовых рыночных цен
TradeSnapshot   EQU Game.Trade.PromptCargoQuantityAndRefugees.TradeBackup       ; адрес структуры FTradeSnapshot
.CashHigh       EQU TradeSnapshot + FTradeSnapshot.CashHigh                     ; сохранённое старшее слово денег перед сделкой
.CashLow        EQU TradeSnapshot + FTradeSnapshot.CashLow                      ; сохранённое младшее слово денег перед сделкой
.CargoCount     EQU TradeSnapshot + FTradeSnapshot.CargoCount                   ; сохранённое количество товара в трюме
.StockCount     EQU TradeSnapshot + FTradeSnapshot.StockCount                   ; сохранённый остаток товара станции
.FreeCargo      EQU TradeSnapshot + FTradeSnapshot.FreeCargo                    ; сохранённый свободный объём трюма
.Selection      EQU TradeSnapshot + FTradeSnapshot.Selection                    ; введённое количество товара либо номер покупаемого оборудования
.Validator      EQU TradeSnapshot + FTradeSnapshot.Validator                    ; адрес проверки очередного изменения количества
EquipmentWork   EQU Game.Trade.EquipmentAlreadyOwned.EquipmentData              ; адрес структуры FEquipmentWork
.ItemLimit      EQU EquipmentWork + FEquipmentWork.ItemLimit                    ; наибольший номер разрешённого оборудования
.ItemIndex      EQU EquipmentWork + FEquipmentWork.ItemIndex                    ; номер пункта при выводе списка оборудования
.PriceCursor    EQU EquipmentWork + FEquipmentWork.PriceCursor                  ; адрес текущей трёхбайтовой цены оборудования
.LaserType      EQU EquipmentWork + FEquipmentWork.LaserType                    ; код выбранного типа лазера

BeforePrices    EQU Game.Trade.GenerateMarket.BeforePrices                      ; нулевое слово перед ценами, обход сначала увеличивает указатель на 2
BuyAttributes   EQU Game.Trade.ResetCloakingAndSeedFlightRandom.BuyAttributes   ; двухбайтовая последовательность настройки атрибутов экрана покупки
TradeAttrs      EQU Game.Trade.PromptCargoQuantityAndRefugees.TradeAttrs        ; однобайтовая последовательность настройки атрибутов торговли

MarketStore     EQU Game.Trade.GenerateMarket.StoreStock                        ; изменяемая команда LD (HL),A, NOP сохраняет остатки рынка нового командира
LaserTariffs    EQU Game.Input.ScanKeyboardMatrix.LaserTariffs                  ; четыре номера тарифов оборудования для лазеров типов 1..4

                endif                                                           ; ~_VARIABLES_TRADE_
