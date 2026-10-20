                module Trade
                module ChooseLaserDirection
; -----------------------------------------
; Замена лазера с возвратом цены прежнего
; исходный диапазон #EAE0..#EB26
; In:
;   ASCII 0..3, EB62 = новый тип
; Out:
;   D07D+направление = новый лазер, прежний компенсирован деньгами
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Старый тип через FD89 переводится в номер тарифа 705F, обе группы денег возвращаются
;   отдельно, другая клавиша восстанавливает снимок
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #EAE0
                ; ответ 0..3 выбирает сторону, прежний лазер затем возвращает свою стоимость
Entry:          CALL Game.Trade.WaitForKeyCode.Entry
                CP #30
                JP C, CancelLaser                                               ; переход, если нажатая клавиша меньше цифры 0, отменить выбор направления

                CP #34
                JP NC, CancelLaser                                              ; переход, если нажатая клавиша не меньше цифры 4, отменить выбор направления

                PUSH AF
                CALL Game.Trade.PrintTokenNewline.Entry
                POP AF
                SUB #30
                LD HL, State.FrontLaser
                CALL Game.Trade.AddByteOffsetToHL.Entry
                LD B, (HL)
                LD A, (EquipmentWork.LaserType)
                LD (HL), A
                LD A, B
                AND A
                JR Z, LaserSuccess                                              ; переход, если на выбранной стороне лазера не было, возвращать его стоимость не нужно

                LD HL, LaserTariffs - 1                                         ; база перед таблицей, старый тип лазера имеет индекс 1..4
                CALL Game.Trade.AddByteOffsetToHL.Entry
                LD A, (HL)
                CALL Game.Trade.GetEquipmentPriceAddress.Entry
                LD D, #00
                LD E, (HL)
                PUSH HL
                CALL Game.Economy.AddCashThousands.Entry
                POP HL
                INC HL
                LD E, (HL)
                INC HL
                LD D, (HL)
                CALL Game.Economy.AddCashLow.Entry
LaserSuccess:   CALL Game.Trade.ShowTradeSuccess.Entry
                JP Game.Trade.OpenEquipmentShop.Entry

CancelLaser:    CALL Game.Trade.RestoreTradeSnapshot.Entry
                JR @Game.Trade.EquipmentAlreadyOwned.ReturnStatus
                ; проверка исходного конца фрагмента
                ASSERT $ == #EB27
                endmodule
                endmodule
