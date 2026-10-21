                module Trade
                module EquipmentAlreadyOwned
; -----------------------------------------
; Отказ повторной установки и откат
; исходный диапазон #EB43..#EB62
; In:
;   Game.Trade.EquipmentAlreadyOwned.Entry выбирает текст 7C, Game.Trade.EquipmentAlreadyOwned.PrintItemError выбирает 68+TradeSnapshot.Selection
; Out:
;   Снимок восстановлен, открыт экран пилота
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   После имени устройства печатает 1E, выполняет сигнал и паузу, откатывает списание,
;   EquipmentWork содержит предел, индекс, указатель цены и тип лазера
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #EB43
                ; при повторной покупке выводится отказ, далее используется общий денежный откат
Entry:          LD A, #7C
                JR ShowError

PrintItemError: LD A, #68
                LD B, A
                LD A, (TradeSnapshot.Selection)
                ADD A, B
ShowError:      CALL Game.Trade.PrintMainTokenSpace.Entry
                CALL Game.Text.PrintInlineToken.Entry
                DB #1E                                                          ; аргумент вызываемой процедуры из потока команд
                CALL Game.Trade.TradeBeepAndPause.Entry
                CALL Game.Trade.RestoreTradeSnapshot.Entry
ReturnStatus:   JP Game.Menus.OpenCommanderStatus.Entry

                ; состояние списка и покупки оборудования
EquipmentData   FEquipmentWork {
                    #00,                                                        ; FEquipmentWork.ItemLimit, наибольший номер разрешённого оборудования
                    #00,                                                        ; FEquipmentWork.ItemIndex, номер пункта при выводе списка оборудования
                    #0000,                                                      ; FEquipmentWork.PriceCursor, адрес текущей трёхбайтовой цены оборудования
                    #00                                                         ; FEquipmentWork.LaserType, код выбранного типа лазера
                }
                ASSERT $ - EquipmentData == FEquipmentWork

                ; прежние имена указывают на поля экземпляра EquipmentData
ItemLimit       EQU EquipmentData.ItemLimit                                     ; поле FEquipmentWork.ItemLimit
ItemIndex       EQU EquipmentData.ItemIndex                                     ; поле FEquipmentWork.ItemIndex
PriceCursor     EQU EquipmentData.PriceCursor                                   ; поле FEquipmentWork.PriceCursor
LaserType       EQU EquipmentData.LaserType                                     ; поле FEquipmentWork.LaserType
                ; проверка исходного конца фрагмента
                ASSERT $ == #EB63
                endmodule
                endmodule
