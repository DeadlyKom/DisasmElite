                module Screen
                module UnclippedArcDown
; -----------------------------------------
; подготовка половины окружности без бокового отсечения, движение вниз
; In:
;   HL, DE, адреса концов строки
;   BC, маски краёв
;   AF, исходное состояние построителя
;   альтернативные C и E, исходные смещения относительно центра
; Out:
;   нарисована выбранная половина окружности
;   AF сохраняется
; Corrupt:
;   HL, DE, BC, HL', DE', BC'
; Note:
;   PUSH AF создаёт сохранение, все выходы восстанавливают AF через POP AF
;   часть выходов по переполнению C' завершается до обратного EXX, ориентация банков не сохраняется
;   HL' и D' обнуляют накопители ошибки, B'=#FF задаёт исходную маску
;   направление CircleState.DirectionDown устанавливается в 1
;   при CircleState.OutlineOnly=0 выполняется заливка по Game.Circles.BeginFilledUnclippedHalf.Entry, иначе контур по Game.Circles.SkipRowsDownAndDrawCircleContours.BothArc
;   внутренние процедуры временно используют SP для быстрого заполнения, затем восстанавливают его
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #8689
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
                JP NZ, Game.Circles.SkipRowsDownAndDrawCircleContours.BothArc   ; переход, если выбран контур без заливки

                JP Game.Circles.BeginFilledUnclippedHalf.Entry

                ASSERT $ == #86A1
                endmodule
                endmodule
