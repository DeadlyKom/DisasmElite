                module Menus
                module ApplyMissionMarketRestrictions
; -----------------------------------------
; Коррекция рынка и миссионного состояния в особых системах
; исходный диапазон #EEDB..#EF00
; In:
;   Галактика, координаты, State.Invasion/State.MineralLife и состояние миссий
; Out:
;   Возможны нулевые запасы State.MarketStock + FGoods.Textiles, State.MarketStock + FGoods.Firearms, State.MarketStock + FGoods.Minerals и изменение State.Mission3
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   В галактике 0 проверяет специальную полосу Game.Menus.CheckMissionRegionBand.Entry и сохранённую планету Game.Text.CheckSavedSystemRegion.Entry, затем Game.Text.CheckMineralLifeColony.Entry
;   определяет запрет товара State.MarketStock + FGoods.Minerals, NOP после Game.Text.CheckSavedSystemRegion.Entry является встроенным нулевым порогом
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #EEDB
                ; военная область изменяет запасы продовольствия и оружия, живая колония запрещает покупку
                ; минералов
                ; миссии 7 INVASION, 7+2, военная область ограничивает рынок и устанавливает общее состояние 4 либо 0
                ; описание в Docs/Manual.md, раздел mission-7-invasion, mission-7-2
Entry:          LD A, (State.Galaxy)
                AND A
                JR NZ, CheckMinerals                                            ; переход, если галактика не первая, военные ограничения рынка не применяются

                CALL Game.Menus.CheckMissionRegionBand.Entry
                JR NC, CheckRegion                                              ; переход, если планета вне полосы сопротивления, запасы текстиля и оружия не обнуляются

                XOR A
                LD (State.MarketStock + FGoods.Textiles), A
                LD (State.MarketStock + FGoods.Firearms), A
CheckRegion:    CALL Game.Text.CheckSavedSystemRegion.Entry
                NOP
                LD A, #04
                JR C, StoreInvasion                                             ; переход, если сохранённая планета попала в оккупированную область, установить состояние 4

                XOR A
StoreInvasion:  LD (State.Mission3), A
                ; миссия 4 MINERAL LIFE, живая колония обнуляет рыночный остаток минералов
                ; описание в Docs/Manual.md, раздел mission-4
CheckMinerals:  CALL Game.Text.CheckMineralLifeColony.Entry
                RET NZ                                                          ; выход, если колония MINERAL LIFE не активна, обычный рынок минералов сохраняется

                LD (State.MarketStock + FGoods.Minerals), A
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #EF01
                endmodule
                endmodule
