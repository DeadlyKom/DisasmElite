; -----------------------------------------
; Очистка семи строк виртуальной клавиатуры
; исходный диапазон #EC92..#EC9E
; In:
;   первые семь строк Keyboard, от RowShiftZXCV до RowEnterLKJH
; Out:
;   семь байтов 0, строка скорости Keyboard.RowSpaceSMNB и маркер Keyboard.ScannedMarker сохранены
; Corrupt:
;   HL
; Note:
;   LD/DJNZ/INC HL не изменяют флаги, AF сохраняется
; -----------------------------------------
                ; семь строк очищаются, строка скорости Keyboard.RowSpaceSMNB остаётся для общего управления
ClearMainKeys:  PUSH BC
                LD BC, #0700
                LD HL, Keyboard
ClearKeyRow:    LD (HL), C
                INC HL
                DJNZ ClearKeyRow

                POP BC
                RET
