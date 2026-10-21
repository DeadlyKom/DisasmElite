                module Combat
                module CreateWreckAndDamageState
; -----------------------------------------
; совместимый вход создания обломков и рабочие поля урона
; исходный диапазон #9C9F..#9CAE
; In:
;   состояние полёта
; Out:
;   сцена заменена обломками
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
; Game.Combat.CreateWreckAndDamageState.Entry переходит в Game.Combat.CreatePlayerWreckScene.Entry. Байты CombatState.EnergyDrain/CombatState.FrontDamage/CombatState.RearDamage хранят расход энергии и урон передней/задней защите.
; Game.Combat.CreateWreckAndDamageState.SignedDelta отдельный JP HalfDelta, далее сохранены JP Game.Motion.UpdateObjectCoordinatesAndRotation.Entry, JP Game.Motion.AnimateIntroObject.Entry и рабочий байт OrdinarySeen.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #9C9F
                ; переход к созданию сцены обломков
Entry:          JP Game.Combat.CreatePlayerWreckScene.Entry

                ; данные расхода энергии и двух накопителей урона
EnergyDrain     DB #00                                                          ; накопленный расход энергии за объектный кадр, включая лазер и ECM
FrontDamage     DB #00                                                          ; накопленный урон передней защите от лазеров и столкновений
RearDamage      DB #00                                                          ; накопленный урон задней защите от лазеров и столкновений
                ; отдельный совместимый вход знаковой полуразности
SignedDelta:    JP Game.Math.HalfDelta

                ; сохранённые переходы пересчёта и демонстрации, рабочий байт OrdinarySeen

; -----------------------------------------
; совместимый переход к пересчёту положения и базиса объекта
; In:
;   IX, объект
;   IY, описание модели
; Out:
;   положение, базис и команды вращения обновлены, IX и IY сохраняются
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   сохранённый вход таблицы совместимости, прямые входящие переходы не найдены
; -----------------------------------------
MoveObjects:    ; совместимый переход к пересчёту положения и базиса объекта
                JP Game.Motion.UpdateObjectCoordinatesAndRotation.Entry

; -----------------------------------------
; совместимый переход к вращению объекта демонстрации
; In:
;   память Memory.Missile, демонстрационный объект и указатель модели
; Out:
;   демонстрационный объект повёрнут и выведен через Game.Motion.AnimateIntroObject.Entry
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
;   сохранённый вход таблицы совместимости, прямые входящие переходы не найдены
; -----------------------------------------
RotateDemo:     ; совместимый переход к вращению объекта демонстрации
                JP Game.Motion.AnimateIntroObject.Entry

                ; исходные байты вне раскрываемого входа
OrdinarySeen    DB #00                                                          ; энергия последнего живого объекта без Flags2.bit2, ноль если таких объектов нет
                ; проверка исходного конца фрагмента
                ASSERT $ == #9CAF
                endmodule
                endmodule
