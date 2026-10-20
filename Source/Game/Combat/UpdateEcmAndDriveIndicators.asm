                module Combat
                module UpdateEcmAndDriveIndicators
; -----------------------------------------
; обновление двух индикаторов в полётном виде
; исходный диапазон #9B01..#9B13
; In:
;   память 70E3, вид
;   память 9C9B/711C, состояния ECM и режима движения
; Out:
;   атрибуты 5AD5/5AD6 обновлены
; Corrupt:
;   HL, AF
; Note:
; Первый индикатор рисуется вызовом 9B14, второй продолжением в тот же общий хвост.
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
                LD A, (FlightState.StationZone)
                ; проверка исходного конца фрагмента
                ASSERT $ == #9B14
                endmodule
                endmodule
