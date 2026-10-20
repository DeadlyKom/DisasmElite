                module Motion
                module UpdateObjectCoordinatesAndRotation
; -----------------------------------------
; пересчёт положения и базиса объекта за один такт
; исходный диапазон #9F82..#9FFC
; In:
;   IX, объект
;   IY, описание модели
; Out:
;   IX, исходный объект
;   IY, исходная модель
;   положение, базис и команды вращения обновлены
; Corrupt:
;   HL, DE, BC, AF
; Note:
; Сначала применяется движение игрока к относительным координатам.
; Объекты за пределами диапазона освобождаются через энергию IX+22 и снятие ракетных целей.
; Базис поворачивается углами игрока, затем формируются собственные углы объекта.
; В командах IX+1D/+1E бит 7 задаёт непрерывное вращение, бит 6 направление, low4 длительность.
; Условие выхода по дальности для объектов с IX+26.2 ослаблено.
; Фрагмент без RET продолжается в #9FFD, где выполняются собственное вращение и скорость.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #9F82
                ; пересчёт относительных координат по движению игрока
Entry:          CALL Game.Motion.ApplyPlayerMotionToObject.Entry
                ; проверка дальностных ограничений объекта
                BIT OBJ_SPECIAL_BIT, (IX + FSpaceObject.Flags2)
                JR NZ, CheckDepthHigh                                           ; переход, если для особого объекта не применяется младший порог дальности #60

                LD A, L
                CP #60
                JR NC, ReleaseObject                                            ; переход, если младший целый байт глубины достиг порога #60

CheckDepthHigh: LD A, H
                AND #7F
                JR Z, CheckSideRange                                            ; переход, если старшие разряды модуля глубины равны нулю

                ; удаление объекта из слота и снятие ракетных целей
ReleaseObject:  XOR A
                LD (IX + FSpaceObject.Energy), A
                JP Game.Combat.ReleaseMissileTargets.Entry

                ; проверка старших разрядов боковых координат
CheckSideRange: LD A, (IX + FSpaceObject.X.SignHigh)
                ADD A, A
                JR NZ, ReleaseObject                                            ; переход, если старшие разряды модуля X выходят за рабочий диапазон

                LD A, (IX + FSpaceObject.Y.SignHigh)
                ADD A, A
                JR NZ, ReleaseObject                                            ; переход, если старшие разряды модуля Y выходят за рабочий диапазон

                LD HL, (FlightState.Roll)
                LD (RotationState.Roll), HL
                PUSH IX
                LD DE, #0009
                ADD IX, DE
                CALL Game.Motion.RotateAxisByPlayer.Entry
                CALL Game.Motion.RotateAxisByPlayer.Entry
                CALL Game.Motion.RotateAxisByPlayer.Entry
                POP IX
                ; расчёт угла собственного вращения LR по команде объекта
                LD A, (IX + FSpaceObject.Roll)
                LD B, A
                BIT 7, A
                JR NZ, SetRollStep                                              ; переход, если вращение LR задано как непрерывное

                AND #0F
                LD A, #00
                JR Z, StoreRollStep                                             ; переход, если счётчик вращения LR равен нулю

                LD A, B
                DEC A
                LD (IX + FSpaceObject.Roll), A
SetRollStep:    LD A, #0C
                BIT 6, (IX + FSpaceObject.Roll)
                JR Z, StoreRollStep                                             ; переход, если вращение LR имеет положительное направление

                ADD A, #80
StoreRollStep:  LD (RotationState.Roll), A
                ; расчёт угла собственного вращения DU
                LD A, (IX + FSpaceObject.Pitch)
                LD B, A
                BIT 7, A
                JR NZ, SetPitchStep                                             ; переход, если вращение DU задано как непрерывное

                AND #0F
                LD A, #00
                JR Z, Game.Motion.AdvanceObjectAlongLocalAxis.Entry             ; переход, если счётчик вращения DU равен нулю

                LD A, B
                DEC A
                LD (IX + FSpaceObject.Pitch), A
SetPitchStep:   LD A, #08
                BIT 6, (IX + FSpaceObject.Pitch)
                JR Z, Game.Motion.AdvanceObjectAlongLocalAxis.Entry             ; переход, если вращение DU имеет положительное направление

                ADD A, #80
                ; проверка исходного конца фрагмента
                ASSERT $ == #9FFD
                endmodule
                endmodule
