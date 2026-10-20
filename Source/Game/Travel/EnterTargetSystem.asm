                module Travel
                module EnterTargetSystem
; -----------------------------------------
; Установка новой текущей системы после гиперперехода
; исходный диапазон #DCE9..#DD47
; In:
;   DEBA..DEBF = семя выбранной планеты, DEED = её имя
; Out:
;   D096..D09B и DEE4 обновлены, установлены параметры нового пространства
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   D8DD возвращает HL=DEBA и выставляет E07A, копирует 6 байт семени и 8 байт имени, сохраняет
;   технологию/правительство, обновляет рынок и 18 байт геометрии 7107..7118, затем формирует
;   станцию через DD60
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #DCE9
                ; копирование выбранного семени в текущую систему и пересоздание окружения
Entry:          XOR A
                LD (FlightState.SpaceMode), A
                CALL Game.Text.BeginSystemLaunchState.Entry
                LD DE, State.SystemSeed
                LD BC, #0006
                LDIR
                ; имя выбранной планеты становится именем текущей системы
                LD HL, GalaxyState.TargetName
                LD DE, GalaxyState.CurrentName
                LD BC, #0008
                LDIR
                LD A, (GalaxyState.Technology)
                LD (State.Technology), A
                LD A, (GalaxyState.Government)
                LD (State.Government), A
                CALL Game.Trade.RefreshMarketRandom.Entry
                LD B, #12
                XOR A
                LD HL, FlightState.Sun
ClearBodies:    LD (HL), A
                INC HL
                DJNZ ClearBodies

                LD A, #FF
                LD (FlightState.StationFar), A
                LD HL, Game.Travel.SetFuelAndGauge.SeedPrefix
                LD DE, FlightState.Sun - 1
                LD BC, #0003
                CALL Game.Travel.BuildPlanetCoordinateByte.Entry
                CALL Game.Travel.BuildPlanetCoordinateByte.Entry
                CALL Game.Travel.BuildPlanetCoordinateMagnitude.Entry
                INC A
                OR #81
                LD (DE), A
                CALL Game.Travel.BuildPlanetCoordinateByte.Entry
                CALL Game.Travel.BuildPlanetCoordinateByte.Entry
                CALL Game.Travel.BuildPlanetCoordinateMagnitude.Entry
                LD (DE), A
                LD C, (HL)
                CALL Game.Travel.BuildStationGeometry.Entry
                JP @Game.Travel.LaserTypeAndArrivalEvents.ArrivalEvents
                ; проверка исходного конца фрагмента
                ASSERT $ == #DD48
                endmodule
                endmodule
