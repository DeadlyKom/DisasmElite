                ifndef _VARIABLES_TABLES_
                define _VARIABLES_TABLES_

MarketTable     EQU Game.Extensions.AttributeVectorAndEnergyBomb.MarketParams   ; 17 записей FMarketEntry
.Base           EQU MarketTable                                                 ; первый товар, продовольствие
                ; изменяемая базовая цена оружия
.FirearmPrice   EQU MarketTable + FGoods.Firearms * FMarketEntry + FMarketEntry.Price
                ; изменяемый коэффициент экономики оружия
.FirearmEconomy EQU MarketTable + FGoods.Firearms * FMarketEntry + FMarketEntry.Economy
                ; 14 записей FEquipmentPrice
EquipmentTable  EQU Game.Extensions.AttributeVectorAndEnergyBomb.EquipmentPrices
.Base           EQU EquipmentTable                                              ; первый пункт, топливо
.FuelPrice      EQU EquipmentTable + FEquipmentPrice.Low                        ; младший байт цены топлива, старший байт слова исходно нулевой
MessageTable    EQU Game.Extensions.PrintCargoAndMessageBanks.MainTable         ; два указателя на банки сообщений
.Main           EQU MessageTable                                                ; указатель на основной банк токенов
.Description    EQU Game.Extensions.PrintCargoAndMessageBanks.DescTable         ; указатель на банк описаний систем

                endif                                                           ; ~_VARIABLES_TABLES_
