; -----------------------------------------
; Выбор тангажа по знаку Y цели
; исходный диапазон #E96E..#E991
; In:
;   IX, Keyboard, начало восьми полурядов виртуальной клавиатуры
;   IY, цель с общим положением FSpaceObject.X/Y/Z
;   IX, Keyboard, начало восьми полурядов виртуальной клавиатуры
; Out:
;   клавиша 1, таймер EA80 младший FF, отрицательный Y→S, положительный Y→X
; Corrupt:
;   AF
; Note:
;   X/Y/Z совпадают в первых девяти байтах объекта, солнца и планеты
;   BrakeWhenFar может затормозить перед выбором, противоположная клавиша S/X снимается
; -----------------------------------------
                ; передний вид и продление таймера перед тангажом
ApplyPitch:     SET KEYBOARD_1_BIT, (IX + FKeyboardRows.Row12345)
                LD A, #FF
                LD (ActionTimer), A
                CALL BrakeWhenFar
                ; знак Y определяет выбор виртуальной S или X
                BIT 7, (IY + FSpaceObject.Y.SignHigh)
                JR NZ, PressPitchS                                              ; переход, если Y цели отрицательна, выбрать S

                ; S снимается, X устанавливается
PressPitchX:    RES KEYBOARD_S_BIT, (IX + FKeyboardRows.RowASDFG)
                SET KEYBOARD_X_BIT, (IX + FKeyboardRows.RowShiftZXCV)
                RET

                ; X снимается, S устанавливается
PressPitchS:    RES KEYBOARD_X_BIT, (IX + FKeyboardRows.RowShiftZXCV)
                SET KEYBOARD_S_BIT, (IX + FKeyboardRows.RowASDFG)
                RET
