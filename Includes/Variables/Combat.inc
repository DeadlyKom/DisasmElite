                ifndef _VARIABLES_COMBAT_
                define _VARIABLES_COMBAT_

OrdinarySeen    EQU Game.Combat.CreateWreckAndDamageState.OrdinarySeen          ; энергия последнего живого объекта без Flags2.bit2, ноль если таких объектов нет
MissionPhase    EQU Game.Combat.AnimateIntroAndObjectPipeline.MissionPhase      ; фаза появления особых кораблей второй миссии
ActiveShips     EQU Game.Combat.AnimateIntroAndObjectPipeline.ActiveShips       ; число живых управляемых кораблей среди шести обычных слотов
ObjectIndex     EQU Game.Combat.AnimateIntroAndObjectPipeline.ObjectIndex       ; номер обрабатываемого объекта, 8..1
MissileCount    EQU Game.Combat.PrintMissileStock.MissileCount                  ; сохранённое число ракет для обновления панели
AimState        EQU Game.Interface.DispatchJumpKey.AimState                     ; состояние прицела и выбранной цели
MissileTarget   EQU Game.Missions.DispatchMissionEvents.MissileTarget           ; код захваченной цели ракеты

ShieldHits      EQU Game.Combat.DamageShieldAndEnergy.ShieldHits                ; накопитель пробитий щитов, прибавка 5, повреждение оборудования при значении от 13

                endif                                                           ; ~_VARIABLES_COMBAT_
