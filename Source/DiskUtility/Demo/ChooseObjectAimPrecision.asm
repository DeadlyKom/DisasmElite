; -----------------------------------------
; Выбор точности наведения на объект
; исходный диапазон #E865..#E885
; In:
;   IX=Keyboard, IY объект
; Out:
;   DE=FFF0 при сумме<45, иначе FC00, Flags2=#0A сдвигает E влево дважды
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   RandomThrottle вызывается переходом из AimNearBody при существующей станции
;   младший бит R выбирает SteerToTarget с начальным ускорением либо CheckRearAim без него
; -----------------------------------------
                ; выбор точности наведения по сумме координат меньше 45
AimAtObject:    LD DE, #002D
                CALL CompareRange
                LD DE, #FFF0
                JR C, AdjustAimMask                                             ; переход, если сумма целых координат цели меньше 45, оставить точную маску FFF0

                LD E, #00
                LD D, #FC
                ; для полного набора Flags2=#0A младшая маска меняется F0 на C0
AdjustAimMask:  LD A, (IY + FSpaceObject.Flags2)
                CP OBJ_CARGO_FL
                JR NZ, SteerToTarget                                            ; переход, если полный байт Flags2 цели не равен #0A, использовать выбранную маску без изменения

                SLA E
                SLA E
                JR SteerToTarget

                ; отдельный вход случайно пропускает вызов ускорения
RandomThrottle: LD A, R
                RRCA
                JR C, CheckRearAim                                              ; переход, если младший бит регистра R установлен, пропустить начальное ускорение

                ; JP SteerToTarget, продолжение в SteerTowardTarget.asm
