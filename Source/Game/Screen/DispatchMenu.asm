                module Screen
                module DispatchMenu
; -----------------------------------------
; вызов обработчика меню через самомодифицируемую команду CALL
; In:
;   AF, A содержит индекс действия в таблице #D000
; Out:
;   стек возвращён к сохранённому уровню
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   сохраняет SP в #80D1 и рассчитывает адрес команды JP как #D000 + 3*A
;   адрес записывается в два байта операнда CALL по #8154
;   после обработчика SP восстанавливается независимо от использованных вложенных выходов
;   последний JP #94FE очищает клавиатурные события
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #813E
                ; сохранение уровня стека перед обработчиком с общими выходами
Entry:          LD (MenuDispatch.SavedSP), SP
                NOP
                NOP
                NOP
                ; расчёт адреса трёхбайтного элемента таблицы
                LD B, A
                ADD A, A
                ADD A, B
                LD HL, Game.Interface.MenuDispatchTable.Entry                   ; первый трёхбайтовый JP диспетчера информационных экранов
                ADD A, L
                LD L, A
                JR NC, PatchMenuCall                                            ; переход, если сложение младшего байта не вызвало переноса

                INC H
                ; обновление операнда CALL выбранным адресом
PatchMenuCall:  LD (MenuDispatch.Target), HL
MenuAddress     EQU $ + 1                                                       ; адрес вызываемого обработчика меню в операнде CALL
                CALL Game.Interface.DispatchStatusAndChartKeys.Entry
                ; восстановление стека и очистка событий клавиатуры
                LD SP, (MenuDispatch.SavedSP)
                JP Game.Flight.ClearFlightKeyEvents.Entry
                ASSERT $ == #815D
                endmodule
                endmodule
