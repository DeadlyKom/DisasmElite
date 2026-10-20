; -----------------------------------------
; Согласование виртуальной скорости с поворотами и сбором груза
; исходный диапазон #E70A..#E72F
; In:
;   IX, Keyboard, начало восьми полурядов виртуальной клавиатуры
;   IX=4700, флаги объектов, наличие ковша D088 и свободный трюм D07C
; Out:
;   клавиша J снята при доступном грузе, поворот по S/X включает торможение
; Corrupt:
;   HL, AF, затем полный контракт YieldToGame
; Note:
;   Проверяется побитовое D07C AND D088, не две независимые проверки ненулевых величин
;   IX6.3 соответствует J, IX7.0/1 пробел/Symbol Shift, IX0.2/IX1.1 X/S
; -----------------------------------------
                ; подсчёт доступной комбинации объектных признаков перед разрешением J
YieldWithBrake: CALL CountCargo
                JR Z, CheckPitchKeys                                            ; переход, если подходящих по флагам объектов нет, сохранить команду J

                ; побитовое сочетание свободного трюма и ковша запрещает J при ненулевом результате
                LD HL, State.FreeCargo
                LD A, (HL)
                LD L, #88
                AND (HL)
                JR Z, CheckPitchKeys                                            ; переход, если побитовое сочетание свободного трюма и ковша равно нулю, сохранить J

                RES KEYBOARD_J_BIT, (IX + FKeyboardRows.RowEnterLKJH)
                ; проверка виртуального тангажа X/S, поворот сочетается с торможением
CheckPitchKeys: BIT KEYBOARD_X_BIT, (IX + FKeyboardRows.RowShiftZXCV)
                JR NZ, BrakeForPitch                                            ; переход, если выставлена клавиша X, включить торможение

                BIT KEYBOARD_S_BIT, (IX + FKeyboardRows.RowASDFG)
                JR Z, YieldToGame                                               ; переход, если клавиша S не выставлена, уступить кадр без дополнительного торможения

                ; пробел снимается, Symbol Shift устанавливается перед уступкой кадра
BrakeForPitch:  RES KEYBOARD_SP_BIT, (IX + FKeyboardRows.RowSpaceSMNB)
                SET KEYBOARD_SS_BIT, (IX + FKeyboardRows.RowSpaceSMNB)
