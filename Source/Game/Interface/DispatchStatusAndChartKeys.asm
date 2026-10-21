                module Interface
                module DispatchStatusAndChartKeys
; -----------------------------------------
; Таблица переходов обработчиков экранов и карты
; исходный диапазон #D015..#D032
; In:
;   AF и глобальное состояние по контракту выбранного обработчика
; Out:
;   Управление передано выбранному обработчику
; Corrupt:
;   По контракту выбранного обработчика
; Note:
;   Game.Interface.DispatchStatusAndChartKeys.Entry открывает состояние пилота, Game.Interface.DispatchStatusAndChartKeys.OpenCargo грузовой отсек, Game.Interface.DispatchStatusAndChartKeys.CursorLeft/Game.Interface.DispatchStatusAndChartKeys.CursorRight меняют X, Game.Interface.DispatchStatusAndChartKeys.CursorDown/Game.Interface.DispatchStatusAndChartKeys.CursorUp меняют
;   Y, Game.Interface.DispatchStatusAndChartKeys.CurrentSystem возвращает курсор к текущей системе, Game.Interface.DispatchStatusAndChartKeys.SelectSystem выбирает ближайшую планету, Game.Interface.DispatchStatusAndChartKeys.FindSystem ищет по
;   имени, Game.Interface.DispatchStatusAndChartKeys.NextGalaxy меняет галактику
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D015
Entry:          JP Game.Menus.OpenCommanderStatus.Entry

                ; продолжение таблицы трёхбайтовых векторов экранов и клавиш карты
OpenCargo:      JP @Game.Menus.PrintStatusFieldAndCargoScreen.CargoScreen

CursorLeft:     JP Game.Charts.MapCursorTransformAndKeys.CursorLeft

CursorRight:    JP Game.Charts.MapCursorTransformAndKeys.CursorRight

CursorDown:     JP Game.Charts.MapCursorTransformAndKeys.CursorDown

CursorUp:       JP Game.Charts.MapCursorTransformAndKeys.CursorUp

CurrentSystem:  JP Game.Charts.MapCursorTransformAndKeys.CurrentSystem

SelectSystem:   JP Game.Charts.TextInputLoop.SelectSystem

FindSystem:     JP Game.Charts.FindSystemNameDialog.Entry

NextGalaxy:     JP Game.Galaxy.AdvanceGalaxySeed.Entry

                ; проверка исходного конца фрагмента
                ASSERT $ == #D033
                endmodule
                endmodule
