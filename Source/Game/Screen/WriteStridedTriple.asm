                module Screen
                module WriteStridedTriple
; -----------------------------------------
; запись трёх значений с шагом DE и общий хвост ближнего компаса
; In:
;   HL, адрес первого значения
;   DE, шаг и значение D
;   AF, A содержит третье значение
; Out:
;   HL, исходный адрес плюс 3*DE
;   записаны D, D, A с шагом DE
; Corrupt:
;   HL, AF
; Note:
;   вход Entry заканчивается собственным RET, BC, DE и A сохраняются
;   независимый вход Game.Screen.WriteStridedTriple.PlanetIsNear продолжает UpdateCelestialProximity
;   близкая планета проверяется на столкновение, затем устанавливается высота
;   для компаса безусловно выбирается слот станции Memory.Station
;   при FlightState.StationFar=#FF длина берётся по старшим словам, иначе по младшим
;   для нормирования нулевая длина заменяется #FFFF, чтобы избежать нулевого делителя
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #8217
                ; заполнение трёх разреженных полей и продвижение указателя
Entry:          LD (HL), D
                ADD HL, DE
                LD (HL), D
                ADD HL, DE
                LD (HL), A
                ADD HL, DE
                RET

                ; общий хвост обработки близкой планеты, переход из Game.Screen.UpdateCelestialProximity.Entry
PlanetIsNear:   LD A, #01
                LD (CompassState.PlanetNear), A
                JR NZ, SelectStation                                            ; переход, если старшие координаты требуют обработки станции без высоты

                CALL Game.Screen.VectorLength.Entry
                LD A, H
                OR L
                JR Z, SelectStation                                             ; переход, если длина вектора планеты обнулилась

                EX DE, HL
                LD HL, #0000
                SBC HL, DE
                EX DE, HL
                LD HL, #4000
                AND A
                SBC HL, DE
                JP C, Game.Screen.SetGameOver.Entry                             ; переход, если расстояние соответствует столкновению с планетой

                EX DE, HL
                CALL Game.Screen.ScaleProximity.Entry
                LD A, #A0
                SUB H
                LD (GaugeState + FGaugeState.Altitude.Current), A
                ; выбор станции для ближнего указателя компаса
SelectStation:  LD A, #01
                LD (FlightState.StationZone), A
                LD A, (FlightState.StationFar)
                INC A
                LD IX, Memory.Station
                JR Z, Game.Screen.CompassNearAxis.HighWordLength                ; переход, если FlightState.StationFar=#FF, станционный вектор нормируется по старшим словам

                CALL Game.Screen.VectorLength.Entry
                LD A, H
                OR L
                JR NZ, NormalizeX                                               ; переход, если делитель ненулевой

                DEC HL
                ; нормирование первой координаты компаса с сохранением общей длины
NormalizeX:     EX DE, HL
                PUSH DE
                CALL Game.Screen.CompassNearAxis.Entry
                LD (CompassState.X), A
                INC IX
                INC IX
                INC IX
                POP DE
                CALL Game.Screen.CompassNearAxis.Entry
                JR Game.Screen.CompassNearAxis.StoreCompassY

                ASSERT $ == #8271
                endmodule
                endmodule
