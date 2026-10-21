                module Motion
                module ProjectObjectAndSelectDetail
; -----------------------------------------
; проекция объекта, отсечение и выбор каркаса либо дальней точки
; исходный диапазон #A6DF..#A83B
; In:
;   IX, объект
;   IY, описание модели
;   память ObjectEffects.Current, указатель расширенных метаданных объекта
; Out:
;   память ProjectionState.Depth, глубина
;   память ProjectionState.ScreenX/ProjectionState.ScreenY/ProjectionState.Flags, проекция центра и знаки
;   память ProjectedRadius, экранный радиус
;   графический буфер и флаги прицеливания обновлены
; Corrupt:
;   HL, DE, BC, AF
; Note:
; Game.Text.InvalidateObjectLineCache.Entry сначала сбрасывает два поля метаданных в FF и возвращает текущий вид.
; Для переднего/заднего вида глубина Z, для боковых X, знак выбирается направлением камеры.
; Делитель Game.Wireframe.DivideProjectionRatio.Entry строит проекции координат и радиуса, затем проверяется пересечение с областью 256×128.
; Проверка близости к прицелу содержит патч LD A,0/NOP/NOP, поэтому CombatState.CrosshairTarget этой ветвью только обнуляется.
; Переход Game.Universe.SpawnDestructionContentsAndEffects.RenderEffects обрабатывает уничтожение и расширенные эффекты, обычный возврат потока в Game.Motion.ProjectObjectAndSelectDetail.CheckMission.
; в первой фазе второй миссии OBJ_MISSION_BIT в FSpaceObject.Flags2 скрывает каркас
; Близкий объект рисуется каркасом, далёкий блоком 2×2 пикселя. Общий хвост всегда обрабатывает лазер.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #A6DF
                ; сброс расширенных метаданных проекции и проверка типа экрана
Entry:          CALL Game.Text.InvalidateObjectLineCache.Entry
                LD B, A
                CP #04
                RET NC                                                          ; выход, если текущий экран не относится к четырём видам из кабины

                ; выбор оси глубины и проверка полупространства камеры
                PUSH IX
                POP HL
                BIT 1, A
                JR NZ, ReadDepth                                                ; переход, если выбран боковой вид и глубиной служит X

                LD DE, #0006
                ADD HL, DE
ReadDepth:      LD E, (HL)
                INC HL
                LD D, (HL)
                INC HL
                LD C, (HL)
                SRL A
                XOR B
                RRCA
                XOR C
                AND #80
                RET NZ                                                          ; выход, если объект лежит за камерой для выбранного направления

                ; проверка ближнего порога модели
                LD (ProjectionState.Depth), DE
                LD H, #00
                LD L, (IY + FModel.Collision)
                PUSH HL
                AND A
                SBC HL, DE
                JR C, ProjectCenter                                             ; переход, если глубина больше ближнего порога модели

                POP HL
                RET

                ; расчёт проекции центра для выбранного вида
ProjectCenter:  PUSH DE
                PUSH DE
                BIT 1, B
                JR NZ, ProjectSide                                              ; переход, если выбран боковой вид и горизонтальная координата строится из Z

                EX DE, HL
                LD D, (IX + FSpaceObject.X.Low)
                LD E, (IX + FSpaceObject.X.Fraction)
                XOR A
                LD C, A
                CALL Game.Wireframe.DivideProjectionRatio.Entry
                LD A, C
                LD (ProjectionState.ScreenX), A
                POP HL
                LD D, (IX + FSpaceObject.Y.Low)
                LD E, (IX + FSpaceObject.Y.Fraction)
                XOR A
                LD C, A
                CALL Game.Wireframe.DivideProjectionRatio.Entry
                LD A, C
                LD (ProjectionState.ScreenY), A
                LD B, (IX + FSpaceObject.X.SignHigh)
                JP PackProjection

ProjectSide:    EX DE, HL
                LD D, (IX + FSpaceObject.Z.Low)
                LD E, (IX + FSpaceObject.Z.Fraction)
                XOR A
                LD C, A
                CALL Game.Wireframe.DivideProjectionRatio.Entry
                LD A, C
                LD (ProjectionState.ScreenX), A
                POP HL
                LD D, (IX + FSpaceObject.Y.Low)
                LD E, (IX + FSpaceObject.Y.Fraction)
                XOR A
                LD C, A
                CALL Game.Wireframe.DivideProjectionRatio.Entry
                LD A, C
                LD (ProjectionState.ScreenY), A
                LD B, (IX + FSpaceObject.Z.SignHigh)
                ; упаковка знаков проекции и расчёт экранного радиуса
PackProjection: LD A, (IX + FSpaceObject.Y.SignHigh)
                SLA B
                RLA
                RLA
                LD (ProjectionState.Flags), A
                POP HL
                POP DE
                XOR A
                LD C, A
                CALL Game.Wireframe.DivideProjectionRatio.Entry
                LD H, C
                LD A, C
                LD (ProjectedRadius), A
                LD E, C
                ; проверка пересечения проекции с границами обзора
                LD A, (ProjectionState.ScreenY)
                LD C, A
                SUB H
                JR C, CheckWidth                                                ; переход, если радиус уже перекрывает вертикальное отклонение центра

                SUB #40
                JP NC, Game.Wireframe.FinishObjectAndDrawLaser.Entry            ; переход, если объект целиком выходит за вертикальную границу обзора

CheckWidth:     LD A, (ProjectionState.ScreenX)
                LD B, A
                SUB H
                JR C, CheckCrosshair                                            ; переход, если радиус уже перекрывает горизонтальное отклонение центра

                SUB #80
                JP NC, Game.Wireframe.FinishObjectAndDrawLaser.Entry            ; переход, если объект целиком выходит за горизонтальную границу обзора

                ; проверка близости объекта к центру прицела
CheckCrosshair: LD A, B
                ADD A, C
                LD D, A
                JR C, DispatchEffect                                            ; переход, если сумма отклонений центра переполнилась и близость к прицелу не проверяется

                SUB E
                JR NC, CheckAwayMode                                            ; переход, если сумма отклонений не меньше радиуса

                LD A, (IX + FSpaceObject.Z.Low)
                CP #2C
                JR NC, CheckAwayMode                                            ; переход, если глубина не меньше #2C и патч прицеливания не применяется

                ; патч версии, накопитель прицеливания получает только ноль
TargetValue     EQU $ + 1                                                       ; операнд LD A,0, значение записи в номер цели прицела
                LD A, #00
                NOP
                NOP
                LD (CombatState.CrosshairTarget), A
                ; проверка курса враждебного корабля для сброса режима удаления
CheckAwayMode:  BIT OBJ_ACTIVE_BIT, (IX + FSpaceObject.Flags)
                JR Z, DispatchEffect                                            ; переход, если объект не помечен как управляемый корабль

                BIT OBJ_HOSTILE_BIT, (IX + FSpaceObject.Hostility)
                JR Z, DispatchEffect                                            ; переход, если объект не враждебен

                LD A, (FlightState.View)
                BIT 1, A
                LD A, (IX + FSpaceObject.AxisX.Z + FSignWord.SignHigh)
                LD E, (IX + FSpaceObject.Z.Low)
                JR Z, CheckAxis                                                 ; переход, если вид передний либо задний и проверяется продольная компонента

                LD A, (IX + FSpaceObject.AxisX.X + FSignWord.SignHigh)
                LD E, (IX + FSpaceObject.X.Low)
CheckAxis:      LD B, A
                AND #7F
                CP #40
                JR C, DispatchEffect                                            ; переход, если модуль выбранной компоненты оси меньше #40

                LD A, D
                CP #20
                JR NC, DispatchEffect                                           ; переход, если сумма экранных отклонений не меньше #20

                RES OBJ_RETREAT_BIT, (IX + FSpaceObject.Flags2)
                ; передача уничтожения и расширенных эффектов обработчику Game.Universe.SpawnDestructionContentsAndEffects.RenderEffects
DispatchEffect: BIT OBJ_DESTROY_BIT, (IX + FSpaceObject.Flags)
                JP Game.Universe.SpawnDestructionContentsAndEffects.RenderEffects

                ; продолжение после эффектов, проверка миссионной видимости
                ; миссия 2 CLOAKING DEVICE, первая фаза скрывает каркас корабля с миссионным признаком
                ; описание в Docs/Manual.md, раздел mission-2
CheckMission:   LD A, (MissionPhase)
                DEC A
                JR NZ, SelectDetail                                             ; переход, если миссия не находится в первой фазе

                BIT OBJ_MISSION_BIT, (IX + FSpaceObject.Flags2)
                JP NZ, Game.Wireframe.FinishObjectAndDrawLaser.Entry            ; переход, если особый объект скрыт в первой фазе миссии

                ; выбор подробного каркаса либо дальней точки
SelectDetail:   LD HL, (ProjectionState.Depth)
                LD A, H
                CP (IY + FModel.DotDistance)
                JR C, Game.Wireframe.DrawWireframeObject.Entry                  ; переход, если глубина меньше порога модели и нужен подробный каркас

                LD A, (ProjectionState.ScreenX)
                CP #7F
                JP NC, Game.Wireframe.FinishObjectAndDrawLaser.Entry            ; переход, если центр далёкого объекта выходит за допустимую ширину

                LD C, A
                LD A, (ProjectionState.ScreenY)
                CP #3F
                JP NC, Game.Wireframe.FinishObjectAndDrawLaser.Entry            ; переход, если центр далёкого объекта выходит за допустимую высоту

                ; расчёт экранных координат с учётом знаков и зеркалирования
                LD B, A
                LD A, (FlightState.View)
                BIT 0, A
                LD A, (ProjectionState.Flags)
                JR Z, CheckMirrorX                                              ; переход, если вид не требует горизонтального зеркалирования

                XOR PROJ_NEGX_MASK
CheckMirrorX:   LD D, A
                BIT PROJ_NEGX_BIT, D
                JR NZ, SubtractX                                                ; переход, если знак горизонтальной проекции требует вычитания из центра

                LD A, C
                ADD A, #7F
                LD C, A
                JR ProjectY

SubtractX:      LD A, #7F
                SUB C
                LD C, A
ProjectY:       BIT PROJ_POSY_BIT, D
                JR Z, SubtractY                                                 ; переход, если знак вертикальной проекции требует вычитания из центра

                LD A, B
                ADD A, #3F
                LD B, A
                JR DrawFarDot

SubtractY:      LD A, #3F
                SUB B
                LD B, A
                ; создание дальней точки четырьмя XOR-пикселями
DrawFarDot:     CALL Game.Motion.XorFarObjectPixel.Entry
                INC B
                CALL Game.Motion.XorFarObjectPixel.Entry
                INC C
                CALL Game.Motion.XorFarObjectPixel.Entry
                DEC B
                CALL Game.Motion.XorFarObjectPixel.Entry
                JP Game.Wireframe.FinishObjectAndDrawLaser.Entry

                ; проверка исходного конца фрагмента
                ASSERT $ == #A83C
                endmodule
                endmodule
