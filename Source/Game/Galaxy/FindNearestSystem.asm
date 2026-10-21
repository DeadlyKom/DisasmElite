                module Galaxy
                module FindNearestSystem
; -----------------------------------------
; Поиск системы с минимальной метрикой до курсора
; исходный диапазон #DF74..#DFC3
; In:
;   TargetX/TargetY = целевая точка, State.GalaxySeed = семя галактики
; Out:
;   GalaxyState.TargetSeed параметры выбранной планеты, GalaxyState.TargetName имя, GalaxyState.Distance расстояние от текущей системы
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Перебирает 256 семян, сохраняет лучшее 6 байтное семя, равная метрика заменяет прежнего
;   кандидата, затем генерирует данные/имя и повторно измеряет расстояние от State.SystemSeed + FSystemSeed.X/State.SystemSeed + FSystemSeed.Y, точное
;   совпадение координат в Game.Screen.MatchTargetPlanet.Entry немедленно завершает поиск через Game.Galaxy.FindNearestSystem.MeasureNearest со снятием вложенного
;   адреса возврата
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #DF74
                ; перебор систем с хранением минимальной квадратичной метрики в NearestMetric
Entry:          CALL Game.Galaxy.LoadGalaxySeed.Entry
                LD HL, #FFFF
                LD (NearestMetric), HL
                LD B, #00
CheckSystem:    PUSH BC
                LD A, (GalaxyState.WorkingSeed + FSystemSeed.X)
                LD B, A
                LD A, (GalaxyState.WorkingSeed + FSystemSeed.Y)
                CALL Game.Screen.MatchTargetPlanet.Entry
                JR C, AdvanceSystem                                             ; переход, если расчёт метрики дал перенос, эта система не подходит

                EX DE, HL
                LD HL, (NearestMetric)
                AND A
                SBC HL, DE
                JR C, AdvanceSystem                                             ; переход, если сохранённая лучшая метрика меньше новой, оставить прежнюю систему

                LD (NearestMetric), DE
                CALL Game.Galaxy.SaveWorkingSystemSeed.Entry
                ; сохранение найденного лучшего семени и завершение очередного шага поиска
AdvanceSystem:  CALL Game.Galaxy.AdvanceSystemSeed.Entry
                POP BC
                DJNZ CheckSystem

MeasureNearest: LD HL, (NearestMetric)
                AND A
                CALL Game.Galaxy.DistanceMetricToFuel.Entry
                CALL Game.Galaxy.RestoreWorkingSystemSeed.Entry
                CALL Game.Galaxy.DeriveSystemProperties.Entry
                CALL Game.Galaxy.GenerateSystemName.Entry
                CALL Game.Galaxy.CopySystemNameToTarget.Entry
SetFuelCost:    LD A, (State.SystemSeed + FSystemSeed.X)
                LD B, A
                LD A, (State.SystemSeed + FSystemSeed.Y)
                CALL Game.Galaxy.SquaredDistanceToTarget.Entry
                CALL Game.Galaxy.DistanceMetricToFuel.Entry
                AND A
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #DFC4
                endmodule
                endmodule
