                module Screen
                module UpdateCelestialProximity
; -----------------------------------------
; обновление близости солнца, температуры, высоты и компаса
; In:
;   координаты солнца FlightState.Sun и планеты FlightState.Planet, состояние пространства FlightState.SpaceMode
; Out:
;   флаги близости, FlightState.SunScooping, высота GaugeState + FGaugeState.Altitude.Current и указатель компаса обновлены
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   близкое солнце определяется по нулевым модулям старших байтов трёх координат
;   длина вектора сравнивается с порогами #4000 и #2000
;   ветвь Game.Screen.SetGameOver.Entry устанавливает гибель при опасном сближении
;   Game.Screen.ScaleProximity.Entry масштабирует расстояние для температуры или высоты
;   для удалённой планеты используется ветвь дальнего компаса Game.Screen.CompassNearAxis.FarCompass
;   для близкой планеты выполнение переходит непосредственно к Game.Screen.WriteStridedTriple.PlanetIsNear
;   CompassState пересчитывается каждый вызов, FlightState.SunScooping здесь только устанавливается до внешнего сброса
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #81A9
                ; сброс признака близкого солнца и проверка старших разрядов координат
Entry:          XOR A
                LD (CompassState.SunNear), A
                LD IX, FlightState.Sun
                LD A, (FlightState.SpaceMode)
                OR (IX + FCoordinate.SignHigh)
                OR (IX + FCoordinate + FCoordinate.SignHigh)
                OR (IX + FCoordinate + FCoordinate + FCoordinate.SignHigh)
                AND #7F
                NOP
                NOP
                NOP
                NOP
                NOP
                JR NZ, CheckPlanet                                              ; переход, если солнце далеко или корабль находится вне обычной системы

                CALL Game.Screen.VectorLength.Entry
                LD A, H
                OR L
                JR Z, CheckPlanet                                               ; переход, если нормированная длина вектора обнулилась

                LD A, #01
                LD (CompassState.SunNear), A
                ; расчёт расстояния до границы опасного сближения
                EX DE, HL
                LD HL, #0000
                SBC HL, DE
                EX DE, HL
                LD HL, #4000
                AND A
                SBC HL, DE
                JP C, Game.Screen.SetGameOver.Entry                             ; переход, если расстояние попало в область гибели

                ; проверка зоны работы топливных черпаков
                LD HL, #2000
                XOR A
                SBC HL, DE
                JR NC, StoreScooping                                            ; переход, если не требуется устанавливать признак черпаков

                LD A, #01
StoreScooping:  LD (FlightState.SunScooping), A
                EX DE, HL
                CALL Game.Screen.ScaleProximity.Entry
                LD A, H
                CALL Game.Circles.SetCabinHeatAndContinueFilledCircle.Entry
                ; сброс близости планеты и выбор ближнего или дальнего компаса
CheckPlanet:    XOR A
                LD (CompassState.PlanetNear), A
                LD IX, FlightState.Planet
                LD A, (FlightState.SpaceMode)
                AND A
                JR NZ, Game.Screen.CompassNearAxis.FarCompass                   ; переход, если обычная планета отсутствует

                LD A, (IX + FCoordinate.SignHigh)
                OR (IX + FCoordinate + FCoordinate.SignHigh)
                OR (IX + FCoordinate + FCoordinate + FCoordinate.SignHigh)
                AND #7F
                CP #02
                JR NC, Game.Screen.CompassNearAxis.FarCompass                   ; переход, если старший модуль координат планеты не меньше 2

                AND A
                JR Game.Screen.WriteStridedTriple.PlanetIsNear

                ASSERT $ == #8217
                endmodule
                endmodule
