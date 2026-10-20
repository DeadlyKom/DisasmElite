                module Travel
                module LaserTypeAndArrivalEvents
; -----------------------------------------
; Выбор типа лазера и обработка прибытия
; исходный диапазон #DDEC..#DE66
; In:
;   AF, A = номер оборудования, BC, B = обычный тип лазера для DDEC
; Out:
;   EB62 = B либо 42 для пункта 15
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   DDF7 отдельный обработчик прибытия, проверяет миссии и совпадение семян, увеличивает 16
;   битный счётчик D063, DE4C ставит D040=1 и сбрасывает экранные/полётные флаги, законность
;   новой системы влияет на дальнейшее событие
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #DDEC
                ; тип лазера 0F заменяется кодом 42 для общего пути вооружения
Entry:          CP #0F
                LD A, #42
                JR Z, StoreLaser                                                ; переход, если тип лазера равен 0F, использовать установленный код 42

                LD A, B
StoreLaser:     LD (EquipmentWork.LaserType), A
                RET

                ; обработка миссионных состояний и счётчика прибытия в новую систему
ArrivalEvents:  LD A, (State.Galaxy)
                AND A
ArrivalGate     EQU $                                                           ; изменяемый JR Z событий прибытия, временный RET подавляет этот хвост
                JR Z, FinishArrival                                             ; переход, если галактика имеет индекс 0, перейти к общим событиям прибытия

                LD HL, Memory.Station + FSpaceObject.Flags2
                BIT 7, (HL)
                RES 7, (HL)
                JR NZ, @Game.Travel.BuildStationGeometry.MissionStage           ; переход, если у объекта установлен бит 7 события, выполнить специальный хвост

                LD HL, State.Mission3
                LD A, (HL)
                AND A
                JR Z, CountArrival                                              ; переход, если третья миссия не активна, перейти к счётчику переходов

                DEC A
                JR NZ, CheckStage                                               ; переход, если состояние третьей миссии не равно 1, проверить следующий этап

                INC (HL)
                JR CheckTarget

CheckStage:     CP #03
                JR NZ, CheckTarget                                              ; переход, если состояние миссии не равно 3, сохранить выбранный этап

                LD (HL), A
CheckTarget:    LD HL, State.SystemSeed
                CALL Game.Menus.CompareSystemSeedToGalaxyBase.Entry
                JR C, CountArrival                                              ; переход, если семя текущей системы отличается от базового, цель миссии не достигнута

                LD A, #04
StoreMission:   LD (State.Mission3), A
CountArrival:   LD HL, State.RankState
                LD A, (HL)
                INC HL
                INC (HL)
                INC HL
                JR NZ, CheckGrant                                               ; переход, если младший байт счётчика переходов не переполнился

                INC (HL)
CheckGrant:     BIT JUMP_MSN_BIT, (HL)
                RES JUMP_MSN_BIT, (HL)
                JR Z, RandomPolice                                              ; переход, если у старшего байта счётчика нет бита 7, специальный допуск не установлен

                LD L, LOW State.MissionFlags
                JR @Game.Travel.GetSalePriceAndMissionFlags.GrantMission

RandomPolice:   LD HL, FlightState.RandomByte
                LD A, (State.Government)
                XOR #FF
                AND #07
                RRA
                CP (HL)
                JR C, FinishArrival                                             ; переход, если номер текущей галактики меньше порога события, пропустить выдачу миссии

                LD HL, Memory.Station + FSpaceObject.Roll
                RES 7, (HL)
FinishArrival:  LD A, #01
                LD (ViewKeyLock), A
                XOR A
                LD (FlightState.View), A
                LD (GaugeState + FGaugeState.CabinHeat.Current), A
                LD (FlightState.SunScooping), A
                LD (AimState), A
                LD (MissionPhase), A
                LD A, #A0
                LD (GaugeState + FGaugeState.Altitude.Current), A
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #DE67
                endmodule
                endmodule
