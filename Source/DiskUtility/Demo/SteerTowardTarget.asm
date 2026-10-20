; -----------------------------------------
; Наведение с чередованием крена и тангажа
; исходный диапазон #E886..#E908
; In:
;   DE маски двух младших байтов, IX4700, IY координаты цели
; Out:
;   виртуальные клавиши поворота, скорости и вида обновлены
; Corrupt:
;   HL, BC, AF
; Note:
;   X/Y/Z совпадают в первых девяти байтах объекта, солнца и планеты
;   После Accelerate цель строго сзади при нулевых старших X/Y вызывает ReverseCourse
;   E992 задаёт 5 проходов тангажа, E939 окно 15 проходов крена, исходно E939=50
;   Порог координаты вычисляется как (((low&E)|middle)&D)|(high&7F)
;   При значимом X крен>=8 оставляется без изменения, малый Y передаёт LegacySteer, который фактически JP
;   ApplyRoll
;   При значимом Y вызывается ApplyPitch, затем ненулевой 70E5&7E вызывает LegacySteer, это также крен,
;   названия старых входов не меняют фактический поток
; -----------------------------------------
                ; начальное ускорение перед расчётом поворотов
SteerToTarget:  CALL Accelerate
                ; проверка цели строго сзади с нулевыми старшими модулями X/Y
CheckRearAim:   BIT 7, (IY + FSpaceObject.Z.SignHigh)
                JR Z, CheckPitchTime                                            ; переход, если цель впереди, перейти к обычному выбору поворотов

                LD A, (IY + FSpaceObject.X.SignHigh)
                OR (IY + FSpaceObject.Y.SignHigh)
                AND #7F
                JR NZ, CheckPitchTime                                           ; переход, если старшие модули X/Y ненулевые, продолжить обычное наведение

                CALL ReverseCourse
                RET

                ; окно тангажа уменьшается до нуля и передаёт управление его обработчику
CheckPitchTime: LD A, (PitchWindow)
                AND A
                JR Z, CheckRollTime                                             ; переход, если окно тангажа закончилось, проверить окно крена

                DEC A
                LD (PitchWindow), A
                JR SteerPitch

                ; проверка окна крена, нуль перезагружается 15 перед переключением
CheckRollTime:  LD A, (RollWindow)
                AND A
                JR NZ, StepRollWindow                                           ; переход, если окно крена ещё активно, уменьшить его и оценить X

                LD A, #0F
                LD (RollWindow), A
                JR StartPitchTime

                ; уменьшение окна крена и вычисление маскированного отклонения X
StepRollWindow: DEC A
                LD (RollWindow), A
                LD A, (IY + FSpaceObject.X.Fraction)
                AND E
                OR (IY + FSpaceObject.X.Low)
                AND D
                LD B, (IY + FSpaceObject.X.SignHigh)
                RES 7, B
                OR B
                JR Z, StartPitchTime                                            ; переход, если маскированное отклонение X нулевое, переключиться на тангаж

                ; проверка предельного модуля крена 8 перед новым поворотом
                LD A, (FlightState.Roll)
                AND #7F
                CP #08
                RET NC                                                          ; выход, если модуль текущего крена не меньше 8, не добавлять поворот

                ; проверка Y с точностью FE/FF перед выбором крена
                LD A, (IY + FSpaceObject.Y.Fraction)
                AND #FE
                OR (IY + FSpaceObject.Y.Low)
                AND #FF
                LD B, (IY + FSpaceObject.Y.SignHigh)
                RES 7, B
                OR B
                JP Z, LegacySteer                                               ; переход, если отклонение Y после маски FE нулевое, использовать совместимый вход ApplyRoll

                JP ApplyRoll

                RET

                ; пять следующих проходов отводятся тангажу
StartPitchTime: LD A, #05
                LD (PitchWindow), A
                ; расчёт маскированного отклонения Y и вызов выбора тангажа
SteerPitch:     LD A, (IY + FSpaceObject.Y.Fraction)
                AND E
                OR (IY + FSpaceObject.Y.Low)
                AND D
                LD B, (IY + FSpaceObject.Y.SignHigh)
                RES 7, B
                OR B
                CALL NZ, ApplyPitch                                             ; вызов, если маскированное отклонение Y ненулевое, задать тангаж
                ; проверка текущего тангажа, модуль от 2 передаёт управление совместимому ApplyRoll
                LD A, (FlightState.Pitch)
                AND #7E
                RET Z                                                           ; выход, если модуль тангажа равен 0 или 1, дополнительный крен не нужен

                CALL LegacySteer
                RET
