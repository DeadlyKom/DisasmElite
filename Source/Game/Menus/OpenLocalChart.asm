                module Menus
                module OpenLocalChart
; -----------------------------------------
; Построение местной карты с двумя проходами по системам
; исходный диапазон #EC58..#ECD1
; In:
;   State.SystemSeed + FSystemSeed.X/State.SystemSeed + FSystemSeed.Y = координаты текущей системы, State.Fuel = топливо
; Out:
;   Показаны звёзды, имена, круг дальности и малый курсор
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   Обнуляет 24 признака занятости строк ProjectedVerts + 16, вычисляет насыщенные границы X±19, Y±34 и
;   записывает их в CP по LocalMapLeft/LocalMapRight/LocalMapTop/LocalMapBottom, первый проход рисует звёзды через Game.Menus.LocalSystemPixelPosition.PlotStar, второй
;   имена через Game.Menus.PlaceLocalSystemLabel.Entry
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #EC58
                ; расчёт прямоугольника местной карты вокруг текущей системы с насыщением границ
Entry:          XOR A
                LD B, #18
                LD HL, ProjectedVerts + 16
ClearRowUsage:  LD (HL), A
                INC HL
                DJNZ ClearRowUsage

                CALL Game.Text.ClearViewAndFrame.Entry
                LD A, #BE
                CALL Game.Menus.MapCaptionAndGalaxyChart.Entry
                CALL Game.Text.SetPromptAttributes.Entry
                LD A, (State.SystemSeed + FSystemSeed.X)
                SUB #13
                CALL C, Game.Menus.ReturnZero.Entry                             ; вызов, если вычитание 19 из X дало заём, ограничить левую границу нулём
                LD (LocalMapLeft), A
                LD A, (State.SystemSeed + FSystemSeed.X)
                ADD A, #13
                CALL C, Game.Menus.Return255.Entry                              ; вызов, если прибавление 19 к X переполнилось, ограничить правую границу 255
                LD (LocalMapRight), A
                LD A, (State.SystemSeed + FSystemSeed.Y)
                SUB #22
                CALL C, Game.Menus.ReturnZero.Entry                             ; вызов, если вычитание 34 из Y дало заём, ограничить верхнюю границу нулём
                LD (LocalMapTop), A
                LD A, (State.SystemSeed + FSystemSeed.Y)
                ADD A, #22
                CALL C, Game.Menus.Return255.Entry                              ; вызов, если прибавление 34 к Y переполнилось, ограничить нижнюю границу 255
                LD (LocalMapBottom), A
                ; два прохода по 256 системам отдельно рисуют звёзды и размещают подписи
                LD A, #18
                LD (MapViewport.Top), A
                LD A, #A7
                LD (MapViewport.Bottom), A
                LD A, #18
                LD (MapViewport.CrosshairSize), A
                LD A, #61
                LD (MapCircleX), A
                LD A, #60
                LD (MapCircleY), A
                CALL Game.Charts.XorMapCrosshair.Entry
                LD HL, Game.Menus.LocalSystemPixelPosition.PlotStar
                CALL Game.Menus.VisitLocalChartSystems.Entry
                LD HL, Game.Menus.PlaceLocalSystemLabel.Entry
                CALL Game.Menus.VisitLocalChartSystems.Entry
                LD A, (State.Fuel)
                LD (MapRadius), A
                CALL Game.Flight.DispatchChartCircle.Entry
                LD A, #10
                LD (MapViewport.CrosshairSize), A
                JP Game.Charts.MapCursorTransformAndKeys.Entry

                ; проверка исходного конца фрагмента
                ASSERT $ == #ECD2
                endmodule
                endmodule
