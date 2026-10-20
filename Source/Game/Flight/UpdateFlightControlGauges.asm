                module Flight
                module UpdateFlightControlGauges
; -----------------------------------------
; Перенос управления в скорость и шкалы вращения
; исходный диапазон #713C..#717A
; In:
;   FF09/FF0B знако-модульные углы, FF0D скорость
; Out:
;   70E4/70E5 углы,70FE/7100 позиции шкал,70E6 скорость,70F4=5*скорость+5
; Corrupt:
;   HL, BC, AF
; Note:
;   Положительный угол даёт 21+модуль, отрицательный 21-модуль, значения считаются в байте
; -----------------------------------------
                ASSERT $ == #713C
                ; расчёт крена относительно середины шкалы 21
Entry:          LD HL, InputMotion.Roll + FSignWord.SignHigh
                LD A, (HL)
                LD (FlightState.Roll), A
                BIT 7, A
                JR NZ, NegativeRoll                                             ; переход, если крен отрицателен, вычесть модуль из центра шкалы 21

                ADD A, #15
                JR StoreRoll

NegativeRoll:   AND #7F
                LD C, A
                LD A, #15
                SUB C
StoreRoll:      LD (GaugeState + FGaugeState.Roll.Current), A
                ; расчёт тангажа по следующей паре байтов управления
                INC L
                INC L
                LD A, (HL)
                LD (FlightState.Pitch), A
                BIT 7, A
                JR NZ, NegativePitch                                            ; переход, если тангаж отрицателен, вычесть модуль из центра шкалы 21

                ADD A, #15
                JR StorePitch

NegativePitch:  AND #7F
                LD C, A
                LD A, #15
                SUB C
StorePitch:     LD (GaugeState + FGaugeState.Pitch.Current), A
                ; расчёт длины полосы скорости как 5*скорость+5
                INC L
                INC L
                LD A, (HL)
                LD (FlightState.Speed), A
                LD B, A
                ADD A, A
                ADD A, A
                ADD A, B
                ADD A, #05
                LD (GaugeState + FGaugeState.Speed.Current), A
                RET
                ASSERT $ == #717B
                endmodule
                endmodule
