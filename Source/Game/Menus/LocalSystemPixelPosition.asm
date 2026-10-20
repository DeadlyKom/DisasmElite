                module Menus
                module LocalSystemPixelPosition
; -----------------------------------------
; Экранная позиция планеты на местной карте
; исходный диапазон #ECFD..#ED5F
; In:
;   DEC1/DEC3 = координаты планеты, D097/D099 = центр
; Out:
;   BC = координаты для ROM22AA, HL = адрес пикселя, A = бит
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   X=98+4*dx, B=75-2*dy в координатах ROM, ED27 отдельный обработчик звезды использует размер
;   из DEC5 и сам продвигает семя, ED59..ED5F таблица данных
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #ECFD
                ; масштабирование координат выбранной системы относительно центра местной карты
Entry:          LD C, #61
                LD A, (State.SystemSeed + FSystemSeed.X)
                LD B, A
                LD A, (GalaxyState.WorkingSeed + FSystemSeed.X)
                SUB B
                SLA A
                SLA A
                ADD A, C
                ADD A, #01
                LD C, A
                LD D, #60
                LD A, (State.SystemSeed + FSystemSeed.Y)
                LD B, A
                LD A, (GalaxyState.WorkingSeed + FSystemSeed.Y)
                SUB B
                SLA A
                NEG
                ADD A, D
                SUB #15
                LD B, A
                PUSH BC
                CALL Rom.PlotAddress
                POP BC
                RET

                ; рисование звезды местной карты с временной заменой операции в #FB00
PlotStar:       CALL Entry
                LD A, H
                EX AF, AF'
                LD HL, Game.Extensions.OrSpriteByte.Entry
                LD (HL), #AE
                PUSH HL
                LD A, (GalaxyState.WorkingSeed + FSystemSeed.Syllable)
                AND #0C
                RRA
                RRA
                JR NZ, StarRadius                                               ; переход, если пара бит размера звезды ненулевая, не увеличивать её принудительно

                INC A
StarRadius:     ADD A, #02
                PUSH AF
                PUSH BC
                CALL Game.Extensions.BuildSmallCircleProfile.Entry
                POP BC
                POP AF
                SUB B
                NEG
                ADD A, #04
                LD B, A
                PUSH DE
                CALL Rom.PlotAddress
                POP DE
                CALL Game.Extensions.DrawSmallSilhouette.DrawRaster
                POP HL
                LD (HL), #B6
                JP Game.Galaxy.AdvanceSystemSeed.Entry
                ; параметры малых кругов, BuildSmallCircleProfile читает их по радиусу 2..8
StarProfile     DB #81, #41, #42, #22, #23, #13, #14                            ; семь параметров малого круга, индексы радиуса 2..8
                ; проверка исходного конца фрагмента
                ASSERT $ == #ED60
                endmodule
                endmodule
