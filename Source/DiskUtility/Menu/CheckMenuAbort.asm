; -----------------------------------------
; опрос SPACE с аварийным возвратом к завершению меню
; исходный диапазон #CA2D..#CA3A
; In:
;   RestoreStack + 1, SP входа в BuildSaveList
;   клавиатура, строка #7FFE
; Out:
;   при отпущенном SPACE обычный RET
;   при нажатом SPACE SP восстановлен, A=0/Z=1 и переход DiskUtility.Menu.ReturnMenu
; Corrupt:
;   AF, при прерывании также SP и регистры общего завершения
; Note:
;   Нулевой бит 0 строки #7FFE означает нажатый SPACE.
;   LD SP восстанавливает сохранённый BuildSaveList стек и выбрасывает вложенные вызовы.
;   ConfirmCopy заменяет первый байт LD SP по DiskUtility.Menu.RestoreStack на RET, отключая этот выход.
; -----------------------------------------
CheckSpaceExit: LD A, #7F
                IN A, (#FE)
                AND 1 << KEYBOARD_SP_BIT
                RET NZ                                                          ; выход, если SPACE не нажат и вложенная операция продолжается

RestoreStack:   LD SP, DiskStream.AbortSP
                XOR A
                JP ReturnMenu
