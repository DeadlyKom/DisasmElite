                ifndef _VARIABLES_INPUTSTATE_
                define _VARIABLES_INPUTSTATE_

InputState      EQU Game.Extensions.CompareObjectCoordinateDepth.KeyEvents      ; адрес состояния игрового ввода
.SystemKeys     EQU InputState + FInputState.SystemKeys                         ; маска клавиш Y, 0, I, O, P, K, L, ENTER
.FlightKeys     EQU InputState + FInputState.FlightKeys                         ; нормализованные направления и изменение скорости
.ViewJumpKeys   EQU InputState + FInputState.ViewJumpKeys                       ; виды кабины, переходы и CAPS SHIFT
.DeviceKeys     EQU InputState + FInputState.DeviceKeys                         ; маска команд C, Q, W, E, U, F, T, A
.ChartKeys      EQU InputState + FInputState.ChartKeys                          ; маска клавиш R, D, B
.LastKey        EQU InputState + FInputState.LastKey                            ; последний символ, #FF нет клавиши, #FE сочетание 0 и CAPS SHIFT
.Config         EQU InputState + FInputState.Config                             ; режим источника, настройки направлений и звук
.NumberKeys     EQU InputState + FInputState.NumberKeys                         ; цифровые направления до нормализации

                endif                                                           ; ~_VARIABLES_INPUTSTATE_
