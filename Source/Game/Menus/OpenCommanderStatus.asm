                module Menus
                module OpenCommanderStatus
; -----------------------------------------
; Экран состояния командира
; исходный диапазон #EF87..#EFC4
; In:
;   Сериализуемое состояние D054..D0B9
; Out:
;   70E3=11, показан заголовок и начало сведений пилота
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   Настраивает атрибуты FD8E, вызывает расширения F90E/8D38, выводит поля 2/3 и сообщения 5/7,
;   дальше без RET продолжается EFC5
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #EF87
                ; режим 11 включает экран состояния, заголовок, цветовую схему и расширенные сведения
Entry:          LD A, #0B
                LD (FlightState.View), A
FormatCall      EQU $ + 1                                                       ; операнд CALL форматирования экрана командира
                CALL Game.Trade.TradeTitleAndSellLoop.Entry
                CALL Game.Flight.DispatchDangerIndicator.Entry
                LD DE, StatusFormat
                CALL Game.Text.ApplyAttributeRuns.Entry
                ; имя пилота и признак Cobra Mk4 печатаются до стандартных полей состояния
                CALL Game.Extensions.SetExtendedTextCursor.Entry
                NOP
                CALL Game.Text.PrintInlineToken.Entry
                DB #7E                                                          ; аргумент вызываемой процедуры из потока команд
                CALL Game.Circles.PrintShipAndContinueRightFill.Entry
                NOP
                NOP
                ; два поля состояния выводятся последовательно через общий обработчик F0A1
                LD A, #02
                CALL Game.Menus.PrintStatusFieldAndCargoScreen.Entry
                LD A, #03
                CALL Game.Menus.PrintStatusFieldAndCargoScreen.Entry
                LD A, #06
                CALL Game.Trade.SetTextRow.Entry
                CALL Game.Text.PrintInlineToken.Entry
                DB #05                                                          ; аргумент вызываемой процедуры из потока команд
                CALL Game.Text.PrintInlineToken.Entry
                DB #07                                                          ; аргумент вызываемой процедуры из потока команд
                LD A, #71
                CALL Game.Trade.PrintDescriptionColon.Entry
                CALL Game.Text.PrintInlineToken.Entry
                DB #20                                                          ; аргумент вызываемой процедуры из потока команд
                ; проверка исходного конца фрагмента
                ASSERT $ == #EFC5
                endmodule
                endmodule
