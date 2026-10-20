; -----------------------------------------
; Виртуальное ускорение и команда прыжка
; исходный диапазон #E9E6..#E9F8
; In:
;   IX, Keyboard, начало восьми полурядов виртуальной клавиатуры
;   70E6 скорость
; Out:
;   пробел установлен, Symbol Shift снят, J при скорости>=15
; Corrupt:
;   AF
; Note:
;   J это IX6.3, YieldWithBrake может снять его при доступном для сбора грузе
; -----------------------------------------
                ; согласованная пара ускорения и проверка порога J
Accelerate:     SET KEYBOARD_SP_BIT, (IX + FKeyboardRows.RowSpaceSMNB)
                RES KEYBOARD_SS_BIT, (IX + FKeyboardRows.RowSpaceSMNB)
                LD A, (FlightState.Speed)
                CP #0F
                RET C                                                           ; выход, если скорость меньше 15, команду J не выставлять

                SET KEYBOARD_J_BIT, (IX + FKeyboardRows.RowEnterLKJH)
                RET
