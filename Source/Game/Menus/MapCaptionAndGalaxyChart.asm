                module Menus
                module MapCaptionAndGalaxyChart
; -----------------------------------------
; Заголовок карты и экран всей галактики
; исходный диапазон #EB63..#EBED
; In:
;   AF, A = токен заголовка для Game.Menus.MapCaptionAndGalaxyChart.Entry
; Out:
;   заголовок выведен, вход GalaxyChart строит карту 256 систем
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   Game.Menus.MapCaptionAndGalaxyChart.Entry печатает заголовок, заполняет 64 атрибута цветом 17 и рисует линию Memory.Screen + #0740, GalaxyChart задаёт
;   границы карты, рисует большой курсор и круг топлива, затем 256 раз вызывает Game.Menus.PlotGalaxySystem.Entry с четырьмя
;   шагами семени между планетами
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #EB63
                ; общий заголовок карты выводит номер галактики и рамку окна
Entry:          PUSH AF
                CALL Game.Trade.SetInlineTextColumn.Entry
                DB #06                                                          ; аргумент вызываемой процедуры из потока команд
                POP AF
                CALL Game.Trade.PrintScreenCaption.Entry
                LD A, #17
                LD HL, Memory.Attributes + #0020                                ; атрибуты со второй символьной строки
                LD B, #40
                CALL Game.Text.FillBytes.Entry
                LD HL, Memory.Screen + #0740                                    ; пиксельная строка под заголовком карты
                JP Game.Text.DrawFullWidthRule.Entry

                ; вход построения общей карты, очистка окна и ширина перекрестия 24
GalaxyChart:    CALL Game.Text.ClearViewAndFrame.Entry
                LD A, #18
                LD (MapViewport.Top), A
                ; перебор всех систем для общей карты с последующим возвратом выбранного семени
                LD A, #98
                LD (MapViewport.Bottom), A
                LD A, #10
                LD (MapViewport.CrosshairSize), A
                LD A, (State.SystemSeed + FSystemSeed.X)
                LD (MapCircleX), A
                LD A, (State.SystemSeed + FSystemSeed.Y)
                SRL A
                ADD A, #18
                LD (MapCircleY), A
                CALL Game.Charts.XorMapCrosshair.Entry
                LD A, (State.Fuel)
                SRL A
                SRL A
                LD (MapRadius), A
                CALL Game.Flight.DispatchChartCircle.Entry
                LD HL, Memory.Screen + #0060                                    ; начало очистки двух символьных строк карты
                LD A, #02
                CALL Game.Menus.ClearCharacterRowsBackward.Entry
                LD HL, Memory.Screen + #1100                                    ; начало очистки пяти символьных строк под картой
                LD A, #05
                CALL Game.Menus.ClearCharacterRowsBackward.Entry
                CALL Game.Text.DrawViewFrame.Entry
                LD A, #0A
                LD (MapViewport.CrosshairSize), A
                CALL Game.Charts.MapCursorTransformAndKeys.Entry
                LD A, #C7
                CALL Game.Menus.MapCaptionAndGalaxyChart.Entry
                LD A, #17
                LD HL, Memory.Attributes + #0260                                ; атрибуты пяти нижних строк карты
                LD B, #A0
                CALL Game.Text.FillBytes.Entry
                LD HL, Memory.Screen + #1060                                    ; горизонтальная разделительная линия карты
                CALL Game.Text.DrawFullWidthRule.Entry
                CALL Game.Galaxy.LoadGalaxySeed.Entry
                LD B, #00
PlotSystem:     PUSH BC
                CALL Game.Menus.PlotGalaxySystem.Entry
                CALL Game.Galaxy.AdvanceSystemSeed.Entry
                POP BC
                DJNZ PlotSystem

                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #EBEE
                endmodule
                endmodule
