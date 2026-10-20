                module Extensions
                module UpdateSpecialCargoStatus
; -----------------------------------------
; обновление состояния специального груза после меню
; исходный диапазон #6EBC..#6ED3
; смысловое имя UpdateSpecialCargoStatus
; In: #D077 и #D07A — сравниваемые количества, состояние задания проверяет #EEDB
; Out: при Z из #EEDB разность #D07A-#D077 записана в #D07A либо #D087
; Corrupt: HL, DE, BC, AF по контракту вызываемых процедур
; Если #D07A<#D077, сначала L меняется на #87 и C=1 запрещает звуковой сигнал
; Иначе запись выполняется по текущему L=#7A и вызывается сигнал #7344
; Разные адреса записи в двух ветвях являются частью оригинального алгоритма
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #6EBC
                ; миссия 4 MINERAL LIFE, расчёт кормления колонии драгоценными камнями
                ; описание в Docs/Manual.md, раздел mission-4
                ; сброс скорости и углов перед проверкой состояния меню
Entry:          CALL Game.Flight.ResetFlightControls.Entry
                CALL Game.Menus.ApplyMissionMarketRestrictions.Entry
                RET NZ                                                          ; выход, если проверка состояния #EEDB завершилась ненулевым результатом

                ; расчёт разности двух грузовых полей с различным адресом записи
                LD HL, State.Cargo + FGoods.Minerals
                LD B, (HL)
                LD L, #7A
                LD A, (HL)
                SUB B
                JR NC, StoreBalance                                             ; переход, если #D07A не меньше #D077, сохранить разность в #D07A

                LD L, #87
StoreBalance:   LD (HL), A
                RET C                                                           ; выход, если #D07A меньше #D077, разность уже записана в #D087

                JP Game.Flight.PlaySweepingBeeperAndBootstrap.Entry
                ; проверка исходного конца фрагмента
                ASSERT $ == #6ED4
                endmodule
                endmodule
