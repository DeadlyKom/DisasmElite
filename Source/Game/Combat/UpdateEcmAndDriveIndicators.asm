                module Combat
                module UpdateEcmAndDriveIndicators
; -----------------------------------------
; обновление двух индикаторов в полётном виде
; исходный диапазон #9B01..#9B13
; In:
;   память FlightState.View, вид
;   память CombatState.EcmTimer/FlightState.StationZone, состояния ECM и режима движения
; Out:
;   атрибуты Memory.Attributes + #02D5/Memory.Attributes + #02D6 обновлены
; Corrupt:
;   HL, AF
; Note:
; Первый индикатор рисуется вызовом Game.Combat.SetIndicatorAndPrintMissileStock.Entry, второй продолжением в тот же общий хвост.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #9B01
                ; проверка вида и обновление двух индикаторов
Entry:          LD A, (FlightState.View)
                CP #04
                RET NC                                                          ; выход, если текущий экран не относится к четырём видам кабины

                LD HL, Memory.Attributes + #02D5                                ; атрибут индикатора ECM, следующий байт относится к зоне станции
                LD A, (CombatState.EcmTimer)
                CALL Game.Combat.SetIndicatorAndPrintMissileStock.Entry
                INC HL
                LD A, (FlightState.StationZone)                                 ; далее Game.Combat.SetIndicatorAndPrintMissileStock.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #9B14
                endmodule
                endmodule
