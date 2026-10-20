                module Menus
                module CompareSystemSeedToGalaxyBase
; -----------------------------------------
; Побайтное сравнение шести байтов с базовым семенем галактики
; исходный диапазон #EF37..#EF86
; In:
;   HL = проверяемое семя
; Out:
;   CY=0 при равенстве, CY=1 при первом отличии
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Равный путь оставляет HL+6, DE=D096, B=0, EF48 отдельный экран цен перебирает 17 товаров и
;   запрещает список в межзвёздном пространстве 7103!=0
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #EF37
                ; шесть байтов сравниваются до первого отличия, исходные указатели не сохраняются
Entry:          LD DE, State.GalaxySeed
                LD B, #06
CompareByte:    LD A, (DE)
                CP (HL)
                JR NZ, DifferentSeeds                                           ; переход, если очередные байты семян различаются, вернуть перенос

                INC DE
                INC HL
                DJNZ CompareByte

                AND A
                RET

DifferentSeeds: SCF
                RET

                ; экран рыночных цен с последовательным выводом 17 товаров
MarketPrices:   CALL Game.Trade.ResetCloakingAndSeedFlightRandom.PrepareBuy
                CALL Game.Trade.TradeTitleAndSellLoop.Entry
                LD A, #A7
                CALL Game.Trade.PrintScreenCaption.Entry
                LD HL, #0310
                LD (TextColumn), HL
                LD A, #FF
                CALL Game.Trade.PrintTokenNewline.Entry
                LD DE, GalaxyFormat
                CALL Game.Text.ApplyAttributeRuns.Entry
                LD A, (FlightState.SpaceMode)
                AND A
                RET NZ                                                          ; выход, если включён режим межзвёздного пространства, рынок недоступен

                XOR A
                LD (MarketWork.Commodity), A
                LD HL, BeforePrices
                LD (MarketWork.PriceCursor), HL
                LD HL, State.Government
                LD (MarketWork.StockCursor), HL
MarketRow:      CALL Game.Trade.PrintMarketRow.Entry
                LD HL, MarketWork.Commodity
                INC (HL)
                LD A, (HL)
                CP #11
                JR C, MarketRow                                                 ; переход, если индекс товара меньше 17, напечатать следующую строку рынка

                RET
                ; сохранённый байт 03 между экраном рынка и экраном командира
                DB #03                                                          ; #EF86..#EF86
                ; проверка исходного конца фрагмента
                ASSERT $ == #EF87
                endmodule
                endmodule
