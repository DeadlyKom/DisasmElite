                module Trade
                module RestoreTextPosition
; -----------------------------------------
; Восстановление печатного курсора
; исходный диапазон #E38D..#E397
; In:
;   MarketWork.TextPosition/MarketWork.TextPosition + 1 = сохранённая позиция
; Out:
;   TextPosition/TextRow восстановлены, HL = позиция
; Corrupt:
;   HL
; Note:
;   TextInput.Length, TextInput.Cursor и TextInput.LastKey после RET содержат состояние редактора строки
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E38D
                ; восстановление сохранённых X и Y после диалога ввода
Entry:          LD HL, (MarketWork.TextPosition)
                LD (TextColumn), HL
                RET

                ; состояние редактора строки
InputData       FTextInput {
                    #00,                                                        ; FTextInput.Length, число введённых символов
                    #0000,                                                      ; FTextInput.Cursor, адрес следующего символа в буфере ввода
                    #00                                                         ; FTextInput.LastKey, последний принятый код клавиши
                }
                ASSERT $ - InputData == FTextInput

                ; прежние имена указывают на поля экземпляра InputData
Length          EQU InputData.Length                                            ; поле FTextInput.Length
Cursor          EQU InputData.Cursor                                            ; поле FTextInput.Cursor
LastKey         EQU InputData.LastKey                                           ; поле FTextInput.LastKey
                ; проверка исходного конца фрагмента
                ASSERT $ == #E398
                endmodule
                endmodule
