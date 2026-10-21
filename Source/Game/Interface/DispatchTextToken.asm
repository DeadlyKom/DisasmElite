                module Interface
                module DispatchTextToken
; -----------------------------------------
; Вектор печати токена основной таблицы
; исходный диапазон #D048..#D04D
; In:
;   AF, A = символ либо токен
; Out:
;   Переход в Game.Text.PrintMainToken.Entry
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   GlyphPatch хранит адрес Game.Text.XorCharacterScanlines.XorOpcode, следующий байт сохранён как состояние, после JP эти данные не исполняются
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D048
Entry:          JP Game.Text.PrintMainToken.Entry

                ; сохранённое слово Game.Text.XorCharacterScanlines.XorOpcode, адрес изменяемой операции глифа
GlyphPatch      DW #D548                                                        ; сохранённый адрес изменяемой команды рисования глифа
                ; сохранённый байт перед вектором дискового меню
                DB #00                                                          ; #D04D..#D04D
                ; проверка исходного конца фрагмента
                ASSERT $ == #D04E
                endmodule
                endmodule
