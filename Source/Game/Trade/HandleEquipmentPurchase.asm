                module Trade
                module HandleEquipmentPurchase
; -----------------------------------------
; Проверка пункта и списание цены оборудования
; исходный диапазон #E9E6..#EA3A
; In:
;   E8AB = введённый номер, EB5E = текущий предел
; Out:
;   Цена списана либо восстановлена, выбранный предмет выдан
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Обработчик EB2D снимает CY, номер 0 или вне предела возвращает экран пилота, списание обеих
;   групп денег защищено снимком, пункт 1 заполняет бак до 70 и сбрасывает цену топлива 7060
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E9E6
                ; перед вводом номера сохраняется денежный снимок для отмены любой неудачной выдачи
Entry:          LD A, #3F
                CALL Game.Trade.PrintMainTokenSpace.Entry
                CALL Game.Trade.SnapshotTrade.Entry
                LD HL, Game.Trade.EquipmentPaymentFailed.AcceptInput
                CALL Game.Trade.InputTradeQuantity.Entry
                JR C, CheckItemLimit                                            ; переход, если ввод номера завершился служебным результатом, проверить допустимость выхода

                CALL Game.Trade.Newline.Entry
                LD A, (TradeSnapshot.Selection)
                AND A
                JP Z, Game.Menus.OpenCommanderStatus.Entry                      ; переход, если введён нулевой номер, вернуться на экран командира

                LD B, A
                CALL Game.Text.EquipmentMenuLimit.Entry
                CP B
CheckItemLimit: JP C, Game.Menus.OpenCommanderStatus.Entry                      ; переход, если введённый номер превышает разрешённый предел оборудования

                CALL Game.Trade.SnapshotTrade.Entry
                ; списание старшей и младшей групп стоимости с единым путём возврата денег
                LD A, (TradeSnapshot.Selection)
                CALL Game.Trade.GetEquipmentPriceAddress.Entry
                LD D, #00
                LD E, (HL)
                PUSH HL
                CALL Game.Economy.SubtractCashThousands.Entry
                POP HL
                JR C, CheckPayment                                              ; переход, если старшей группы денег не хватает, перейти к общему отказу

                INC HL
                LD E, (HL)
                INC HL
                LD D, (HL)
                CALL Game.Economy.SubtractCashLow.Entry
CheckPayment:   JP C, Game.Trade.EquipmentPaymentFailed.Entry                   ; переход, если списание цены дало заём, восстановить деньги до покупки

                LD A, (TradeSnapshot.Selection)
                CP #01
                JR NZ, Game.Trade.InstallPurchasedEquipment.Entry               ; переход, если покупается не топливо, перейти к выдаче оборудования

                XOR A
                LD (EquipmentTable.FuelPrice), A
                CALL Game.Trade.ShowTradeSuccess.Entry
                LD A, #46
                CALL Game.Travel.SetFuelAndGauge.Entry
                JP Game.Trade.OpenEquipmentShop.Entry
                ; проверка исходного конца фрагмента
                ASSERT $ == #EA3B
                endmodule
                endmodule
