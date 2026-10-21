                module Screen
                module LeftArcDown
; -----------------------------------------
; подготовка половины окружности слева, движение вниз
; In:
;   HL, DE, адреса концов строки
;   BC, маски краёв
;   AF, исходное состояние построителя
;   альтернативные C и E, исходные смещения относительно центра
; Out:
;   нарисована выбранная половина окружности
;   AF сохраняется
; Corrupt:
;   HL, DE, BC, HL', DE', BC', AF'
; Note:
;   PUSH AF создаёт сохранение, все выходы восстанавливают AF через POP AF
;   часть выходов по переполнению C' завершается до обратного EXX, ориентация банков не сохраняется
;   HL' и D' обнуляют накопители ошибки, B'=#FF задаёт исходную маску
;   направление CircleState.DirectionDown устанавливается в 1
;   при CircleState.OutlineOnly=0 выполняется заливка по Game.Circles.SetCabinHeatAndContinueFilledCircle.LeftFixedFill, иначе контур по Game.Circles.SkipRowsDownAndDrawCircleContours.LeftCutArc
;   внутренние процедуры временно используют SP для быстрого заполнения, затем восстанавливают его
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #865A
                ; сохранение состояния вызывающего и подготовка накопителей дуги
Entry:          PUSH AF
                EXX
                LD HL, #0000
                LD D, H
                LD B, #FF
                EXX
                LD A, #01
                LD (CircleState.DirectionDown), A
                LD A, (CircleState.OutlineOnly)
                AND A
                JP NZ, Game.Circles.SkipRowsDownAndDrawCircleContours.LeftCutArc ; переход, если выбран контур без заливки

                JP Game.Circles.SetCabinHeatAndContinueFilledCircle.LeftFixedFill

                ASSERT $ == #8672
                endmodule
                endmodule
