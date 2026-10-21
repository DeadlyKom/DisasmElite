; -----------------------------------------
; Восстановление состояния старта под демонстрацией
; исходный диапазон #E6D2..#E6DB
; In:
;   AF, A новое состояние маскировки
; Out:
;   CloakActive=A,FlightState.RandomByte=State.MarketRandom
; Corrupt:
;   AF
; Note:
;   Точное повторение исходного Game.Trade.ResetCloakingAndSeedFlightRandom.Entry, который перезаписан оверлеем
; -----------------------------------------
                ; состояние маскировки и копия рыночного случайного байта повторяют Game.Trade.ResetCloakingAndSeedFlightRandom.Entry
RestoreFlight:  LD (CloakActive), A
                LD A, (State.MarketRandom)
                LD (FlightState.RandomByte), A
                RET
