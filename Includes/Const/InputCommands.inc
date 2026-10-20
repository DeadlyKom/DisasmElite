                ifndef _CONST_INPUT_COMMANDS_
                define _CONST_INPUT_COMMANDS_

; InputState.SystemKeys, накопленные команды клавиатуры
SYS_ENTER_BIT   EQU 0                                                           ; флаг, нажата клавиша ENTER
SYS_L_BIT       EQU 1                                                           ; флаг, нажата клавиша L
SYS_K_BIT       EQU 2                                                           ; флаг, нажата клавиша K
SYS_P_BIT       EQU 3                                                           ; флаг, нажата клавиша P
SYS_O_BIT       EQU 4                                                           ; флаг, нажата клавиша O
SYS_I_BIT       EQU 5                                                           ; флаг, нажата клавиша I
SYS_0_BIT       EQU 6                                                           ; флаг, нажата клавиша 0
SYS_Y_BIT       EQU 7                                                           ; флаг, нажата клавиша Y

; InputState.FlightKeys, накопленные команды клавиатуры
FLY_ROLL_N_BIT  EQU 0                                                           ; флаг, отрицательный крен, N
FLY_ROLL_P_BIT  EQU 1                                                           ; флаг, положительный крен, M
FLY_PITCH_N_BIT EQU 2                                                           ; флаг, отрицательный тангаж, X
FLY_PITCH_P_BIT EQU 3                                                           ; флаг, положительный тангаж, S
FLY_SPEED_BIT   EQU 4                                                           ; флаг, увеличение скорости, SPACE
FLY_BRAKE_BIT   EQU 5                                                           ; флаг, уменьшение скорости, SYMBOL SHIFT

; InputState.ViewJumpKeys, накопленные команды клавиатуры
VIEW_FRONT_BIT  EQU 0                                                           ; флаг, передний вид, 1
VIEW_REAR_BIT   EQU 1                                                           ; флаг, задний вид, 2
VIEW_LEFT_BIT   EQU 2                                                           ; флаг, левый вид, 3
VIEW_RIGHT_BIT  EQU 3                                                           ; флаг, правый вид, 4
VIEW_HYPER_BIT  EQU 4                                                           ; флаг, обычный гиперпереход, H
VIEW_GALAX_BIT  EQU 5                                                           ; флаг, клавиша G, галактический переход совместно с H
VIEW_FAST_BIT   EQU 6                                                           ; флаг, ускоренное перемещение, J
VIEW_PAUSE_BIT  EQU 7                                                           ; флаг, пауза, CAPS SHIFT

; InputState.DeviceKeys, накопленные команды клавиатуры
DEV_FIRE_BIT    EQU 0                                                           ; флаг, лазер, A
DEV_ARM_BIT     EQU 1                                                           ; флаг, взведение ракеты, T
DEV_LAUNCH_BIT  EQU 2                                                           ; флаг, пуск ракеты, F
DEV_UNARM_BIT   EQU 3                                                           ; флаг, снятие ракеты со взвода, U
DEV_ECM_BIT     EQU 4                                                           ; флаг, включение ECM, E
DEV_BOMB_BIT    EQU 5                                                           ; флаг, энергетическая бомба, W
DEV_ESCAPE_BIT  EQU 6                                                           ; флаг, спасательная капсула, Q
DEV_DOCK_BIT    EQU 7                                                           ; флаг, автоматическая стыковка, C

; InputState.ChartKeys, накопленные команды клавиатуры
CHART_B_BIT     EQU 4                                                           ; флаг, нажата клавиша B
CHART_D_BIT     EQU 5                                                           ; флаг, нажата клавиша D
CHART_R_BIT     EQU 6                                                           ; флаг, нажата клавиша R

; InputState.NumberKeys, результат текущего опроса
NUM_9_BIT       EQU 0                                                           ; флаг, нажата клавиша 9
NUM_5_BIT       EQU 1                                                           ; флаг, нажата клавиша 5
NUM_8_BIT       EQU 2                                                           ; флаг, нажата клавиша 8
NUM_6_BIT       EQU 3                                                           ; флаг, нажата клавиша 6
NUM_7_BIT       EQU 4                                                           ; флаг, нажата клавиша 7

; маски составных полей ввода
FLY_ROLL_MASK   EQU #03                                                         ; два направления крена
FLY_PITCH_MASK  EQU #0C                                                         ; два направления тангажа
FLY_DIR_MASK    EQU #0F                                                         ; четыре направления управления
FLY_NEG_MASK    EQU #05                                                         ; отрицательные направления крена и тангажа
FLY_POS_MASK    EQU #0A                                                         ; положительные направления крена и тангажа
FLY_AUX_MASK    EQU #F0                                                         ; скорость и неназначенные старшие биты, сохраняются при замене направлений
VIEW_JUMP_MASK  EQU #30                                                         ; клавиши H и G
CHART_KEY_MASK  EQU #70                                                         ; клавиши B, D, R
DEV_KEEP_MASK   EQU #91                                                         ; сохранение огня, ECM и стыковки после опроса боевых команд

VIEW_FAST_KEEP  EQU #FF - (1 << VIEW_FAST_BIT)                                  ; сохранение остальных команд после поглощения клавиши J

                endif                                                           ; ~_CONST_INPUT_COMMANDS_
