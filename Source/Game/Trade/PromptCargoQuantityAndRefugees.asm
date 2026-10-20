                module Trade
                module PromptCargoQuantityAndRefugees
; -----------------------------------------
; Приглашение количества товара и условия миссии
; исходный диапазон #E87E..#E8D8
; In:
;   E1DF = товар
; Out:
;   Выведен вопрос количества с единицей измерения
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   E8A4..E8AD является рабочей областью транзакции, E8AE отдельно проверяет миссию и бит 5
;   D0B0, обрабатывает освобождение трюма, E8D8 является таблицей атрибутов
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E87E
                ; приглашение количества содержит номер и название текущего товара
Entry:          CALL Game.Trade.ClearPromptRows.Entry
                LD A, #01
                LD (WordStart), A
                CALL Game.Text.PrintInlineToken.Entry
                DB #CC                                                          ; аргумент вызываемой процедуры из потока команд
                LD A, #D0
                LD B, A
                LD A, (MarketWork.Commodity)
                ADD A, B
                CALL Game.Text.PrintMainToken.Entry
                CALL Game.Text.PrintInlineToken.Entry
                DB #2F                                                          ; аргумент вызываемой процедуры из потока команд
                CALL Game.Trade.PrintCommodityUnit.Entry
                CALL Game.Text.PrintInlineToken.Entry
                DB #20                                                          ; аргумент вызываемой процедуры из потока команд
                LD A, #3F
                JP Game.Trade.PrintTokenNewline.Entry
                ; снимок старшей группы денег до торговой операции
CashHigh        DW #0000                                                        ; сохранённое старшее слово денег перед сделкой
                ; снимок младшей группы денег до торговой операции
CashLow         DW #0000                                                        ; сохранённое младшее слово денег перед сделкой
                ; снимок количества текущего груза пилота
CargoCount      DB #00                                                          ; сохранённое количество товара в трюме
                ; снимок остатка товара станции
StockCount      DB #00                                                          ; сохранённый остаток товара станции
                ; снимок свободного тоннажа трюма
FreeCargo       DB #00                                                          ; сохранённый свободный объём трюма
                ; введённое количество товара
Selection       DB #00                                                          ; введённое количество товара либо номер покупаемого оборудования
                ; адрес callback пробной торговой операции
Validator       DW #0000                                                        ; адрес проверки очередного изменения количества
                ; миссии 1 и 7+1, проверка разрешения высадки и выдача награды
                ; описание в Docs/Manual.md, раздел mission-1 и mission-7-1
                ; завершение перевозки беженцев либо переход к обычной продаже
UnloadRefugees: LD A, (State.Mission1)
                AND A
                JR NZ, Game.Trade.TradeTitleAndSellLoop.SellCargo               ; переход, если первая миссия ещё активна, перейти к обычной продаже

                LD HL, State.MissionFlags
                CALL Game.Universe.ApplyEnhancedFlightControl.CheckRefugees
                JR Z, Game.Trade.TradeTitleAndSellLoop.SellCargo                ; переход, если высадка беженцев не разрешена, перейти к обычной продаже

                RES MS_CARGO_BIT, (HL)
                XOR A
                LD (State.MineralLife), A
                LD A, #64
                LD (State.Cargo + FGoods.Gemstones), A
                CALL Game.Screen.ResetCargoCapacity.Entry
                NOP
                NOP
                LD DE, #0F0F
                LD HL, #0700
                CALL Game.Missions.OfferThirdMission.ShowAndWait
                JP @Game.Menus.PrintStatusFieldAndCargoScreen.CargoScreen
                ; сохранённый байт F0 после обработчика беженцев
TradeAttrs      DB #F0                                                          ; однобайтовая последовательность настройки атрибутов торговли
                ; проверка исходного конца фрагмента
                ASSERT $ == #E8D9
                endmodule
                endmodule
