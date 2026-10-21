; -----------------------------------------
; Разворот к цели за кораблём
; исходный диапазон #E9F9..#EA0E
; In:
;   IX, Keyboard, начало восьми полурядов виртуальной клавиатуры
;   Memory.Station + FSpaceObject.Energy, ненулевое значение означает существующую станцию
; Out:
;   включён X, при существующей станции Brake и J
; Corrupt:
;   AF
; Note:
;   Снятие S и установка X выполняются при любом состоянии станции
; -----------------------------------------
                ; наличие станции добавляет торможение и J перед разворотом
ReverseCourse:  LD A, (Memory.Station + FSpaceObject.Energy)
                AND A
                JR Z, ReversePitch                                              ; переход, если станция отсутствует, выполнять только разворот X

                CALL Brake
                SET KEYBOARD_J_BIT, (IX + FKeyboardRows.RowEnterLKJH)
                ; разворот всегда выбирает X и снимает S
ReversePitch:   RES KEYBOARD_S_BIT, (IX + FKeyboardRows.RowASDFG)
                SET KEYBOARD_X_BIT, (IX + FKeyboardRows.RowShiftZXCV)
                RET
