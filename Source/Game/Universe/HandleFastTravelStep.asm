                module Universe
                module HandleFastTravelStep
; -----------------------------------------
; быстрый перенос небесных тел и станции по команде движения
; исходный диапазон #7EDE..#7F2C
; In:
;   память InputState.ViewJumpKeys.6, команда
;   память FlightState.SpaceMode/FlightState.StationFar/CompassState/CombatState.ShipsPresent, ограничения
; Out:
;   очищены обычные объекты, координаты сдвинуты по Z
;   FastTravel получает 1
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
; Команда снимается сразу после чтения. В обычной системе нужны FlightState.StationFar=FF и нулевое слово CompassState.
; Наличие обычного корабля запрещает перенос. Успех сбрасывает миссионное состояние и очищает окружение.
; Операнд FastSpawnPhase циклически вращается 55/AA, через раз задаёт счётчик появления CombatState.SpawnCounter=1.
; Два CALL сдвигают координаты FlightState.Sun/FlightState.Planet, затем поток падает в Game.Universe.MoveCoordinateDepthBy32.Entry для станции Memory.Station.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #7EDE
                ; чтение и снятие команды быстрого движения
                ; миссия 2 CLOAKING DEVICE, быстрое перемещение обнуляет фазу второй миссии при очистке окружения
                ; описание в Docs/Manual.md, раздел mission-2
Entry:          LD A, (InputState.ViewJumpKeys)
                BIT VIEW_FAST_BIT, A
                PUSH AF
                AND VIEW_FAST_KEEP
                LD (InputState.ViewJumpKeys), A
                POP AF
                RET Z                                                           ; выход, если команда быстрого движения не поступила

                ; проверка геометрических и боевых ограничений
                LD A, (FlightState.SpaceMode)
                AND A
                JR NZ, CheckShips                                               ; переход, если активно особое пространство и геометрические ограничения обходятся

                LD HL, (CompassState.SunNear)
                LD A, (FlightState.StationFar)
                INC A
                OR H
                OR L
                RET NZ                                                          ; выход, если станционный режим либо слово CompassState не допускают быстрого переноса

CheckShips:     LD A, (CombatState.ShipsPresent)
                AND A
                RET NZ                                                          ; выход, если в сцене присутствует обычный корабль

                ; очистка окружения и смена чередующейся фазы
                LD (MissionPhase), A
                LD IX, Memory.Station
                CALL Game.Flight.ClearNearbyShipSlots.Entry
SpawnPhase      EQU $ + 1                                                       ; чередующаяся маска #55/#AA в операнде LD A
                LD A, #55
                NOP
                RRCA
                LD (FastSpawnPhase), A
                LD A, #01
                JR C, StorePhase                                                ; переход, если чередующаяся фаза пропускает сброс счётчика появления

                LD (CombatState.SpawnCounter), A
StorePhase:     LD (FastTravel), A
                ; перенос двух небесных тел и переход к станции
                LD IX, FlightState.Sun
                CALL Game.Universe.MoveCoordinateDepthBy32.Entry
                LD IX, FlightState.Planet
                CALL Game.Universe.MoveCoordinateDepthBy32.Entry
                LD IX, Memory.Station                                           ; далее Game.Universe.MoveCoordinateDepthBy32.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #7F2D
                endmodule
                endmodule
