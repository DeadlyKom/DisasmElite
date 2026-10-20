                ifndef _VARIABLES_GRAPHICS_
                define _VARIABLES_GRAPHICS_

CircleState     EQU Game.Screen.WriteIndicatorMask.CircleData.OffsetY           ; адрес структуры FCircleState
.OffsetY        EQU CircleState + FCircleState.OffsetY                          ; модуль вертикального смещения центра
.OffsetX        EQU CircleState + FCircleState.OffsetX                          ; модуль горизонтального смещения центра
.Flags          EQU CircleState + FCircleState.Flags                            ; знаки и признаки диапазона центра, схема в FCircleState
.Radius         EQU CircleState + FCircleState.Radius                           ; радиус окружности в пикселях
.ClipY          EQU CircleState + FCircleState.ClipY                            ; рабочий модуль Y или расстояние до вертикальной границы
.ClipX          EQU CircleState + FCircleState.ClipX                            ; рабочий модуль X или расстояние до боковой границы
.ScreenY        EQU CircleState + FCircleState.ScreenY                          ; экранная строка центра или начало отсечённой дуги
.ScreenX        EQU CircleState + FCircleState.ScreenX                          ; экранный столбец центра
.Cathetus       EQU CircleState + FCircleState.Cathetus                         ; катет точки пересечения круга с границей
.SavedSP        EQU CircleState + FCircleState.SavedSP                          ; реальный стек до временного заполнения или чтения таблицы
.Radicand       EQU CircleState + FCircleState.Radicand                         ; подкоренное значение r*r - d*d - входной перенос
.LeftMask       EQU CircleState + FCircleState.LeftMask                         ; маска левого края перед заполнением строки
.DirectionDown  EQU CircleState + FCircleState.DirectionDown                    ; направление дуги, 0 вверх, 1 вниз
.OutlineOnly    EQU CircleState + FCircleState.OutlineOnly                      ; режим окружности, 0 заливка, 1 только контур
.PatchCount     EQU CircleState + FCircleState.PatchCount                       ; число байтов патча области обзора

ProjectionState EQU Game.Wireframe.AdvanceObjectMetadata.GeometryData.Depth     ; адрес структуры FProjectionState
.Depth          EQU ProjectionState + FProjectionState.Depth                    ; глубина объекта, младший байт затем переиспользуется как уровень детализации
.VertexOffset   EQU ProjectionState + FProjectionState.VertexOffset             ; смещение трёхбайтовой записи в таблице экранных вершин
.X              EQU ProjectionState + FProjectionState.X                        ; повёрнутая X-компонента, затем X с добавленным положением объекта
.Y              EQU ProjectionState + FProjectionState.Y                        ; повёрнутая Y-компонента, затем Y с добавленным положением объекта
.Z              EQU ProjectionState + FProjectionState.Z                        ; повёрнутая Z-компонента, затем Z с добавленным положением объекта
.ScreenX        EQU ProjectionState + FProjectionState.ScreenX                  ; модуль горизонтальной проекции центра или вершины
.ScreenY        EQU ProjectionState + FProjectionState.ScreenY                  ; модуль вертикальной проекции центра или вершины
.Flags          EQU ProjectionState + FProjectionState.Flags                    ; бит 1 знак X, бит 0 знак Y, схема в FProjectionState
.SignX          EQU ProjectionState + FProjectionState.SignX                    ; знаковый старший байт пространственной координаты X
.SignY          EQU ProjectionState + FProjectionState.SignY                    ; знаковый старший байт пространственной координаты Y
.SignZ          EQU ProjectionState + FProjectionState.SignZ                    ; знаковый старший байт пространственной координаты Z
.Scale          EQU ProjectionState + FProjectionState.Scale                    ; число левых сдвигов для повышенной точности ближней вершины
.NoCache        EQU ProjectionState + FProjectionState.NoCache                  ; флаг, произведения предыдущей вершины нельзя использовать

CompassState    EQU Game.Screen.RestrictDockingView.CompassData.SunNear         ; адрес структуры FCompassState
.SunNear        EQU CompassState + FCompassState.SunNear                        ; флаг, солнце в ближнем диапазоне
.PlanetNear     EQU CompassState + FCompassState.PlanetNear                     ; флаг, планета в ближнем диапазоне
.X              EQU CompassState + FCompassState.X                              ; координата X компаса
.Y              EQU CompassState + FCompassState.Y                              ; координата Y компаса
.Behind         EQU CompassState + FCompassState.Behind                         ; флаг, цель за кораблём

RotationState   EQU Game.Motion.ScaleAxisHighByte.RotationData.Roll             ; адрес структуры FRotationState
.Roll           EQU RotationState + FRotationState.Roll                         ; угол крена
.Pitch          EQU RotationState + FRotationState.Pitch                        ; угол тангажа

SteeringVector  EQU Game.Motion.AnimateIntroObject.SteeringData.X               ; адрес структуры FSteeringVector
.X              EQU SteeringVector + FSteeringVector.X                          ; X вектора к цели
.Y              EQU SteeringVector + FSteeringVector.Y                          ; Y вектора к цели
.Z              EQU SteeringVector + FSteeringVector.Z                          ; Z вектора к цели
.Length         EQU SteeringVector + FSteeringVector.Length                     ; длина вектора к цели

DistantBodies   EQU Game.Circles.UpdateThargoidAndBodyCoords.DistantData.FirstX ; два вектора далёких тел
.First          EQU DistantBodies                                               ; первый вектор
.Second         EQU DistantBodies + FSpacePosition                              ; второй вектор
.First.X        EQU DistantBodies.First + FSpacePosition.X                      ; координата X
.First.Y        EQU DistantBodies.First + FSpacePosition.Y                      ; координата Y
.First.Z        EQU DistantBodies.First + FSpacePosition.Z                      ; координата Z
.Second.X       EQU DistantBodies.Second + FSpacePosition.X                     ; координата X
.Second.Y       EQU DistantBodies.Second + FSpacePosition.Y                     ; координата Y
.Second.Z       EQU DistantBodies.Second + FSpacePosition.Z                     ; координата Z

CircleFillWord  EQU Game.Circles.PatchCircleScreenTarget.CircleFillData.Word    ; образец #FFFF для заполнения двух экранных байтов через PUSH AF

CircleRaster    EQU Game.Circles.ComputeLeftEdgeMask.BufferOpcode               ; именованные адреса CircleRaster
.LeftBuffer     EQU Game.Circles.ComputeLeftEdgeMask.BufferOpcode               ; двухбайтовый SET 7,H либо NOP/NOP, выбор буфера левого края
.RightBuffer    EQU Game.Circles.ComputeRightEdgeMask.BufferOpcode              ; двухбайтовый SET 7,H либо NOP/NOP, выбор буфера правого края
.FillTop        EQU Game.Circles.PrepareBothClippedMasksAndFillRows.UpperLimit  ; верхний предел в младшем байте пары предела и кода JR
.FillBottom     EQU Game.Circles.PrepareBothClippedMasksAndFillRows.LowerLimit  ; нижний предел в младшем байте пары предела и кода JR
                ; двухбайтовый SET 7,H либо NOP/NOP для заполнения строк
.FillBuffer     EQU Game.Circles.PrepareBothClippedMasksAndFillRows.BufferOpcode
.RowStep        EQU Game.Circles.PrepareBothClippedMasksAndFillRows.RowStep     ; пара LD A,H/DEC H либо INC H/LD A,H, направление обхода
.CellStep       EQU Game.Circles.PrepareBothClippedMasksAndFillRows.CellStep    ; пара SUB #20 либо ADD A,#20, переход между знакоместами
.ThirdStep      EQU Game.Circles.PrepareBothClippedMasksAndFillRows.ThirdStep   ; пара ADD A,#08 либо SUB #08, коррекция трети экрана
.LimitBranch    EQU Game.Circles.PrepareBothClippedMasksAndFillRows.LimitBranch ; операнд CP и код следующего JR, предел и условие продолжения
.BothTop        EQU Game.Circles.BeginFilledUnclippedHalf.UpperLimit            ; верхний предел заполнения круга без бокового отсечения
.BothBottom     EQU Game.Circles.BeginFilledUnclippedHalf.LowerLimit            ; нижний предел заполнения круга без бокового отсечения
.BothPairJump   EQU Game.Circles.SetCabinHeatAndContinueFilledCircle.PairJump   ; смещение JR, выбор числа пар байтов для заполнения через PUSH AF
.LeftTop        EQU Game.Circles.SetCabinHeatAndContinueFilledCircle.UpperLimit ; верхний предел заполнения круга с левым отсечением
.LeftBottom     EQU Game.Circles.SetCabinHeatAndContinueFilledCircle.LowerLimit ; нижний предел заполнения круга с левым отсечением
.LeftPairJump   EQU Game.Circles.SelectJumpAndContinueLeftFill.PairJump         ; смещение JR, число пар внутренних байтов при левом отсечении
.RightTop       EQU Game.Circles.SelectJumpAndContinueLeftFill.UpperLimit       ; верхний предел заполнения круга с правым отсечением
.RightBottom    EQU Game.Circles.SelectJumpAndContinueLeftFill.LowerLimit       ; нижний предел заполнения круга с правым отсечением
.RightPairJump  EQU Game.Circles.PrintShipAndContinueRightFill.PairJump         ; смещение JR, число пар внутренних байтов при правом отсечении
.PreviousRow    EQU Game.Circles.CrossCircleCharacterRowUp.UpperLimit           ; верхний предел при переходе на предыдущее знакоместо
.NextRow        EQU Game.Circles.CrossCircleCharacterRowDown.LowerLimit         ; нижний предел при переходе на следующее знакоместо
.TargetBottom   EQU Game.Circles.PatchCircleScreenTarget.LowerLimit             ; нижний предел, который патчер распространяет на три обработчика
.TargetTop      EQU Game.Circles.PatchCircleScreenTarget.UpperLimit             ; верхний предел, который патчер распространяет на четыре обработчика

CircleViewport  EQU Game.Circles.ApplyCircleViewportPatches.ChartValues         ; именованные адреса CircleViewport
.Chart          EQU Game.Circles.ApplyCircleViewportPatches.ChartValues         ; 32 значения патчей полного экрана карты
.Flight         EQU Game.Circles.ApplyCircleViewportPatches.FlightValues        ; 32 значения патчей области обзора
.Addresses      EQU Game.Circles.ApplyCircleViewportPatches.PatchAddresses      ; 32 адреса однобайтовых патчей

FaceVisibility  EQU Game.Wireframe.AdvanceObjectMetadata.GeometryData.Faces     ; 16 байтов видимости граней

GaugeAddresses  EQU Game.Screen.UpdateIndicators.IndicatorData.Addresses        ; экранные адреса шкал, UpdateIndicators использует первые 13 слов

IndicatorDraw   EQU #8523                                                       ; именованные адреса IndicatorDraw
.MarkerMode     EQU Game.Screen.UpdateIndicators.IndicatorData.MarkerMode       ; режим прибора, 0 полоса, 1 подвижный маркер
.BoundaryMask   EQU Game.Screen.DrawIndicatorBar.BoundaryMask                   ; маска границы, #FF для полосы и #03 для маркера
.BodyFill       EQU Game.Screen.DrawIndicatorBar.BodyFill                       ; заполнитель полных байтов полосы, #FF либо #00
.FullFill       EQU Game.Screen.DrawIndicatorBar.FullFill                       ; заполнитель полной шкалы, #FF либо #00

LaserRaster     EQU Game.Wireframe.ReadObjectTacticsGates.LaserData.Signs       ; именованные адреса LaserRaster
.Signs          EQU Game.Wireframe.ReadObjectTacticsGates.LaserData.Signs       ; биты 3/2 знаков центральной точки свободного лазерного луча
.TriggerHeld    EQU Game.Wireframe.ReadObjectTacticsGates.LaserData.TriggerHeld ; флаг, спуск лазера был активен на предыдущем обновлении

LineRaster      EQU Game.Wireframe.DrawClippedLine.SteepOpcode                  ; именованные адреса LineRaster
.SteepStep      EQU Game.Wireframe.DrawClippedLine.SteepOpcode                  ; код INC H либо DEC H для крутого отрезка
.SteepPixel     EQU Game.Wireframe.DrawClippedLine.SteepPixelOp                 ; код OR (HL) либо XOR (HL), наложение одиночного пикселя
.SteepFraction  EQU Game.Wireframe.DrawClippedLine.SteepFraction                ; дробный шаг X в операнде ADD A для крутого отрезка
.SteepRowOffset EQU Game.Wireframe.DrawClippedLine.SteepRowOffset               ; смещение JR к направлению смены знакоместа крутого отрезка
.RunStep        EQU Game.Wireframe.DrawClippedLine.RunOpcode                    ; код INC H либо DEC H для пологого отрезка
.RunLength      EQU Game.Wireframe.DrawClippedLine.RunLength                    ; целая часть числа пикселей на строку в операнде LD D
.RunFraction    EQU Game.Wireframe.DrawClippedLine.RunFraction                  ; дробная часть числа пикселей на строку в операнде ADD A
.MaskOffset     EQU Game.Wireframe.DrawClippedLine.MaskOffset                   ; смещение IX при выборе маски первого байта группы
.FirstPixel     EQU Game.Wireframe.DrawClippedLine.FirstPixelOp                 ; код OR (HL) либо XOR (HL), наложение первого байта группы
.FullPixel      EQU Game.Wireframe.DrawClippedLine.FullPixelOp                  ; код OR (HL) либо XOR (HL), наложение полного байта группы
.LastPixel      EQU Game.Wireframe.DrawClippedLine.LastPixelOp                  ; код OR (HL) либо XOR (HL), наложение последнего байта группы
.NextBit        EQU Game.Wireframe.DrawClippedLine.NextBit                      ; номер первого пикселя следующей строки в операнде LD C
.RunRowOffset   EQU Game.Wireframe.DrawClippedLine.RunRowOffset                 ; смещение JR к направлению смены знакоместа пологого отрезка

MenuDispatch    EQU #80D1                                                       ; именованные адреса MenuDispatch
.SavedSP        EQU Game.Screen.ResetCargoCapacity.MenuStack.SavedSP            ; реальный стек, сохранённый перед вызовом меню
.Target         EQU Game.Screen.DispatchMenu.MenuAddress                        ; адрес вызываемого обработчика меню в операнде CALL

ObjectEffects   EQU Game.Wireframe.DrawScannerMarkerSegment.EffectData.Current  ; именованные адреса ObjectEffects
.Current        EQU ObjectEffects + FObjectEffects.Current                      ; указатель текущей FEffectRecord10
.Phase          EQU ObjectEffects + FObjectEffects.Phase                        ; фаза 1..3 в младших двух битах
.Remaining      EQU ObjectEffects + FObjectEffects.Remaining                    ; счётчик оставшихся слотов, 8..1
.Flags          EQU ObjectEffects + FObjectEffects.Flags                        ; общие признаки взаимодействия
.Records        EQU ObjectEffects + FObjectEffects                              ; восемь записей FEffectRecord10
.Scratch        EQU ObjectEffects.Records + 8 * FEffectRecord10                 ; дополнительная запись, исходная цель Current

ObjectMatrix    EQU Game.Wireframe.AdvanceObjectMetadata.GeometryData.Matrix    ; матрица поворота, три строки по три знаковых слова

ObjectRaster    EQU Game.Motion.ProjectObjectAndSelectDetail.TargetValue        ; именованные адреса ObjectRaster
.TargetValue    EQU Game.Motion.ProjectObjectAndSelectDetail.TargetValue        ; операнд LD A,0, значение записи в номер цели прицела
.PixelMode      EQU Game.Motion.XorFarObjectPixel.PixelMode                     ; два байта конца SET 7,H и XOR (HL), патч прямого экрана

ProjectedRadius EQU Game.Motion.DotProductAxisHighBytes.RadiusData.Radius       ; экранный радиус объекта после деления на глубину

ProjectedVerts  EQU Game.Wireframe.AdvanceObjectMetadata.GeometryData.Vertices  ; 46 экранных вершин по три байта, X, Y, признаки

ScannerAttrs    EQU Game.Wireframe.DrawWireframeObject.AttributeList            ; смещения изменяемых атрибутов сканера, #FF завершает таблицу

ScannerRaster   EQU Game.Wireframe.DrawScannerMarkerSegment.StepOpcodes         ; именованные адреса ScannerRaster
.StepOpcodes    EQU Game.Wireframe.DrawScannerMarkerSegment.StepOpcodes         ; два кода INC/DEC B/C либо NOP, шаг отрезка маркера
.Mode           EQU Game.Scanner.DrawScannerObjects.ModeOpcode                  ; код AND A либо SCF, выбор обычной или альтернативной проекции
.BackdropMode   EQU Game.Wireframe.RefreshScannerBackground.BackdropMode        ; операнд LD A, 7 обычный фон и атрибут, 0 альтернативный фон

                ; именованные адреса VertexFlags
VertexFlags     EQU Game.Wireframe.BuildProjectedVertexTable.VertexFlagData.Previous
                ; предыдущие признаки знаков для повторного использования произведений
.Previous       EQU Game.Wireframe.BuildProjectedVertexTable.VertexFlagData.Previous
                ; текущие признаки координат из потока вершин
.Current        EQU Game.Wireframe.BuildProjectedVertexTable.VertexFlagData.Current

                ; именованные адреса VertexFraction
VertexFraction  EQU Game.Wireframe.DivideFractionAndProjectVertex.VertexFraction.X
                ; дополнительные дробные разряды повёрнутой X-компоненты
.X              EQU Game.Wireframe.DivideFractionAndProjectVertex.VertexFraction.X
                ; дополнительные дробные разряды повёрнутой Y-компоненты
.Y              EQU Game.Wireframe.DivideFractionAndProjectVertex.VertexFraction.Y
                ; дополнительные дробные разряды повёрнутой Z-компоненты
.Z              EQU Game.Wireframe.DivideFractionAndProjectVertex.VertexFraction.Z

VertexProducts  EQU Game.Wireframe.AdvanceObjectMetadata.GeometryData.Products  ; девять кэшированных произведений модулей вершины и матрицы

VertexRaster    EQU Game.Wireframe.AnyPackedFaceVisible.FaceCombine             ; именованные адреса VertexRaster
.FaceCombine    EQU Game.Wireframe.AnyPackedFaceVisible.FaceCombine             ; код OR B, объединение видимости двух граней
.FaceAddress    EQU Game.Wireframe.ReadFaceVisibilityNibble.FaceAddress         ; младший байт адреса чтения флага выбранной грани

ScannerState    EQU Game.Sound.StartHyperjumpNoise.ScaledX                      ; адрес структуры FScannerState
.ScaledX        EQU ScannerState + FScannerState.ScaledX                        ; масштабированная X, знак в бите 7
.ScaledY        EQU ScannerState + FScannerState.ScaledY                        ; масштабированная высота Y, знак в бите 7
.ScaledZ        EQU ScannerState + FScannerState.ScaledZ                        ; масштабированная глубина Z, знак в бите 7
.ObjectIndex    EQU ScannerState + FScannerState.ObjectIndex                    ; обратный номер обрабатываемого слота, 8..1
.Redraw         EQU ScannerState + FScannerState.Redraw                         ; флаг, фон сканера изменён и требует восстановления

ScannerCopy     EQU Game.Scanner.RestoreScannerBackground.SelectSource          ; адреса изменяемых команд ScannerCopy
.SelectSource   EQU Game.Scanner.RestoreScannerBackground.SelectSource          ; код EX DE,HL либо NOP, выбор источника
.SaveCharRow    EQU Game.Scanner.RestoreScannerBackground.SaveCharRow           ; код PUSH HL либо PUSH DE, сохранение экранной базы знакоместа
.SavePixelRow   EQU Game.Scanner.RestoreScannerBackground.SavePixelRow          ; код PUSH HL либо PUSH DE, сохранение экранной строки
.RestoreRow     EQU Game.Scanner.ScaleValueAndFinishBackground.RestoreRow       ; код POP HL либо POP DE, восстановление экранной строки
.AdvanceRow     EQU Game.Scanner.ScaleValueAndFinishBackground.AdvanceRow       ; код INC H либо INC D, следующая пиксельная строка
.SelectScreen   EQU Game.Scanner.ScaleValueAndFinishBackground.SelectScreen     ; код EX DE,HL либо NOP перед переходом к знакоместу
.SelectTarget   EQU Game.Scanner.ScaleValueAndFinishBackground.SelectTarget     ; код NOP либо EX DE,HL, возврат направления копирования

MotionRaster    EQU Game.Motion.ApplyPlayerMotionToObject.TranslateGate         ; адреса изменяемых команд MotionRaster
.TranslateGate  EQU Game.Motion.ApplyPlayerMotionToObject.TranslateGate         ; код LD A либо RET, временное отключение поступательного сдвига

CompassBitmap   EQU Game.Screen.ConsumeEscapePod.CompassBitmap                  ; фон компаса, 12 строк по три байта
ScannerMap      EQU Game.Scanner.ScaleValueAndFinishBackground.BackdropMap      ; байты прежнего кода, используемые как поток альтернативного фона
CockpitBlink    EQU Game.Scanner.FillCockpitAttributePanel.BlinkCounter         ; счётчик мигания аварийного индикатора, бит 1 выбирает красную фазу
DemoModels      EQU Game.Wireframe.InitializeObjectFromModelNumber.DemoModels   ; двенадцать номеров моделей демонстрационного экрана
ScannerBlocks   EQU Game.Wireframe.DivideSlopeAndDrawScanner.BackdropBlocks     ; блоки альтернативного фона сканера с шагом выбора 9 байтов
MissileAttr     EQU Memory.Attributes + 23 * 32 + 7                             ; атрибут ракеты, строка 23, столбец 7 экрана

LegacyPrice     EQU #0667                                                       ; адрес ROM, из которого читается цена при индексе от 14

                endif                                                           ; ~_VARIABLES_GRAPHICS_
