                module Flight
                module IndexNextPauseTable
; -----------------------------------------
; Переход к следующей таблице команд паузы
; исходный диапазон #72D4..#72D4
; In:
;   HL указывает нулевой разделитель предыдущей таблицы, A=символ
; Out:
;   HL увеличен на 1, далее общий поиск Game.Flight.IndexPauseCommandAndHandlers.Entry
; Corrupt:
;   HL, BC, AF
; Note:
;   Этот вход связывает две последовательные таблицы ключ-значение
; -----------------------------------------
                ASSERT $ == #72D4
                ; пропуск разделителя перед второй таблицей клавиш
Entry:          INC HL                                                          ; далее Game.Flight.IndexPauseCommandAndHandlers.Entry без команды перехода
                ASSERT $ == #72D5
                endmodule
                endmodule
