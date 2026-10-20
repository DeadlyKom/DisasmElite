                module Flight
                module TryAutomaticDocking
; -----------------------------------------
; Проверка запроса автоматической стыковки
; исходный диапазон #717B..#71BF
; In:
;   маска FC0B bit7 и состояние корабля/станции
; Out:
;   при допуске 7129=1, вид 0, координаты относительны станции и переход 93ED
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
;   Сначала 9C9A позволяет специальный путь без клавиатурных проверок
;   Обычный путь требует 711C!=0, установленный D08C, полёт 7104!=0, отсутствие отсчёта D03F и bit2
;   станции 6069
; -----------------------------------------
                ASSERT $ == #717B
                ; принудительный запрос обходит клавишу и допуски компьютера
Entry:          LD A, (CombatState.DockRequest)
                AND A
                JR Z, CheckDockKey                                              ; переход, если нет принудительной команды стыковки, проверить клавишу

                XOR A
                LD (CombatState.DockRequest), A
                JR StartDocking

                ; чтение и поглощение клавиши стыковки
CheckDockKey:   LD A, (InputState.DeviceKeys)
                LD B, A
                AND 1 << DEV_DOCK_BIT
                RES DEV_DOCK_BIT, B
                LD A, B
                LD (InputState.DeviceKeys), A
                RET Z                                                           ; выход, если клавиша автоматической стыковки не нажата

                ; проверка доступности станции и стыковочного компьютера
                LD A, (FlightState.StationZone)
                AND A
                RET Z                                                           ; выход, если стыковка запрещена текущим состоянием 711C

                LD A, (State.DockComputer)
                AND A
                RET Z                                                           ; выход, если стыковочный компьютер отсутствует

                ; проверка полёта, отсутствия туннеля и невраждебности станции
                LD A, (FlightState.FlightStatus)
                AND A
                RET Z                                                           ; выход, если корабль уже находится на станции

                LD A, (JumpMode)
                AND A
                RET NZ                                                          ; выход, если анимация перехода ещё не завершена

                LD HL, Memory.Station + FSpaceObject.Hostility
                BIT 2, (HL)
                RET NZ                                                          ; выход, если станция отмечена как враждебная

                ; включение автоматического режима и переднего вида
                LD A, #01
                LD (FlightState.AutoDock), A
StartDocking:   XOR A
                LD (FlightState.View), A
                CALL Game.Screen.RestoreCockpitIfNeeded.Entry
RebaseForDock:  CALL Game.Flight.RebaseSunAgainstStation.Entry
                JP Game.Flight.LaunchOrDockShip.Entry
                ASSERT $ == #71C0
                endmodule
                endmodule
