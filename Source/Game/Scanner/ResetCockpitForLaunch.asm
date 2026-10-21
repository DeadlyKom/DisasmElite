                module Scanner
                module ResetCockpitForLaunch
; -----------------------------------------
; Начальные щиты, энергия и состояния приборов после старта
; исходный диапазон #9946..#9973
; In:
;   поля полёта, очередь сообщения и ракетное вооружение
; Out:
;   щиты, высота и четыре банка энергии равны 160, временные состояния сброшены
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Game.Combat.PrintMissileStock.Entry обновляет запас ракет, Game.Missions.DispatchMissionEvents.Entry очищает очередь сообщения
;   Обнуляются прицел ракеты AimState, нагрев лазера GaugeState + FGaugeState.LaserHeat.Current, нагрев кабины GaugeState + FGaugeState.CabinHeat.Current, автопилот FlightState.AutoDock,CombatState.EcmTimer и таймер
;   капсулы MissileCount
;   Последняя DJNZ падает в Game.Scanner.SetCockpitDeviceAttributes.Entry для обновления атрибутов приборов
;   Высота GaugeState + FGaugeState.Altitude.Current устанавливается 160, энергия хранится в четырёх банках GaugeState + FGaugeState.Energy1.Current/GaugeState + FGaugeState.Energy2.Current/GaugeState + FGaugeState.Energy3.Current/GaugeState + FGaugeState.Energy4.Current
; -----------------------------------------
                ASSERT $ == #9946
                ; запас ракет и очередь сообщений обновляются перед стартом
Entry:          CALL Game.Combat.PrintMissileStock.Entry
                CALL Game.Missions.DispatchMissionEvents.Entry
                ; сброс прицела, температур, автопилота и таймеров
                XOR A
                LD (AimState), A
                LD (GaugeState + FGaugeState.LaserHeat.Current), A
                LD (GaugeState + FGaugeState.CabinHeat.Current), A
                LD (FlightState.AutoDock), A
                LD (CombatState.EcmTimer), A
                LD (MissileCount), A
                ; полные щиты, максимальная высота и четыре банка энергии
                LD A, #A0
                LD (GaugeState + FGaugeState.FrontShield.Current), A
                LD (GaugeState + FGaugeState.RearShield.Current), A
                LD (GaugeState + FGaugeState.Altitude.Current), A
                LD HL, GaugeState + FGaugeState.Energy1.Current
                LD B, #04
ResetDevice:    LD (HL), A
                INC HL
                INC HL
                DJNZ ResetDevice                                                ; далее Game.Scanner.SetCockpitDeviceAttributes.Entry без команды перехода
                ASSERT $ == #9974
                endmodule
                endmodule
