                module Universe
                module UpdateExtendedObjectEffects
; -----------------------------------------
; обновление связей объектов и вывод расширенных лучевых эффектов
; исходный диапазон #7C60..#7D3D
; In:
;   AF, A содержит новый массовый запрос уничтожения
;   восемь объектов и десятибайтовые записи ObjectEffects.Records
; Out:
;   CombatState.DestroyAll обновлён, фаза ObjectEffects.Phase продвинута
;   энергия, ссылки и графический буфер обновлены
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
; Фаза ObjectEffects.Phase циклически использует младшие значения 1,2,3, пропуская 0.
; каждая запись содержит FEffectRecord10.Timer, новая задержка зависит от FSignWord.SignHigh компоненты FSpaceObject.AxisZ.X соответствующего объекта
; Сочетания bit6/bit5 и двухбитной группы выбирают поиск взаимодействия либо превращение записи в эффект A0.
; После успешного взаимодействия рисуется линия между сохранёнными тройками+1..3 и+4..6.
; FF в обоих концах отменяет вывод, один FF заменяется случайной удалённой точкой.
; Game.Universe.UpdateExtendedObjectEffects.LoopOrDraw является двойным входом, перенос от взаимодействия включает вывод, сброшенный перенос следующей итерации ведёт в Game.Universe.UpdateExtendedObjectEffects.ProcessSlot.
; Главный цикл синхронно увеличивает IX на 39 и HL на 10. Замена первымбайтом A0 запускает восьмифазный круговой эффект.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #7C60
                ; сохранение массового запроса и расчёт очередной фазы
Entry:          LD (CombatState.DestroyAll), A
                LD HL, ObjectEffects.Phase
                INC (HL)
                LD A, (HL)
                AND FX_GROUP_MASK
                JR NZ, StartSlots                                               ; переход, если младшая двухбитная фаза ненулевая и пропускать её не нужно

                INC (HL)
                ; подготовка синхронного обхода восьми объектов
StartSlots:     LD IX, Memory.Station
                LD HL, ObjectEffects.Records
                LD A, #08
                ; проверка типа записи и таймера взаимодействия
ProcessSlot:    PUSH AF
                LD (ObjectEffects.Remaining), A
                LD A, (HL)
                AND FX_PAIR_MASK
                XOR FX_PAIR_MASK
                PUSH HL
                POP IY
                JR Z, TickTimer                                                 ; переход, если оба старших бита записи установлены и нужно обновить таймер

                BIT FX_TIMER_BIT, (HL)
                JR Z, CheckCarry                                                ; переход, если bit5 записи сброшен и таймер этой ветви не требуется

TickTimer:      DEC (IY+FEffectRecord10.Timer)
                JR NZ, CheckCarry                                               ; переход, если таймер ещё не истёк

                ; расчёт новой задержки из компоненты ориентации
                LD A, (IX+FSpaceObject.AxisZ.X+FSignWord.SignHigh)
                CPL
                RRCA
                RRCA
                RRCA
                AND #1F
                OR #03
                LD (IY+FEffectRecord10.Timer), A
                ; выбор допуска взаимодействия по типу и состоянию
                BIT FX_GROUP_BIT, (HL)
                JR Z, CheckChance                                               ; переход, если bit6 записи сброшен и выбирается переход к круговому эффекту

                LD A, (IX+FSpaceObject.Flags)
                AND A
                JR Z, CheckCarry                                                ; переход, если байт управления объекта нулевой и взаимодействие пропускается

                BIT FX_TIMER_BIT, (HL)
                JR Z, FindPartner                                               ; переход, если bit5 записи сброшен и можно сразу искать взаимодействие

                LD A, (HL)
                AND FX_GROUP_MASK
                XOR FX_GROUP_MASK
                JR Z, CheckEnergy                                               ; переход, если двухбитная группа равна 3 и используется проверка энергии

                LD A, (Memory.Station + FSpaceObject.Energy)
                AND A
                LD E, #07
                JR NZ, MaskChance                                               ; переход, если станция существует и применяется более узкая случайная маска

                ; проверка энергии и случайных условий запуска эффекта
CheckEnergy:    LD A, (IX+FSpaceObject.Energy)
                LD E, #3F
                CP E
                JR C, MaskChance                                                ; переход, если энергия меньше 3F и применяется непосредственная случайная проверка

                LD A, (IY+FEffectRecord10.Links)
                AND A
                JR Z, ExactChance                                               ; переход, если поле связанных целей нулевое и первая случайная проверка обходится

                CALL Game.Combat.NextRandomByte.Entry
                CP E
                JR C, FindPartner                                               ; переход, если случайное число меньше порога и разрешён поиск взаимодействия

ExactChance:    CALL Game.Combat.NextRandomByte.Entry
                CP E
                JR Z, FindPartner                                               ; переход, если случайное число точно равно порогу и разрешён поиск взаимодействия

MaskChance:     CALL Game.Combat.NextRandomByte.Entry
                AND E
CheckChance:    JR Z, StartCircle                                               ; переход, если случайная маска нулевая либо ветвь без bit6 требует кругового эффекта

                ; поиск участника взаимодействия с временным снятием bit7
FindPartner:    RES FX_ACTIVE_BIT, (HL)
                CALL Game.Universe.FindInteractingObject.Entry
                SET FX_ACTIVE_BIT, (HL)
CheckCarry:     JR NC, NextSlot                                                 ; переход, если взаимодействие не произошло и нужно перейти к следующему слоту

                ; двойной вход продолжения итерации либо вывода эффекта
LoopOrDraw:     JR NC, ProcessSlot                                              ; переход, если перенос сброшен после счётчика цикла и начинается следующая итерация

                LD A, (HL)
                PUSH HL
                PUSH IY
                POP HL
                CALL Game.Wireframe.MergeInverseHostilityFlag.Entry
                POP HL
                LD (HL), A
                ; чтение двух экранных концов и проверка их допустимости
                LD C, (IY+FEffectRecord10.SecondFlags)
                LD D, (IY+FEffectRecord10.SecondX)
                LD E, (IY+FEffectRecord10.SecondY)
                PUSH HL
                PUSH HL
                POP IY
                LD B, (IY+FEffectRecord10.FirstFlags)
                LD H, (IY+FEffectRecord10.FirstX)
                LD L, (IY+FEffectRecord10.FirstY)
                LD A, B
                AND C
                INC A
                JR Z, RestoreRecord                                             ; переход, если оба экранных конца имеют признак FF

                LD A, B
                INC A
                JR NZ, CheckEndpoint                                            ; переход, если первый экранный конец допустим и перестановка не нужна

                LD A, B
                LD B, C
                LD C, A
                EX DE, HL
CheckEndpoint:  LD A, C
                INC A
                JR NZ, PackLine                                                 ; переход, если второй экранный конец допустим и случайная замена не нужна

                ; создание случайного конца для непроецируемой точки
                CALL Game.Combat.NextRandomByte.Entry
                LD C, A
                OR #C0
                LD D, A
                LD E, A
                ; упаковка знаков и вывод линии эффекта
PackLine:       LD A, B
                RRCA
                RRCA
                RL C
                RLCA
                RLCA
                RL C
                CALL Game.Wireframe.DrawClippedLine.Entry
RestoreRecord:  POP HL
                ; переход к следующему объекту и записи
NextSlot:       LD DE, FSpaceObject
                ADD IX, DE
                LD E, #0A
                ADD HL, DE
                POP AF
                DEC A
                AND A
                JR NZ, LoopOrDraw                                               ; переход, если остались необработанные слоты

                RET

                ; создание кругового эффекта A0
StartCircle:    LD (HL), EffectRecord.CircleType
                LD (IY+FEffectRecord10.Timer), H
                JR NextSlot

                ; проверка исходного конца фрагмента
                ASSERT $ == #7D3E
                endmodule
                endmodule
