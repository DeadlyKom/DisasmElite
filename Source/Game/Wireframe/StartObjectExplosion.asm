                module Wireframe
                module StartObjectExplosion
; -----------------------------------------
; преобразование полей движения объекта в параметры экранного взрыва
; исходный диапазон #A8AC..#A8DD
; In:
;   IX, объект
;   память A9C1/A9C2/A9C3/A6DE, центр, знаки и экранный радиус
; Out:
;   IX, исходный объект
;   IX+1C/+1D, экранный центр
;   IX+1E, упакованные знаки и начальное состояние
;   IX+1F, радиус
;   IX+20.5, флаг взрыва
; Corrupt:
;   BC, AF
; Note:
; С этого момента поля ускорения и вращения переиспользуются анимацией взрыва.
; Горизонтальный знак меняется для зеркального вида, два знака упаковываются в младшие биты состояния.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #A8AC
                ; сохранение проекции центра и радиуса для взрыва
Entry:          LD A, (ProjectionState.ScreenX)
                LD (IX + FSpaceObject.Acceleration), A
                LD A, (ProjectionState.ScreenY)
                LD (IX + FSpaceObject.Roll), A
                LD A, (ProjectedRadius)
                LD (IX + FSpaceObject.Payload), A
                LD A, (FlightState.View)
                BIT 0, A
                LD A, (ProjectionState.Flags)
                JR Z, PackCenterSign                                            ; переход, если текущий вид не требует горизонтального зеркалирования

                XOR PROJ_NEGX_MASK
PackCenterSign: LD C, A
                XOR A
                RR C
                RLA
                RR C
                RLA
                XOR CIRC_SIGN_MASK
                ; создание начального состояния анимации взрыва
                ADD A, CIRC_RANGE_MASK
                LD (IX + FSpaceObject.Pitch), A
                SET OBJ_EXPLODE_BIT, (IX + FSpaceObject.Flags)
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #A8DE
                endmodule
                endmodule
