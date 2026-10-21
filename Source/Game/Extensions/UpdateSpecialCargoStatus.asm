                module Extensions
                module UpdateSpecialCargoStatus
; -----------------------------------------
; обновление состояния специального груза после меню
; исходный диапазон #6EBC..#6ED3
; смысловое имя UpdateSpecialCargoStatus
; In: State.Cargo + FGoods.Minerals и State.Cargo + FGoods.Gemstones — сравниваемые количества, состояние задания проверяет Game.Menus.ApplyMissionMarketRestrictions.Entry
; Out: при Z из ApplyMissionMarketRestrictions разность количеств Gemstones и Minerals записана в State.Cargo + FGoods.Gemstones либо State.MineralLife
; Corrupt: HL, DE, BC, AF по контракту вызываемых процедур
; если драгоценных камней меньше минералов, L выбирает State.MineralLife, перенос запрещает звуковой сигнал
; Иначе запись выполняется по текущему L=#7A и вызывается сигнал Game.Flight.PlaySweepingBeeperAndBootstrap.Entry
; Разные адреса записи в двух ветвях являются частью оригинального алгоритма
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #6EBC
                ; миссия 4 MINERAL LIFE, расчёт кормления колонии драгоценными камнями
                ; описание в Docs/Manual.md, раздел mission-4
                ; сброс скорости и углов перед проверкой состояния меню
Entry:          CALL Game.Flight.ResetFlightControls.Entry
                CALL Game.Menus.ApplyMissionMarketRestrictions.Entry
                RET NZ                                                          ; выход, если проверка состояния Game.Menus.ApplyMissionMarketRestrictions.Entry завершилась ненулевым результатом

                ; расчёт разности двух грузовых полей с различным адресом записи
                LD HL, State.Cargo + FGoods.Minerals
                LD B, (HL)
                LD L, #7A
                LD A, (HL)
                SUB B
                JR NC, StoreBalance                                             ; переход, если State.Cargo + FGoods.Gemstones не меньше State.Cargo + FGoods.Minerals, сохранить разность в State.Cargo + FGoods.Gemstones

                LD L, #87
StoreBalance:   LD (HL), A
                RET C                                                           ; выход, если State.Cargo + FGoods.Gemstones меньше State.Cargo + FGoods.Minerals, разность уже записана в State.MineralLife

                JP Game.Flight.PlaySweepingBeeperAndBootstrap.Entry

                ; проверка исходного конца фрагмента
                ASSERT $ == #6ED4
                endmodule
                endmodule
