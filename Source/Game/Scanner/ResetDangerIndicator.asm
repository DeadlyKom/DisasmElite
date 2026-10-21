                module Scanner
                module ResetDangerIndicator
; -----------------------------------------
; Базовый зелёный сигнал для следующего кадра
; исходный диапазон #9A3A..#9A3F
; In:
;   без параметров
; Out:
;   A=4, FlightState.FlightStatus=4
; Corrupt:
;   AF, флаги не изменяются
; Note:
;   Потребители Game.Scanner.DrawDangerAndMissileIndicators.Entry и вызывающий цикл заново повышают опасность при необходимости
; -----------------------------------------
                ASSERT $ == #9A3A
                ; исходный зелёный сигнал для следующего кадра
Entry:          LD A, #04
                LD (FlightState.FlightStatus), A
                RET

                ASSERT $ == #9A40
                endmodule
                endmodule
