                module Menus
                module PrintStatusFieldAndCargoScreen
; -----------------------------------------
; Вывод поля состояния и начало экрана трюма
; исходный диапазон #F0A1..#F0EA
; In:
;   AF, A = токен поля для F0A1
; Out:
;   Поле выведено после двоеточия при X=21
; Corrupt:
;   HL, DE, BC, AF, AF'
; Note:
;   A сохраняется в альтернативном AF, F0AE..F0B7 таблицы рейтинга, F0B8 отдельный экран трюма
;   ставит 70E3=12, оформляет заголовок и проверяет расширенный трюм D084
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #F0A1
                ; номер поля определяет пару токенов стандартного экрана командира
Entry:          EX AF, AF'
                CALL Game.Trade.SetInlineTextColumn.Entry
                DB #15                                                          ; аргумент вызываемой процедуры из потока команд
                CALL Game.Text.PrintInlineToken.Entry
                DB #3A                                                          ; аргумент вызываемой процедуры из потока команд
                EX AF, AF'
                JP Game.Trade.PrintTokenNewline.Entry
                ; пороги младшей части рейтинга, 08,10,20,40,80,FF
RankLowLimits   DB #08, #10, #20, #40, #80, #FF                                 ; пороги младшего байта боевого рейтинга
                ; пороги старшей части рейтинга, 02,0A,19,FF
RankHighLimits  DB #02, #0A, #19, #FF                                           ; пороги старшего байта боевого рейтинга
                ; отдельный вход экрана грузового отсека перечисляет содержимое и суммарную вместимость
CargoScreen:    LD A, #0C
                LD (FlightState.View), A
FormatCall      EQU $ + 1                                                       ; операнд CALL форматирования экрана груза
                CALL Game.Trade.TradeTitleAndSellLoop.Entry
                LD A, #A4
                CALL Game.Trade.PrintScreenCaption.Entry
                LD DE, CargoFormat
                CALL Game.Text.ApplyAttributeRuns.Entry
                LD A, #03
                CALL Game.Trade.SetTextRow.Entry
                CALL Game.Text.PrintInlineToken.Entry
                DB #05                                                          ; аргумент вызываемой процедуры из потока команд
                LD A, #07
                CALL Game.Trade.PrintTokenNewline.Entry
                LD A, (State.LargeCargo)
                AND A
                JR Z, Game.Extensions.PrintCargoAndMessageBanks.Entry           ; переход, если расширенный трюм не установлен, перейти к печати обычной вместимости

                LD HL, Memory.Attributes + #00C1                                ; первое внутреннее знакоместо строки списка груза
                LD A, #05
                CALL Game.Text.FillInnerAttributeRow.Entry
                CALL Game.Text.PrintInlineToken.Entry
                DB #6B                                                          ; аргумент вызываемой процедуры из потока команд
                ; проверка исходного конца фрагмента
                ASSERT $ == #F0EB
                endmodule
                endmodule
