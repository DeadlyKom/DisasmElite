                module Screen
                module ScaleProximity
; -----------------------------------------
; масштабирование расстояния и выбор состояния опасности
; In:
;   HL, исходная мера близости
; Out:
;   HL, 2*HL_in + floor(HL_in/2) по модулю 65536
;   байт #7104 может измениться
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   пороговые значения старшего байта равны #50 и #78
;   при H >= #78 выбирается состояние #63, между порогами состояние 2
;   уже установленное #63 не понижается средней ветвью
;   ниже #50 только состояние 4 заменяется на 6
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #82D7
                ; расчёт масштаба 2,5 с сохранением целочисленного округления
Entry:          PUSH HL
                ADD HL, HL
                POP DE
                SRL D
                RR E
                ADD HL, DE
                LD A, (FlightState.FlightStatus)
                LD B, A
                ; проверка порогов опасного сближения
                LD A, H
                CP #50
                JR C, CheckRecovery                                             ; переход, если масштабированное значение ниже #5000

                CP #78
                JR NC, CriticalRange                                            ; переход, если значение не меньше #7800

                LD A, B
                CP #63
                RET Z                                                           ; выход, если максимальная опасность #63 уже установлена

                LD A, #02
                JR StoreStatus

CriticalRange:  LD A, #63
                JR StoreStatus

CheckRecovery:  LD A, B
                CP #04
                RET NZ                                                          ; выход, если прежнее состояние не равно 4

                LD A, #06
StoreStatus:    LD (FlightState.FlightStatus), A
                RET
                ASSERT $ == #8302
                endmodule
                endmodule
