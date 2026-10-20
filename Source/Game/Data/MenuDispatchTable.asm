                module Interface
                module MenuDispatchTable
; -----------------------------------------
; первые семь элементов исполняемой таблицы экранов и действий
; диспетчер #813E рассчитывает #D000 + A * 3 и записывает результат
; в операнд CALL по #8154, поэтому записи являются командами JP, а не DW
; RET выбранного обработчика возвращает управление диспетчеру
; следующие элементы продолжаются в файле входа #D015
; код действия в A задаёт элемент, отдельного контроля границ здесь нет
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D000
Entry:          JP Game.Charts.NextScreenCharacterRowAndRefugees.OfferRefugees  ; действие 0, покупка товаров

                JP Game.Trade.PromptCargoQuantityAndRefugees.UnloadRefugees     ; действие 1, продажа товаров

                JP Game.Trade.OpenEquipmentShop.Entry                           ; действие 2, приобретение оборудования

                JP Game.Menus.MapCaptionAndGalaxyChart.GalaxyChart              ; действие 3, общая карта галактики

                JP Game.Menus.OpenLocalChart.Entry                              ; действие 4, местная карта

                JP Game.Menus.PrintLabelOnUnusedRow.ShowSystem                  ; действие 5, информация о планете

                JP Game.Menus.CompareSystemSeedToGalaxyBase.MarketPrices        ; действие 6, рыночные цены
                ; проверка исходного конца фрагмента
                ASSERT $ == #D015
                endmodule
                endmodule
