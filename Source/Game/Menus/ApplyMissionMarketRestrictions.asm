                module Menus
                module ApplyMissionMarketRestrictions
; -----------------------------------------
; Коррекция рынка и миссионного состояния в особых системах
; исходный диапазон #EEDB..#EF00
; In:
;   Галактика, координаты, D08F/D087 и состояние миссий
; Out:
;   Возможны нулевые запасы D09F, D0A8, D0AA и изменение D0AF
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   В галактике 0 проверяет специальную полосу EC40 и сохранённую планету D675, затем D5B4
;   определяет запрет товара D0AA, NOP после D675 является встроенным нулевым порогом
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #EEDB
                ; военная область изменяет запасы продовольствия и оружия, живая колония запрещает покупку
                ; минералов
Entry:          LD A, (State.Galaxy)
                AND A
                JR NZ, CheckMinerals                                            ; переход, если галактика не первая, военные ограничения рынка не применяются

                CALL Game.Menus.CheckMissionRegionBand.Entry
                JR NC, CheckRegion                                              ; переход, если планета вне полосы сопротивления, запасы продовольствия и оружия не обнуляются

                XOR A
                LD (State.MarketStock + FGoods.Textiles), A
                LD (State.MarketStock + FGoods.Firearms), A
CheckRegion:    CALL Game.Text.CheckSavedSystemRegion.Entry
                NOP
                LD A, #04
                JR C, StoreInvasion                                             ; переход, если сохранённая планета попала в оккупированную область, установить состояние 4

                XOR A
StoreInvasion:  LD (State.Mission3), A
CheckMinerals:  CALL Game.Text.CheckMineralLifeColony.Entry
                RET NZ                                                          ; выход, если колония MINERAL LIFE не активна, обычный рынок минералов сохраняется

                LD (State.MarketStock + FGoods.Minerals), A
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #EF01
                endmodule
                endmodule
