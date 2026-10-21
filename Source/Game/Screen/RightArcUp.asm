                module Screen
                module RightArcUp
; -----------------------------------------
; подготовка половины окружности справа, движение вверх
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
;   направление CircleState.DirectionDown устанавливается в 0
;   при CircleState.OutlineOnly=0 выполняется заливка по Game.Circles.SelectJumpAndContinueLeftFill.RightFixedFill, иначе контур по Game.Circles.SkipRowsDownAndDrawCircleContours.RightCutArc
;   внутренние процедуры временно используют SP для быстрого заполнения, затем восстанавливают его
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #8643
                ; сохранение состояния вызывающего и подготовка накопителей дуги
Entry:          PUSH AF
                EXX
                LD HL, #0000
                LD D, H
                LD B, #FF
                EXX
                XOR A
                LD (CircleState.DirectionDown), A
                LD A, (CircleState.OutlineOnly)
                AND A
                JP NZ, Game.Circles.SkipRowsDownAndDrawCircleContours.RightCutArc ; переход, если выбран контур без заливки

                JP Game.Circles.SelectJumpAndContinueLeftFill.RightFixedFill

                ASSERT $ == #865A
                endmodule
                endmodule
