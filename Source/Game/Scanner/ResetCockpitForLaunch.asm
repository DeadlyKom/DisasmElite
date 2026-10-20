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
;   9C18 обновляет запас ракет, D0DA очищает очередь сообщения
;   Обнуляются прицел ракеты D047, нагрев лазера 70F0, нагрев кабины 70EE, автопилот 7129,9C9B и таймер
;   капсулы 9C1B
;   Последняя DJNZ падает в 9974 для обновления атрибутов приборов
;   Высота 70F2 устанавливается 160, энергия хранится в четырёх банках 70F6/70F8/70FA/70FC
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
                DJNZ ResetDevice
                ASSERT $ == #9974
                endmodule
                endmodule
