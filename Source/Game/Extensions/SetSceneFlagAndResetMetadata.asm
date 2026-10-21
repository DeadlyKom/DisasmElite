                module Extensions
                module SetSceneFlagAndResetMetadata
; -----------------------------------------
; сохранение флага сцены перед сбросом метаданных
; исходный диапазон #F9A8..#F9AA
; смысловое имя SetSceneFlagAndResetMetadata
; In: AF — A содержит новое значение FastTravel
; Out: после записи выполнение продолжается по Game.Extensions.ResetObjectMetadata.Entry
; Corrupt: по контракту продолжения Game.Extensions.ResetObjectMetadata.Entry
; Граница файла не является возвратом, следующий вход выполняется обязательно
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #F9A8
                ; обновление флага сцены перед общим сбросом
Entry:          LD (FastTravel), A                                              ; далее Game.Extensions.ResetObjectMetadata.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #F9AB
                endmodule
                endmodule
