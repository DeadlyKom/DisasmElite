                module Combat
                module ProcessCombatControls
; -----------------------------------------
; обработка ракет, спасательной капсулы и дополнительных боевых команд
; исходный диапазон #9A40..#9A58
; In:
;   память FlightState.View, текущий вид
;   память InputState.DeviceKeys, события клавиш
; Out:
;   обновлено состояние оружия и событий
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
; Работает только в четырёх видах кабины. После обработки сохраняет в InputState.DeviceKeys биты 0,4,7.
; Фрагмент без RET продолжается в применение повреждений Game.Combat.ApplyPlayerDamage.Entry.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #9A40
                ; проверка полётного вида перед боевыми командами
Entry:          LD A, (FlightState.View)
                CP #04
                RET NC                                                          ; выход, если текущий экран не относится к видам кабины

                ; обновление индикаторов и обработка ракет, капсулы и расширения
                CALL Game.Combat.UpdateEcmAndDriveIndicators.Entry
                CALL Game.Combat.HandleMissileControls.Entry
                CALL Game.Combat.HandleEscapeCapsule.Entry
                CALL Game.Extensions.EnergyBombAndFlashVectors.Entry
                LD HL, InputState.DeviceKeys
                LD A, (HL)
                AND DEV_KEEP_MASK
                LD (HL), A                                                      ; далее Game.Combat.ApplyPlayerDamage.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #9A59
                endmodule
                endmodule
