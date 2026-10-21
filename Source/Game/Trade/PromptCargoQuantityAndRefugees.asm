                module Trade
                module PromptCargoQuantityAndRefugees
; -----------------------------------------
; Приглашение количества товара и условия миссии
; исходный диапазон #E87E..#E8D8
; In:
;   MarketWork.Commodity содержит индекс товара
; Out:
;   Выведен вопрос количества с единицей измерения
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   TradeSnapshot содержит снимок транзакции и параметры ввода, UnloadRefugees отдельно проверяет миссию и бит 5
;   State.MissionFlags, обрабатывает освобождение трюма, TradeAttrs является таблицей атрибутов
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

                ; снимок сделки для проверки и отката изменения количества
TradeBackup     FTradeSnapshot {
                    #0000,                                                      ; FTradeSnapshot.CashHigh, сохранённое старшее слово денег перед сделкой
                    #0000,                                                      ; FTradeSnapshot.CashLow, сохранённое младшее слово денег перед сделкой
                    #00,                                                        ; FTradeSnapshot.CargoCount, сохранённое количество товара в трюме
                    #00,                                                        ; FTradeSnapshot.StockCount, сохранённый остаток товара станции
                    #00,                                                        ; FTradeSnapshot.FreeCargo, сохранённый свободный объём трюма
                    #00,                                                        ; FTradeSnapshot.Selection, введённое количество товара либо номер покупаемого оборудования
                    #0000                                                       ; FTradeSnapshot.Validator, адрес проверки очередного изменения количества
                }
                ASSERT $ - TradeBackup == FTradeSnapshot

                ; прежние имена указывают на поля экземпляра TradeBackup
CashHigh        EQU TradeBackup.CashHigh                                        ; поле FTradeSnapshot.CashHigh
CashLow         EQU TradeBackup.CashLow                                         ; поле FTradeSnapshot.CashLow
CargoCount      EQU TradeBackup.CargoCount                                      ; поле FTradeSnapshot.CargoCount
StockCount      EQU TradeBackup.StockCount                                      ; поле FTradeSnapshot.StockCount
FreeCargo       EQU TradeBackup.FreeCargo                                       ; поле FTradeSnapshot.FreeCargo
Selection       EQU TradeBackup.Selection                                       ; поле FTradeSnapshot.Selection
Validator       EQU TradeBackup.Validator                                       ; поле FTradeSnapshot.Validator
                ; миссии 1 и 7+1, проверка разрешения высадки и выдача награды
                ; описание в Docs/Manual.md, раздел mission-1 и mission-7-1
                ; завершение перевозки беженцев либо переход к обычной продаже
                ; миссии 1, 4, 7+1, разрешённая высадка снимает особый груз, выдаёт Gemstones и сбрасывает колонию
                ; описание в Docs/Manual.md, раздел mission-1, mission-4, mission-7-1
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
