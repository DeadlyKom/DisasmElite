; -----------------------------------------
; Совместимая подстановка форматирующего токена
; исходный диапазон #E6CD..#E6D1
; In:
;   текстовый вывод Game.Text.PrintDescriptionToken.Entry
; Out:
;   выведен токен 96 вторичной таблицы, байты 09,0B,01,08
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Подменяет вызовы Game.Menus.OpenCommanderStatus.FormatCall и Game.Menus.PrintStatusFieldAndCargoScreen.FormatCall, код 96 передаётся как номер вторичной таблицы
;   Точная копия исходного Game.Trade.TradeTitleAndSellLoop.Entry, который перекрыт оверлеем, токен содержит управляющие коды
;   форматирования и сигнала
; -----------------------------------------
                ; сохранённая копия Game.Trade.TradeTitleAndSellLoop.Entry раскрывает форматирующий токен 96
FormatToken:    LD A, #96
                JP @Game.Text.PrintDescriptionToken.Entry
