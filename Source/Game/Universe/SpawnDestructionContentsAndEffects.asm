                module Universe
                module SpawnDestructionContentsAndEffects
; -----------------------------------------
; создание содержимого уничтоженного объекта и расширенные эффекты его проекции
; исходный диапазон #7DC5..#7EA8
; In:
;   BC, C содержит мощность лазера для условия C=32
;   AF, Z отражает проверку OBJ_DESTROY_BIT поля FSpaceObject.Flags при отдельном входе Game.Universe.SpawnDestructionContentsAndEffects.RenderEffects
;   IX, объект
;   IY, модель
; Out:
;   созданы объекты содержимого либо обновлены энергия и графический эффект
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
; Основной вход выбирает действие 6 для миссионного содержимого либо непустого младшего типа модели.
; При максимальной энергии модели от 55 выбирается действие 5, при энергии 3C и мощности 32 действие 8.
; Отдельный Game.Universe.SpawnDestructionContentsAndEffects.RenderEffects вызывается из проекции Game.Motion.ProjectObjectAndSelectDetail.Entry, запрос уничтожения передаётся в Game.Wireframe.StartObjectExplosion.Entry.
; Без запроса тип A0 запускает концентрические окружности, bit3 другого типа управляет энергетическим эффектом.
; Энергетический эффект выбирает маску 78/38/0C по энергии, вращениями извлекает соответствующий бит записи.
; Единичный бит увеличивает энергию и возвращает обычный вывод, нулевой уменьшает энергию и скрывает каркас.
; Круговой эффект уменьшает исходный радиус на фазу с нижним пределом 4 и рисует от 2 до 5 окружностей.
; После каждого круга радиус растёт на удвоенный текущий счётчик, фазы 0..2 дополнительно показывают каркас.
; Game.Motion.ProjectObjectAndSelectDetail.CheckMission и Game.Wireframe.DrawWireframeObject.CheckLaser являются двумя внешними продолжениями, собственного общего RET у эффектов нет.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #7DC5
                ; проверка миссионного содержимого уничтоженного объекта
                ; миссия 2 CLOAKING DEVICE, уничтожение миссионного корабля переводит встречу в фазу специального контейнера
                ; описание в Docs/Manual.md, раздел mission-2
Entry:          BIT OBJ_MISSION_BIT, (IX+FSpaceObject.Flags2)
                JR Z, NormalLoot                                                ; переход, если объект не помечен миссионным bit6

                LD A, (MissionPhase)
                AND A
                JR Z, NormalLoot                                                ; переход, если миссионное состояние нулевое

                CP #03
                JR Z, NormalLoot                                                ; переход, если миссия уже находится в состоянии 3

                LD A, #03
                LD (MissionPhase), A
                ADD A, A
                JR SpawnAction

                ; выбор обычного содержимого по полям модели
NormalLoot:     LD H, (IX+FSpaceObject.Blueprint+1)
                LD L, (IX+FSpaceObject.Blueprint)
                LD A, (HL)
                AND MODEL_LOOT_MASK
                LD A, #06
                JR NZ, SpawnAction                                              ; переход, если модель задаёт непустой младший тип содержимого

                LD DE, #0007
                ADD HL, DE
                LD A, (HL)
                CP #55
                LD A, #05
                JR NC, SpawnAction                                              ; переход, если максимальная энергия модели не меньше 55

                LD A, (HL)
                CP #3C
                RET NZ                                                          ; выход, если максимальная энергия модели отличается от 3C

                LD A, C
                CP #32
                RET NZ                                                          ; выход, если мощность лазера отличается от 32

                LD A, #08
                ; передача выбранного действия диспетчеру объектов
SpawnAction:    JP Game.Objects.DispatchObjectAction.Entry

                ; отдельный вход расширенных эффектов после проекции
RenderEffects:  JR Z, CheckEffects                                              ; переход, если запрос уничтожения отсутствует и нужно проверить обычные эффекты

                CALL Game.Extensions.GetViewAdjustedProjectedPoint.Entry
                CALL Game.Extensions.StorePairedObjectDirections.Entry
                JP Game.Wireframe.StartObjectExplosion.Entry

                ; проверка типа кругового либо энергетического эффекта
CheckEffects:   LD HL, (ObjectEffects.Current)
                LD A, (HL)
                AND EffectRecord.TypeMask
                CP EffectRecord.CircleType
                JR Z, CircleRadius                                              ; переход, если тип записи соответствует круговому эффекту A0

                BIT FX_ENERGY_BIT, A
                JP Z, Game.Motion.ProjectObjectAndSelectDetail.CheckMission     ; переход, если bit3 записи сброшен и продолжается обычная проекция

                ; расчёт изменения энергии по выбранному биту записи
                CALL Game.Extensions.GetViewAdjustedProjectedPoint.Entry
                CALL Game.Extensions.StorePairedObjectDirections.Entry
                INC HL
                LD A, (IX+FSpaceObject.Flags)
                AND A
                JR Z, CheckWireframe                                            ; переход, если байт управления объекта нулевой и его каркас скрывается

                LD A, (IX+FSpaceObject.Energy)
                LD E, #78
                CP E
                JR NC, SelectBit                                                ; переход, если энергия не меньше 78 и выбирается верхняя маска

                LD E, #38
                CP E
                JR NC, SelectBit                                                ; переход, если энергия не меньше 38 и выбирается средняя маска

                LD E, #0C
SelectBit:      LD A, (HL)
FindMaskBit:    RRC E
                JR C, ApplyEnergy                                               ; переход, если найден младший единичный бит выбранной маски

                RRCA
                JR FindMaskBit

ApplyEnergy:    RRCA
                INC (IX+FSpaceObject.Energy)
                JR C, CheckWireframe                                            ; переход, если выбранный бит записи единичный, энергия увеличена и каркас сохраняется

                DEC (IX+FSpaceObject.Energy)
                DEC (IX+FSpaceObject.Energy)
                JR FinishObject

                ; расчёт радиуса и количества концентрических окружностей
CircleRadius:   LD A, (HL)
                AND EffectRecord.PhaseMask
                LD B, A
                LD A, (ProjectedRadius)
                SUB B
                JR C, MinimumRadius                                             ; переход, если вычитание фазы из радиуса дало заём

                CP #04
                JR NC, CircleCenter                                             ; переход, если полученный радиус не меньше 4

MinimumRadius:  LD A, #04
CircleCenter:   LD H, A
                LD A, (FlightState.View)
                RRCA
                LD A, (ProjectionState.Flags)
                JR C, PackSigns                                                 ; переход, если направление камеры не требует инверсии горизонтального знака

                XOR PROJ_NEGX_MASK
PackSigns:      LD C, A
                XOR A
                RR C
                RLA
                RR C
                RLA
                XOR CIRC_PROJ_XOR
                LD L, A
                LD (CircleState.Flags), HL
                LD HL, (ProjectionState.ScreenX)
                EX DE, HL
                LD L, D
                LD H, E
                LD (CircleState.OffsetY), HL
                LD C, B
                LD A, B
                BIT FX_PHASE4_BIT, A
                JR Z, CircleCount                                               ; переход, если фаза меньше 4 и отражать счётчик окружностей не нужно

                XOR #07
CircleCount:    LD B, A
                INC B
                INC B
                ; вывод очередной окружности и увеличение радиуса
DrawRing:       PUSH BC
                CALL Game.Screen.DrawCircleOutline.Entry
                LD HL, CircleState.Radius
                LD A, (HL)
                POP BC
                ADD A, B
                ADD A, B
                LD (HL), A
                DJNZ DrawRing

                ; выбор обычного каркаса либо скрытого завершения
                LD A, C
                CP #03
CheckWireframe: JP C, Game.Motion.ProjectObjectAndSelectDetail.CheckMission     ; переход, если фаза эффекта меньше 3 и дополнительно выводится обычный каркас

                CALL Game.Extensions.GetViewAdjustedProjectedPoint.Entry
                CALL Game.Extensions.StorePairedObjectDirections.Entry
FinishObject:   JP Game.Wireframe.DrawWireframeObject.CheckLaser

                ; проверка исходного конца фрагмента
                ASSERT $ == #7EA9
                endmodule
                endmodule
