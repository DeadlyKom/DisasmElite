                module Trade
                module EquipmentAlreadyOwned
; -----------------------------------------
; Отказ повторной установки и откат
; исходный диапазон #EB43..#EB62
; In:
;   EB43 выбирает текст 7C, EB47 выбирает 68+E8AB
; Out:
;   Снимок восстановлен, открыт экран пилота
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   После имени устройства печатает 1E, выполняет сигнал и паузу, откатывает списание,
;   EB5E..EB62 содержат предел, индекс, указатель цены и тип лазера
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
                ; максимальный номер разрешённого оборудования
ItemLimit       DB #00                                                          ; наибольший номер разрешённого оборудования
                ; текущий номер пункта при печати оборудования
ItemIndex       DB #00                                                          ; номер пункта при выводе списка оборудования
                ; указатель текущей трёхбайтовой цены оборудования
PriceCursor     DW #0000                                                        ; адрес текущей трёхбайтовой цены оборудования
                ; код выбранного типа лазера
LaserType       DB #00                                                          ; код выбранного типа лазера
                ; проверка исходного конца фрагмента
                ASSERT $ == #EB63
                endmodule
                endmodule
