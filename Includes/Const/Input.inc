; -----------------------------------------
; номера битов внутри пяти клавиш полуряда Spectrum
; смысл полуряда задаётся полем FKeyboardRows, единица означает нажатие
; -----------------------------------------

; RowShiftZXCV
KEYBOARD_CS_BIT EQU 0                                                           ; бит клавиши CAPS_SHIFT
KEYBOARD_Z_BIT  EQU 1                                                           ; бит клавиши Z
KEYBOARD_X_BIT  EQU 2                                                           ; бит клавиши X
KEYBOARD_C_BIT  EQU 3                                                           ; бит клавиши C
KEYBOARD_V_BIT  EQU 4                                                           ; бит клавиши V

; RowASDFG
KEYBOARD_A_BIT  EQU 0                                                           ; бит клавиши A
KEYBOARD_S_BIT  EQU 1                                                           ; бит клавиши S
KEYBOARD_D_BIT  EQU 2                                                           ; бит клавиши D
KEYBOARD_F_BIT  EQU 3                                                           ; бит клавиши F
KEYBOARD_G_BIT  EQU 4                                                           ; бит клавиши G

; RowQWERT
KEYBOARD_Q_BIT  EQU 0                                                           ; бит клавиши Q
KEYBOARD_W_BIT  EQU 1                                                           ; бит клавиши W
KEYBOARD_E_BIT  EQU 2                                                           ; бит клавиши E
KEYBOARD_R_BIT  EQU 3                                                           ; бит клавиши R
KEYBOARD_T_BIT  EQU 4                                                           ; бит клавиши T

; Row12345
KEYBOARD_1_BIT  EQU 0                                                           ; бит клавиши 1
KEYBOARD_2_BIT  EQU 1                                                           ; бит клавиши 2
KEYBOARD_3_BIT  EQU 2                                                           ; бит клавиши 3
KEYBOARD_4_BIT  EQU 3                                                           ; бит клавиши 4
KEYBOARD_5_BIT  EQU 4                                                           ; бит клавиши 5

; Row09876
KEYBOARD_0_BIT  EQU 0                                                           ; бит клавиши 0
KEYBOARD_9_BIT  EQU 1                                                           ; бит клавиши 9
KEYBOARD_8_BIT  EQU 2                                                           ; бит клавиши 8
KEYBOARD_7_BIT  EQU 3                                                           ; бит клавиши 7
KEYBOARD_6_BIT  EQU 4                                                           ; бит клавиши 6

; RowPOIUY
KEYBOARD_P_BIT  EQU 0                                                           ; бит клавиши P
KEYBOARD_O_BIT  EQU 1                                                           ; бит клавиши O
KEYBOARD_I_BIT  EQU 2                                                           ; бит клавиши I
KEYBOARD_U_BIT  EQU 3                                                           ; бит клавиши U
KEYBOARD_Y_BIT  EQU 4                                                           ; бит клавиши Y

; RowEnterLKJH
KEYBOARD_EN_BIT EQU 0                                                           ; бит клавиши ENTER
KEYBOARD_L_BIT  EQU 1                                                           ; бит клавиши L
KEYBOARD_K_BIT  EQU 2                                                           ; бит клавиши K
KEYBOARD_J_BIT  EQU 3                                                           ; бит клавиши J
KEYBOARD_H_BIT  EQU 4                                                           ; бит клавиши H

; RowSpaceSMNB
KEYBOARD_SP_BIT EQU 0                                                           ; бит клавиши SPACE
KEYBOARD_SS_BIT EQU 1                                                           ; бит клавиши SYMBOL_SHIFT
KEYBOARD_M_BIT  EQU 2                                                           ; бит клавиши M
KEYBOARD_N_BIT  EQU 3                                                           ; бит клавиши N
KEYBOARD_B_BIT  EQU 4                                                           ; бит клавиши B
