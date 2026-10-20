                module Flight
                module LaunchOrDockShip
; -----------------------------------------
; Постановочная последовательность старта либо стыковки
; исходный диапазон #93ED..#94F3
; In:
;   7103 межзвёздный режим,7104 текущее состояние полёта
; Out:
;   при стыковке 7104=0 и возврат к меню, при запуске 7104=4 и возврат в полёт
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
;   Общая настройка выбирает 8 колец 93E3, порог 48 (#30) и фазы D03F/D040=1
;   Стыковка фиксирует скорость 12, блокирует ручное управление, выполняет 47 кадров и проверяет
;   предложение Mk4
;   Запуск очищает объекты, задаёт положение станции и светил, рисует 36 кадров первой фазы и 11 второй
;   Пороговые JR и CP тоннеля задаются патчами 932B/9326, после 47 кадров запуска блокировка 7124
;   снимается, исполнение продолжается 94F4
; -----------------------------------------
                ASSERT $ == #93ED
                ; проверка обычного пространства перед запуском или посадкой
Entry:          LD A, (FlightState.SpaceMode)
                AND A
                RET NZ                                                          ; выход, если особый режим пространства запрещает запуск или стыковку

                ; восемь колец, порог 48 и начальное время 64 для стыковочного туннеля
                LD HL, DockDepths
                LD (TunnelDepths), HL
                LD A, #08
                LD (TunnelRings), A
                LD A, #30
                LD (TunnelLimit), A
                LD A, #40
                LD (TunnelFrames), A
                LD HL, #0101
                LD (JumpMode), HL
                ; выбор направления перехода по полётному сигналу 7104
                LD A, (FlightState.FlightStatus)
                AND A
                JR Z, LaunchStation                                             ; переход, если корабль находится на станции, выполнить старт

                ; стыковка выбирает хвост 9364 и блокирует управление
                LD A, #38
                LD (TunnelFinish), A
                LD A, #0C
                LD (FlightState.Speed), A
                XOR A
                LD (FlightState.Pitch), A
                LD (FlightState.Roll), A
                LD (CombatState.EcmTimer), A
                INC A
                LD (FlightState.ControlsLocked), A
                ; снятие активности ECM перед сорока семью кадрами посадки
                LD HL, State.ECM
                RES ECM_ON_BIT, (HL)
                CALL Game.Screen.ClearFlightBuffer.Entry
                CALL Game.Flight.DrawTransitionTunnelIfActive.Entry
                LD B, #2F
DockFrame:      PUSH BC
                CALL Game.Screen.ClearFlightBuffer.Entry
                CALL Game.Flight.DrawTransitionTunnelIfActive.Entry
                CALL Game.Screen.CopyFlightView.Entry
                POP BC
                DJNZ DockFrame

                ; завершение посадки, сохранение кабины, предложение Mk4 и сообщение
                CALL Game.Sound.PlayLaunchSound.Entry
                XOR A
                LD (FlightState.FlightStatus), A
                CALL Game.Screen.SaveCockpit.Entry
                CALL Game.Flight.ResetFlightControls.Entry
                CALL Game.Extensions.OfferUpgradeAndCorrectPosition.Entry
                CALL Game.Flight.ReportBoardingAndReturnToTitle.Entry
                ; сохранённый хвост после невозвращающегося 728D, отдельный путь счётчика
                LD A, #07
                JP Game.Extensions.FillBackwardAndCountDemo.CountDemo

                ; старт со станции задаёт зелёный полётный сигнал 4
LaunchStation:  LD A, #04
                LD (FlightState.FlightStatus), A
                CALL Game.Sound.PlayLaunchSound.Entry
                ; сброс временных полей, инициализация генератора и хвост 935E
                XOR A
                LD (CombatState.DockRequest), A
                LD (FlightState.View), A
                LD (FlightState.StationFar), A
RestoreCall     EQU $ + 1                                                       ; операнд CALL восстановления маскировки и случайного параметра полёта
                CALL Game.Trade.ResetCloakingAndSeedFlightRandom.Entry
                LD A, #32
                LD (TunnelFinish), A
                ; подготовка щитов, энергии, кабины и цвета первой миссии
                CALL Game.Screen.RestoreCockpitIfNeeded.Entry
                CALL Game.Scanner.ResetCockpitForLaunch.Entry
                CALL Game.Flight.MarkMissionViewInitialized.Entry
                ; начальное положение планеты и изменение знака Z солнца
                LD HL, FlightState.Planet
                LD B, #07
                CALL Game.Flight.ClearBytes.Entry
                LD (HL), #80
                INC HL
                LD (HL), #01
                LD A, (FlightState.Sun + 2 * FCoordinate + FCoordinate.SignHigh)
                XOR #80
                LD (FlightState.Sun + 2 * FCoordinate + FCoordinate.SignHigh), A
                ; очистка 27 байтов геометрии станции перед установкой базиса
                LD HL, Memory.Station
                LD B, #1B
                CALL Game.Flight.ClearBytes.Entry
                LD IX, Memory.Station
                ; станция по отрицательной Z, диагональные элементы базиса равны 7F
                LD A, #F0
                LD (IX+FSpaceObject.Z.Fraction), A
                LD A, #80
                LD (IX+FSpaceObject.Z.SignHigh), A
                DEC A
                LD (IX+FSpaceObject.AxisX.Z+FSignWord.SignHigh), A
                LD (IX+FSpaceObject.AxisY.Y+FSignWord.SignHigh), A
                LD (IX+FSpaceObject.AxisZ.X+FSignWord.SignHigh), A
                LD A, #F0
                LD (IX+FSpaceObject.Energy), A
                ; очистка прочих объектов и первые 36 кадров старта
                CALL Game.Flight.ClearNearbyShipSlots.Entry
                CALL Game.Screen.UpdateIndicators.Entry
                CALL Game.Screen.ClearFlightBuffer.Entry
                CALL Game.Flight.DrawTransitionTunnelIfActive.Entry
                LD B, #24
LaunchFrame:    PUSH BC
                CALL Game.Screen.ClearFlightBuffer.Entry
                CALL Game.Universe.DrawStarsWithJumpEffect.Entry
                CALL Game.Flight.DrawTransitionTunnelIfActive.Entry
                CALL Game.Screen.CopyFlightView.Entry
                POP BC
                DJNZ LaunchFrame

                ; последние 11 кадров дополнительно обновляют координаты и рисуют планету
                LD B, #0B
FinalFrame:     PUSH BC
                CALL Game.Screen.ClearFlightBuffer.Entry
                CALL Game.Universe.UpdateCelestialCoordinates.Entry
                CALL Game.Universe.DrawStarsWithJumpEffect.Entry
                CALL Game.Flight.DrawTransitionTunnelIfActive.Entry
                CALL Game.Universe.DrawSunAndPlanet.Entry
                CALL Game.Screen.CopyFlightView.Entry
                POP BC
                DJNZ FinalFrame

                ; снятие блокировки и общий сброс управления
                XOR A
                LD (FlightState.ControlsLocked), A
                ASSERT $ == #94F4
                endmodule
                endmodule
