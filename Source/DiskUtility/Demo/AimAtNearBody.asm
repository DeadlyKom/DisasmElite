; -----------------------------------------
; Выбор станции или планеты для ближнего наведения
; исходный диапазон #E851..#E864
; In:
;   IX=Keyboard
; Out:
;   DE=FF00 либо 0000, маска точности
;   IY=Memory.Station либо FlightState.Planet, затем SteerToTarget
; Corrupt:
;   DE, AF, IY
; Note:
;   X/Y/Z совпадают в первых девяти байтах объекта, солнца и планеты
;   При существующей станции DiskUtility.Demo.RandomThrottle случайно пропускает Accelerate, используя R.0
; -----------------------------------------
                ; проверка станции, при её отсутствии выбирается планета
AimNearBody:    LD IY, Memory.Station
                LD DE, #FF00
                LD A, (IY + FSpaceObject.Energy)
                AND A
                JR NZ, RandomThrottle                                           ; переход, если станция существует, выбрать её и случайный вариант начала наведения

                LD IY, FlightState.Planet
                LD D, E
                JR SteerToTarget
