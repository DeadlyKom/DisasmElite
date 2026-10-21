                module Screen
                module RestrictDockingView
; -----------------------------------------
; ограничение вида в активном стыковочном туннеле
; In:
;   BC, B содержит прежний режим, C новый режим
;   AF, A содержит новый режим
; Out:
;   режим от 4 принимается, режимы 0..3 заменяются нулём
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   переход к Game.Screen.SelectScreen.StoreView сохраняет информационный режим обычным путём
;   CompassData содержит резервный байт, CompassState.SunNear и поля CompassState.X, Y, Behind указателя компаса
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #819A
                ; проверка выбора меню вместо бокового или заднего вида
Entry:          CP #04
                JR NC, Game.Screen.SelectScreen.StoreView                       ; переход, если выбран информационный экран

                XOR A
                LD (FlightState.View), A
                RET

CompassData     EQU $                                                           ; исходная база блока с отдельным резервным байтом
.Reserved       DB #00                                                          ; исходный резервный байт перед структурой FCompassState
.SunNear        EQU CompassFields.SunNear                                       ; адрес поля FCompassState.SunNear
.PlanetNear     EQU CompassFields.PlanetNear                                    ; адрес поля FCompassState.PlanetNear
.X              EQU CompassFields.X                                             ; адрес поля FCompassState.X
.Y              EQU CompassFields.Y                                             ; адрес поля FCompassState.Y
.Behind         EQU CompassFields.Behind                                        ; адрес поля FCompassState.Behind

CompassFields   FCompassState {
                    #00,                                                        ; FCompassState.SunNear, флаг, солнце в ближнем диапазоне
                    #00,                                                        ; FCompassState.PlanetNear, флаг, планета в ближнем диапазоне
                    #00,                                                        ; FCompassState.X, нормированная координата X
                    #00,                                                        ; FCompassState.Y, нормированная координата Y
                    #00                                                         ; FCompassState.Behind, флаг, цель за кораблём
                }
                ASSERT $ == #81A9
                endmodule
                endmodule
