                module Combat
                module UpdateAllSpaceObjects
; -----------------------------------------
; полный такт восьми объектов, их поведения, уничтожения и проекции
; исходный диапазон #9CBB..#9E65
; In:
;   восемь записей FSpaceObject от Memory.Station до Memory.Missile и соответствующие записи ObjectEffects.Records
; Out:
;   обновлены объекты, флаги сцены, прицел и графический буфер
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
; В режиме State.Mission3=4 станция становится враждебной. FlightState.XorObjects выбирает OR либо XOR патчами четырёх команд рендера.
; Счётчик CombatState.SpawnCounter управляет появлением объектов, оно запрещается во время специальных режимов и при числе кораблей от 4.
; В начале кадра обнуляются накопители урона и признаки сцены, затем пересчитываются шесть обычных слотов.
; Основной цикл идёт по восьми слотам и 10-байтовым метаданным, номер объекта хранится в ObjectIndex.
; Пустой слот очищает соответствующие метаданные через общий вход Game.Motion.GuideMissileAndCheckImpact.ClearMetadata.
; OBJ_DESTROY_BIT и OBJ_EXPLODE_BIT в FSpaceObject.Flags задают запрос уничтожения и этап взрыва, завершённый объект освобождается с начислением наград
; Обычный объект получает выбор цели Game.Extensions.ChooseLinkedObjectTarget.Entry, ракетное наведение либо периодическую тактику Game.Disk.ReactionOnPrivateStack.Entry.
; Затем применяются движение, ортогонализация, нормализация трёх осей и столкновение.
; Game.Extensions.PrintCargoAndMessageBanks.ProjectSafely вызывает проекцию на специальном стеке, возвращает в обработку флагов и переход к следующему слоту.
; Game.Extensions.DrawCircleAndProtectScratchStack.NextOrFinish выбирает следующую итерацию либо завершение кадра, поэтому собственного RET у этого фрагмента нет.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #9CBB
                ; проверка режима станции и выбор OR/XOR для рендера
                ; миссии 3, 7 INVASION, 7+4, общее состояние 4 делает станцию враждебной
                ; описание в Docs/Manual.md, раздел mission-3, mission-7-invasion, mission-7-4
Entry:          LD A, (State.Mission3)
                CP #04
                JR NZ, SelectRaster                                             ; переход, если режим отличается от 4 и станция не переводится во враждебное состояние

                LD HL, Memory.Station + FSpaceObject.Hostility
                SET OBJ_HOSTILE_BIT, (HL)
SelectRaster:   LD A, (FlightState.XorObjects)
                AND A
                LD A, #B6
                JR Z, PatchRaster                                               ; переход, если режим XOR выключен и рендер использует OR

                LD A, #AE
PatchRaster:    LD (LineRaster.SteepPixel), A
                LD (LineRaster.FirstPixel), A
                LD (LineRaster.FullPixel), A
                LD (LineRaster.LastPixel), A
                ; обновление счётчика появления и проверка допуска нового объекта
                LD A, (CombatState.SpawnCounter)
                DEC A
                LD (CombatState.SpawnCounter), A
                LD B, A
                LD A, (FlightState.StationZone)
                AND A
                JR NZ, ResetFrame                                               ; переход, если игрок находится в зоне станции и создание объектов пропускается

                LD A, (FlightState.SpaceMode)
                AND A
                JR NZ, ResetFrame                                               ; переход, если активно особое пространство и создание обычных объектов пропускается

                LD A, (ActiveShips)
                CP #04
                JR NC, ResetFrame                                               ; переход, если управляемых кораблей уже не меньше четырёх

                LD A, B
                AND A
                CALL Z, Game.Objects.DispatchObjectAction.Entry                 ; вызов процедуры, если счётчик появления объектов достиг нуля
                ; очистка накопителей и признаков нового кадра
ResetFrame:     XOR A
                LD (CombatState.EnergyDrain), A
                LD (CombatState.RearDamage), A
                LD (CombatState.FrontDamage), A
                LD (CombatState.CrosshairTarget), A
                LD (OrdinarySeen), A
                ; сброс признака наличия отображаемого объекта перед новым обходом
                LD (CombatState.ObjectsPresent), A
                LD (CombatState.ShipsPresent), A
                LD C, A
                LD IX, Memory.Objects + 5 * FSpaceObject
                LD DE, -FSpaceObject
                LD B, #06
CountShips:     LD A, (IX+FSpaceObject.Energy)
                AND A
                JR Z, NextCount                                                 ; переход, если проверяемый обычный слот пуст

                BIT OBJ_ACTIVE_BIT, (IX+FSpaceObject.Flags)
                JR Z, NextCount                                                 ; переход, если живой объект не помечен управляемым кораблём

                INC C
NextCount:      ADD IX, DE
                DJNZ CountShips

                LD A, C
                CALL Game.Combat.BeginObjectMetadataPass.Entry
                LD A, D
                LD (Game.Extensions.DrawCompressedEdges.FrameCounter), A
                LD A, #08
                ; начало итерации слота и соответствующей записи метаданных
ProcessSlot:    PUSH AF
                LD B, A
                CALL Game.Wireframe.SetTargetDisplayState.Entry
EnergyRead      EQU $                                                           ; CALL проверки энергии слота, демо заменяет прямым чтением поля объекта
                CALL Game.Menus.ReadVisibleObjectByte.Entry
                AND A
                JP Z, Game.Motion.GuideMissileAndCheckImpact.ClearMetadata      ; переход, если текущий слот пуст и нужно очистить его метаданные

                CALL Game.Extensions.MarkObjectEventAndUpdateMetadata.Entry
                BIT OBJ_SPECIAL_BIT, (IX+FSpaceObject.Flags2)
                JR NZ, SceneFlags                                               ; переход, если объект имеет специальный тип bit2

                LD (OrdinarySeen), A
                ; обновление признаков сцены и массового запроса уничтожения
SceneFlags:     CALL Game.Universe.AdvanceCircularObjectEffect.Entry
                LD A, C
                BIT OBJ_NOTSHIP_BIT, (IX+FSpaceObject.Flags2)
                JR NZ, CheckMassKill                                            ; переход, если объект исключён битом 3 из признака обычного корабля

                LD A, #01
                LD (CombatState.ShipsPresent), A
CheckMassKill:  LD A, (CombatState.DestroyAll)
                AND A
                JR Z, CheckDanger                                               ; переход, если массовое уничтожение не запрошено

                BIT OBJ_SPECIAL_BIT, (IX+FSpaceObject.Flags2)
                JR NZ, CheckDanger                                              ; переход, если особый тип защищён от массового запроса

                LD A, (IY+FModel.MaxSpeed)
                CP #27
                JR Z, CheckDanger                                               ; переход, если скорость модели равна #27 и этот тип исключён из массового запроса

                SET OBJ_DESTROY_BIT, (IX+FSpaceObject.Flags)
                ; проверка опасной обстановки по флагам враждебного объекта
CheckDanger:    BIT OBJ_HOSTILE_BIT, (IX+FSpaceObject.Hostility)
                JR Z, CheckMissile                                              ; переход, если объект не враждебен

                LD A, (IX+FSpaceObject.Hostility)
                AND OBJ_LAW_MASK
                JR Z, CheckMissile                                              ; переход, если у враждебного объекта не установлен ни один из битов 5/6

                LD A, #01
                LD (CombatState.Danger), A
CheckMissile:   LD A, (Memory.Missile + FSpaceObject.Energy)
                AND A
                JR NZ, SetAggression                                            ; переход, если последний ракетный слот занят и требуется расширенная реакция

                LD A, (CombatState.Danger)
                AND A
                JR Z, ReadBlueprint                                             ; переход, если опасная обстановка отсутствует и расширенная реакция не нужна

SetAggression:  CALL Game.Extensions.SetObjectAggressionFlag.Entry
                NOP
                ; поиск модели и разбор стадии уничтожения
ReadBlueprint:  LD H, (IX+FSpaceObject.Blueprint+FSignWord.SignHigh)
                LD L, (IX+FSpaceObject.Blueprint)
                PUSH HL
                POP IY
                LD A, (IX+FSpaceObject.Flags)
                AND OBJ_DEATH_MASK
                JR Z, ScheduleAI                                                ; переход, если объект не находится ни в запросе уничтожения, ни во взрыве

                SUB ObjectFlag.Exploding
                JP NZ, ProjectObject                                            ; переход, если состояние отличается от чистого этапа взрыва #20

                RES OBJ_EXPLODE_BIT, (IX+FSpaceObject.Flags)
                LD (IX+FSpaceObject.Pitch), A
                LD A, #C0
                LD (IX+FSpaceObject.Roll), A
                BIT OBJ_MISSILE_BIT, (IX+FSpaceObject.Flags2)
                JR NZ, ReleaseObject                                            ; переход, если уничтожаемый объект является ракетой

                LD HL, FlightState.SoundRequests
                SET SND_BLAST_BIT, (HL)
                LD A, (MissionPhase)
                AND A
                JR Z, ReleaseObject                                             ; переход, если миссионное состояние нулевое

                CP #03
                JR Z, CheckMission                                              ; переход, если миссия находится в состоянии специального груза 3

                BIT OBJ_MISSION_BIT, (IX+FSpaceObject.Flags2)
                JR Z, ReleaseObject                                             ; переход, если у уничтоженного объекта нет миссионного бита 6

                JR ClearMission

CheckMission:   LD A, (IY+FModel.Collision)
                CP #1E
                JR NZ, ReleaseObject                                            ; переход, если размер модели не равен #1E и миссионное состояние сохраняется

                ; миссия 2 CLOAKING DEVICE, уничтожение миссионного корабля либо контейнера сбрасывает фазу встречи
                ; описание в Docs/Manual.md, раздел mission-2
ClearMission:   XOR A
                LD (MissionPhase), A
                ; освобождение слота, снятие целей и начисление наград
ReleaseObject:  XOR A
                LD (IX+FSpaceObject.Energy), A
                CALL Game.Combat.ReleaseMissileTargets.Entry
                ; денежная награда из модели, в десятых кредита
                LD D, (IY+FModel.Bounty+FSignWord.SignHigh)
                LD E, (IY+FModel.Bounty)
                CALL Game.Universe.AwardUnlinkedDestructionBounty.Entry
                ; рейтинг за уничтожение равен половине 16-битового показателя модели
                LD D, (IY+FModel.Rating+FSignWord.SignHigh)
                LD E, (IY+FModel.Rating)
                SRL D
                RR E
                CALL Game.Universe.AwardOrStoreLinkedDestruction.Entry
                LD A, (IX+FSpaceObject.Hostility)
                AND OBJ_LAW_MASK
                JR Z, NextSlot                                                  ; переход, если объект не имеет битов 5/6 для изменения правового статуса

                PUSH HL
                LD HL, State.LegalStatus
                CALL Game.Input.MarkModelVisibilityMask.Entry
                POP HL
                JR NextSlot

                ; выбор расписания поведения и цели текущего объекта
ScheduleAI:     LD A, B
                XOR C
                AND #0F
                BIT OBJ_ACTIVE_BIT, (IX+FSpaceObject.Flags)
                JR Z, MoveObject                                                ; переход, если объект неуправляемый и тактическое наведение пропускается

                CALL Game.Extensions.ChooseLinkedObjectTarget.Entry
                LD A, C
                JR Z, ScheduleTactic                                            ; переход, если расширенный выбор цели указал обычное поведение вместо ракетного наведения

                CALL Game.Motion.GuideMissileAndCheckImpact.Entry
                JR MoveObject

ScheduleTactic: AND #03
                CALL Z, Game.Disk.ReactionOnPrivateStack.Entry                  ; вызов процедуры, если младшие два бита расписания равны нулю и нужно выполнить тактический шаг
                ; движение, коррекция базиса и проверка столкновения
MoveObject:     CALL Game.Motion.UpdateObjectCoordinatesAndRotation.Entry
                CALL Game.Wireframe.OrthogonalizeObjectYAxis.Entry
                PUSH IX
                LD DE, #0009
                ADD IX, DE
                CALL Game.Motion.RenormalizeAxisHighBytes.Entry
                CALL Game.Motion.RenormalizeAxisHighBytes.Entry
                CALL Game.Motion.RenormalizeAxisHighBytes.Entry
                POP IX
                ; переход на защищённую проекцию объекта
ProjectObject:  CALL Game.Combat.HandleObjectCollision.Entry
                JP Game.Extensions.PrintCargoAndMessageBanks.ProjectSafely

AfterProject:   RES OBJ_LASER_BIT, (IX+FSpaceObject.Flags)
                LD A, (IX+FSpaceObject.Flags)
                AND OBJ_DEATH_MASK
                CP ObjectFlag.Destroy
                JR NZ, NextSlot                                                 ; переход, если состояние объекта отличается от одиночного запроса уничтожения #10

                SET OBJ_EXPLODE_BIT, (IX+FSpaceObject.Flags)
                RES OBJ_DESTROY_BIT, (IX+FSpaceObject.Flags)
                ; переход к следующему слоту и расширенной записи
NextSlot:       POP AF
                CALL Game.Wireframe.AdvanceObjectMetadata.Entry
                ADD IX, DE
                DEC A
                JP Game.Extensions.DrawCircleAndProtectScratchStack.NextOrFinish

                ; проверка исходного конца фрагмента
                ASSERT $ == #9E66
                endmodule
                endmodule
