; -----------------------------------------
; Выбор крена по знакам X и Y цели
; исходный диапазон #E912..#E938
; In:
;   IX, Keyboard, начало восьми полурядов виртуальной клавиатуры
;   IY, цель с общим положением FSpaceObject.X/Y/Z
; Out:
;   клавиша 1, таймер DiskUtility.Demo.ActionTimer младший FF, один из M/N
; Corrupt:
;   AF
; Note:
;   X/Y/Z совпадают в первых девяти байтах объекта, солнца и планеты
;   Разные знаки X/Y выбирают N, одинаковые M, перед выбором BrakeWhenFar может включить торможение
; -----------------------------------------
                ; передний вид и продление таймера поведения при повороте
ApplyRoll:      SET KEYBOARD_1_BIT, (IX + FKeyboardRows.Row12345)
                LD A, #FF
                LD (ActionTimer), A
                CALL BrakeWhenFar
                ; разность знаков X/Y задаёт направление крена
                LD A, (IY + FSpaceObject.X.SignHigh)
                XOR (IY + FSpaceObject.Y.SignHigh)
                RLCA
                JR C, PressRollN                                                ; переход, если знаки X и Y цели различны, выбрать N

                ; клавиша M включается одновременно со снятием N
PressRollM:     RES KEYBOARD_N_BIT, (IX + FKeyboardRows.RowSpaceSMNB)
                SET KEYBOARD_M_BIT, (IX + FKeyboardRows.RowSpaceSMNB)
                RET

                ; клавиша N включается одновременно со снятием M
PressRollN:     RES KEYBOARD_M_BIT, (IX + FKeyboardRows.RowSpaceSMNB)
                SET KEYBOARD_N_BIT, (IX + FKeyboardRows.RowSpaceSMNB)
                RET
