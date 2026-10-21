                module Combat
                module ApplyPlayerDamage
; -----------------------------------------
; восстановление и расход энергии игрока за такт
; исходный диапазон #9A59..#9A8C
; In:
;   память FlightState.FlightStatus, признак активного полёта
;   память CombatState.EnergyDrain/CombatState.FrontDamage/CombatState.RearDamage, расходы энергии и урон щитам
; Out:
;   обновлены банки энергии, щиты и признак гибели
; Corrupt:
;   HL, DE, BC, AF
; Note:
; Если верхний банк не полон, FlightState.FlightStatus получает #63. Затем применяется восстановление и урон обоим щитам.
; Маскировка CloakActive добавляет единицу расхода энергии. B=4 задаёт четыре шага расхода в хвосте Game.Combat.DrainEnergyBanks.Entry.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #9A59
                ; проверка активности полёта и состояния верхнего банка
Entry:          LD HL, FlightState.FlightStatus
                XOR A
                CP (HL)
                RET Z                                                           ; выход, если полёт не активен

                LD A, (GaugeState + FGaugeState.Energy4.Current)
                CP #A0
                JR Z, RecoverEnergy                                             ; переход, если верхний банк энергии полностью заряжен

                LD A, #63
                LD (FlightState.FlightStatus), A
                ; восстановление энергии перед применением урона щитам
                ; миссия 2 CLOAKING DEVICE, включённая маскировка добавляет единицу к расходу энергии
                ; описание в Docs/Manual.md, раздел mission-2
RecoverEnergy:  CALL Game.Combat.RecoverPlayerEnergy.Entry
                LD HL, GaugeState + FGaugeState.FrontShield.Current
                LD A, (CombatState.FrontDamage)
                CALL Game.Combat.DamageShieldAndEnergy.Entry
                LD HL, GaugeState + FGaugeState.RearShield.Current
                LD A, (CombatState.RearDamage)
                CALL Game.Combat.DamageShieldAndEnergy.Entry
                LD A, (CloakActive)
                AND A
                LD A, (CombatState.EnergyDrain)
                JR Z, DrainCost                                                 ; переход, если маскировка выключена и дополнительного расхода нет

                INC A
DrainCost:      LD C, A
                LD B, #04                                                       ; далее Game.Combat.DrainEnergyBanks.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #9A8D
                endmodule
                endmodule
