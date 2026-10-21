; -----------------------------------------
; Выбор крена по знаку текущего вращения
; исходный диапазон #E909..#E911
; In:
;   FlightState.Roll текущий крен, IX=Keyboard
; Out:
;   отрицательный крен включает M, положительный N
; Corrupt:
;   AF
; Note:
;   M и N задаются KEYBOARD_M_BIT и KEYBOARD_N_BIT строки FKeyboardRows.RowSpaceSMNB
;   противоположная клавиша снимается
; -----------------------------------------
                ; знак существующего крена выбирает клавишу M или N
RollBySign:     LD A, (FlightState.Roll)
                BIT 7, A
                JR Z, PressRollN                                                ; переход, если текущий крен неотрицателен, выбрать N

                JR PressRollM
