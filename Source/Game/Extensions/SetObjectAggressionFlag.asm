                module Extensions
                module SetObjectAggressionFlag
; -----------------------------------------
; разрешение агрессивного поведения объекта
; исходный диапазон #F9C9..#F9E0
; смысловое имя SetObjectAggressionFlag
; In: IX — объект, (State.Mission3) и (ObjectEffects.Flags) — режим окружения
; Out: OBJ_HOSTILE_BIT в FSpaceObject.Hostility установлен, кроме защищённой ветки
; Corrupt: AF
; Режим State.Mission3=4 либо бит 2 ObjectEffects.Flags принудительно разрешают поведение
; В остальных режимах OBJ_NOTSHIP_BIT в FSpaceObject.Flags2 запрещает изменение, все прочие флаги сохраняются
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #F9C9
                ; проверка принудительного режима агрессии
                ; миссии 3, 7 INVASION, общее состояние 4 разрешает агрессивное поведение объекта
                ; описание в Docs/Manual.md, раздел mission-3, mission-7-invasion
Entry:          LD A, (State.Mission3)
                CP #04
                JR Z, EnableAttack                                              ; переход, если State.Mission3 равен 4, установить агрессивное поведение

                LD A, (ObjectEffects.Flags)
                AND 1 << FX_ALLOW_BIT
                JR NZ, EnableAttack                                             ; переход, если бит 2 общего режима установлен, установить агрессивное поведение

                ; проверка признака исключения из обычных кораблей перед включением агрессии
                BIT OBJ_NOTSHIP_BIT, (IX+FSpaceObject.Flags2)
                RET NZ                                                          ; выход, если у объекта установлен бит 3 дополнительных флагов Flags2

                ; установка бита поведения без изменения остальных признаков
EnableAttack:   SET OBJ_HOSTILE_BIT, (IX+FSpaceObject.Hostility)
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #F9E1
                endmodule
                endmodule
