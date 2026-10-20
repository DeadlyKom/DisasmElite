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
;   D015 открывает состояние пилота, D018 грузовой отсек, D01B/D01E меняют X, D021/D024 меняют
;   Y, D027 возвращает курсор к текущей системе, D02A выбирает ближайшую планету, D02D ищет по
;   имени, D030 меняет галактику
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
