; -----------------------------------------
; Виртуальная команда уменьшения скорости
; исходный диапазон #E9DD..#E9E5
; In:
;   IX, Keyboard, начало восьми полурядов виртуальной клавиатуры
;   
; Out:
;   пробел снят, Symbol Shift установлен
; Corrupt:
;   флаги не изменяются
; Note:
;   Меняются только KEYBOARD_SP_BIT и KEYBOARD_SS_BIT строки (IX + FKeyboardRows.RowSpaceSMNB)
; -----------------------------------------
                ; согласованная пара клавиш уменьшения скорости
Brake:          RES KEYBOARD_SP_BIT, (IX + FKeyboardRows.RowSpaceSMNB)
                SET KEYBOARD_SS_BIT, (IX + FKeyboardRows.RowSpaceSMNB)
                RET
