                module Flight
                module DispatchDangerIndicator
; -----------------------------------------
; Вектор обновления индикатора опасности
; исходный диапазон #7121..#7124
; In:
;   состояние полёта
; Out:
;   передача управления Game.Scanner.DrawDangerAndMissileIndicators.Entry
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   FlightState.ControlsLocked после JP является блокировкой ручного обновления скорости и вращения
; -----------------------------------------
                ASSERT $ == #7121
                ; передача управления общему индикатору опасности
Entry:          JP Game.Scanner.DrawDangerAndMissileIndicators.Entry

                ; блокировка ручного обновления углов и скорости
ControlsLocked  DB #00                                                          ; флаг, главный цикл пропускает ручное обновление крена, тангажа и скорости
                ASSERT $ == #7125
                endmodule
                endmodule
