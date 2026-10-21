                module Universe
                module TryObjectInteraction
; -----------------------------------------
; проверка совместимости и близости двух объектов с нанесением урона
; исходный диапазон #7B81..#7C12
; In:
;   HL, основной слот цели
;   BC, C содержит признаки источника
;   IX, объект-источник
;   IY, расширенная запись цели
; Out:
;   AF, перенос при выполненном взаимодействии
;   IX, исходный источник
;   IY, исходная запись цели
;   ссылки и энергия цели обновлены
; Corrupt:
;   HL, DE, BC
; Note:
; Цель обязана иметь bit7 метаданных. Ветвь без bit6 требует bit2, совпадения номера цели и случайного допуска 1/16.
; Ветвь с bit6 сравнивает младшие двухбитные группы, одинаковые группы не взаимодействуют.
; Проверка трёх целых координат требует расстояние меньше 24 по каждой оси.
; Номер источника ObjectEffects.Remaining записывается в low4 поля+8, прежняя младшая ссылка сдвигается в старшую тетраду.
; Урон равен ((энергия источника>>2) AND3F) XOR0F, это исходная немонотонная формула.
; При заёме ставится запрос уничтожения, создаётся содержимое и энергия цели оставляется 1.
; Точное вычитание до 0 не входит в ветвь заёма и записывает нулевую энергию непосредственно.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #7B81
                ; проверка активности цели и выбор ветви совместимости
Entry:          LD A, (IY+FEffectRecord10.TypeFlags)
                AND A
                BIT FX_ACTIVE_BIT, A
                RET Z                                                           ; выход, если у цели не установлен активный bit7 метаданных

                BIT FX_GROUP_BIT, A
                JR NZ, CompareGroups                                            ; переход, если цель имеет bit6 и проверяется совместимость групп

                ; проверка номера связанной цели и случайного допуска
                BIT FX_ALLOW_BIT, A
                RET Z                                                           ; выход, если в упрощённой ветви у цели отсутствует разрешающий bit2

                PUSH IX
                PUSH HL
                POP IX
                LD A, (ObjectEffects.Remaining)
                XOR (IX+FSpaceObject.Target)
                AND FX_LINK_MASK
                POP IX
                RET NZ                                                          ; выход, если номер цели объекта не совпал с источником ObjectEffects.Remaining

                CALL Game.Combat.NextRandomByte.Entry
                AND #0F
                RET NZ                                                          ; выход, если случайный допуск 1/16 не выполнен

                JR CheckDistance

                ; проверка различия групп и разрешающих признаков
CompareGroups:  LD E, A
                OR C
                AND FX_GROUP_MASK
                RET Z                                                           ; выход, если обе младшие группы нулевые

                LD A, E
                XOR C
                AND FX_GROUP_MASK
                RET Z                                                           ; выход, если младшие группы источника и цели совпадают

                BIT OBJ_MISSILE_BIT, (IX+FSpaceObject.Flags2)
                JR NZ, CheckDistance                                            ; переход, если источник является ракетой и дополнительная проверка bit2 обходится

                BIT FX_ALLOW_BIT, E
                JR NZ, CheckDistance                                            ; переход, если цель имеет разрешающий bit2

                BIT FX_ALLOW_BIT, C
                RET Z                                                           ; выход, если ни источник, ни цель не имеют нужного bit2

                ; проверка близости по трём целым координатам
CheckDistance:  PUSH IY
                PUSH HL
                POP IY
                PUSH IX
                CALL Game.Universe.CompareObjectAxisDistance.Entry
                CALL C, Game.Universe.CompareObjectAxisDistance.Entry           ; вызов процедуры, если первая координата достаточно близка и проверяется вторая
                CALL C, Game.Universe.CompareObjectAxisDistance.Entry           ; вызов процедуры, если предыдущие координаты достаточно близки и проверяется третья
                POP IX
                POP IY
                RET NC                                                          ; выход, если хотя бы одна координата не прошла порог 24

                ; обновление двух упакованных ссылок цели
                LD A, (ObjectEffects.Remaining)
                LD E, A
                LD A, (IY+FEffectRecord10.Links)
                ADD A, A
                ADD A, A
                ADD A, A
                ADD A, A
                OR E
                LD (IY+FEffectRecord10.Links), A
                ; расчёт урона по энергии источника
                PUSH HL
                EX (SP), IY
                LD A, (IX+FSpaceObject.Energy)
                RRCA
                RRCA
                AND #3F
                XOR #0F
                LD E, A
                LD A, (IY+FSpaceObject.Energy)
                SUB E
                JR NC, SetEnergy                                                ; переход, если вычитание урона не вызвало заёма

                ; подготовка уничтожения при недостатке энергии
                SET OBJ_DESTROY_BIT, (IY+FSpaceObject.Flags)
                PUSH HL
                PUSH IX
                PUSH IY
                POP IX
                PUSH IX
                CALL Game.Combat.SpawnDestroyedObjectContents.Entry
                POP IY
                POP IX
                POP HL
                LD A, #01
SetEnergy:      LD (IY+FSpaceObject.Energy), A
                POP IY
                SCF
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #7C13
                endmodule
                endmodule
