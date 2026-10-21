                module Galaxy
                module FindSystemByExactName
; -----------------------------------------
; Поиск системы по полному имени среди 256 планет
; исходный диапазон #DF24..#DF5F
; In:
;   GalaxyState.InputBuffer = строка с нулём, State.GalaxySeed = семя галактики
; Out:
;   CY=1 если не найдено, CY=0 и выбранная планета при успехе
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Сохраняет семя до генерации имени, сравнивает побайтно до общего 0, цикл завершает
;   переполнение счётчика GalaxyState.ScanIndex, при совпадении обновляет данные, имя назначения и расстояние,
;   NearestMetric рабочий минимум расстояния
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #DF24
                ; полный перебор 256 систем, имя сравнивается до первого различия или нуля
Entry:          CALL Game.Galaxy.LoadGalaxySeed.Entry
                XOR A
                LD (GalaxyState.ScanIndex), A
NextSystem:     CALL Game.Galaxy.SaveWorkingSystemSeed.Entry
                CALL Game.Galaxy.GenerateSystemName.Entry
                LD HL, GalaxyState.InputBuffer
                LD DE, GalaxyState.GeneratedName
CompareName:    LD B, (HL)
                LD A, (DE)
                CP B
                JR NZ, AdvanceSystem                                            ; переход, если очередные символы названий различаются, перейти к следующей системе

                AND A
                JR Z, SelectFound                                               ; переход, если совпавший символ является нулевым завершителем, система найдена

                INC HL
                INC DE
                JR CompareName

AdvanceSystem:  LD HL, GalaxyState.ScanIndex
                INC (HL)
                JP NZ, NextSystem                                               ; переход, если счётчик 256 систем ещё не обернулся в ноль, продолжить поиск

                SCF
                RET

SelectFound:    CALL Game.Galaxy.RestoreWorkingSystemSeed.Entry
                CALL Game.Charts.MapCursorTransformAndKeys.Entry
                CALL Game.Galaxy.DeriveSystemProperties.Entry
                CALL Game.Charts.MapCursorTransformAndKeys.Entry
                CALL Game.Galaxy.CopySystemNameToTarget.Entry
                JP @Game.Galaxy.FindNearestSystem.SetFuelCost

                ; минимальная квадратичная метрика текущего поиска
NearestMetric   DW #0000                                                        ; наименьшая квадратичная метрика до курсора
                ; проверка исходного конца фрагмента
                ASSERT $ == #DF60
                endmodule
                endmodule
