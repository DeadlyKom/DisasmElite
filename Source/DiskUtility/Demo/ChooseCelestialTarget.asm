; -----------------------------------------
; Выбор солнца либо станции в качестве ориентира
; исходный диапазон #E83C..#E850
; In:
;   IX=Keyboard
; Out:
;   DE маски точности, IY цель, переход SteerToTarget или AimNearBody
; Corrupt:
;   HL, DE, BC, AF, IY
; Note:
;   Солнце с порогом 0888 выбирается при удалении либо нулевой энергии Memory.Station + FSpaceObject.Energy, иначе падение AimNearBody
;   DE=0000 означает проверку только старших модулей координат
; -----------------------------------------
                ; солнце выбирается ориентиром с маской только старшего слова
ChooseBody:     LD IY, FlightState.Sun
                LD DE, #0888
                CALL CompareRange
                LD DE, #0000
                JR NC, SteerToTarget                                            ; переход, если солнце не ближе 0888, направить корабль на него

                ; при близком солнце непустая станция меняет ориентир
                LD A, (Memory.Station + FSpaceObject.Energy)
                AND A
                JR Z, SteerToTarget                                             ; переход, если станция отсутствует, направить корабль на солнце

                ; JP AimNearBody, продолжение в AimAtNearBody.asm
