; -----------------------------------------
; виртуальная клавиатура занимает область от Keyboard до Keyboard.ScannedMarker включительно
; InstallDemo подменяет IN чтением этих восьми байтов через BC
; размещение не изменяется, ни одна директива ниже не выделяет память
; -----------------------------------------
Keyboard        EQU Memory.Screen + #0700                                       ; начало восьми полурядов в экранном буфере
.RowShiftZXCV   EQU Keyboard + FKeyboardRows.RowShiftZXCV                       ; полуряд CS, Z, X, C, V
.RowASDFG       EQU Keyboard + FKeyboardRows.RowASDFG                           ; полуряд A, S, D, F, G
.RowQWERT       EQU Keyboard + FKeyboardRows.RowQWERT                           ; полуряд Q, W, E, R, T
.Row12345       EQU Keyboard + FKeyboardRows.Row12345                           ; полуряд 1, 2, 3, 4, 5
.Row09876       EQU Keyboard + FKeyboardRows.Row09876                           ; полуряд 0, 9, 8, 7, 6
.RowPOIUY       EQU Keyboard + FKeyboardRows.RowPOIUY                           ; полуряд P, O, I, U, Y
.RowEnterLKJH   EQU Keyboard + FKeyboardRows.RowEnterLKJH                       ; полуряд EN, L, K, J, H
.RowSpaceSMNB   EQU Keyboard + FKeyboardRows.RowSpaceSMNB                       ; полуряд SP, SS, M, N, B
.ScannedMarker  EQU Keyboard + FKeyboardRows                                    ; ReadKeyboard записывает 1, чтение маркера в демо не найдено
