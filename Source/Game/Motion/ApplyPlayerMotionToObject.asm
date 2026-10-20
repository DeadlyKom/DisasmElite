                module Motion
                module ApplyPlayerMotionToObject
; -----------------------------------------
; поворот и перенос относительных координат при движении игрока
; исходный диапазон #A173..#A1E9
; In:
;   IX, объект
;   память #70E4..#70E6, углы LR, DU и скорость игрока
; Out:
;   HL, слово целой части глубины после переноса
;   IX, исходный объект, координаты обновлены
; Corrupt:
;   DE, BC, AF
; Note:
; 7F81 при активном специальном управлении может изменить сразу оба угла и скорость игрока.
; Четыре малых поворота связывают Y с Z и X с Y.
; Поступательное движение вычитает 2*(скорость+1) из младшего байта Z.
; Переход через ноль меняет знак глубины, переполнение отрицательной глубины передаётся в #5FD5.
; Два байта #A1CE..#A1CF сохраняют старый JR за безусловным JP и не достигаются этим путём.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #A173
                ; расчёт первого поворота относительного положения по DU
Entry:          CALL Game.Universe.ApplyEnhancedFlightControl.Entry
                XOR #80
                LD C, A
                LD DE, #0003
                LD HL, #0006
                CALL Game.Motion.AddScaledCoordinate.Entry
                ; расчёт двух сопряжённых поворотов по LR
                LD A, (FlightState.Roll)
                XOR #80
                CALL Game.Motion.DoubleSignedAngle.Entry
                LD DE, #0003
                LD H, D
                LD L, D
                CALL Game.Motion.AddScaledCoordinate.Entry
                LD A, (FlightState.Roll)
                CALL Game.Motion.DoubleSignedAngle.Entry
                LD HL, #0003
                LD D, H
                LD E, H
                CALL Game.Motion.AddScaledCoordinate.Entry
                ; завершение поворота Y/Z
                LD A, (FlightState.Pitch)
                LD C, A
                LD HL, #0003
                LD DE, #0006
                CALL Game.Motion.AddScaledCoordinate.Entry
                ; расчёт поступательного смещения игрока
TranslateGate   EQU $                                                           ; код LD A либо RET, временное отключение поступательного сдвига
                LD A, (FlightState.Speed)
                INC A
                ADD A, A
                LD B, A
                LD H, (IX + FSpaceObject.Z.SignHigh)
                LD L, (IX + FSpaceObject.Z.Low)
                LD A, (IX + FSpaceObject.Z.Fraction)
                ; проверка знака глубины перед изменением модуля
                BIT 7, H
                JR Z, MovePositiveZ                                             ; переход, если глубина неотрицательна и нужно уменьшать её модуль

                ADD A, B
                LD (IX + FSpaceObject.Z.Fraction), A
                JR NC, DepthReady                                               ; переход, если прибавление скорости к отрицательной глубине не переносит единицу

                INC HL
                BIT 7, H
                JR NZ, StoreDepth                                               ; переход, если после переноса отрицательная глубина остаётся в допустимом диапазоне

                JP Game.Extensions.OfferUpgradeAndCorrectPosition.CorrectCentre

                ; сохранённые байты прежнего перехода за недостижимым продолжением

; -----------------------------------------
; переход к отрицательной ветви обновления координаты Z
; In:
;   HL, подготовленная старшая часть координаты
;   AF, A содержит младший байт величины
;   IX, объект
; Out:
;   продолжение #A1DE меняет знак A и сохраняет координату Z
; Corrupt:
;   AF
; Note:
;   сохранённый переход после безусловного JP #5FD5
;   прямые входящие переходы на #A1CE не найдены
;   сам #A1DE остаётся частью действующего обновления движения
; -----------------------------------------
LegacyNegate:   ; переход к отрицательной ветви обновления координаты Z
                JR FlipFraction

                ; обновление положительной глубины с обработкой перехода через ноль
MovePositiveZ:  SUB B
                LD (IX + FSpaceObject.Z.Fraction), A
                JR NC, DepthReady                                               ; переход, если вычитание скорости не требует заёма из целой части

                DEC HL
                BIT 7, H
                JR Z, StoreDepth                                                ; переход, если после заёма глубина остаётся неотрицательной

                LD HL, #8000
FlipFraction:   NEG
                LD (IX + FSpaceObject.Z.Fraction), A
StoreDepth:     LD (IX + FSpaceObject.Z.SignHigh), H
                LD (IX + FSpaceObject.Z.Low), L
DepthReady:     RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #A1EA
                endmodule
                endmodule
