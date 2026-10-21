                module Charts
                module TextInputLoop
; -----------------------------------------
; Обработка букв, цифр, удаления и завершения ввода
; исходный диапазон #E3E7..#E46E
; In:
;   Настройки и указатели подготовлены Game.Charts.BeginTextInput.Entry
; Out:
;   В буфере строка с нулём, TextInput = длина
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Разрешает ASCII0..9 и @..Z, FE удаляет последний символ, ENTER и код меньше 30 завершают
;   ввод, предел CP InputLimit самомодифицируемый, после завершения ждёт отпускания ENTER, Game.Charts.TextInputLoop.SelectSystem
;   отдельно выбирает ближайшую планету и печатает её данные
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E3E7
                ; цикл клавиатурного ввода принимает цифры и латинские заглавные буквы
Entry:          LD A, (InputPrompt)
                CALL Game.Text.PrintDescriptionToken.Entry
ReadKey:        CALL Game.Trade.WaitForKeyCode.Entry
                LD (TextInput.LastKey), A
                CP #0D
                JR Z, EndInput                                                  ; переход, если нажат ENTER, завершить строковый ввод

                CP #FE
                JR Z, DeleteChar                                                ; переход, если нажато удаление FE, стереть последний символ

                LD A, (TextInput.LastKey)
                CP #30
                JR C, EndInput                                                  ; переход, если код клавиши меньше цифры 0, закончить ввод

                CP #5B
                JR NC, ReadKey                                                  ; переход, если код клавиши не меньше [, символ вне разрешённого алфавита

                CP #3A
                JR C, CheckLength                                               ; переход, если код находится в диапазоне цифр 0..9, принять его

                CP #40
                JR C, ReadKey                                                   ; переход, если код между 3A и 3F, пропустить запрещённый знак

                ; проверка максимальной длины предшествует записи очередного символа
CheckLength:    LD D, A
                LD A, (TextInput.Length)
LengthLimit     EQU $ + 1                                                       ; изменяемый предел длины строки в операнде CP
                CP #0A
                JR NC, EndInput                                                 ; переход, если уже введено десять символов, закончить ввод

                INC A
                LD (TextInput.Length), A
                LD A, D
                LD HL, (TextInput.Cursor)
                LD (HL), A
                INC HL
                LD (TextInput.Cursor), HL
                CALL Game.Text.PrintMainToken.Entry
                JR ReadKey

                ; удаление уменьшает длину, возвращает курсор и стирает прежний символ
DeleteChar:     LD A, (TextInput.Length)
                AND A
                JR Z, ReadKey                                                   ; переход, если строка пуста, удалять нечего

                DEC A
                LD (TextInput.Length), A
                LD HL, (TextInput.Cursor)
                DEC HL
                LD (TextInput.Cursor), HL
                CALL Game.Trade.ErasePreviousCharacter.Entry
                LD B, #06
EraseDelay:     HALT
                DJNZ EraseDelay

                CALL Game.Trade.ClearPressedKeyBits.Entry
                JR ReadKey

                ; запись нулевого завершителя и ожидание отпускания ENTER
EndInput:       LD HL, (TextInput.Cursor)
                LD (HL), #00
                CALL Game.Trade.Newline.Entry
                CALL Game.Trade.Wait20Interrupts.Entry
ReleaseEnter:   LD A, (InputState.LastKey)
                CP #0D
                JR Z, ReleaseEnter                                              ; переход, если ENTER остаётся нажатым, дождаться его отпускания

                JP Game.Trade.ClearPressedKeyBits.Entry

                ; клавиша выбора планеты у курсора с обновлением информации
SelectSystem:   CALL Game.Galaxy.SelectNearestSystemWithCursor.Entry
ShowSelection:  CALL Game.Trade.ClearPromptRows.Entry
                LD A, #03
                CALL Game.Trade.PrintDecoratedToken.Entry
                CALL Game.Trade.Newline.Entry
                CALL Game.Galaxy.PrintTargetDistance.Entry
                JP Game.Trade.OptionalBeep.Entry

                ; проверка исходного конца фрагмента
                ASSERT $ == #E46F
                endmodule
                endmodule
