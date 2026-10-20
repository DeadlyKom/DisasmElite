# Внутренние входы, циклы и ветви

Указатель 1309 меток, добавленных при разборе числовых переходов и точек самомодификации.
Каждый адрес сверяется с символами текущей сборки. В памяти код и данные остаются на исходных местах.
Полный словарь, включая прежние входы, структуры и константы, находится в
[SourceNames.json](../Tools/Disasm/Reports/SourceNames.json). Назначение файлов и контракты процедур
описаны в [игровом указателе](Functions.md) и [указателе остальных файлов](Auxiliary.md).

Внутри модуля переходы используют короткие имена, межмодульные ссылки содержат полный путь.
Префикс `@` в части ссылок явно выбирает глобальную область имён sjasmplus.
Перекрывающиеся входы задаются через `EQU` относительно команды, в чьи байты они входят.

## [CoroutineStackPointers](../Source/DiskUtility/Demo/CoroutineStackPointers.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `DiskUtility.Demo.DemoStack` | `#E6DE` | сохранённый указатель стека корутины |

## [ResumeDemoCoroutine](../Source/DiskUtility/Demo/ResumeDemoCoroutine.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `DiskUtility.Demo.ResumeJump` | `#E706` | изменяемый переход возобновления корутины |

## [Include](../Source/DiskUtility/Include.inc)

| Метка | Адрес | Назначение |
|---|---|---|
| `DiskUtility.ResetRom` | `#0000` | вход перезапуска ПЗУ Spectrum |
| `DiskUtility.DosGateway` | `#3D2F` | шлюз включения ПЗУ TR-DOS |

## [CheckMenuAbort](../Source/DiskUtility/Menu/CheckMenuAbort.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `DiskUtility.Menu.RestoreStack` | `#CA34` | изменяемый LD SP восстанавливает стек меню при аварийном выходе |

## [FormatTrack](../Source/DiskUtility/Menu/FormatTrack.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `DiskUtility.Menu.VerifySector` | `#CDB7` | подменяемый выбор сектора для проверки после форматирования |

## [BuildHighBitRun](../Source/Game/Charts/BuildHighBitRun.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Charts.BuildHighBitRun.NextBit` | `#E612` | старшие E битов устанавливаются последовательными сдвигами с переносом 1, входная команда SCF |

## [BuildLowBitRun](../Source/Game/Charts/BuildLowBitRun.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Charts.BuildLowBitRun.NextBit` | `#E61A` | младшие D битов устанавливаются последовательными сдвигами с переносом 1, входная команда SCF |

## [FindSystemNameDialog](../Source/Game/Charts/FindSystemNameDialog.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Charts.FindSystemNameDialog.SearchFailed` | `#E3C2` | сообщение о неудачном поиске системы |

## [MapCursorTransformAndKeys](../Source/Game/Charts/MapCursorTransformAndKeys.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Charts.MapCursorTransformAndKeys.LeftOfSystem` | `#E48B` | преобразование смещения курсора слева от системы |
| `Game.Charts.MapCursorTransformAndKeys.StoreScreenX` | `#E496` | сохранение экранного X и расчёт вертикального смещения |
| `Game.Charts.MapCursorTransformAndKeys.AboveSystem` | `#E4AC` | преобразование смещения курсора выше системы |
| `Game.Charts.MapCursorTransformAndKeys.ClipScreenY` | `#E4B6` | отсечение вертикальной координаты по окну карты |
| `Game.Charts.MapCursorTransformAndKeys.GalacticMap` | `#E4C1` | общая карта преобразует галактические координаты непосредственно в экранные, входная команда LD A,(#D0BB) |
| `Game.Charts.MapCursorTransformAndKeys.DrawCrosshair` | `#E4D1` | вывод перекрестия по рассчитанным экранным координатам |
| `Game.Charts.MapCursorTransformAndKeys.StoreUp` | `#E4E1` | сохранение координаты после перемещения вверх |
| `Game.Charts.MapCursorTransformAndKeys.StoreDown` | `#E4F4` | сохранение координаты после перемещения вниз |
| `Game.Charts.MapCursorTransformAndKeys.StoreLeft` | `#E503` | сохранение координаты после перемещения влево |
| `Game.Charts.MapCursorTransformAndKeys.RedrawCursor` | `#E506` | повторный XOR-вывод курсора в новом положении |
| `Game.Charts.MapCursorTransformAndKeys.StoreRight` | `#E515` | сохранение координаты после перемещения вправо |

## [PixelAddressAndVerticalCrosshair](../Source/Game/Charts/PixelAddressAndVerticalCrosshair.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Charts.PixelAddressAndVerticalCrosshair.XorHighMask` | `#E63F` | инверсия пикселей по маске старших битов |
| `Game.Charts.PixelAddressAndVerticalCrosshair.XorLowMask` | `#E644` | инверсия пикселей по маске младших битов |
| `Game.Charts.PixelAddressAndVerticalCrosshair.DrawVertical` | `#E647` | вертикаль обрезается по верхней и нижней границам текущего окна карты, входная команда LD A,(#E52B) |
| `Game.Charts.PixelAddressAndVerticalCrosshair.VerticalCount` | `#E671` | сохранение видимой длины вертикального перекрестия |
| `Game.Charts.PixelAddressAndVerticalCrosshair.ClipTop` | `#E674` | отсечение верхней части вертикального перекрестия |
| `Game.Charts.PixelAddressAndVerticalCrosshair.PixelMask` | `#E683` | из X mod8 получается одиночная битовая маска для всех строк вертикали, входная команда LD A,(#D051) |
| `Game.Charts.PixelAddressAndVerticalCrosshair.ShiftMask` | `#E690` | выбор битовой позиции вертикальной линии в байте экрана |
| `Game.Charts.PixelAddressAndVerticalCrosshair.MaskReady` | `#E695` | сохранение маски пикселя для прохода по строкам |
| `Game.Charts.PixelAddressAndVerticalCrosshair.RasterRow` | `#E696` | XOR выбранного бита и переход к следующей растровой строке повторяются B раз, входная команда LD A,(HL) |

## [TextInputLoop](../Source/Game/Charts/TextInputLoop.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Charts.TextInputLoop.ReadKey` | `#E3ED` | цикл клавиатурного ввода принимает цифры и латинские заглавные буквы, входная команда CALL Game.Trade.WaitForKeyCode.Entry |
| `Game.Charts.TextInputLoop.CheckLength` | `#E40E` | проверка максимальной длины предшествует записи очередного символа, входная команда LD D,A |
| `Game.Charts.TextInputLoop.DeleteChar` | `#E428` | удаление уменьшает длину, возвращает курсор и стирает прежний символ, входная команда LD A,(#E394) |
| `Game.Charts.TextInputLoop.EraseDelay` | `#E43E` | задержка после удаления символа |
| `Game.Charts.TextInputLoop.EndInput` | `#E446` | запись нулевого завершителя и ожидание отпускания ENTER, входная команда LD HL,(#E395) |
| `Game.Charts.TextInputLoop.ReleaseEnter` | `#E451` | ожидание отпускания ENTER после окончания ввода |
| `Game.Charts.TextInputLoop.ShowSelection` | `#E45E` | клавиша выбора планеты у курсора с обновлением информации, входная команда CALL Game.Trade.ClearPromptRows.Entry |

## [XorMapCrosshair](../Source/Game/Charts/XorMapCrosshair.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Charts.XorMapCrosshair.FullSpan` | `#E551` | вычисление маски неполного левого байта и числа полностью заполненных байтов, входная команда LD E,A |
| `Game.Charts.XorMapCrosshair.FirstMask` | `#E561` | подготовка маски первого байта горизонтального перекрестия |
| `Game.Charts.XorMapCrosshair.CountFullBytes` | `#E563` | подсчёт полных байтов между крайними масками |
| `Game.Charts.XorMapCrosshair.ClipLeft` | `#E56F` | отсечение горизонтального перекрестия слева |
| `Game.Charts.XorMapCrosshair.LeftMask` | `#E586` | подготовка маски видимого конца после левого отсечения |
| `Game.Charts.XorMapCrosshair.LeftFullBytes` | `#E588` | подсчёт полных байтов после левого отсечения |
| `Game.Charts.XorMapCrosshair.ClipRight` | `#E594` | отсечение горизонтального перекрестия справа |
| `Game.Charts.XorMapCrosshair.RightMask` | `#E5A6` | подготовка маски видимого конца после правого отсечения |
| `Game.Charts.XorMapCrosshair.RightFullBytes` | `#E5A8` | подсчёт полных байтов после правого отсечения |
| `Game.Charts.XorMapCrosshair.EdgePair` | `#E5B4` | вывод двух крайних масок без полных внутренних байтов |
| `Game.Charts.XorMapCrosshair.LeftEdgeOnly` | `#E5C0` | вывод единственного края после левого отсечения |
| `Game.Charts.XorMapCrosshair.RightEdgeOnly` | `#E5C7` | вывод единственного края после правого отсечения |
| `Game.Charts.XorMapCrosshair.DrawFullSpan` | `#E5CF` | вывод полного горизонтального отрезка перекрестия |
| `Game.Charts.XorMapCrosshair.FullByte` | `#E5DA` | инверсия очередного полного байта горизонтального отрезка |
| `Game.Charts.XorMapCrosshair.LastEdge` | `#E5E1` | вывод завершающего края горизонтального отрезка |
| `Game.Charts.XorMapCrosshair.DrawLeftClip` | `#E5E4` | вывод отрезка после левого отсечения |
| `Game.Charts.XorMapCrosshair.LeftClipByte` | `#E5F0` | инверсия полного байта после левого отсечения |
| `Game.Charts.XorMapCrosshair.DrawRightClip` | `#E5F9` | вывод отрезка после правого отсечения |
| `Game.Charts.XorMapCrosshair.RightClipByte` | `#E604` | инверсия полного байта после правого отсечения |
| `Game.Charts.XorMapCrosshair.RightBoundary` | `#E60B` | вывод конечной маски у правой границы |

## [ApplyCircleViewportPatches](../Source/Game/Circles/ApplyCircleViewportPatches.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Circles.ApplyCircleViewportPatches.ApplyByte` | `#8E81` | применение очередного байта патча области обзора |

## [BeginFilledUnclippedHalf](../Source/Game/Circles/BeginFilledUnclippedHalf.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Circles.BeginFilledUnclippedHalf.CheckBottom` | `#8B08` | проверка нижнего предела заливки |
| `Game.Circles.BeginFilledUnclippedHalf.EmptyHalf` | `#8B0D` | возврат без рисования пустой половины круга |
| `Game.Circles.BeginFilledUnclippedHalf.SaveRealStack` | `#8B0F` | сохранение рабочего стека перед экранной заливкой |
| `Game.Circles.BeginFilledUnclippedHalf.FillEdgeRow` | `#8B13` | наложение краевых масок и заполнение строки |
| `Game.Circles.BeginFilledUnclippedHalf.FillMiddle` | `#8B25` | заполнение внутренних байтов между краями |

## [BuildLeftContourPixelMask](../Source/Game/Circles/BuildLeftContourPixelMask.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Circles.BuildLeftContourPixelMask.RotatePixel` | `#8FE6` | поворот однобитовой маски левого контура |

## [BuildRightContourPixelMask](../Source/Game/Circles/BuildRightContourPixelMask.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Circles.BuildRightContourPixelMask.RotatePixel` | `#8FEF` | поворот однобитовой маски правого контура |

## [CheckBodiesAndRestoreViewport](../Source/Game/Circles/CheckBodiesAndRestoreViewport.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Circles.CheckBodiesAndRestoreViewport.CheckPlanet` | `#8E6C` | проверка грубой оценки расстояния до планеты |
| `Game.Circles.CheckBodiesAndRestoreViewport.NormalViewport` | `#8E74` | выбор таблицы штатных границ области обзора |

## [CheckSystemCoordinateBand](../Source/Game/Circles/CheckSystemCoordinateBand.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Circles.CheckSystemCoordinateBand.TestBandWidth` | `#8D35` | проверка ширины диагональной полосы системы |

## [ComputeLeftEdgeMask](../Source/Game/Circles/ComputeLeftEdgeMask.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Circles.ComputeLeftEdgeMask.ShiftLeftMask` | `#89E8` | формирование левой сплошной маски |

## [ComputeRightEdgeMask](../Source/Game/Circles/ComputeRightEdgeMask.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Circles.ComputeRightEdgeMask.ShiftRightMask` | `#8A0C` | формирование правой сплошной маски |

## [CrossCircleCharacterRowDown](../Source/Game/Circles/CrossCircleCharacterRowDown.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Circles.CrossCircleCharacterRowDown.SameThird` | `#8E1D` | коррекция адреса строки внутри трети экрана |
| `Game.Circles.CrossCircleCharacterRowDown.FinishHalf` | `#8E22` | нелокальный выход половины круга за пределы экрана |

## [CrossCircleCharacterRowUp](../Source/Game/Circles/CrossCircleCharacterRowUp.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Circles.CrossCircleCharacterRowUp.SameThird` | `#8E03` | коррекция адреса строки внутри трети экрана |

## [DetachMissileTarget](../Source/Game/Circles/DetachMissileTarget.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Circles.DetachMissileTarget.DetachTarget` | `#8C34` | сброс ракетной цели без прямого уничтожения |

## [DispatchClippedCircle](../Source/Game/Circles/DispatchClippedCircle.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Circles.DispatchClippedCircle.FinishCenterY` | `#8702` | получение экранной координаты центра по Y |
| `Game.Circles.DispatchClippedCircle.FinishCenterX` | `#870E` | получение экранной координаты центра по X |
| `Game.Circles.DispatchClippedCircle.CheckOuterY` | `#8728` | проверка вертикального случая по признаку проекции |
| `Game.Circles.DispatchClippedCircle.CheckOuterX` | `#872B` | проверка горизонтального случая по признаку проекции |
| `Game.Circles.DispatchClippedCircle.OuterX` | `#872C` | обработка центра за боковой границей |
| `Game.Circles.DispatchClippedCircle.OuterYCorner` | `#8733` | проверка вертикальной границы внешнего угла |
| `Game.Circles.DispatchClippedCircle.InnerCenter` | `#8736` | проверка диаметра круга с внутренним центром |
| `Game.Circles.DispatchClippedCircle.CheckHalfWidth` | `#873F` | проверка внутренней полуширины круга |
| `Game.Circles.DispatchClippedCircle.SelectSideClip` | `#8745` | выбор одного или двух боковых отсечений |
| `Game.Circles.DispatchClippedCircle.MeasureSideGap` | `#874B` | расстояние внешнего центра до боковой границы |
| `Game.Circles.DispatchClippedCircle.OuterY` | `#875E` | проверка пересечения вертикальной границы |
| `Game.Circles.DispatchClippedCircle.OuterCorner` | `#878E` | проверка пересечения внешнего угла |
| `Game.Circles.DispatchClippedCircle.NarrowCorner` | `#87BC` | рисование узкого углового участка |

## [DrawChartCircleWithPatchedViewport](../Source/Game/Circles/DrawChartCircleWithPatchedViewport.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Circles.DrawChartCircleWithPatchedViewport.NegativeX` | `#8E37` | модуль отрицательного смещения центра карты |
| `Game.Circles.DrawChartCircleWithPatchedViewport.StoreCenterX` | `#8E3A` | сохранение горизонтального положения окружности карты |
| `Game.Circles.DrawChartCircleWithPatchedViewport.StoreGeometry` | `#8E4A` | сохранение геометрии окружности карты |

## [DrawCornerClippedArc](../Source/Game/Circles/DrawCornerClippedArc.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Circles.DrawCornerClippedArc.CornerCathetus` | `#88C2` | расчёт катета пересечения угла |
| `Game.Circles.DrawCornerClippedArc.SaveCornerCut` | `#88C5` | сохранение углового ограничения в AF' |
| `Game.Circles.DrawCornerClippedArc.PrepareLeft` | `#88EE` | подготовка левой краевой маски |
| `Game.Circles.DrawCornerClippedArc.MoveRightEdge` | `#8910` | расчёт подвижного правого края |
| `Game.Circles.DrawCornerClippedArc.PrepareRight` | `#8921` | подготовка правой маски и фиксированного левого края |

## [DrawCornerWideCircle](../Source/Game/Circles/DrawCornerWideCircle.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Circles.DrawCornerWideCircle.CrossingHeight` | `#884A` | высота пересечения внешнего угла |
| `Game.Circles.DrawCornerWideCircle.SaveRowLimit` | `#884D` | сохранение ограничения полных строк |
| `Game.Circles.DrawCornerWideCircle.FillUpward` | `#8877` | заливка полных строк снизу вверх |

## [DrawOneSideClippedCircle](../Source/Game/Circles/DrawOneSideClippedCircle.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Circles.DrawOneSideClippedCircle.SideLimit` | `#8898` | расчёт предела единственного бокового отсечения |
| `Game.Circles.DrawOneSideClippedCircle.ChooseSide` | `#889B` | выбор левого или правого отсечения |
| `Game.Circles.DrawOneSideClippedCircle.ClipLeft` | `#88AC` | подготовка двух половин с левым отсечением |

## [DrawPendingObjectExplosions](../Source/Game/Circles/DrawPendingObjectExplosions.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Circles.DrawPendingObjectExplosions.CheckObject` | `#8F2F` | проверка признаков взрыва очередного объекта |
| `Game.Circles.DrawPendingObjectExplosions.DrawRing` | `#8F53` | вывод очередного круга взрыва |
| `Game.Circles.DrawPendingObjectExplosions.NextObject` | `#8F6C` | переход к следующему экземпляру объекта |

## [DrawVerticalClippedCircle](../Source/Game/Circles/DrawVerticalClippedCircle.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Circles.DrawVerticalClippedCircle.CrossingEnds` | `#895B` | расчёт экранных концов пересечения круга |

## [DrawWideCircleAcrossBothSides](../Source/Game/Circles/DrawWideCircleAcrossBothSides.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Circles.DrawWideCircleAcrossBothSides.FarSideLimit` | `#87FE` | расчёт катета пересечения дальней стороны |
| `Game.Circles.DrawWideCircleAcrossBothSides.SaveFarLimit` | `#8802` | сохранение предела дальней стороны в AF' |

## [IntegerCircleCathetus](../Source/Game/Circles/IntegerCircleCathetus.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Circles.IntegerCircleCathetus.TryRootBit` | `#8AE3` | проверка очередного пробного бита корня |
| `Game.Circles.IntegerCircleCathetus.NextRootBit` | `#8AEF` | выбор следующего пробного бита корня |

## [PrepareBothClippedMasksAndFillRows](../Source/Game/Circles/PrepareBothClippedMasksAndFillRows.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Circles.PrepareBothClippedMasksAndFillRows.PatchUpward` | `#8A37` | настройка заполнения полных строк вверх |
| `Game.Circles.PrepareBothClippedMasksAndFillRows.PatchDownward` | `#8A4E` | настройка заполнения полных строк вниз |
| `Game.Circles.PrepareBothClippedMasksAndFillRows.SaveContext` | `#8A63` | сохранение регистров после настройки направления |
| `Game.Circles.PrepareBothClippedMasksAndFillRows.FillRow` | `#8A76` | заполнение тридцати байтов текущей строки |
| `Game.Circles.PrepareBothClippedMasksAndFillRows.CountRow` | `#8A8B` | проверка остатка полных строк |
| `Game.Circles.PrepareBothClippedMasksAndFillRows.RestoreContext` | `#8A8D` | восстановление сохранённых регистров |
| `Game.Circles.PrepareBothClippedMasksAndFillRows.CrossCharRow` | `#8A91` | коррекция экранного адреса на границе знакоместа |
| `Game.Circles.PrepareBothClippedMasksAndFillRows.CheckViewport` | `#8A9D` | проверка изменяемого предела экранного буфера |

## [PrepareLeftClippedCircle](../Source/Game/Circles/PrepareLeftClippedCircle.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Circles.PrepareLeftClippedCircle.OutlineMask` | `#89C0` | одиночный пиксель левого контура вместо маски заливки |

## [PrintShipAndContinueRightFill](../Source/Game/Circles/PrintShipAndContinueRightFill.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Circles.PrintShipAndContinueRightFill.NextRightRow` | `#8D4C` | выбор следующей строки правой отсечённой заливки |
| `Game.Circles.PrintShipAndContinueRightFill.RightRowDown` | `#8D53` | переход правой отсечённой дуги вниз |
| `Game.Circles.PrintShipAndContinueRightFill.AddRightYError` | `#8D56` | ошибка правой дуги после шага Y |
| `Game.Circles.PrintShipAndContinueRightFill.AddRightXError` | `#8D63` | ошибка правой дуги после шага X |
| `Game.Circles.PrintShipAndContinueRightFill.TestRightError` | `#8D6F` | выбор строки или сужения правой заливки |
| `Game.Circles.PrintShipAndContinueRightFill.CrossLeftByte` | `#8D74` | переход подвижного левого края в соседний байт |
| `Game.Circles.PrintShipAndContinueRightFill.JoinBothArc` | `#8D7D` | снятие отсечения и переход к общей дуге |
| `Game.Circles.PrintShipAndContinueRightFill.JoinBothSweep` | `#8D81` | снятие отсечения в горизонтальном проходе |
| `Game.Circles.PrintShipAndContinueRightFill.FinishRight` | `#8D85` | завершение правой отсечённой заливки |
| `Game.Circles.PrintShipAndContinueRightFill.SweepLeftByte` | `#8D8B` | переход левой маски в горизонтальном проходе |
| `Game.Circles.PrintShipAndContinueRightFill.SweepRightFill` | `#8D94` | горизонтальное сужение правой отсечённой заливки |
| `Game.Circles.PrintShipAndContinueRightFill.RightSweepErr` | `#8D98` | ошибка горизонтального шага правой заливки |
| `Game.Circles.PrintShipAndContinueRightFill.SetFillPairs` | `#8DBC` | расчёт числа пар для быстрой заливки строки |
| `Game.Circles.PrintShipAndContinueRightFill.FillPairsJump` | `#8DC8` | изменяемый вход в последовательность парных записей |
| `Game.Circles.PrintShipAndContinueRightFill.StepFillDown` | `#8DE9` | переход вниз после быстрой заливки |

## [ScanUpgradeKeyRow](../Source/Game/Circles/ScanUpgradeKeyRow.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Circles.ScanUpgradeKeyRow.TestKey` | `#8B36` | проверка очередной клавиши дополнительного ряда |
| `Game.Circles.ScanUpgradeKeyRow.KeepKeyState` | `#8B3C` | возврат резервного состояния клавиатуры |

## [SelectJumpAndContinueLeftFill](../Source/Game/Circles/SelectJumpAndContinueLeftFill.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Circles.SelectJumpAndContinueLeftFill.NextLeftRow` | `#8C4A` | выбор следующей строки левой отсечённой заливки |
| `Game.Circles.SelectJumpAndContinueLeftFill.LeftRowDown` | `#8C51` | переход левой отсечённой дуги вниз |
| `Game.Circles.SelectJumpAndContinueLeftFill.AddLeftYError` | `#8C54` | ошибка левой дуги после шага Y |
| `Game.Circles.SelectJumpAndContinueLeftFill.AddLeftXError` | `#8C61` | ошибка левой дуги после шага X |
| `Game.Circles.SelectJumpAndContinueLeftFill.TestLeftError` | `#8C6D` | выбор строки или сужения левой заливки |
| `Game.Circles.SelectJumpAndContinueLeftFill.CrossRightByte` | `#8C72` | переход подвижного правого края в соседний байт |
| `Game.Circles.SelectJumpAndContinueLeftFill.JoinBothArc` | `#8C7C` | снятие отсечения и переход к общей дуге |
| `Game.Circles.SelectJumpAndContinueLeftFill.JoinBothSweep` | `#8C86` | снятие отсечения в горизонтальном проходе |
| `Game.Circles.SelectJumpAndContinueLeftFill.FinishLeft` | `#8C90` | завершение левой отсечённой заливки |
| `Game.Circles.SelectJumpAndContinueLeftFill.SweepRightByte` | `#8C96` | переход правой маски в горизонтальном проходе |
| `Game.Circles.SelectJumpAndContinueLeftFill.SweepLeftFill` | `#8CA0` | горизонтальное сужение левой отсечённой заливки |
| `Game.Circles.SelectJumpAndContinueLeftFill.LeftSweepError` | `#8CA4` | ошибка горизонтального шага левой заливки |
| `Game.Circles.SelectJumpAndContinueLeftFill.SetFillPairs` | `#8CC6` | расчёт числа пар для быстрой заливки строки |
| `Game.Circles.SelectJumpAndContinueLeftFill.FillPairsJump` | `#8CD2` | изменяемый вход в последовательность парных записей |
| `Game.Circles.SelectJumpAndContinueLeftFill.StepFillDown` | `#8CF3` | переход вниз после быстрой заливки |
| `Game.Circles.SelectJumpAndContinueLeftFill.RightFixedFill` | `#8CF8` | вход заливки с фиксированным правым краем |
| `Game.Circles.SelectJumpAndContinueLeftFill.RightBottom` | `#8D0C` | проверка нижнего предела правой отсечённой заливки |
| `Game.Circles.SelectJumpAndContinueLeftFill.EmptyRightFill` | `#8D11` | возврат при пустой правой отсечённой половине |
| `Game.Circles.SelectJumpAndContinueLeftFill.RightFillStack` | `#8D13` | сохранение стека для правой отсечённой заливки |
| `Game.Circles.SelectJumpAndContinueLeftFill.FillToRight` | `#8D17` | заливка строки до фиксированного правого края |
| `Game.Circles.SelectJumpAndContinueLeftFill.FillRightCore` | `#8D26` | заполнение середины правого отсечённого участка |

## [SetCabinHeatAndContinueFilledCircle](../Source/Game/Circles/SetCabinHeatAndContinueFilledCircle.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Circles.SetCabinHeatAndContinueFilledCircle.StoreHeat` | `#8B47` | сохранение рассчитанного нагрева кабины |
| `Game.Circles.SetCabinHeatAndContinueFilledCircle.NextArcRow` | `#8B4B` | выбор направления следующей строки дуги |
| `Game.Circles.SetCabinHeatAndContinueFilledCircle.StepArcDown` | `#8B52` | переход на следующую строку вниз |
| `Game.Circles.SetCabinHeatAndContinueFilledCircle.AddYError` | `#8B55` | обновление ошибки окружности после шага Y |
| `Game.Circles.SetCabinHeatAndContinueFilledCircle.MoveRightMask` | `#8B62` | сужение правой краевой маски |
| `Game.Circles.SetCabinHeatAndContinueFilledCircle.AddXError` | `#8B66` | обновление ошибки после шага X |
| `Game.Circles.SetCabinHeatAndContinueFilledCircle.FinishXError` | `#8B69` | завершение поправки ошибки после шага X |
| `Game.Circles.SetCabinHeatAndContinueFilledCircle.TestRowError` | `#8B6D` | выбор следующей строки или сужения текущей |
| `Game.Circles.SetCabinHeatAndContinueFilledCircle.CrossLeftByte` | `#8B72` | переход левого края в следующий байт |
| `Game.Circles.SetCabinHeatAndContinueFilledCircle.CrossRightByte` | `#8B7B` | переход правого края в предыдущий байт |
| `Game.Circles.SetCabinHeatAndContinueFilledCircle.FinishHalf` | `#8B84` | восстановление стека при завершении половины круга |
| `Game.Circles.SetCabinHeatAndContinueFilledCircle.SweepLeftByte` | `#8B8A` | переход левого края при горизонтальном проходе |
| `Game.Circles.SetCabinHeatAndContinueFilledCircle.SweepRightByte` | `#8B93` | переход правого края при горизонтальном проходе |
| `Game.Circles.SetCabinHeatAndContinueFilledCircle.SweepEdges` | `#8B9C` | сужение обоих краёв без смены строки |
| `Game.Circles.SetCabinHeatAndContinueFilledCircle.SweepRightMask` | `#8BA0` | сужение правой маски в горизонтальном проходе |
| `Game.Circles.SetCabinHeatAndContinueFilledCircle.SweepXError` | `#8BA4` | обновление ошибки горизонтального шага |
| `Game.Circles.SetCabinHeatAndContinueFilledCircle.EndSweepError` | `#8BA9` | завершение поправки горизонтального шага |
| `Game.Circles.SetCabinHeatAndContinueFilledCircle.SetFillPairs` | `#8BC6` | выбор числа пар байтов для быстрой заливки |
| `Game.Circles.SetCabinHeatAndContinueFilledCircle.FillPairsJump` | `#8BD2` | изменяемый вход в последовательность парных записей |
| `Game.Circles.SetCabinHeatAndContinueFilledCircle.StepFillDown` | `#8BF3` | переход вниз после заполнения строки через стек |
| `Game.Circles.SetCabinHeatAndContinueFilledCircle.LeftFixedFill` | `#8BF8` | вход заливки с фиксированным левым краем |
| `Game.Circles.SetCabinHeatAndContinueFilledCircle.LeftFillBottom` | `#8C0C` | проверка нижнего предела левой отсечённой заливки |
| `Game.Circles.SetCabinHeatAndContinueFilledCircle.EmptyLeftFill` | `#8C11` | возврат при пустой левой отсечённой половине |
| `Game.Circles.SetCabinHeatAndContinueFilledCircle.LeftFillStack` | `#8C13` | сохранение стека для левой отсечённой заливки |
| `Game.Circles.SetCabinHeatAndContinueFilledCircle.FillLeft` | `#8C17` | заполнение строки до фиксированного левого края |
| `Game.Circles.SetCabinHeatAndContinueFilledCircle.FillLeftMiddle` | `#8C24` | заливка внутренних байтов левого отсечённого участка |

## [SkipRowsDownAndDrawCircleContours](../Source/Game/Circles/SkipRowsDownAndDrawCircleContours.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Circles.SkipRowsDownAndDrawCircleContours.StepDown` | `#9042` | пропуск очередной строки вниз |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.CountSkipRow` | `#9048` | проверка остатка пропускаемых строк |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.EndSkipRows` | `#904A` | возврат после пропуска строк |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.CrossSkipRow` | `#904D` | переход вниз через границу знакоместа |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.CheckSkipLimit` | `#9059` | проверка нижнего предела пропуска строк |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.RightCutArc` | `#9060` | вход контура с фиксированным правым краем |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.RightCutBottom` | `#9074` | проверка нижнего предела правого отсечённого контура |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.EmptyRightArc` | `#9079` | возврат при пустом правом отсечённом контуре |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.SaveRightStack` | `#907B` | сохранение стека для правого отсечённого контура |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.DrawLeftPixel` | `#907F` | вывод подвижного левого пикселя контура |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.RightArcDown` | `#9090` | переход правой отсечённой дуги вниз |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.RightYError` | `#9093` | ошибка правой отсечённой дуги после шага Y |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.RightXError` | `#90A0` | ошибка правой отсечённой дуги после шага X |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.RightCrossLeft` | `#90B0` | переход подвижного левого края в соседний байт |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.JoinArcRight` | `#90B7` | снятие правого отсечения в дуговом проходе |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.JoinSweepRight` | `#90BB` | снятие правого отсечения в горизонтальном проходе |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.FinishRightArc` | `#90BF` | восстановление стека правого отсечённого контура |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.RightSweepByte` | `#90C5` | переход левого края правого горизонтального участка |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.SweepLeftPixel` | `#90CC` | вывод левого пикселя горизонтального участка |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.RightSweepErr` | `#90D6` | ошибка горизонтального шага правого отсечённого контура |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.RightSweepDown` | `#90F6` | переход на следующую строку правого горизонтального участка |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.BothArc` | `#90FB` | вход контура с двумя подвижными краями |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.BothArcBottom` | `#910C` | проверка нижнего предела двухкраевого контура |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.EmptyBothArc` | `#9111` | возврат при пустом двухкраевом контуре |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.SaveBothStack` | `#9113` | сохранение стека двухкраевого контура |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.DrawBothPixels` | `#9117` | вывод двух граничных пикселей контура |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.BothArcDown` | `#912F` | переход двухкраевой дуги вниз |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.BothYError` | `#9136` | ошибка двухкраевой дуги после шага Y |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.MoveRightPixel` | `#9144` | перемещение правого пикселя дуги |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.BothXError` | `#9148` | ошибка двухкраевой дуги после шага X |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.EndBothXError` | `#914B` | завершение поправки шага X двухкраевой дуги |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.BothCrossLeft` | `#9155` | переход левого края двухкраевой дуги в соседний байт |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.BothCrossRight` | `#915D` | переход правого края двухкраевой дуги в соседний байт |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.FinishBothArc` | `#9165` | восстановление стека двухкраевого контура |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.BothSweepLeft` | `#916B` | переход левого края горизонтального двухкраевого участка |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.BothSweepRight` | `#9173` | переход правого края горизонтального двухкраевого участка |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.SweepBothBits` | `#917B` | вывод двух пикселей горизонтального участка |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.SweepRightBit` | `#9188` | перемещение правого пикселя горизонтального участка |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.BothSweepError` | `#918C` | ошибка горизонтального шага двухкраевого контура |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.EndBothSweep` | `#9191` | завершение поправки горизонтального шага двухкраевого контура |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.BothSweepDown` | `#91A7` | переход на следующую строку двухкраевого горизонтального участка |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.CloseLeftEnd` | `#91AC` | закрытие остатка левого конечного участка |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.FindLeftBit` | `#91B6` | поиск установленного бита левого остатка |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.StoreLeftEnd` | `#91BD` | сохранение расширенного левого конечного участка |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.CloseRightEnd` | `#91C0` | закрытие остатка правого конечного участка |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.FindRightBit` | `#91C6` | поиск установленного бита правого остатка |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.StoreEndMask` | `#91CD` | сохранение сплошной маски конечного участка |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.LeaveClosedArc` | `#91CE` | возврат после закрытия конечных участков контура |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.CloseBothEnds` | `#91D1` | закрытие обоих конечных участков контура |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.FindFirstBit` | `#91D9` | поиск границы первого конечного участка |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.FillFirstEnd` | `#91E0` | сплошное заполнение пустого первого остатка |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.StoreFirstEnd` | `#91E2` | сохранение первого и чтение второго конечного участка |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.FindSecondBit` | `#91EA` | поиск границы второго конечного участка |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.StoreSecondEnd` | `#91F1` | сохранение маски второго конечного участка |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.LeftCutArc` | `#91F4` | вход контура с фиксированным левым краем |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.LeftCutBottom` | `#9208` | проверка нижнего предела левого отсечённого контура |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.EmptyLeftArc` | `#920D` | возврат при пустом левом отсечённом контуре |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.SaveLeftStack` | `#920F` | сохранение стека для левого отсечённого контура |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.DrawRightPixel` | `#9213` | вывод подвижного правого пикселя контура |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.LeftArcDown` | `#9221` | переход левой отсечённой дуги вниз |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.LeftYError` | `#9224` | ошибка левой отсечённой дуги после шага Y |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.LeftXError` | `#9231` | ошибка левой отсечённой дуги после шага X |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.LeftCrossRight` | `#9241` | переход подвижного правого края в соседний байт |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.JoinArcLeft` | `#9249` | снятие левого отсечения в дуговом проходе |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.JoinSweepLeft` | `#924D` | снятие левого отсечения в горизонтальном проходе |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.FinishLeftArc` | `#9251` | восстановление стека левого отсечённого контура |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.LeftSweepByte` | `#9257` | переход правого края левого горизонтального участка |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.DrawRightSweep` | `#925F` | вывод правого пикселя горизонтального участка |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.LeftSweepError` | `#9266` | ошибка горизонтального шага левого отсечённого контура |
| `Game.Circles.SkipRowsDownAndDrawCircleContours.LeftSweepDown` | `#9286` | переход на следующую строку левого горизонтального участка |

## [SkipViewportRowsUp](../Source/Game/Circles/SkipViewportRowsUp.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Circles.SkipViewportRowsUp.StepUp` | `#9014` | пропуск очередной строки вверх |
| `Game.Circles.SkipViewportRowsUp.CountRow` | `#901A` | проверка остатка пропускаемых строк |
| `Game.Circles.SkipViewportRowsUp.RestoreContext` | `#901C` | восстановление регистров после пропуска строк |
| `Game.Circles.SkipViewportRowsUp.CrossCharRow` | `#901F` | переход вверх через границу знакоместа |
| `Game.Circles.SkipViewportRowsUp.CheckTop` | `#902B` | проверка верхнего предела экранного буфера |

## [AnimateIntroAndObjectPipeline](../Source/Game/Combat/AnimateIntroAndObjectPipeline.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Combat.AnimateIntroAndObjectPipeline.CombatFrame` | `#9CB5` | отдельный вход боевого кадра, объекты перед оружием, входная команда CALL Game.Combat.UpdateAllSpaceObjects.Entry |

## [ApplyPlayerDamage](../Source/Game/Combat/ApplyPlayerDamage.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Combat.ApplyPlayerDamage.RecoverEnergy` | `#9A6B` | восстановление энергии перед применением урона щитам, входная команда CALL Game.Combat.RecoverPlayerEnergy.Entry |
| `Game.Combat.ApplyPlayerDamage.DrainCost` | `#9A8A` | настройка величины расхода энергии с учётом маскировки |

## [CalculateFuelPurchasePrice](../Source/Game/Combat/CalculateFuelPurchasePrice.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Combat.CalculateFuelPurchasePrice.MultiplyPrice` | `#9B99` | расчёт произведения количества и коэффициента, входная команда ADD HL,DE |
| `Game.Combat.CalculateFuelPurchasePrice.StorePrice` | `#9B9D` | сохранение рассчитанной стоимости заправки |

## [CreatePlayerWreckScene](../Source/Game/Combat/CreatePlayerWreckScene.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Combat.CreatePlayerWreckScene.ClearSlot` | `#B62A` | очистка энергии всех восьми слотов, входная команда ADD IX,DE |

## [CreateWreckAndDamageState](../Source/Game/Combat/CreateWreckAndDamageState.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Combat.CreateWreckAndDamageState.SignedDelta` | `#9CA5` | отдельный совместимый вход знаковой полуразности, входная команда JP Game.Math.HalfDelta |

## [DamageShieldAndEnergy](../Source/Game/Combat/DamageShieldAndEnergy.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Combat.DamageShieldAndEnergy.DamageGear` | `#9AB3` | проверка сильного попадания для повреждения оборудования, входная команда PUSH BC |
| `Game.Combat.DamageShieldAndEnergy.DamageShield` | `#9ABE` | расчёт четырёх повторений урона щиту, входная команда LD A,(HL) |
| `Game.Combat.DamageShieldAndEnergy.ShieldEmpty` | `#9AC6` | передача оставшегося расхода на банки энергии, входная команда LD (HL),#00 |

## [DrainEnergyBanks](../Source/Game/Combat/DrainEnergyBanks.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Combat.DrainEnergyBanks.DrainBank` | `#9A92` | расчёт расхода с переходом к следующему банку при нехватке, входная команда LD A,(HL) |
| `Game.Combat.DrainEnergyBanks.StoreBank` | `#9AA3` | сохранение остатка энергии текущего банка |

## [FirePlayerLaser](../Source/Game/Combat/FirePlayerLaser.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Combat.FirePlayerLaser.CoolLaser` | `#B64D` | охлаждение лазера с нижним пределом ноль |
| `Game.Combat.FirePlayerLaser.CheckPulse` | `#B672` | проверка четвёртого типа лазера для маски темпа огня |
| `Game.Combat.FirePlayerLaser.CheckTrigger` | `#B678` | проверка нового нажатия либо допустимого кадра удержания, входная команда LD A,E |
| `Game.Combat.FirePlayerLaser.StartShot` | `#B686` | начисление расхода энергии и звукового запроса, входная команда LD HL,CombatState.EnergyDrain |
| `Game.Combat.FirePlayerLaser.AddPower` | `#B69D` | добавление мощности для третьего и старших типов лазера |
| `Game.Combat.FirePlayerLaser.HeatStep` | `#B69F` | сохранение мощности и расчёт нагрева лазера |
| `Game.Combat.FirePlayerLaser.StoreHeat` | `#B6AE` | сохранение температуры после верхнего ограничения |
| `Game.Combat.FirePlayerLaser.FindTarget` | `#B6C3` | поиск поражённого объекта по обратному номеру слота |
| `Game.Combat.FirePlayerLaser.HitTarget` | `#B6CA` | обновление поведения поражённого объекта, входная команда CALL Game.Extensions.SetAggressionThenContinue.Entry |
| `Game.Combat.FirePlayerLaser.PackTarget` | `#B6EB` | переупаковка кода поведения цели с сохранением старшего признака |
| `Game.Combat.FirePlayerLaser.KillTarget` | `#B701` | установка запроса уничтожения и создание содержимого цели, входная команда XOR A |

## [HandleEscapeCapsule](../Source/Game/Combat/HandleEscapeCapsule.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Combat.HandleEscapeCapsule.CheckCommand` | `#9C29` | проверка команды, оборудования и режима пространства, входная команда LD A,(#FC0B) |
| `Game.Combat.HandleEscapeCapsule.ClearCargo` | `#9C50` | очистка части грузового состояния, входная команда LD (HL),A |
| `Game.Combat.HandleEscapeCapsule.SaveEvacuation` | `#9C71` | сохранение параметров эвакуации, входная команда LD (#D0B2),A |

## [HandleMissileControls](../Source/Game/Combat/HandleMissileControls.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Combat.HandleMissileControls.ReadCommands` | `#9BCF` | чтение трёх команд управления ракетой, входная команда LD HL,#FC0B |
| `Game.Combat.HandleMissileControls.ArmMissile` | `#9BE5` | постановка на взвод и сброс прежней цели, входная команда LD A,(HL) |
| `Game.Combat.HandleMissileControls.DisarmMissile` | `#9BF0` | снятие ракеты с боевого взвода |
| `Game.Combat.HandleMissileControls.FireMissile` | `#9BF3` | формирование команды пуска с упакованным номером цели, входная команда LD A,(HL) |
| `Game.Combat.HandleMissileControls.FinishLaunch` | `#9C0D` | завершение успешного пуска, входная команда LD (HL),#00 |

## [HandleObjectCollision](../Source/Game/Combat/HandleObjectCollision.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Combat.HandleObjectCollision.CheckCargo` | `#B4F0` | проверка признака груза перед выбором порога столкновения |
| `Game.Combat.HandleObjectCollision.CheckDistance` | `#B4F8` | проверка трёх координат относительно порога, входная команда LD L,(IX+FSpaceObject.X.Fraction) |
| `Game.Combat.HandleObjectCollision.MissionCargo` | `#B548` | проверка специального миссионного груза при подборе |
| `Game.Combat.HandleObjectCollision.RandomCargo` | `#B555` | выбор случайного типа подбираемого груза |
| `Game.Combat.HandleObjectCollision.ScoopCargo` | `#B55A` | передача выбранного груза миссионному обработчику |
| `Game.Combat.HandleObjectCollision.CheckStation` | `#B55D` | проверка допуска стыковки со станцией, входная команда BIT 2,(IX+FSpaceObject.Flags2) |
| `Game.Combat.HandleObjectCollision.DockDamage` | `#B595` | начисление урона при неполном совмещении, входная команда LD HL,FlightState.SoundRequests |
| `Game.Combat.HandleObjectCollision.DestroyImpact` | `#B5A8` | удаление объекта при обычном ударе, входная команда XOR A |
| `Game.Combat.HandleObjectCollision.DamageSide` | `#B5BF` | выбор передней либо задней защиты для урона, входная команда LD HL,FlightState.SoundRequests |
| `Game.Combat.HandleObjectCollision.FatalImpact` | `#B5D3` | установка признака смертельного столкновения, входная команда INC A |
| `Game.Combat.HandleObjectCollision.FrontImpact` | `#B5D8` | начисление урона передней защите после столкновения |

## [ProcessLaserAndEcm](../Source/Game/Combat/ProcessLaserAndEcm.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Combat.ProcessLaserAndEcm.CheckEcmLock` | `#B7F4` | проверка специального ограничения ECM, входная команда LD A,(State.MissionFlags) |
| `Game.Combat.ProcessLaserAndEcm.ReadEcm` | `#B801` | чтение команды ECM и его текущего таймера, входная команда LD HL,#FC0B |
| `Game.Combat.ProcessLaserAndEcm.EcmCost` | `#B819` | звуковой запрос и расход энергии ECM, входная команда LD HL,FlightState.SoundRequests |

## [RecoverOneEnergyUnit](../Source/Game/Combat/RecoverOneEnergyUnit.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Combat.RecoverOneEnergyUnit.CheckBank` | `#9AE7` | поиск первого неполного банка от верхнего к нижнему, входная команда LD A,(HL) |
| `Game.Combat.RecoverOneEnergyUnit.NextBank` | `#9AEE` | переход к следующему банку при полном текущем |

## [ReleaseMissileTargets](../Source/Game/Combat/ReleaseMissileTargets.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Combat.ReleaseMissileTargets.CheckTarget` | `#B5EE` | проверка живого слота и совпадения кода цели, входная команда ADD IY,DE |
| `Game.Combat.ReleaseMissileTargets.NextMissile` | `#B600` | продолжение обхода ракет после снятия ссылки на удалённую цель |

## [SetIndicatorAndPrintMissileStock](../Source/Game/Combat/SetIndicatorAndPrintMissileStock.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Combat.SetIndicatorAndPrintMissileStock.StoreIndicator` | `#9B19` | запись атрибута индикатора наличия оборудования |
| `Game.Combat.SetIndicatorAndPrintMissileStock.PrintStock` | `#9B1B` | отдельный вход печати четырёх позиций ракет, входная команда LD HL,#1702 |
| `Game.Combat.SetIndicatorAndPrintMissileStock.MissileSlot` | `#9B2D` | проверка наличия очередной ракеты перед выбором символа, входная команда DEC C |
| `Game.Combat.SetIndicatorAndPrintMissileStock.PrintMissile` | `#9B37` | печать символа занятого или пустого ракетного места |

## [SetObjectEnergyAndDrawMissedLaser](../Source/Game/Combat/SetObjectEnergyAndDrawMissedLaser.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Combat.SetObjectEnergyAndDrawMissedLaser.MissedBeam` | `#B749` | отдельный вход расчёта случайного смещения луча, входная команда CALL Game.Combat.NextRandomByte.Entry |

## [UpdateAllSpaceObjects](../Source/Game/Combat/UpdateAllSpaceObjects.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Combat.UpdateAllSpaceObjects.SelectRaster` | `#9CC7` | выбор OR/XOR для вывода объектов |
| `Game.Combat.UpdateAllSpaceObjects.PatchRaster` | `#9CD1` | запись выбранного логического кода в изменяемые растровые команды |
| `Game.Combat.UpdateAllSpaceObjects.ResetFrame` | `#9CFD` | очистка накопителей и признаков нового кадра, входная команда XOR A |
| `Game.Combat.UpdateAllSpaceObjects.CountShips` | `#9D1D` | подсчёт живых управляемых кораблей в обычных слотах |
| `Game.Combat.UpdateAllSpaceObjects.NextCount` | `#9D2A` | переход к следующему слоту подсчёта кораблей |
| `Game.Combat.UpdateAllSpaceObjects.ProcessSlot` | `#9D38` | начало обработки очередного объектного слота и его метаданных |
| `Game.Combat.UpdateAllSpaceObjects.SceneFlags` | `#9D50` | обновление признаков сцены и массового запроса уничтожения, входная команда CALL Game.Universe.AdvanceCircularObjectEffect.Entry |
| `Game.Combat.UpdateAllSpaceObjects.CheckMassKill` | `#9D5F` | проверка массового запроса уничтожения объектов |
| `Game.Combat.UpdateAllSpaceObjects.CheckDanger` | `#9D76` | проверка опасной обстановки по флагам враждебного объекта, входная команда BIT 2,(IX+FSpaceObject.Hostility) |
| `Game.Combat.UpdateAllSpaceObjects.CheckMissile` | `#9D88` | проверка выделенного ракетного слота и опасности сцены |
| `Game.Combat.UpdateAllSpaceObjects.SetAggression` | `#9D94` | установка расширенного признака агрессии |
| `Game.Combat.UpdateAllSpaceObjects.ReadBlueprint` | `#9D98` | поиск модели и разбор стадии уничтожения, входная команда LD H,(IX+FSpaceObject.Blueprint+FSignWord.SignHigh) |
| `Game.Combat.UpdateAllSpaceObjects.CheckMission` | `#9DD6` | проверка размера модели перед сбросом второй миссии |
| `Game.Combat.UpdateAllSpaceObjects.ClearMission` | `#9DDD` | сброс состояния второй миссии при уничтожении её объекта |
| `Game.Combat.UpdateAllSpaceObjects.ReleaseObject` | `#9DE1` | освобождение слота, снятие целей и начисление наград, входная команда XOR A |
| `Game.Combat.UpdateAllSpaceObjects.ScheduleAI` | `#9E0F` | выбор расписания поведения и цели текущего объекта, входная команда LD A,B |
| `Game.Combat.UpdateAllSpaceObjects.ScheduleTactic` | `#9E24` | планирование тактического шага через каждые четыре фазы |
| `Game.Combat.UpdateAllSpaceObjects.MoveObject` | `#9E29` | движение, коррекция базиса и проверка столкновения, входная команда CALL Game.Motion.UpdateObjectCoordinatesAndRotation.Entry |
| `Game.Combat.UpdateAllSpaceObjects.ProjectObject` | `#9E41` | переход на защищённую проекцию объекта, входная команда CALL Game.Combat.HandleObjectCollision.Entry |
| `Game.Combat.UpdateAllSpaceObjects.AfterProject` | `#9E47` | продолжение объектного цикла после защищённой проекции |
| `Game.Combat.UpdateAllSpaceObjects.NextSlot` | `#9E5C` | переход к следующему слоту и расширенной записи, входная команда POP AF |

## [UpdateClockAndRotateDistantBodies](../Source/Game/Combat/UpdateClockAndRotateDistantBodies.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Combat.UpdateClockAndRotateDistantBodies.TickNegative` | `#9B5A` | продвижение отрицательной кодировки внутреннего счётчика времени |
| `Game.Combat.UpdateClockAndRotateDistantBodies.WrapClock` | `#9B65` | переход счётчика времени через ноль к значению 127 |
| `Game.Combat.UpdateClockAndRotateDistantBodies.RotateBodies` | `#9B68` | отдельный вход вращения объекта и двух далёких тел, входная команда CALL Game.Combat.ApplyPlayerMotion.Entry |

## [SystemBoundaryAndObjects](../Source/Game/Data/SystemBoundaryAndObjects.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Data.SystemBoundaryAndObjects.FindPlanet` | `#6005` | поиск планеты в новой точке карты, входная команда LD HL,(#D099) |
| `Game.Data.SystemBoundaryAndObjects.PlaceBodies` | `#6028` | завершение миссионной обработки и размещение небесных тел, входная команда CALL Game.Universe.CheckSpecialSystemOrRandom.Entry |

## [BlackAttributesAndOverlayState](../Source/Game/Disk/BlackAttributesAndOverlayState.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Disk.BlackAttributesAndOverlayState.ClearAttribute` | `#D97B` | очистка всех 768 атрибутов, по 256 байтов в каждой из трёх страниц, входная команда LD (HL),C |

## [DrawScreenStripsAndPrivateStack](../Source/Game/Disk/DrawScreenStripsAndPrivateStack.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Disk.DrawScreenStripsAndPrivateStack.DrawStrips` | `#DA51` | вывод очередной растровой полосы |

## [LoadDiskMenuOverlay](../Source/Game/Disk/LoadDiskMenuOverlay.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Disk.LoadDiskMenuOverlay.ZeroTrackRead` | `#D964` | чтение с нулевой дорожки с общими параметрами дискового потока |
| `Game.Disk.LoadDiskMenuOverlay.ReadTrackBytes` | `#D967` | чтение дискового потока с уже заданной дорожкой |
| `Game.Disk.LoadDiskMenuOverlay.EnterDiskRom` | `#D970` | вход в TR-DOS после установки параметров чтения |

## [TransferDiskSectors](../Source/Game/Disk/TransferDiskSectors.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Disk.TransferDiskSectors.PrepareSector` | `#D9CB` | передача очередного сектора и продвижение адреса буфера на 256 байтов, входная команда LD (#D9E5),IX |
| `Game.Disk.TransferDiskSectors.TransferSector` | `#D9E1` | передача одного сектора через дисковую процедуру |
| `Game.Disk.TransferDiskSectors.SelectTrack` | `#D9F4` | выбор дорожки для следующего сектора |
| `Game.Disk.TransferDiskSectors.NextSector` | `#DA10` | переход к очередному сектору блока |

## [PrintByteInteger](../Source/Game/Economy/PrintByteInteger.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Economy.PrintByteInteger.ExtendByte` | `#D2E2` | целый формат, A расширяется до слова без знака, входная команда LD H,#00 |

## [PrintDecimalPlace](../Source/Game/Economy/PrintDecimalPlace.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Economy.PrintDecimalPlace.CountDigit` | `#D35C` | подсчёт очередной цифры последовательным вычитанием её веса |
| `Game.Economy.PrintDecimalPlace.RestoreRest` | `#D364` | возврат последнего лишнего вычитания и сохранение остатка для следующего разряда, входная команда ADD HL,DE |

## [PrintDigitOrLeadingZero](../Source/Game/Economy/PrintDigitOrLeadingZero.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Economy.PrintDigitOrLeadingZero.LeadingZero` | `#D376` | перевод цифры 0..9 в ASCII, дополнительный вход D376 подавляет нули при D0CC!=0, входная команда LD A,(#D0CC) |

## [PrintNumberPadding](../Source/Game/Economy/PrintNumberPadding.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Economy.PrintNumberPadding.CountDigits` | `#D38B` | определение числа десятичных позиций по порогам 10,100,1000,10000 |
| `Game.Economy.PrintNumberPadding.FourDigits` | `#D3AD` | установка ширины четырёхзначного числа |
| `Game.Economy.PrintNumberPadding.ThreeDigits` | `#D3AE` | установка ширины трёхзначного числа |
| `Game.Economy.PrintNumberPadding.TwoPositions` | `#D3AF` | добавление второй позиции для числа либо ведущего нуля дробной суммы |
| `Game.Economy.PrintNumberPadding.CheckWidth` | `#D3B0` | сопоставление ширины числа с шириной поля |
| `Game.Economy.PrintNumberPadding.PadPosition` | `#D3B8` | добивка поля до заданной ширины выбранными пробелами или нулями, входная команда PUSH BC |
| `Game.Economy.PrintNumberPadding.ZeroPadding` | `#D3C5` | выбор символа нуля для дополнения поля |
| `Game.Economy.PrintNumberPadding.PrintPadding` | `#D3C7` | печать выбранного символа дополнения |

## [PrintSplitCash](../Source/Game/Economy/PrintSplitCash.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Economy.PrintSplitCash.OnlyLowGroup` | `#D34D` | вывод суммы без старшей тысячной группы |
| `Game.Economy.PrintSplitCash.PrintLowGroup` | `#D352` | печать младшей группы суммы с выбранным дополнением |

## [PrintWordDecimal](../Source/Game/Economy/PrintWordDecimal.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Economy.PrintWordDecimal.PrintPoint` | `#D319` | печать десятичной точки перед последним дробным разрядом |

## [SubtractCashLow](../Source/Game/Economy/SubtractCashLow.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Economy.SubtractCashLow.StoreBalance` | `#D41B` | сохранение уменьшенной младшей группы денежного баланса |

## [SubtractCashThousands](../Source/Game/Economy/SubtractCashThousands.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Economy.SubtractCashThousands.NoFunds` | `#D3FB` | отказ списания денег с установкой переноса |

## [AllocateVariantObjectSlot](../Source/Game/Extensions/AllocateVariantObjectSlot.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Extensions.AllocateVariantObjectSlot.MixVariant` | `#FAE2` | смешивание случайного байта с промежуточным типом корабля |
| `Game.Extensions.AllocateVariantObjectSlot.ClearMetaFlag` | `#FAE9` | очистка признака метаданных для выбранного типа |

## [AttributeVectorAndEnergyBomb](../Source/Game/Extensions/AttributeVectorAndEnergyBomb.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Extensions.AttributeVectorAndEnergyBomb.ConfirmUpgrade` | `#6FFB` | обработка ответа на предложение улучшения |
| `Game.Extensions.AttributeVectorAndEnergyBomb.SelectMenu` | `#7005` | выбор продолжения меню по наличию улучшения |
| `Game.Extensions.AttributeVectorAndEnergyBomb.ReadCargoByte` | `#700F` | чтение текущей товарной строки с проверкой колонии |
| `Game.Extensions.AttributeVectorAndEnergyBomb.ColonyGate` | `#7013` | изменяемая команда NOP либо RET для проверки живой колонии |
| `Game.Extensions.AttributeVectorAndEnergyBomb.UseEnergyBomb` | `#7089` | проверка команды и расход энергетической бомбы |
| `Game.Extensions.AttributeVectorAndEnergyBomb.FlashAgain` | `#70A2` | очередная вспышка экрана после расхода бомбы |

## [BuildSmallCircleProfile](../Source/Game/Extensions/BuildSmallCircleProfile.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Extensions.BuildSmallCircleProfile.ReadProfile` | `#FB10` | чтение параметров профиля для заданного радиуса |
| `Game.Extensions.BuildSmallCircleProfile.SlopeRow` | `#FB1B` | запись очередной маски наклонной части силуэта |
| `Game.Extensions.BuildSmallCircleProfile.RepeatRow` | `#FB22` | запись очередной строки с последней маской |

## [ChooseLinkedObjectTarget](../Source/Game/Extensions/ChooseLinkedObjectTarget.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Extensions.ChooseLinkedObjectTarget.ClearReserve` | `#FA47` | сброс недействительной резервной ссылки |
| `Game.Extensions.ChooseLinkedObjectTarget.CheckSearch` | `#FA48` | проверка разрешающих флагов перед поиском новой цели |
| `Game.Extensions.ChooseLinkedObjectTarget.FindLinked` | `#FA54` | поиск записи метаданных с признаком подходящей цели |
| `Game.Extensions.ChooseLinkedObjectTarget.NoTarget` | `#FA79` | возврат нулевого результата при отсутствии цели |
| `Game.Extensions.ChooseLinkedObjectTarget.FoundLinked` | `#FA7B` | возврат указателя метаданных после выбора связанной цели |
| `Game.Extensions.ChooseLinkedObjectTarget.StoreTarget` | `#FA7C` | сохранение выбранного номера цели с прежним старшим битом |
| `Game.Extensions.ChooseLinkedObjectTarget.ReturnTarget` | `#FA81` | возврат выбранного номера цели и ненулевого признака |

## [CompareObjectCoordinateDepth](../Source/Game/Extensions/CompareObjectCoordinateDepth.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Extensions.CompareObjectCoordinateDepth.AcceptDepth` | `#FC00` | возврат ненулевого признака принятия объекта по глубине |
| `Game.Extensions.CompareObjectCoordinateDepth.RejectDepth` | `#FC03` | возврат нуля при отбраковке объекта по глубине |

## [CreateMissileOrMissionCraft](../Source/Game/Extensions/CreateMissileOrMissionCraft.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Extensions.CreateMissileOrMissionCraft.SpendMissile` | `#5EEC` | расход ракеты перед проверкой специального груза |
| `Game.Extensions.CreateMissileOrMissionCraft.SetBlueprint` | `#5F09` | назначение выбранной модели созданному объекту |

## [DrawCircleAndProtectScratchStack](../Source/Game/Extensions/DrawCircleAndProtectScratchStack.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Extensions.DrawCircleAndProtectScratchStack.NextOrFinish` | `#F8E4` | продолжение обхода объектов либо восстановление временного стека |

## [DrawCompressedEdges](../Source/Game/Extensions/DrawCompressedEdges.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Extensions.DrawCompressedEdges.ReadEdgeBlock` | `#6F5B` | чтение указателей потоков упакованных рёбер |
| `Game.Extensions.DrawCompressedEdges.ReadEdgeGroup` | `#6F78` | чтение очередной группы порогов видимости |
| `Game.Extensions.DrawCompressedEdges.UseThreshold` | `#6F80` | применение порога текущей группы рёбер |
| `Game.Extensions.DrawCompressedEdges.TestEdge` | `#6F8A` | проверка ограничения дальности и видимости ребра |
| `Game.Extensions.DrawCompressedEdges.TestFace` | `#6F98` | проверка видимости грани текущего ребра |
| `Game.Extensions.DrawCompressedEdges.LowVertex` | `#6FB3` | извлечение номера вершины без добавочного старшего бита |
| `Game.Extensions.DrawCompressedEdges.ProjectFirst` | `#6FB5` | чтение проекции первой вершины ребра |
| `Game.Extensions.DrawCompressedEdges.NextEdge` | `#6FD5` | восстановление указателей и переход к следующему ребру |
| `Game.Extensions.DrawCompressedEdges.CountEdge` | `#6FE1` | уменьшение числа оставшихся рёбер |

## [DrawSmallSilhouette](../Source/Game/Extensions/DrawSmallSilhouette.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Extensions.DrawSmallSilhouette.ClipLeft` | `#FB59` | проверка размещения левого края силуэта |
| `Game.Extensions.DrawSmallSilhouette.ClipRight` | `#FB5F` | проверка размещения правого края силуэта |
| `Game.Extensions.DrawSmallSilhouette.CheckHeight` | `#FB65` | проверка вертикального диапазона центра |
| `Game.Extensions.DrawSmallSilhouette.RejectCentre` | `#FB6A` | отказ от вывода силуэта вне допустимого диапазона |
| `Game.Extensions.DrawSmallSilhouette.ScreenY` | `#FB6C` | расчёт экранной строки из знаковой проекции |
| `Game.Extensions.DrawSmallSilhouette.AddRadius` | `#FB75` | смещение к нижней строке силуэта на радиус |
| `Game.Extensions.DrawSmallSilhouette.DrawRaster` | `#FB7B` | вывод готового профиля по экранному адресу HL и смещению пикселя A |
| `Game.Extensions.DrawSmallSilhouette.NextScanline` | `#FB83` | переход к следующей экранной строке силуэта |
| `Game.Extensions.DrawSmallSilhouette.BuildRowMask` | `#FB98` | построение трёхбайтовой маски строки |
| `Game.Extensions.DrawSmallSilhouette.MirrorMask` | `#FB9E` | перестановка битов профиля в старший байт маски |
| `Game.Extensions.DrawSmallSilhouette.ShiftRowMask` | `#FBAA` | смещение маски к пиксельной позиции центра |
| `Game.Extensions.DrawSmallSilhouette.WriteCentre` | `#FBBA` | наложение центрального байта силуэта |
| `Game.Extensions.DrawSmallSilhouette.RestoreClip` | `#FBC8` | восстановление флагов отсечения и радиуса |
| `Game.Extensions.DrawSmallSilhouette.AdvanceProfile` | `#FBC9` | переход к следующей строке прямой либо обратной половины профиля |
| `Game.Extensions.DrawSmallSilhouette.ReverseRow` | `#FBD8` | продвижение назад по симметричной половине профиля |

## [FillBackwardAndCountDemo](../Source/Game/Extensions/FillBackwardAndCountDemo.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Extensions.FillBackwardAndCountDemo.RestoreRegs` | `#5E4D` | восстановление регистров после обратного заполнения |
| `Game.Extensions.FillBackwardAndCountDemo.ReturnState` | `#5E50` | возврат состояния результата после заполнения |
| `Game.Extensions.FillBackwardAndCountDemo.CountDemo` | `#5E55` | учёт завершения демонстрационного такта |
| `Game.Extensions.FillBackwardAndCountDemo.ShowMenu` | `#5E65` | возврат к обработке выбранного меню |

## [FindLiveTrackedObject](../Source/Game/Extensions/FindLiveTrackedObject.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Extensions.FindLiveTrackedObject.CheckSlot` | `#F963` | проверка флага ракеты, энергии и идентификатора слота |
| `Game.Extensions.FindLiveTrackedObject.PreviousSlot` | `#F975` | переход к предыдущему 39-байтовому слоту |

## [GetViewAdjustedProjectedPoint](../Source/Game/Extensions/GetViewAdjustedProjectedPoint.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Extensions.GetViewAdjustedProjectedPoint.ReturnFlags` | `#F958` | возврат признаков проекции с поправкой на вид |

## [HandleSpecialMessageToken](../Source/Game/Extensions/HandleSpecialMessageToken.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Extensions.HandleSpecialMessageToken.ApplyGates` | `#5E24` | запись NOP либо RET в две команды допуска колонии |
| `Game.Extensions.HandleSpecialMessageToken.ShowColony` | `#5E30` | замена исходного токена сообщением живой колонии |

## [MarkObjectEventAndUpdateMetadata](../Source/Game/Extensions/MarkObjectEventAndUpdateMetadata.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Extensions.MarkObjectEventAndUpdateMetadata.UpdateMetadata` | `#F927` | вызов обработчика метаданных с сохранением аккумулятора |

## [OfferUpgradeAndCorrectPosition](../Source/Game/Extensions/OfferUpgradeAndCorrectPosition.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Extensions.OfferUpgradeAndCorrectPosition.CorrectCentre` | `#5FD5` | поправка координаты второго координатного объекта |
| `Game.Extensions.OfferUpgradeAndCorrectPosition.DoubleDominant` | `#5FFF` | удвоение выбранной преобладающей координаты |

## [PrintCargoAndMessageBanks](../Source/Game/Extensions/PrintCargoAndMessageBanks.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Extensions.PrintCargoAndMessageBanks.StartCargoList` | `#F0FD` | инициализация указателя и номера товара |
| `Game.Extensions.PrintCargoAndMessageBanks.PrintCargoRow` | `#F107` | вывод очередной непустой товарной строки |
| `Game.Extensions.PrintCargoAndMessageBanks.ProjectSafely` | `#F8B4` | проекция с временным рабочим стеком и отключённым IM2 |
| `Game.Extensions.PrintCargoAndMessageBanks.RestoreStack` | `#F8CB` | восстановление стека перед возвратом к выводу объекта |

## [PrintEquipmentAndSelectIcon](../Source/Game/Extensions/PrintEquipmentAndSelectIcon.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Extensions.PrintEquipmentAndSelectIcon.SelectIcon` | `#6F29` | выбор значка специального пространства и режима координат |

## [ResetObjectMetadata](../Source/Game/Extensions/ResetObjectMetadata.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Extensions.ResetObjectMetadata.ClearRecords` | `#F9B9` | очистка восьмидесяти байтов записей метаданных |

## [ResolveSpecialObjectCollision](../Source/Game/Extensions/ResolveSpecialObjectCollision.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Extensions.ResolveSpecialObjectCollision.DestroyFirst` | `#F9A0` | обнуление энергии первого участника столкновения |

## [ScheduleLinkedObjectLaser](../Source/Game/Extensions/ScheduleLinkedObjectLaser.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Extensions.ScheduleLinkedObjectLaser.CheckLinks` | `#FA98` | проверка наличия ссылок на цели |
| `Game.Extensions.ScheduleLinkedObjectLaser.PermitLaser` | `#FAA8` | установка переноса для разрешённого действия |
| `Game.Extensions.ScheduleLinkedObjectLaser.RestoreTarget` | `#FAA9` | восстановление указателя вызывающей процедуры |
| `Game.Extensions.ScheduleLinkedObjectLaser.TestRandom` | `#FABB` | проверка результата случайного сравнения либо безусловного допуска |
| `Game.Extensions.ScheduleLinkedObjectLaser.UpdateHistory` | `#FABF` | сдвиг накопленной истории случайного выбора |

## [SelectCharacterFont](../Source/Game/Extensions/SelectCharacterFont.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Extensions.SelectCharacterFont.ExtraFont` | `#5E16` | выбор дополнительного знакогенератора |

## [SetObjectAggressionFlag](../Source/Game/Extensions/SetObjectAggressionFlag.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Extensions.SetObjectAggressionFlag.EnableAttack` | `#F9DC` | разрешение агрессивного поведения |

## [UpdateInvasionOnRatingOverflow](../Source/Game/Extensions/UpdateInvasionOnRatingOverflow.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Extensions.UpdateInvasionOnRatingOverflow.CheckRating` | `#5E9C` | проверка рейтинга и битов счётчика переходов |
| `Game.Extensions.UpdateInvasionOnRatingOverflow.MarkJumpCount` | `#5EB7` | установка старшего бита счётчика переходов |
| `Game.Extensions.UpdateInvasionOnRatingOverflow.ReturnInput` | `#5EBB` | возврат указателя для вызывающего обработчика рейтинга |
| `Game.Extensions.UpdateInvasionOnRatingOverflow.ReduceIfEven` | `#5EBE` | уменьшение чётного кода рейтинга либо счётчика переходов |

## [UpdateSpecialCargoStatus](../Source/Game/Extensions/UpdateSpecialCargoStatus.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Extensions.UpdateSpecialCargoStatus.StoreBalance` | `#6ECF` | запись разности в выбранное грузовое поле |

## [UpdateStationAndFinishGlyph](../Source/Game/Extensions/UpdateStationAndFinishGlyph.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Extensions.UpdateStationAndFinishGlyph.FinishGlyph` | `#5DF0` | извлечение адреса глифа со стека и вывод восьми строк |

## [UpdateStationAndSpecialShips](../Source/Game/Extensions/UpdateStationAndSpecialShips.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Extensions.UpdateStationAndSpecialShips.NearSun` | `#5F3F` | обработка станции в солнечной полосе |
| `Game.Extensions.UpdateStationAndSpecialShips.CopySunAxis` | `#5F5A` | перенос средней части и знака очередной координаты солнца |
| `Game.Extensions.UpdateStationAndSpecialShips.OfferCobra` | `#5F81` | запись предложения Cobra Mk4 перед созданием Asp |
| `Game.Extensions.UpdateStationAndSpecialShips.SpawnShip` | `#5F87` | создание корабля с временной защитой второго слота |

## [ValidatePackedObjectTarget](../Source/Game/Extensions/ValidatePackedObjectTarget.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Extensions.ValidatePackedObjectTarget.FindEnergy` | `#F9F7` | переход к энергии следующего объектного слота |
| `Game.Extensions.ValidatePackedObjectTarget.ReturnNumber` | `#FA0B` | возврат номера подтверждённой цели |

## [AnimateTransitionTunnel](../Source/Game/Flight/AnimateTransitionTunnel.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Flight.AnimateTransitionTunnel.InitHyperRings` | `#92B3` | очистка экрана и подготовка шестнадцати глубин гипертуннеля, входная команда CALL Game.Screen.ClearFlightBuffer.Entry |
| `Game.Flight.AnimateTransitionTunnel.SelectFrameEnd` | `#92D6` | выбор завершения кадра через изменяемое смещение JR9317, входная команда LD A,(#D040) |
| `Game.Flight.AnimateTransitionTunnel.MainFrameEnd` | `#92E3` | установка продолжения кадра для основной фазы тоннеля |
| `Game.Flight.AnimateTransitionTunnel.InitCircle` | `#92E8` | нулевой центр окружностей и признаки всех четвертей 0F, входная команда LD A,#0F |
| `Game.Flight.AnimateTransitionTunnel.SelectDepths` | `#92F9` | SMC, HL выбирает таблицу из 16 либо 8 глубин, входная команда LD HL,#93D3 |
| `Game.Flight.AnimateTransitionTunnel.AdvanceRing` | `#92FC` | приближение кольца на единицу, радиус равен целой части 256/глубина, входная команда LD A,(HL) |
| `Game.Flight.AnimateTransitionTunnel.CountRing` | `#9313` | проверка конца набора колец, JR9317 ведёт на 931E либо 9337, входная команда LD A,(#93D1) |
| `Game.Flight.AnimateTransitionTunnel.ShowFrame` | `#931E` | вывод кадра и уменьшение времени основного этапа, входная команда CALL Game.Screen.CopyFlightView.Entry |
| `Game.Flight.AnimateTransitionTunnel.RestoreHyper` | `#934E` | восстановление шестнадцати глубин гипертуннеля |
| `Game.Flight.AnimateTransitionTunnel.EndLaunch` | `#935E` | завершение старта снимает D040 и задаёт скорость 7, входная команда XOR A |
| `Game.Flight.AnimateTransitionTunnel.EndDockTunnel` | `#9369` | окончание остаточной фазы снимает D03F и восстанавливает 8 глубин вычитанием C0, входная команда XOR A |
| `Game.Flight.AnimateTransitionTunnel.RestoreDock` | `#9373` | восстановление восьми глубин стыковочных колец |
| `Game.Flight.AnimateTransitionTunnel.SetSpeed` | `#937B` | скорость после выхода из туннеля равна 7, входная команда LD A,#07 |

## [ApplyMissionViewColour](../Source/Game/Flight/ApplyMissionViewColour.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Flight.ApplyMissionViewColour.MissionColour` | `#7260` | проверка первой миссии перед применением её цвета, входная команда LD L,#02 |

## [ClearBytes](../Source/Game/Flight/ClearBytes.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Flight.ClearBytes.ClearByte` | `#9504` | заполнение B байтов нулями, B=0 означает 256 итераций, входная команда LD (HL),A |

## [ClearNearbyShipSlots](../Source/Game/Flight/ClearNearbyShipSlots.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Flight.ClearNearbyShipSlots.ClearShip` | `#951A` | освобождение очередного слота корабля через его поле энергии |

## [DispatchDeviceAndAppendDigit](../Source/Game/Flight/DispatchDeviceAndAppendDigit.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Flight.DispatchDeviceAndAppendDigit.AppendDigit` | `#7130` | отдельный вход рассчитывает 10*старое+B по модулю 256, входная команда LD A,(HL) |

## [DispatchThirdMissionStage](../Source/Game/Flight/DispatchThirdMissionStage.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Flight.DispatchThirdMissionStage.OfferStage` | `#727F` | предложение очередного этапа третьей миссии |

## [DivideByteFractionForTunnel](../Source/Game/Flight/DivideByteFractionForTunnel.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Flight.DivideByteFractionForTunnel.QuotientBit` | `#93AE` | удвоение остатка перед очередным битом частного, входная команда ADD A,A |
| `Game.Flight.DivideByteFractionForTunnel.SubDivisor` | `#93B9` | вычитание делителя и единичный бит частного, входная команда SUB B |

## [DrawDemoHeading](../Source/Game/Flight/DrawDemoHeading.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Flight.DrawDemoHeading.RestoreScreen` | `#7459` | общий хвост возвращает печать в экран 4000, входная команда LD HL,(#D0D5) |

## [DrawTitleCaption](../Source/Game/Flight/DrawTitleCaption.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Flight.DrawTitleCaption.PrintCaption` | `#7438` | позиция подписи и временный выбор экранного буфера C000, входная команда LD (#D045),HL |

## [Fill240Attributes](../Source/Game/Flight/Fill240Attributes.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Flight.Fill240Attributes.FillAttribute` | `#746B` | заливка 240 байтов значением 07, HL указывает продолжение, входная команда LD (HL),A |

## [FillViewAttributesAndFlightState](../Source/Game/Flight/FillViewAttributesAndFlightState.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Flight.FillViewAttributesAndFlightState.SyncFill` | `#70C4` | синхронизация с кадром перед заливкой внутреннего окна, входная команда HALT |
| `Game.Flight.FillViewAttributesAndFlightState.FillRow` | `#70CB` | размножение атрибута в 30 ячеек строки, затем пропуск боковых столбцов рамки, входная команда LD (HL),A |

## [HandleMapCursorKeys](../Source/Game/Flight/HandleMapCursorKeys.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Flight.HandleMapCursorKeys.FindKeyBit` | `#7210` | поиск установленного бита команды курсора карты |

## [HandlePauseMenu](../Source/Game/Flight/HandlePauseMenu.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Flight.HandlePauseMenu.WaitRelease` | `#72AC` | ожидание отпускания клавиши, FF означает отсутствие символа, входная команда HALT |
| `Game.Flight.HandlePauseMenu.ReadPauseKey` | `#72B3` | поиск новой команды сначала среди переключателей настроек, входная команда HALT |
| `Game.Flight.HandlePauseMenu.ToggleOption` | `#72CA` | инверсия маски выбранной настройки в FC0E, входная команда LD A,(HL) |
| `Game.Flight.HandlePauseMenu.RunPauseAction` | `#72D0` | подмена адреса возврата обработчиком в странице 73, входная команда LD L,(HL) |

## [IndexPauseCommandAndHandlers](../Source/Game/Flight/IndexPauseCommandAndHandlers.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Flight.IndexPauseCommandAndHandlers.SwapLasers` | `#72E3` | команда A переставляет пары лазеров только после покупки Mk4, входная команда LD A,(State.ShipUpgrade) |
| `Game.Flight.IndexPauseCommandAndHandlers.SwitchJoystick` | `#7333` | переключение текущего источника управления с сохранённым джойстиком |
| `Game.Flight.IndexPauseCommandAndHandlers.NoUpgrade` | `#733E` | перекрывающий вход на старший байт CALL, исполняемый как RST #18 при отсутствии Mk4 |
| `Game.Flight.IndexPauseCommandAndHandlers.StoreOption` | `#733F` | запись настройки и подстановка возврата в ожидание паузы, входная команда LD (HL),A |
| `Game.Flight.IndexPauseCommandAndHandlers.AwaitPauseKey` | `#7340` | запись настройки и подстановка возврата в ожидание паузы, входная команда LD HL,#72AC |

## [LaunchOrDockShip](../Source/Game/Flight/LaunchOrDockShip.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Flight.LaunchOrDockShip.DockFrame` | `#9438` | вывод очередного кадра тоннеля при стыковке |
| `Game.Flight.LaunchOrDockShip.LaunchStation` | `#945D` | старт со станции задаёт зелёный полётный сигнал 4, входная команда LD A,#04 |
| `Game.Flight.LaunchOrDockShip.LaunchFrame` | `#94C8` | вывод очередного кадра тоннеля при запуске со станции |
| `Game.Flight.LaunchOrDockShip.FinalFrame` | `#94DA` | последние 11 кадров дополнительно обновляют координаты и рисуют планету, входная команда PUSH BC |

## [MainGameLoop](../Source/Game/Flight/MainGameLoop.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Flight.MainGameLoop.HandleKeys` | `#747A` | чтение клавиш и меню паузы, перенос после Q возвращает заставку, входная команда CALL Game.Screen.HandleScreenKeys.Entry |
| `Game.Flight.MainGameLoop.UpdateStatus` | `#748C` | общий интерфейс и разделение станции и полёта, входная команда CALL Game.Interface.DispatchJumpKey.Entry |
| `Game.Flight.MainGameLoop.FlightFrame` | `#74AA` | в полёте сначала проверяется стыковка, затем события и движение мира, входная команда LD A,(FlightState.SpaceMode) |
| `Game.Flight.MainGameLoop.UpdateWorld` | `#74B6` | обновление мира и движения в полётном кадре |
| `Game.Flight.MainGameLoop.UpdateEvents` | `#74D2` | обновление события и восемь кадров обслуживания карты, входная команда CALL Game.Universe.ExpandNovaRadius.Entry |
| `Game.Flight.MainGameLoop.MapFrame` | `#74DA` | обработка клавиш карты в восьмикадровой паузе |
| `Game.Flight.MainGameLoop.DrawView` | `#74E4` | рисование сцены, вне обычного пространства светила пропускаются, входная команда CALL Game.Screen.RestoreCockpitIfNeeded.Entry |
| `Game.Flight.MainGameLoop.DrawObjects` | `#74F4` | обновление объектов и оружия перед выводом индикаторов |
| `Game.Flight.MainGameLoop.DrawIndicators` | `#7502` | завершение кадра, приборы и проверка маскировки, входная команда CALL Game.Menus.DrawExplosionAndScanner.Entry |
| `Game.Flight.MainGameLoop.CheckDeath` | `#750F` | обработка вооружения, опасного сближения и признака гибели, входная команда CALL Game.Screen.UpdateCelestialProximity.Entry |
| `Game.Flight.MainGameLoop.DeathFrame` | `#753A` | тридцать кадров звёзд и надписи о гибели, входная команда PUSH BC |
| `Game.Flight.MainGameLoop.DeathDelay` | `#756B` | пятьдесят кадров ожидания перед возвратом к заставке, входная команда HALT |

## [PlaySweepingBeeperAndBootstrap](../Source/Game/Flight/PlaySweepingBeeperAndBootstrap.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Flight.PlaySweepingBeeperAndBootstrap.SweepGroup` | `#7348` | шесть групп по четыре периода, HALT выполняется перед каждой группой, входная команда PUSH BC |
| `Game.Flight.PlaySweepingBeeperAndBootstrap.NextPeriod` | `#734C` | расчёт периода по формуле E=(2*E+5) mod256, входная команда LD A,E |
| `Game.Flight.PlaySweepingBeeperAndBootstrap.HighDelay` | `#7356` | высокая фаза бипера с задержкой B, входная команда DJNZ #7356 |
| `Game.Flight.PlaySweepingBeeperAndBootstrap.LowDelay` | `#735D` | задержка низкого уровня звукового периода заставки |

## [RebaseCoordinateAxis](../Source/Game/Flight/RebaseCoordinateAxis.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Flight.RebaseCoordinateAxis.StoreAxis` | `#71D6` | сохранение старших двух байтов и переход к следующей оси, входная команда LD (IY+FCoordinate.SignHigh),H |

## [ReportBoardingAndReturnToTitle](../Source/Game/Flight/ReportBoardingAndReturnToTitle.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Flight.ReportBoardingAndReturnToTitle.RestartTitle` | `#7295` | общий вход сообщения сбрасывает одноразовый счётчик и восстанавливает основной стек, входная команда CALL Game.Input.ResetDemoAndNormalizeControls.Entry |

## [SetSelectedLineMetadata](../Source/Game/Flight/SetSelectedLineMetadata.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Flight.SetSelectedLineMetadata.FindLine` | `#939B` | поиск записи линии обратным проходом по десятибайтовым элементам |

## [ShowTitleAndSelectControls](../Source/Game/Flight/ShowTitleAndSelectControls.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Flight.ShowTitleAndSelectControls.WaitRelease` | `#739E` | пометка демонстрационного объекта и ожидание отпускания клавиши, входная команда LD HL,#6065 |
| `Game.Flight.ShowTitleAndSelectControls.NextModel` | `#73AF` | выбор следующей из двенадцати моделей по таблице AE3C, входная команда INC (HL) |
| `Game.Flight.ShowTitleAndSelectControls.AnimateModel` | `#73C3` | очистка буфера и рисование заголовка с вращающейся моделью, входная команда CALL Game.Screen.ClearFlightBuffer.Entry |
| `Game.Flight.ShowTitleAndSelectControls.ChooseControls` | `#73E2` | выбор управления, джойстики 2/3 либо клавиатура 0 по пробелу, входная команда LD A,#02 |
| `Game.Flight.ShowTitleAndSelectControls.SaveJoystick` | `#73F7` | запоминание выбранного джойстика для меню паузы |
| `Game.Flight.ShowTitleAndSelectControls.StoreControls` | `#73FD` | замена младших двух битов управления с сохранением остальных настроек, входная команда LD HL,#FC0E |

## [ToggleCloakingDevice](../Source/Game/Flight/ToggleCloakingDevice.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Flight.ToggleCloakingDevice.CloakedColour` | `#7253` | атрибут маскировки имеет значение 0F, входная команда LD L,#0F |
| `Game.Flight.ToggleCloakingDevice.NormalColour` | `#7257` | обычный атрибут после выключения имеет значение 07, входная команда LD L,#07 |
| `Game.Flight.ToggleCloakingDevice.ApplyColour` | `#7259` | обычный атрибут после выключения имеет значение 07, входная команда JP Game.Extensions.AttributeVectorAndEnergyBomb.Entry |

## [TryAutomaticDocking](../Source/Game/Flight/TryAutomaticDocking.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Flight.TryAutomaticDocking.CheckDockKey` | `#7187` | чтение и поглощение клавиши стыковки, входная команда LD A,(#FC0B) |
| `Game.Flight.TryAutomaticDocking.StartDocking` | `#71B3` | включение автоматического режима и переднего вида, входная команда XOR A |
| `Game.Flight.TryAutomaticDocking.RebaseForDock` | `#71BA` | подготовка станции как базы автоматического причаливания |

## [UpdateFlightControlGauges](../Source/Game/Flight/UpdateFlightControlGauges.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Flight.UpdateFlightControlGauges.NegativeRoll` | `#714B` | преобразование отрицательного крена для стрелочного индикатора |
| `Game.Flight.UpdateFlightControlGauges.StoreRoll` | `#7151` | сохранение стрелки крена после знакового преобразования |
| `Game.Flight.UpdateFlightControlGauges.NegativePitch` | `#7162` | преобразование отрицательного тангажа для стрелочного индикатора |
| `Game.Flight.UpdateFlightControlGauges.StorePitch` | `#7168` | сохранение стрелки тангажа |

## [AdvanceSystemSeed](../Source/Game/Galaxy/AdvanceSystemSeed.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Galaxy.AdvanceSystemSeed.AdvanceSeed` | `#DFC6` | переход к следующей системе четырьмя шагами шестибайтового генератора, входная команда PUSH BC |

## [AppendSystemNameSyllable](../Source/Game/Galaxy/AppendSystemNameSyllable.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Galaxy.AppendSystemNameSyllable.StoreCursor` | `#E060` | сохранение указателя конца сформированного имени |

## [DeriveSystemProperties](../Source/Game/Galaxy/DeriveSystemProperties.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Galaxy.DeriveSystemProperties.Technology` | `#E0BD` | технология зависит от экономики, двух битов семени и половины правительства, входная команда LD A,(#DEF8) |

## [DistanceMetricToFuel](../Source/Game/Galaxy/DistanceMetricToFuel.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Galaxy.DistanceMetricToFuel.ClampDistance` | `#DFF6` | метрика переводится в расход топлива через квадратный корень и масштабирование, входная команда LD HL,#FFFF |
| `Game.Galaxy.DistanceMetricToFuel.ConvertMetric` | `#DFF9` | преобразование расстояния в стоимость гиперперехода |
| `Game.Galaxy.DistanceMetricToFuel.StoreFuelCost` | `#E005` | сохранение рассчитанной стоимости топлива |

## [FindNearestSystem](../Source/Game/Galaxy/FindNearestSystem.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Galaxy.FindNearestSystem.CheckSystem` | `#DF7F` | проверка расстояния очередной системы до точки поиска |
| `Game.Galaxy.FindNearestSystem.AdvanceSystem` | `#DF9C` | сохранение найденного лучшего семени и завершение очередного шага поиска, входная команда CALL Game.Galaxy.AdvanceSystemSeed.Entry |
| `Game.Galaxy.FindNearestSystem.MeasureNearest` | `#DFA2` | вычисление расстояния до выбранной ближайшей системы |
| `Game.Galaxy.FindNearestSystem.SetFuelCost` | `#DFB5` | запись расхода топлива для выбранной ближайшей системы |

## [FindSystemByExactName](../Source/Game/Galaxy/FindSystemByExactName.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Galaxy.FindSystemByExactName.NextSystem` | `#DF2B` | проверка имени следующей системы галактики |
| `Game.Galaxy.FindSystemByExactName.CompareName` | `#DF37` | последовательное сравнение символов с запрошенным именем |
| `Game.Galaxy.FindSystemByExactName.AdvanceSystem` | `#DF43` | переход к семени следующей системы после несовпадения имени |
| `Game.Galaxy.FindSystemByExactName.SelectFound` | `#DF4C` | выбор найденной системы как назначения |

## [GenerateSystemName](../Source/Game/Galaxy/GenerateSystemName.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Galaxy.GenerateSystemName.ClearName` | `#E024` | очистка буфера имени системы |

## [MultiplyBytes](../Source/Game/Galaxy/MultiplyBytes.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Galaxy.MultiplyBytes.MultiplyBit` | `#E010` | обработка очередного разряда множителя |
| `Game.Galaxy.MultiplyBytes.NextBit` | `#E019` | переход к следующему разряду умножения |

## [RestoreWorkingSystemSeed](../Source/Game/Galaxy/RestoreWorkingSystemSeed.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Galaxy.RestoreWorkingSystemSeed.CopySeed` | `#E13C` | возврат сохранённого рабочего семени после временных вычислений, входная команда LD BC,#0006 |

## [SquaredDistanceToTarget](../Source/Game/Galaxy/SquaredDistanceToTarget.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Galaxy.SquaredDistanceToTarget.AddYDistance` | `#DFDE` | включение квадрата вертикального расстояния в метрику |

## [ClampAndStoreFlightSpeed](../Source/Game/Input/ClampAndStoreFlightSpeed.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Input.ClampAndStoreFlightSpeed.SpeedLimit` | `#FF16` | проверка верхнего предела после увеличения скорости, входная команда BIT 5,H |
| `Game.Input.ClampAndStoreFlightSpeed.StoreSpeed` | `#FF1D` | сохранение скорости и очистка обработанных команд, входная команда LD (#FF0C),HL |

## [IntegrateFlightControls](../Source/Game/Input/IntegrateFlightControls.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Input.IntegrateFlightControls.PositiveRoll` | `#FE2E` | проверка нулевого крена перед первым положительным шагом, входная команда LD A,H |
| `Game.Input.IntegrateFlightControls.RollSign` | `#FE3A` | проверка знака для разгона либо смены направления крена, входная команда BIT 7,H |
| `Game.Input.IntegrateFlightControls.NegativeRoll` | `#FE41` | проверка противоположной команды и нулевого модуля крена, входная команда BIT 1,B |
| `Game.Input.IntegrateFlightControls.RollNegative` | `#FE51` | проверка знака отрицательного направления крена, входная команда BIT 7,H |
| `Game.Input.IntegrateFlightControls.IncreaseRoll` | `#FE55` | расчёт увеличения модуля крена с ограничением по биту 4, входная команда LD DE,#00FF |
| `Game.Input.IntegrateFlightControls.ReverseRoll` | `#FE63` | проверка режима мгновенной остановки при смене направления, входная команда BIT 2,C |
| `Game.Input.IntegrateFlightControls.BrakeRoll` | `#FE6D` | расчёт торможения крена полным шагом перед сменой знака, входная команда LD DE,#00FF |
| `Game.Input.IntegrateFlightControls.StoreRoll` | `#FE7A` | сохранение крена и переход к аналогичному расчёту тангажа, входная команда LD (#FF08),HL |
| `Game.Input.IntegrateFlightControls.PositivePitch` | `#FE9C` | проверка нулевого тангажа перед первым положительным шагом, входная команда LD A,H |
| `Game.Input.IntegrateFlightControls.PitchSign` | `#FEA8` | проверка знака для разгона либо смены направления тангажа, входная команда BIT 7,H |
| `Game.Input.IntegrateFlightControls.NegativePitch` | `#FEAF` | проверка противоположной команды и нулевого модуля тангажа, входная команда BIT 3,B |
| `Game.Input.IntegrateFlightControls.PitchNegative` | `#FEBF` | проверка знака отрицательного направления тангажа, входная команда BIT 7,H |
| `Game.Input.IntegrateFlightControls.IncreasePitch` | `#FEC3` | расчёт увеличения модуля тангажа с ограничением по биту 4, входная команда LD DE,#0066 |
| `Game.Input.IntegrateFlightControls.ReversePitch` | `#FED1` | проверка режима мгновенной остановки при смене направления, входная команда BIT 2,C |
| `Game.Input.IntegrateFlightControls.BrakePitch` | `#FEDB` | расчёт торможения тангажа полным шагом перед сменой знака, входная команда LD DE,#0066 |
| `Game.Input.IntegrateFlightControls.StorePitch` | `#FEE8` | сохранение тангажа и проверка двух команд скорости, входная команда LD (#FF0A),HL |

## [InterruptGateAndAcceleration](../Source/Game/Input/InterruptGateAndAcceleration.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Input.InterruptGateAndAcceleration.Accelerate` | `#FF00` | проверка одновременного торможения перед увеличением скорости, входная команда BIT 5,B |

## [MarkModelVisibilityMask](../Source/Game/Input/MarkModelVisibilityMask.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Input.MarkModelVisibilityMask.MergeMask` | `#FC30` | объединение признака видимости с байтом модели |

## [ResetDemoAndNormalizeControls](../Source/Game/Input/ResetDemoAndNormalizeControls.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Input.ResetDemoAndNormalizeControls.DigitalAxes` | `#FC3D` | перестановка цифровых направлений выбранного интерфейса, входная команда DEC A |
| `Game.Input.ResetDemoAndNormalizeControls.ZeroKey` | `#FC57` | преобразование цифровой клавиши 0 в дополнительную команду A, входная команда LD HL,#FC08 |
| `Game.Input.ResetDemoAndNormalizeControls.SwapAxisPairs` | `#FC63` | проверка перестановки обеих пар направлений, входная команда BIT 4,E |
| `Game.Input.ResetDemoAndNormalizeControls.SwapVertical` | `#FC74` | проверка дополнительной перестановки вертикальной пары, входная команда BIT 5,E |
| `Game.Input.ResetDemoAndNormalizeControls.KeyConflicts` | `#FC89` | проверка конфликтов буквенных команд с клавиатурным управлением, входная команда LD HL,#FC09 |
| `Game.Input.ResetDemoAndNormalizeControls.MergeControls` | `#FCA1` | объединение новых направлений со старшими управляющими битами, входная команда LD A,(HL) |

## [ScanKeyboardMatrix](../Source/Game/Input/ScanKeyboardMatrix.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Input.ScanKeyboardMatrix.ScanRow` | `#FD76` | выбор очередного ряда и преобразование активного нуля в единицу, входная команда RLC B |
| `Game.Input.ScanKeyboardMatrix.ScanKey` | `#FD80` | проверка одной клавиши переносом в C и обработка назначения, входная команда RRA |

## [SetPressedKeyAssignment](../Source/Game/Input/SetPressedKeyAssignment.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Input.SetPressedKeyAssignment.StoreKeyCode` | `#FCD1` | запись кода нажатого символа перед обработкой его назначения |

## [ToggleSecondaryCoordinateObject](../Source/Game/Input/ToggleSecondaryCoordinateObject.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Input.ToggleSecondaryCoordinateObject.ForceOffset` | `#FD0B` | принудительное смещение на 9, пропускаемое нулевой фазой только после патча JR |
| `Game.Input.ToggleSecondaryCoordinateObject.ApplyOffset` | `#FD1B` | применение смещения к IX и очистка общего признака, входная команда XOR A |
| `Game.Input.ToggleSecondaryCoordinateObject.CheckPilot` | `#FD23` | проверка пилота и военного допуска по прямому вызову #E6BB, входная команда LD A,(State.Mission1) |

## [ApplyMissionMarketRestrictions](../Source/Game/Menus/ApplyMissionMarketRestrictions.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Menus.ApplyMissionMarketRestrictions.CheckRegion` | `#EEED` | проверка принадлежности сохранённой системы области вторжения |
| `Game.Menus.ApplyMissionMarketRestrictions.StoreInvasion` | `#EEF6` | запись состояния вторжения после проверки региона |
| `Game.Menus.ApplyMissionMarketRestrictions.CheckMinerals` | `#EEF9` | ограничение рынка минералов для активной колонии MINERAL LIFE |

## [BlankLineAndEconomyText](../Source/Game/Menus/BlankLineAndEconomyText.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Menus.BlankLineAndEconomyText.SecondNewline` | `#EEA5` | двукратное увеличение строки отделяет абзацы информации о планете, входная команда JP Game.Trade.Newline.Entry |
| `Game.Menus.BlankLineAndEconomyText.EconomyToken` | `#EEB8` | выбор текстового токена категории экономики |
| `Game.Menus.BlankLineAndEconomyText.EconomyClass` | `#EEBD` | выбор второй части названия экономики |
| `Game.Menus.BlankLineAndEconomyText.PoorEconomy` | `#EEC8` | печать особого первого токена бедной экономики |
| `Game.Menus.BlankLineAndEconomyText.Population` | `#EECE` | выбор варианта населения по старшему биту семени |
| `Game.Menus.BlankLineAndEconomyText.PrintRace` | `#EED8` | печать выбранного токена населения |

## [ClearCharacterRowsBackward](../Source/Game/Menus/ClearCharacterRowsBackward.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Menus.ClearCharacterRowsBackward.RasterLine` | `#EBF0` | очистка идёт назад по символьным строкам и вперёд по восьми линиям растра, входная команда PUSH HL |
| `Game.Menus.ClearCharacterRowsBackward.CharacterRow` | `#EBF2` | очистка очередной символьной строки текущей растровой линии |
| `Game.Menus.ClearCharacterRowsBackward.ClearByte` | `#EBF5` | очистка очередного экранного байта |

## [CompareSystemSeedToGalaxyBase](../Source/Game/Menus/CompareSystemSeedToGalaxyBase.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Menus.CompareSystemSeedToGalaxyBase.CompareByte` | `#EF3C` | шесть байтов сравниваются до первого отличия, исходные указатели не сохраняются, входная команда LD A,(DE) |
| `Game.Menus.CompareSystemSeedToGalaxyBase.DifferentSeeds` | `#EF46` | возврат переноса при различии семян систем |
| `Game.Menus.CompareSystemSeedToGalaxyBase.MarketRow` | `#EF79` | печать очередной строки рыночных цен |

## [LocalSystemPixelPosition](../Source/Game/Menus/LocalSystemPixelPosition.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Menus.LocalSystemPixelPosition.StarRadius` | `#ED3C` | расчёт радиуса символа звезды по выбранной паре битов |

## [MapCaptionAndGalaxyChart](../Source/Game/Menus/MapCaptionAndGalaxyChart.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Menus.MapCaptionAndGalaxyChart.PlotSystem` | `#EBE3` | вывод очередной системы галактической карты |

## [OpenLocalChart](../Source/Game/Menus/OpenLocalChart.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Menus.OpenLocalChart.ClearRowUsage` | `#EC5E` | очистка признаков занятости строк подписей локальной карты |

## [PlaceLocalSystemLabel](../Source/Game/Menus/PlaceLocalSystemLabel.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Menus.PlaceLocalSystemLabel.LabelRow` | `#EDA4` | расчёт символьной строки подписи планеты |
| `Game.Menus.PlaceLocalSystemLabel.TryLowerRow` | `#EDBC` | попытка размещения подписи на нижней соседней строке |

## [PrintCombatRankAndEquipment](../Source/Game/Menus/PrintCombatRankAndEquipment.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Menus.PrintCombatRankAndEquipment.HighRank` | `#EFEF` | выбор таблицы порогов старшей группы боевого рейтинга |
| `Game.Menus.PrintCombatRankAndEquipment.FindRank` | `#EFF4` | поиск боевого звания последовательным сравнением порогов |
| `Game.Menus.PrintCombatRankAndEquipment.PrintRank` | `#EFFC` | печать найденного боевого звания и переход к оборудованию |
| `Game.Menus.PrintCombatRankAndEquipment.NextEquipment` | `#F00B` | шесть адресов устройств читаются из таблицы младших байтов в F09B, входная команда INC C |
| `Game.Menus.PrintCombatRankAndEquipment.SpecialName` | `#F02C` | специальная подпись устройства зависит от сохранённого бита 7 маски D0B0&C, входная команда POP AF |
| `Game.Menus.PrintCombatRankAndEquipment.StandardName` | `#F039` | после особой подписи XOR A обеспечивает заём в SUB19 и подавляет обычное имя устройства, входная команда SUB #19 |
| `Game.Menus.PrintCombatRankAndEquipment.RestoreItem` | `#F03E` | восстановление параметров прохода перед следующим устройством |
| `Game.Menus.PrintCombatRankAndEquipment.NextLaser` | `#F046` | четыре направления лазеров перечисляются независимо от шести устройств, входная команда PUSH BC |

## [PrintDirectionalLaser](../Source/Game/Menus/PrintDirectionalLaser.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Menus.PrintDirectionalLaser.LaserToken` | `#F093` | добавление базы выбранной группы названий лазеров |
| `Game.Menus.PrintDirectionalLaser.SpecialLaser` | `#F096` | выбор текста специального лазера |
| `Game.Menus.PrintDirectionalLaser.PrintLaser` | `#F098` | печать выбранного названия лазера |

## [PrintLegalStatus](../Source/Game/Menus/PrintLegalStatus.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Menus.PrintLegalStatus.Offender` | `#EFD2` | увеличение индекса текста правового состояния до OFFENDER |
| `Game.Menus.PrintLegalStatus.PrintStatus` | `#EFD3` | печать выбранного правового состояния командира |

## [PrintStatusFieldAndCargoScreen](../Source/Game/Menus/PrintStatusFieldAndCargoScreen.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Menus.PrintStatusFieldAndCargoScreen.CargoScreen` | `#F0B8` | отдельный вход экрана грузового отсека перечисляет содержимое и суммарную вместимость, входная команда LD A,#0C |

## [PrintSystemStatistics](../Source/Game/Menus/PrintSystemStatistics.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Menus.PrintSystemStatistics.Description` | `#EE8C` | печать состояния вторжения и описания планеты |

## [ReadVisibleObjectByte](../Source/Game/Menus/ReadVisibleObjectByte.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Menus.ReadVisibleObjectByte.InvalidObject` | `#ED73` | защитная бесконечная петля при недопустимом адресе объекта |

## [VisitLocalChartSystems](../Source/Game/Menus/VisitLocalChartSystems.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Menus.VisitLocalChartSystems.CheckSystem` | `#ECDA` | проверка очередной системы по окну локальной карты |
| `Game.Menus.VisitLocalChartSystems.AdvanceSeed` | `#ECF6` | переход к семени следующей системы без размещения подписи |
| `Game.Menus.VisitLocalChartSystems.NextSystem` | `#ECF9` | завершение итерации обхода систем |

## [OfferThirdMission](../Source/Game/Missions/OfferThirdMission.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Missions.OfferThirdMission.MessageLayout` | `#D145` | установка положения отдельного миссионного сообщения |

## [AddCoordinateDelta](../Source/Game/Motion/AddCoordinateDelta.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Motion.AddCoordinateDelta.SubtractDelta` | `#A0A1` | вычитание противоположно направленного смещения |

## [AddScaledCoordinate](../Source/Game/Motion/AddScaledCoordinate.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Motion.AddScaledCoordinate.AlignProduct` | `#A224` | выравнивание произведения к разрядам координаты |
| `Game.Motion.AddScaledCoordinate.SubtractTerms` | `#A252` | вычитание произведения с противоположным знаком |
| `Game.Motion.AddScaledCoordinate.SubtractHigh` | `#A259` | вычитание старших разрядов с учётом займа |
| `Game.Motion.AddScaledCoordinate.PackSign` | `#A26C` | упаковка знака новой координаты |
| `Game.Motion.AddScaledCoordinate.StoreAxis` | `#A273` | сохранение трёхбайтовой координаты |

## [AddSignedAngularProduct](../Source/Game/Motion/AddSignedAngularProduct.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Motion.AddSignedAngularProduct.SubtractTerms` | `#A11C` | вычитание произведения с противоположным знаком |
| `Game.Motion.AddSignedAngularProduct.PackResult` | `#A123` | упаковка знака и модуля результата |

## [AdvanceObjectAlongLocalAxis](../Source/Game/Motion/AdvanceObjectAlongLocalAxis.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Motion.AdvanceObjectAlongLocalAxis.LimitSpeed` | `#A01E` | определение максимальной скорости объекта |
| `Game.Motion.AdvanceObjectAlongLocalAxis.ClampSpeed` | `#A02B` | ограничение скорости максимумом модели |
| `Game.Motion.AdvanceObjectAlongLocalAxis.StoreSpeed` | `#A02F` | сохранение новой скорости объекта |
| `Game.Motion.AdvanceObjectAlongLocalAxis.AdvanceAxes` | `#A032` | перемещение по трём координатам вдоль локальной оси |

## [ApplyPlayerMotionToObject](../Source/Game/Motion/ApplyPlayerMotionToObject.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Motion.ApplyPlayerMotionToObject.MovePositiveZ` | `#A1D0` | уменьшение положительной глубины движением игрока |
| `Game.Motion.ApplyPlayerMotionToObject.FlipFraction` | `#A1DE` | смена знака дробной части при переходе через ноль |
| `Game.Motion.ApplyPlayerMotionToObject.StoreDepth` | `#A1E3` | сохранение целой части глубины |
| `Game.Motion.ApplyPlayerMotionToObject.DepthReady` | `#A1E9` | возврат после обновления глубины |

## [CheckObjectBoxAndChooseCourse](../Source/Game/Motion/CheckObjectBoxAndChooseCourse.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Motion.CheckObjectBoxAndChooseCourse.ChooseCourse` | `#A42F` | выбор курса после обновления энергии объекта |
| `Game.Motion.CheckObjectBoxAndChooseCourse.CheckInnerBox` | `#A440` | проверка внутренней области удаления |
| `Game.Motion.CheckObjectBoxAndChooseCourse.CheckHostility` | `#A455` | проверка необходимости преследования игрока |
| `Game.Motion.CheckObjectBoxAndChooseCourse.CheckBehavior` | `#A46F` | выбор курса по параметру поведения |
| `Game.Motion.CheckObjectBoxAndChooseCourse.FlyAway` | `#A47C` | построение вектора удаления от игрока |
| `Game.Motion.CheckObjectBoxAndChooseCourse.FlyToward` | `#A498` | построение вектора сближения с игроком |
| `Game.Motion.CheckObjectBoxAndChooseCourse.SteerCourse` | `#A4B2` | передача рассчитанного вектора автопилоту |

## [DivideVectorComponent](../Source/Game/Motion/DivideVectorComponent.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Motion.DivideVectorComponent.StoreQuotient` | `#9EE6` | сохранение знаковой компоненты после деления |

## [DotProductAxisHighBytes](../Source/Game/Motion/DotProductAxisHighBytes.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Motion.DotProductAxisHighBytes.AddThirdTerm` | `#A6D1` | добавление третьего произведения скалярной суммы |
| `Game.Motion.DotProductAxisHighBytes.PackProduct` | `#A6DA` | упаковка знака скалярного произведения |

## [GuideMissileAndCheckImpact](../Source/Game/Motion/GuideMissileAndCheckImpact.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Motion.GuideMissileAndCheckImpact.FindTarget` | `#A4C4` | поиск слота ракетной цели |
| `Game.Motion.GuideMissileAndCheckImpact.NextTarget` | `#A4D7` | переход к следующему слоту ракетной цели |
| `Game.Motion.GuideMissileAndCheckImpact.DestroyTarget` | `#A527` | установка запроса уничтожения поражённой цели |
| `Game.Motion.GuideMissileAndCheckImpact.RestoreTarget` | `#A52B` | восстановление указателя модели после обработки попадания |
| `Game.Motion.GuideMissileAndCheckImpact.ClearMetadata` | `#A52E` | очистка метаданных пустого слота из общего обхода объектов |
| `Game.Motion.GuideMissileAndCheckImpact.SteerMissile` | `#A532` | наведение ракеты по рассчитанному вектору |

## [ProcessObjectEnergyAndTactics](../Source/Game/Motion/ProcessObjectEnergyAndTactics.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Motion.ProcessObjectEnergyAndTactics.ClampEnergy` | `#A2CE` | ограничение восстановленной энергии максимумом модели |
| `Game.Motion.ProcessObjectEnergyAndTactics.CheckMission` | `#A2D2` | проверка специальных энергетических порогов миссии |
| `Game.Motion.ProcessObjectEnergyAndTactics.CheckPhaseOne` | `#A2E6` | проверка расхода энергии в первой фазе миссии |
| `Game.Motion.ProcessObjectEnergyAndTactics.DrainEnergy` | `#A2F4` | уменьшение энергии первой фазы миссии |
| `Game.Motion.ProcessObjectEnergyAndTactics.StoreEnergy` | `#A2F7` | сохранение энергии и проверка аварийного поведения |
| `Game.Motion.ProcessObjectEnergyAndTactics.TryLaunch` | `#A30D` | проверка остатка и вероятности запуска |
| `Game.Motion.ProcessObjectEnergyAndTactics.SelectPayload` | `#A32A` | преобразование типа запускаемого средства |
| `Game.Motion.ProcessObjectEnergyAndTactics.TryEscape` | `#A343` | выбор спасения при критическом уровне энергии |
| `Game.Motion.ProcessObjectEnergyAndTactics.CheckCargoPod` | `#A361` | проверка создания спасательного объекта по модели |
| `Game.Motion.ProcessObjectEnergyAndTactics.CheckLeader` | `#A36C` | проверка потребности специальной группы в ведущем |
| `Game.Motion.ProcessObjectEnergyAndTactics.FindLeader` | `#A37E` | просмотр следующего слота в поиске ведущего |
| `Game.Motion.ProcessObjectEnergyAndTactics.NextLeader` | `#A38D` | переход к следующему кандидату на ведущего |
| `Game.Motion.ProcessObjectEnergyAndTactics.LeaderResult` | `#A390` | возврат к исходному объекту после поиска ведущего |
| `Game.Motion.ProcessObjectEnergyAndTactics.CheckEcm` | `#A3A2` | проверка возможности ответного применения ECM |
| `Game.Motion.ProcessObjectEnergyAndTactics.CheckEcmTimer` | `#A3B6` | проверка уже работающего ECM |
| `Game.Motion.ProcessObjectEnergyAndTactics.EcmPadding` | `#A3D1` | две резервные инструкции после проверки ECM |
| `Game.Motion.ProcessObjectEnergyAndTactics.ChooseFlight` | `#A3D3` | выбор обычного полёта или порождения объектов |
| `Game.Motion.ProcessObjectEnergyAndTactics.PeacefulSpawn` | `#A3FE` | проверка редкой вероятности мирного порождения |

## [ProjectObjectAndSelectDetail](../Source/Game/Motion/ProjectObjectAndSelectDetail.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Motion.ProjectObjectAndSelectDetail.ReadDepth` | `#A6F1` | чтение координаты глубины выбранного вида |
| `Game.Motion.ProjectObjectAndSelectDetail.ProjectCenter` | `#A70F` | проекция центра объекта для выбранного вида |
| `Game.Motion.ProjectObjectAndSelectDetail.ProjectSide` | `#A73B` | горизонтальная проекция Z для бокового вида |
| `Game.Motion.ProjectObjectAndSelectDetail.PackProjection` | `#A75E` | упаковка знаков и расчёт экранного радиуса |
| `Game.Motion.ProjectObjectAndSelectDetail.CheckWidth` | `#A781` | проверка видимости объекта по горизонтали |
| `Game.Motion.ProjectObjectAndSelectDetail.CheckCrosshair` | `#A78D` | проверка близости центра объекта к прицелу |
| `Game.Motion.ProjectObjectAndSelectDetail.CheckAwayMode` | `#A7A3` | проверка сброса режима удаления враждебного корабля |
| `Game.Motion.ProjectObjectAndSelectDetail.CheckAxis` | `#A7C2` | проверка направления выбранной компоненты оси |
| `Game.Motion.ProjectObjectAndSelectDetail.DispatchEffect` | `#A7D2` | передача уничтожения и специальных эффектов |
| `Game.Motion.ProjectObjectAndSelectDetail.CheckMission` | `#A7D9` | проверка миссионной видимости после обработки эффектов |
| `Game.Motion.ProjectObjectAndSelectDetail.SelectDetail` | `#A7E6` | выбор каркаса или дальней точки объекта |
| `Game.Motion.ProjectObjectAndSelectDetail.CheckMirrorX` | `#A80D` | выбор направления горизонтального смещения точки |
| `Game.Motion.ProjectObjectAndSelectDetail.SubtractX` | `#A818` | вычитание горизонтального смещения из центра обзора |
| `Game.Motion.ProjectObjectAndSelectDetail.ProjectY` | `#A81C` | выбор направления вертикального смещения точки |
| `Game.Motion.ProjectObjectAndSelectDetail.SubtractY` | `#A826` | вычитание вертикального смещения из центра обзора |
| `Game.Motion.ProjectObjectAndSelectDetail.DrawFarDot` | `#A82A` | вывод дальней точки четырьмя XOR-пикселями |

## [QuarterCoordinate](../Source/Game/Motion/QuarterCoordinate.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Motion.QuarterCoordinate.QuarterModule` | `#A572` | деление модуля координаты на четыре |

## [SquareVectorComponent](../Source/Game/Motion/SquareVectorComponent.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Motion.SquareVectorComponent.RestoreVector` | `#9EC7` | восстановление указателя следующей компоненты вектора |

## [SteerObjectAndTryLaser](../Source/Game/Motion/SteerObjectAndTryLaser.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Motion.SteerObjectAndTryLaser.PackRoll` | `#A5D7` | упаковка направления и величины команды LR |
| `Game.Motion.SteerObjectAndTryLaser.CalculatePitch` | `#A5E7` | расчёт команды DU при малом отклонении LR |
| `Game.Motion.SteerObjectAndTryLaser.LimitPitch` | `#A5FB` | ограничение модуля команды DU |
| `Game.Motion.SteerObjectAndTryLaser.PackPitch` | `#A5FD` | упаковка направления команды DU |
| `Game.Motion.SteerObjectAndTryLaser.CheckForced` | `#A605` | проверка принудительного ускорения |
| `Game.Motion.SteerObjectAndTryLaser.StoreForced` | `#A60E` | сохранение принудительного ускорения |
| `Game.Motion.SteerObjectAndTryLaser.CheckRange` | `#A625` | проверка расстояния для разгона |
| `Game.Motion.SteerObjectAndTryLaser.StoreSpeedup` | `#A62F` | сохранение ускорения при сближении |
| `Game.Motion.SteerObjectAndTryLaser.CheckLaser` | `#A632` | проверка возможности лазерного выстрела |
| `Game.Motion.SteerObjectAndTryLaser.TryLaser` | `#A64B` | случайная проверка вероятности выстрела |
| `Game.Motion.SteerObjectAndTryLaser.HitPlayer` | `#A669` | запрос лазерного звука и урона защите игрока |
| `Game.Motion.SteerObjectAndTryLaser.DamageFront` | `#A67D` | накопление урона передней защите |
| `Game.Motion.SteerObjectAndTryLaser.BrakeAway` | `#A686` | выбор торможения при курсе от цели |
| `Game.Motion.SteerObjectAndTryLaser.CheckBrake` | `#A690` | проверка расстояния для торможения |
| `Game.Motion.SteerObjectAndTryLaser.StoreBrake` | `#A699` | сохранение отрицательного ускорения |

## [TransformNormalWithObjectCoordinate](../Source/Game/Motion/TransformNormalWithObjectCoordinate.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Motion.TransformNormalWithObjectCoordinate.ScaleNormal` | `#BDD5` | сдвиг нормали к масштабу координаты |
| `Game.Motion.TransformNormalWithObjectCoordinate.SubtractNormal` | `#BDE5` | вычитание нормали с противоположным знаком |
| `Game.Motion.TransformNormalWithObjectCoordinate.PackCoordinate` | `#BDF4` | упаковка знака преобразованной координаты |

## [UpdateObjectCoordinatesAndRotation](../Source/Game/Motion/UpdateObjectCoordinatesAndRotation.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Motion.UpdateObjectCoordinatesAndRotation.CheckDepthHigh` | `#9F90` | проверка старшего модуля глубины |
| `Game.Motion.UpdateObjectCoordinatesAndRotation.ReleaseObject` | `#9F95` | освобождение слота объекта за рабочим диапазоном |
| `Game.Motion.UpdateObjectCoordinatesAndRotation.CheckSideRange` | `#9F9C` | проверка боковых координат объекта |
| `Game.Motion.UpdateObjectCoordinatesAndRotation.SetRollStep` | `#9FD3` | выбор величины непрерывного вращения LR |
| `Game.Motion.UpdateObjectCoordinatesAndRotation.StoreRollStep` | `#9FDD` | сохранение шага вращения LR |
| `Game.Motion.UpdateObjectCoordinatesAndRotation.SetPitchStep` | `#9FF3` | выбор величины непрерывного вращения DU |

## [VelocityComponentDelta](../Source/Game/Motion/VelocityComponentDelta.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Motion.VelocityComponentDelta.MultiplyBit` | `#A083` | добавление вклада очередного бита скорости |
| `Game.Motion.VelocityComponentDelta.NextSpeedBit` | `#A08C` | переход к следующему биту скорости |

## [XorFarObjectPixel](../Source/Game/Motion/XorFarObjectPixel.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Motion.XorFarObjectPixel.RotatePixel` | `#A844` | выбор битовой маски дальней точки |

## [ComputeFaceVisibility](../Source/Game/Objects/ComputeFaceVisibility.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Objects.ComputeFaceVisibility.NextFace` | `#BCFF` | обработка следующей нормали модели |
| `Game.Objects.ComputeFaceVisibility.DotNormal` | `#BD15` | преобразование трёх компонент нормали и расчёт их скалярного произведения, входная команда PUSH IY |
| `Game.Objects.ComputeFaceVisibility.StoreFace` | `#BD4F` | сохранение видимости грани и продвижение указателей нормали |
| `Game.Objects.ComputeFaceVisibility.RestoreObject` | `#BD5A` | восстановление объектных указателей после прохода граней |

## [DotProduct16By8](../Source/Game/Objects/DotProduct16By8.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Objects.DotProduct16By8.AddLastAxis` | `#BD91` | сложение последней компоненты скалярного произведения |

## [FindFreeObjectSlot](../Source/Game/Objects/FindFreeObjectSlot.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Objects.FindFreeObjectSlot.CheckSlot` | `#B93F` | проверка следующего обычного слота на нулевую энергию |

## [GenerateSpaceTraffic](../Source/Game/Objects/GenerateSpaceTraffic.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Objects.GenerateSpaceTraffic.PickEncounter` | `#BBFD` | проверка вероятности обычной случайной встречи |
| `Game.Objects.GenerateSpaceTraffic.EncounterClass` | `#BC21` | выбор встречи по миссии, правительству и случайному классу, входная команда LD B,A |
| `Game.Objects.GenerateSpaceTraffic.ChooseGroup` | `#BC40` | выбор одиночного объекта или групповой ветви |
| `Game.Objects.GenerateSpaceTraffic.ModelSelected` | `#BC63` | передача выбранного номера модели инициализации |
| `Game.Objects.GenerateSpaceTraffic.SaveModel` | `#BC64` | сохранение номера модели для последующей настройки ECM |
| `Game.Objects.GenerateSpaceTraffic.InitEncounter` | `#BC65` | инициализация объекта с возвратом к общей настройке ECM |
| `Game.Objects.GenerateSpaceTraffic.EnableEcm` | `#BC73` | установка признака наличия ECM у созданного корабля |
| `Game.Objects.GenerateSpaceTraffic.MissionShip` | `#BC78` | создание принудительно выбранной миссией модели |
| `Game.Objects.GenerateSpaceTraffic.ChooseTraffic` | `#BC7F` | выбор модели обычного трафика или группы сопровождения |
| `Game.Objects.GenerateSpaceTraffic.SpecialPair` | `#BCA3` | выбор модели 7 либо 8 по старшему биту сохранённого случайного класса |
| `Game.Objects.GenerateSpaceTraffic.GroupCount` | `#BCAB` | расчёт размера группы, два либо три корабля, входная команда CALL Game.Combat.NextRandomByte.Entry |
| `Game.Objects.GenerateSpaceTraffic.SpawnMember` | `#BCB4` | создание очередного корабля группы в свободном слоте |

## [InitializeIntroModel](../Source/Game/Objects/InitializeIntroModel.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Objects.InitializeIntroModel.CopyComponent` | `#BBB3` | копирование разреженных компонент начальной модели |

## [InitializeObject](../Source/Game/Objects/InitializeObject.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Objects.InitializeObject.ModelIndex` | `#B89C` | преобразование младших шести битов номера модели в смещение каталога |
| `Game.Objects.InitializeObject.ReadBlueprint` | `#B8A5` | чтение адреса модели из четырёхбайтового элемента каталога, входная команда INC HL |
| `Game.Objects.InitializeObject.RandomPosition` | `#B903` | создание дробных координат и случайных знаков X/Y, входная команда CALL Game.Combat.NextRandomByte.Entry |

## [RotateSpawnAxisComponent](../Source/Game/Objects/RotateSpawnAxisComponent.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Objects.RotateSpawnAxisComponent.RotateAxes` | `#BA58` | перестановка всех трёх пар старших компонент X/Y с инверсией знака, входная команда LD A,(IX+FSpaceObject.AxisY.X+FSignWord.SignHigh) |

## [SpawnMissile](../Source/Game/Objects/SpawnMissile.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Objects.SpawnMissile.PlayerMissile` | `#B9B6` | создание ракеты игрока в выбранном свободном слоте |
| `Game.Objects.SpawnMissile.ObjectMissile` | `#B9CF` | создание ракеты как дочернего объекта текущего корабля |
| `Game.Objects.SpawnMissile.StoreTarget` | `#B9DE` | сохранение кода цели и признака ракеты, входная команда LD (IX+FSpaceObject.Target),C |

## [SpawnPlayerDebris](../Source/Game/Objects/SpawnPlayerDebris.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Objects.SpawnPlayerDebris.SpawnDebris` | `#BA9E` | проверка исходного начала фрагмента, входная команда CALL Game.Objects.SpawnAtPlayer.Entry |

## [SpawnShipClass](../Source/Game/Objects/SpawnShipClass.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Objects.SpawnShipClass.SpawnChild` | `#BA0D` | создание дочернего корабля выбранной модели |

## [SpawnThargonWave](../Source/Game/Objects/SpawnThargonWave.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Objects.SpawnThargonWave.SpawnNext` | `#B973` | поиск слота для очередного таргона, входная команда CALL Game.Objects.FindFreeObjectSlot.Entry |

## [DrawDangerAndMissileIndicators](../Source/Game/Scanner/DrawDangerAndMissileIndicators.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Scanner.DrawDangerAndMissileIndicators.CheckOverride` | `#99B6` | проверка приоритета специального сигнала тревоги |
| `Game.Scanner.DrawDangerAndMissileIndicators.CheckBlink` | `#99BD` | выбор фазы мигания сигнала тревоги |
| `Game.Scanner.DrawDangerAndMissileIndicators.RedPhase` | `#99CD` | выбор красной фазы сигнала |
| `Game.Scanner.DrawDangerAndMissileIndicators.SelectLayout` | `#99CF` | выбор полного или компактного индикатора |
| `Game.Scanner.DrawDangerAndMissileIndicators.MissileColor` | `#99EF` | преобразование состояния ракеты в экранный атрибут |
| `Game.Scanner.DrawDangerAndMissileIndicators.DrawCompact` | `#99F8` | вывод компактной пары символов индикатора |
| `Game.Scanner.DrawDangerAndMissileIndicators.ReplaceBlack` | `#9A1D` | замена чёрной фазы цветом компактной пары |
| `Game.Scanner.DrawDangerAndMissileIndicators.CompactColor` | `#9A1F` | формирование атрибута компактного индикатора |
| `Game.Scanner.DrawDangerAndMissileIndicators.PrintPair` | `#9A23` | печать пары символов компактного индикатора |
| `Game.Scanner.DrawDangerAndMissileIndicators.StoreColor` | `#9A2F` | запись атрибутов и восстановление XOR-печати |

## [DrawScannerObjects](../Source/Game/Scanner/DrawScannerObjects.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Scanner.DrawScannerObjects.CheckSlot` | `#96ED` | проверка активности и дальности очередного объекта сканера |
| `Game.Scanner.DrawScannerObjects.StoreHeight` | `#9765` | сохранение высоты маркера со знаком |
| `Game.Scanner.DrawScannerObjects.StoreDepth` | `#9785` | сохранение глубины маркера со знаком |
| `Game.Scanner.DrawScannerObjects.CheckSide` | `#97A3` | выбор стороны сканера по знаку X |
| `Game.Scanner.DrawScannerObjects.MoveRightByte` | `#97AA` | горизонтальное смещение основания вправо |
| `Game.Scanner.DrawScannerObjects.RightMask` | `#97AD` | подготовка битовой маски правой стороны |
| `Game.Scanner.DrawScannerObjects.RotateRight` | `#97B6` | сдвиг маски правой стороны внутри байта |
| `Game.Scanner.DrawScannerObjects.CentralByte` | `#97BB` | расчёт маски в центральном байте сетки |
| `Game.Scanner.DrawScannerObjects.MoveLeftByte` | `#97C7` | горизонтальное смещение основания влево |
| `Game.Scanner.DrawScannerObjects.LeftMask` | `#97CA` | подготовка битовой маски левой стороны |
| `Game.Scanner.DrawScannerObjects.RotateLeft` | `#97D3` | сдвиг маски левой стороны внутри байта |
| `Game.Scanner.DrawScannerObjects.OffsetDepth` | `#97D6` | смещение основания по глубине сканера |
| `Game.Scanner.DrawScannerObjects.MoveBaseUp` | `#97E5` | смещение основания маркера вверх |
| `Game.Scanner.DrawScannerObjects.MoveBaseDown` | `#97F0` | смещение основания маркера вниз |
| `Game.Scanner.DrawScannerObjects.CheckHeight` | `#97F9` | выбор направления ножки маркера |
| `Game.Scanner.DrawScannerObjects.DrawStemUp` | `#9807` | рисование восходящей ножки маркера |
| `Game.Scanner.DrawScannerObjects.DrawStemDown` | `#9815` | рисование нисходящей ножки маркера |
| `Game.Scanner.DrawScannerObjects.DrawHead` | `#9821` | рисование трёхпиксельной головки маркера |
| `Game.Scanner.DrawScannerObjects.NextObject` | `#982E` | переход к следующему объекту сканера |
| `Game.Scanner.DrawScannerObjects.ClearTop` | `#983F` | очистка области над маркерами сканера |
| `Game.Scanner.DrawScannerObjects.ClearTopRow` | `#9845` | очистка очередной строки верхнего края |
| `Game.Scanner.DrawScannerObjects.ClearTopByte` | `#9848` | очистка байтов текущей строки верхнего края |
| `Game.Scanner.DrawScannerObjects.HeadAcrossBit7` | `#9852` | вывод головки через границу байтов при первом переносе |
| `Game.Scanner.DrawScannerObjects.HeadAcrossBit6` | `#985E` | вывод головки через границу байтов при втором переносе |

## [FillCockpitAttributePanel](../Source/Game/Scanner/FillCockpitAttributePanel.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Scanner.FillCockpitAttributePanel.FillPanelRow` | `#9997` | заливка очередной строки панели |
| `Game.Scanner.FillCockpitAttributePanel.FillPanelByte` | `#999A` | запись атрибутов текущей строки панели |

## [ResetCockpitForLaunch](../Source/Game/Scanner/ResetCockpitForLaunch.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Scanner.ResetCockpitForLaunch.ResetDevice` | `#996F` | сброс очередной записи устройства панели |

## [RestoreScannerBackground](../Source/Game/Scanner/RestoreScannerBackground.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Scanner.RestoreScannerBackground.ClearExtraRow` | `#98DB` | очистка очередной строки дополнительной области |
| `Game.Scanner.RestoreScannerBackground.ClearExtraByte` | `#98DE` | очистка байтов дополнительной области |
| `Game.Scanner.RestoreScannerBackground.CopyBackground` | `#990C` | подготовка копирования фона между экраном и буфером |
| `Game.Scanner.RestoreScannerBackground.CopyCharRow` | `#9915` | копирование восьми строк очередного ряда знакомест |
| `Game.Scanner.RestoreScannerBackground.CopyPixelRow` | `#991A` | копирование тринадцати байтов пиксельной строки |

## [ScaleValueAndFinishBackground](../Source/Game/Scanner/ScaleValueAndFinishBackground.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Scanner.ScaleValueAndFinishBackground.AdvanceCopy` | `#9935` | переход к следующей строке копируемого фона |

## [SetCockpitDeviceAttributes](../Source/Game/Scanner/SetCockpitDeviceAttributes.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Scanner.SetCockpitDeviceAttributes.SelectColor` | `#997F` | выбор цвета панелей по наличию капсулы |
| `Game.Scanner.SetCockpitDeviceAttributes.FillPanels` | `#9989` | заливка атрибутов левой и правой панели |

## [StepScannerStemDown](../Source/Game/Scanner/StepScannerStemDown.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Scanner.StepScannerStemDown.AdjustHigh` | `#9877` | коррекция старшего байта адреса следующего знакоместа |

## [StepScannerStemUp](../Source/Game/Scanner/StepScannerStemUp.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Scanner.StepScannerStemUp.PreviousRow` | `#9885` | переход к предыдущему знакоместу сканера |

## [CargoTripleOffset](../Source/Game/Screen/CargoTripleOffset.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Screen.CargoTripleOffset.SpecialCargo` | `#80BC` | особое смещение для расширенных грузовых позиций |

## [CompassFarAxis](../Source/Game/Screen/CompassFarAxis.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Screen.CompassFarAxis.ScaleAxis` | `#82BB` | деление координаты на длину вектора и масштабирование |
| `Game.Screen.CompassFarAxis.AxisReady` | `#82D0` | возврат нормированной знаковой координаты |

## [CompassNearAxis](../Source/Game/Screen/CompassNearAxis.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Screen.CompassNearAxis.FarCompass` | `#827A` | выбор дальней цели компаса |
| `Game.Screen.CompassNearAxis.HighWordLength` | `#827E` | длина вектора по старшим словам координат |
| `Game.Screen.CompassNearAxis.NormalizeFar` | `#8288` | нормирование дальней цели компаса |
| `Game.Screen.CompassNearAxis.StoreCompassY` | `#829C` | сохранение вертикального смещения указателя компаса |
| `Game.Screen.CompassNearAxis.StoreSide` | `#82AA` | сохранение передней или задней полусферы цели |

## [DispatchMenu](../Source/Game/Screen/DispatchMenu.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Screen.DispatchMenu.PatchMenuCall` | `#8150` | запись адреса выбранного обработчика меню |

## [DrawEmptyIndicator](../Source/Game/Screen/DrawEmptyIndicator.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Screen.DrawEmptyIndicator.DrawEmptyRow` | `#85E3` | вывод строки пустого индикатора |

## [DrawIndicatorBar](../Source/Game/Screen/DrawIndicatorBar.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Screen.DrawIndicatorBar.ReadBarAddress` | `#855B` | получение экранного адреса полосы индикатора |
| `Game.Screen.DrawIndicatorBar.BuildMask` | `#857A` | построение маски частично заполненного байта |
| `Game.Screen.DrawIndicatorBar.StoreMask` | `#857E` | сохранение маски границы полосы |
| `Game.Screen.DrawIndicatorBar.CountBarBytes` | `#8582` | расчёт полных и пустых байтов индикатора |
| `Game.Screen.DrawIndicatorBar.DrawBarRow` | `#8595` | вывод строки заполненной и пустой частей полосы |
| `Game.Screen.DrawIndicatorBar.FillBarBytes` | `#8598` | заполнение полных байтов индикатора |
| `Game.Screen.DrawIndicatorBar.ClearBarBytes` | `#85A5` | очистка пустых байтов индикатора |
| `Game.Screen.DrawIndicatorBar.DrawRightEdge` | `#85A9` | вывод правой границы индикатора |
| `Game.Screen.DrawIndicatorBar.FullWidthBar` | `#85B5` | подготовка полосы до правой границы |
| `Game.Screen.DrawIndicatorBar.DrawFullRow` | `#85B7` | вывод полностью заполненной строки |
| `Game.Screen.DrawIndicatorBar.FillFullRow` | `#85BA` | заполнение байтов полной строки |

## [DrawLargeOutline](../Source/Game/Screen/DrawLargeOutline.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Screen.DrawLargeOutline.DrawAndEnable` | `#86E9` | рисование окружности и разрешение прерываний |

## [DrawShortIndicator](../Source/Game/Screen/DrawShortIndicator.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Screen.DrawShortIndicator.DrawShortRow` | `#85CE` | вывод строки короткого индикатора |

## [HandleScreenKeys](../Source/Game/Screen/HandleScreenKeys.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Screen.HandleScreenKeys.SecondViewKey` | `#80F0` | обработка второй видовой клавиши |
| `Game.Screen.HandleScreenKeys.SetSecondView` | `#8104` | переключение второго вида в полёте |
| `Game.Screen.HandleScreenKeys.FirstViewKey` | `#8109` | обработка первой видовой клавиши |
| `Game.Screen.HandleScreenKeys.SetFirstView` | `#8114` | переключение первого вида в полёте |
| `Game.Screen.HandleScreenKeys.ReadInfoKeys` | `#8119` | чтение клавиш информационных экранов |
| `Game.Screen.HandleScreenKeys.FindInfoKey` | `#8124` | поиск нажатой клавиши информационного экрана |
| `Game.Screen.HandleScreenKeys.OpenInfoView` | `#812A` | выбор найденного информационного экрана |
| `Game.Screen.HandleScreenKeys.ClearEvents` | `#8136` | сброс обработанных событий клавиатуры |

## [IndicatorMarkerMask](../Source/Game/Screen/IndicatorMarkerMask.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Screen.IndicatorMarkerMask.ShiftMarker` | `#85FF` | сдвиг маркера внутри байта |
| `Game.Screen.IndicatorMarkerMask.MarkerReady` | `#8603` | передача готовой маски маркера |

## [MatchTargetPlanet](../Source/Game/Screen/MatchTargetPlanet.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Screen.MatchTargetPlanet.SetDistance` | `#802C` | расчёт расстояния для несовпадающей системы |
| `Game.Screen.MatchTargetPlanet.SaveMatch` | `#8033` | сохранение точно совпавшей целевой системы |

## [PreviousCharacterRow](../Source/Game/Screen/PreviousCharacterRow.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Screen.PreviousCharacterRow.RestorePanel` | `#8459` | восстановление фона компаса и сканера |
| `Game.Screen.PreviousCharacterRow.CopySpriteRow` | `#8462` | копирование очередной трёхбайтовой строки спрайта |

## [ResetCargoCapacity](../Source/Game/Screen/ResetCargoCapacity.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Screen.ResetCargoCapacity.SumCapacity` | `#80C8` | суммирование вместимости грузовых отсеков |

## [RestoreCockpit](../Source/Game/Screen/RestoreCockpit.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Screen.RestoreCockpit.DrawBorderRow` | `#8059` | вывод очередной строки рамки приборной панели |

## [RestoreCompassBackground](../Source/Game/Screen/RestoreCompassBackground.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Screen.RestoreCompassBackground.CopyBackRow` | `#84BE` | восстановление очередной строки фона компаса |
| `Game.Screen.RestoreCompassBackground.NextScreenRow` | `#84CE` | переход к следующей строке экрана |

## [ScaleProximity](../Source/Game/Screen/ScaleProximity.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Screen.ScaleProximity.CriticalRange` | `#82F4` | переход к критическому состоянию близости |
| `Game.Screen.ScaleProximity.CheckRecovery` | `#82F8` | проверка выхода из опасной зоны |
| `Game.Screen.ScaleProximity.StoreStatus` | `#82FE` | сохранение состояния полёта |

## [SelectScreen](../Source/Game/Screen/SelectScreen.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Screen.SelectScreen.CheckDockView` | `#816C` | проверка ограничения вида стыковочным туннелем |
| `Game.Screen.SelectScreen.StoreView` | `#8173` | сохранение нового номера экрана |

## [SelectTrafficType](../Source/Game/Screen/SelectTrafficType.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Screen.SelectTrafficType.CheckSpecial` | `#8005` | проверка допуска специального корабля |
| `Game.Screen.SelectTrafficType.ChooseSpecial` | `#801A` | выбор специального типа корабля |
| `Game.Screen.SelectTrafficType.KeepType` | `#801E` | возврат с прежним типом корабля |

## [UpdateCelestialProximity](../Source/Game/Screen/UpdateCelestialProximity.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Screen.UpdateCelestialProximity.StoreScooping` | `#81EC` | сохранение признака сбора топлива у солнца |
| `Game.Screen.UpdateCelestialProximity.CheckPlanet` | `#81F7` | проверка близости планеты |

## [UpdateIndicators](../Source/Game/Screen/UpdateIndicators.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Screen.UpdateIndicators.OrdinaryGauge` | `#84E3` | проверка очередного обычного индикатора |
| `Game.Screen.UpdateIndicators.NextOrdinary` | `#84F4` | переход к следующему обычному индикатору |
| `Game.Screen.UpdateIndicators.SpecialGauge` | `#8507` | проверка индикатора второго режима |
| `Game.Screen.UpdateIndicators.NextSpecial` | `#8514` | переход к следующему индикатору второго режима |

## [VectorLength](../Source/Game/Screen/VectorLength.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Screen.VectorLength.Normalize` | `#8327` | совместное удвоение координат вектора |
| `Game.Screen.VectorLength.UndoFirstShift` | `#8338` | отмена последнего сдвига первой координаты |
| `Game.Screen.VectorLength.UndoTwoShifts` | `#833C` | отмена сдвига первых двух координат |
| `Game.Screen.VectorLength.UndoAllShifts` | `#8342` | отмена сдвига всех трёх координат |
| `Game.Screen.VectorLength.SumSquares` | `#8348` | суммирование квадратов нормированных координат |
| `Game.Screen.VectorLength.AddThirdSquare` | `#8359` | добавление квадрата третьей координаты |
| `Game.Screen.VectorLength.CheckOverflow` | `#8361` | проверка старших разрядов суммы квадратов |
| `Game.Screen.VectorLength.TakeRoot` | `#8377` | извлечение приближённого квадратного корня |
| `Game.Screen.VectorLength.RestoreScale` | `#837B` | возврат к исходному двоичному масштабу длины |
| `Game.Screen.VectorLength.DoubleRoot` | `#8386` | удвоение корня после уменьшения суммы квадратов |
| `Game.Screen.VectorLength.LengthReady` | `#838F` | возврат рассчитанной длины |
| `Game.Screen.VectorLength.DrawCompass` | `#8390` | вывод спрайта указателя компаса |
| `Game.Screen.VectorLength.PositionY` | `#83A5` | расчёт вертикального положения указателя компаса |
| `Game.Screen.VectorLength.NegativeY` | `#83B5` | вертикальное смещение для отрицательной координаты |
| `Game.Screen.VectorLength.SetRowCount` | `#83B8` | подготовка числа строк вертикального смещения |
| `Game.Screen.VectorLength.MoveDown` | `#83B9` | переход к экранной строке указателя компаса |
| `Game.Screen.VectorLength.DrawSpriteRow` | `#83C4` | вывод очередной строки спрайта указателя |
| `Game.Screen.VectorLength.ShiftRight` | `#83D7` | сдвиг строки указателя вправо |
| `Game.Screen.VectorLength.ShiftLeft` | `#83DF` | сдвиг строки указателя влево |
| `Game.Screen.VectorLength.MergeSprite` | `#83E5` | наложение трёхбайтовой строки указателя |

## [WriteIndicatorMask](../Source/Game/Screen/WriteIndicatorMask.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Screen.WriteIndicatorMask.MarkerAtEdge` | `#8614` | вывод маркера на границе байтов |

## [WriteStridedTriple](../Source/Game/Screen/WriteStridedTriple.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Screen.WriteStridedTriple.PlanetIsNear` | `#821E` | обработка близкой планеты |
| `Game.Screen.WriteStridedTriple.SelectStation` | `#8246` | выбор станции целью компаса |
| `Game.Screen.WriteStridedTriple.NormalizeX` | `#825D` | нормирование первой координаты компаса |

## [PlayDestructionSound](../Source/Game/Sound/PlayDestructionSound.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Sound.PlayDestructionSound.PlayNoise` | `#9551` | проверка завершения синхронного звука, входная команда LD A,(#9522) |
| `Game.Sound.PlayDestructionSound.EndSound` | `#955C` | завершение синхронного звукового эффекта и включение прерываний |

## [StartLaunchNoise](../Source/Game/Sound/StartLaunchNoise.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Sound.StartLaunchNoise.DisableIrq` | `#96AF` | запрет прерываний на время запуска шумового эффекта |

## [StepDataTone](../Source/Game/Sound/StepDataTone.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Sound.StepDataTone.NextPacket` | `#95EE` | начало следующего пакета из 100 звуковых периодов |
| `Game.Sound.StepDataTone.ReadPeriod` | `#95F0` | чтение данных периода с циклическим изменением младшего байта адреса, входная команда LD A,(HL) |
| `Game.Sound.StepDataTone.HighDelay` | `#95FC` | формирование первой половины звукового периода, входная команда DJNZ #95FC |
| `Game.Sound.StepDataTone.LowDelay` | `#9602` | задержка низкого уровня звукового периода |
| `Game.Sound.StepDataTone.FinishPacket` | `#9607` | обновление оставшегося числа пакетов, входная команда DEC D |
| `Game.Sound.StepDataTone.FinishEffect` | `#9610` | завершение активного эффекта, входная команда XOR A |
| `Game.Sound.StepDataTone.RequestMask` | `#961B` | выбор маски звукового запроса по индексу эффекта |

## [StepNoise](../Source/Game/Sound/StepNoise.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Sound.StepNoise.NextPacket` | `#95AD` | начало следующего пакета из 64 шумовых отсчётов |
| `Game.Sound.StepNoise.NoiseSample` | `#95AF` | чтение следующего шумового отсчёта, используются биты 3 и 4, входная команда LD A,(HL) |
| `Game.Sound.StepNoise.SampleDelay` | `#95B5` | задержка после шумового отсчёта |

## [StepPitchSweep](../Source/Game/Sound/StepPitchSweep.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Sound.StepPitchSweep.NextPeriod` | `#9628` | расчёт следующей задержки, удвоение E и прибавление изменяемого операнда, входная команда LD A,E |
| `Game.Sound.StepPitchSweep.BeeperPeriod` | `#962F` | создание очередного из 15 периодов пакета, входная команда LD A,#30 |
| `Game.Sound.StepPitchSweep.HighDelay` | `#9634` | задержка высокого уровня звукового периода |
| `Game.Sound.StepPitchSweep.LowDelay` | `#963A` | задержка низкого уровня звукового периода |
| `Game.Sound.StepPitchSweep.StartSweep` | `#964D` | установка слагаемого формулы периода и запуск первого пакета, входная команда LD (#962B),A |
| `Game.Sound.StepPitchSweep.StartDataTone` | `#9663` | установка преобразования отсчёта и адреса звуковых данных, входная команда LD DE,#0100 |
| `Game.Sound.StepPitchSweep.StartNoise` | `#967A` | установка восьми пакетов шума, каждый пакет содержит 64 отсчёта, входная команда LD A,#03 |
| `Game.Sound.StepPitchSweep.NoiseLength` | `#967F` | установка восьми пакетов шума, каждый пакет содержит 64 отсчёта, входная команда LD B,#40 |
| `Game.Sound.StepPitchSweep.SetNoisePatch` | `#9684` | обновление параметров самомодифицируемого шумового проигрывателя, входная команда LD HL,#0127 |

## [UpdateSound](../Source/Game/Sound/UpdateSound.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Sound.UpdateSound.FindRequest` | `#958C` | поиск младшего установленного бита запроса через RRA, входная команда INC B |
| `Game.Sound.UpdateSound.StartEffect` | `#959E` | передача управления выбранному обработчику запуска эффекта |
| `Game.Sound.UpdateSound.ResumeEffect` | `#959F` | проверка режима тона с изменяемым периодом, входная команда DEC A |

## [ApplyAttributeRuns](../Source/Game/Text/ApplyAttributeRuns.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Text.ApplyAttributeRuns.ReadRun` | `#D56B` | чтение длины участка и шага до следующей строки |
| `Game.Text.ApplyAttributeRuns.AdvanceRow` | `#D581` | переход на следующую строку атрибутов |
| `Game.Text.ApplyAttributeRuns.CountRows` | `#D588` | учёт пройденной символьной строки |
| `Game.Text.ApplyAttributeRuns.FinishRuns` | `#D58C` | завершение списка и установка двух атрибутов рамки |

## [ApplyTextCase](../Source/Game/Text/ApplyTextCase.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Text.ApplyTextCase.CheckWordStart` | `#D4B8` | выбор регистра по признаку начала слова |
| `Game.Text.ApplyTextCase.Lowercase` | `#D4CC` | преобразование ASCII буквы в строчный регистр |
| `Game.Text.ApplyTextCase.MarkWordStart` | `#D4D2` | отметка границы слова после небуквенного символа |
| `Game.Text.ApplyTextCase.EmitCharacter` | `#D4D8` | восстановление символа перед выводом |

## [CapitalizeNextLetterAndTextCommands](../Source/Game/Text/CapitalizeNextLetterAndTextCommands.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Text.CapitalizeNextLetterAndTextCommands.NextSyllable` | `#D88D` | генерация следующего двухбуквенного слога |
| `Game.Text.CapitalizeNextLetterAndTextCommands.StoreCaseMode` | `#D8B0` | сохранение режима регистра текста |

## [CheckMineralLifeColony](../Source/Game/Text/CheckMineralLifeColony.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Text.CheckMineralLifeColony.KillColony` | `#D5C5` | отметка гибели колонии при нехватке минералов |
| `Game.Text.CheckMineralLifeColony.AbsentResult` | `#D5C9` | возврат FF для отсутствующей или FE для погибшей колонии |

## [CheckMissionRegion](../Source/Game/Text/CheckMissionRegion.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Text.CheckMissionRegion.CheckGalaxy` | `#D67D` | общий вход с выбранным указателем координат |
| `Game.Text.CheckMissionRegion.ConsumeLimit` | `#D691` | пропуск встроенного порога в адресе возврата |
| `Game.Text.CheckMissionRegion.RadiusOverflow` | `#D6A8` | возврат переноса при переполнении метрики радиуса |

## [ClearViewAndFrame](../Source/Game/Text/ClearViewAndFrame.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Text.ClearViewAndFrame.ClearScanline` | `#D621` | очистка очередной пиксельной строки окна |
| `Game.Text.ClearViewAndFrame.ClearByte` | `#D625` | очистка очередного байта пиксельной строки |

## [DrawCharacter8x8](../Source/Game/Text/DrawCharacter8x8.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Text.DrawCharacter8x8.GlyphAddress` | `#D4F1` | вычисление адреса глифа после обновления колонки |
| `Game.Text.DrawCharacter8x8.BottomThird` | `#D51C` | выбор нижней трети экрана для строки текста |
| `Game.Text.DrawCharacter8x8.MiddleThird` | `#D526` | выбор средней трети экрана для строки текста |
| `Game.Text.DrawCharacter8x8.RowOffset` | `#D52D` | добавление номера символьной строки внутри трети экрана |

## [DrawProjectedSunAndTextDispatch](../Source/Game/Text/DrawProjectedSunAndTextDispatch.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Text.DrawProjectedSunAndTextDispatch.CompareSectors` | `#D7CE` | рисование секторов с выбранной осью проекции |
| `Game.Text.DrawProjectedSunAndTextDispatch.MainCommand` | `#D7E2` | вход диспетчера основной таблицы текстовых команд |
| `Game.Text.DrawProjectedSunAndTextDispatch.DescCommand` | `#D7E4` | перекрывающийся вход второй таблицы текстовых команд |
| `Game.Text.DrawProjectedSunAndTextDispatch.PrintWithEol` | `#D848` | вывод токена с переводом строки |
| `Game.Text.DrawProjectedSunAndTextDispatch.PrintString` | `#D878` | вывод подготовленной строки до нулевого байта |

## [DrawViewFrame](../Source/Game/Text/DrawViewFrame.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Text.DrawViewFrame.DrawSides` | `#D64E` | установка крайних пикселей очередной строки рамки |

## [EquipmentMenuLimit](../Source/Game/Text/EquipmentMenuLimit.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Text.EquipmentMenuLimit.OrdinaryLimit` | `#D8D0` | загрузка обычного предела номера оборудования |

## [HandleSpecialObjectMission](../Source/Game/Text/HandleSpecialObjectMission.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Text.HandleSpecialObjectMission.CheckPermit` | `#D6BD` | проверка старшего бита поля допуска миссии |
| `Game.Text.HandleSpecialObjectMission.ReturnCarry` | `#D6C3` | преобразование переноса в результат события |
| `Game.Text.HandleSpecialObjectMission.DestroyStation` | `#D6C5` | обнуление энергии особой станции и проверка фронта вторжения |
| `Game.Text.HandleSpecialObjectMission.ShrinkFront` | `#D6D4` | сокращение области вторжения до освобождения текущей системы |

## [InitializeSixTriples](../Source/Game/Text/InitializeSixTriples.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Text.InitializeSixTriples.InitTriple` | `#D5D5` | запись нулевых младших частей и начального старшего байта |

## [NextDescriptionRandom](../Source/Game/Text/NextDescriptionRandom.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Text.NextDescriptionRandom.CheckSupply` | `#D5FD` | проверка области для поставки продовольствия или оружия |
| `Game.Text.NextDescriptionRandom.ReturnGoods` | `#D609` | восстановление номера проданного товара |

## [OfferRegionDependentMission](../Source/Game/Text/OfferRegionDependentMission.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Text.OfferRegionDependentMission.WartimeTask` | `#D715` | выбор военного задания в полосе сопротивления |
| `Game.Text.OfferRegionDependentMission.FindRewardBit` | `#D729` | выбор бита награды и соответствующего токена |
| `Game.Text.OfferRegionDependentMission.OfferVolunteer` | `#D730` | предложение вступить добровольцем |
| `Game.Text.OfferRegionDependentMission.AdvanceRank` | `#D749` | увеличение кода военного этапа |
| `Game.Text.OfferRegionDependentMission.ShowTask` | `#D74A` | вывод выбранного миссионного сообщения |
| `Game.Text.OfferRegionDependentMission.OccupiedSystem` | `#D74F` | назначение состояния миссии для оккупированной системы |

## [PrintDescriptionToken](../Source/Game/Text/PrintDescriptionToken.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Text.PrintDescriptionToken.SkipToken` | `#D463` | проверка числа оставшихся строк перед искомым токеном |

## [PrintMainToken](../Source/Game/Text/PrintMainToken.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Text.PrintMainToken.ExtendToken` | `#D441` | преобразование управляющего кода в расширенный токен |
| `Game.Text.PrintMainToken.FindToken` | `#D443` | поиск строки основной таблицы |
| `Game.Text.PrintMainToken.SkipToken` | `#D448` | пропуск строк перед искомым токеном |
| `Game.Text.PrintMainToken.ExpandString` | `#D454` | рекурсивный вывод следующего байта строки |

## [PrintRankWithMissionSuffix](../Source/Game/Text/PrintRankWithMissionSuffix.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Text.PrintRankWithMissionSuffix.FinishLine` | `#D785` | перевод строки после звания и дополнительных отметок |

## [PrintTwoLetterSyllable](../Source/Game/Text/PrintTwoLetterSyllable.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Text.PrintTwoLetterSyllable.MainSyllable` | `#D59C` | выбор слога основной таблицы |
| `Game.Text.PrintTwoLetterSyllable.FindPair` | `#D5A1` | поиск двух букв по удвоенному индексу |

## [SetDescriptionModeAndHelpers](../Source/Game/Text/SetDescriptionModeAndHelpers.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Text.SetDescriptionModeAndHelpers.StoreMode` | `#D8EB` | сохранение режима второй таблицы описаний |
| `Game.Text.SetDescriptionModeAndHelpers.SetRow` | `#D8F5` | назначение выбранной строки печати |
| `Game.Text.SetDescriptionModeAndHelpers.PrintLetter` | `#D8F8` | вывод буквы слога с пропуском заполнителя |

## [BuyCargoLoop](../Source/Game/Trade/BuyCargoLoop.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Trade.BuyCargoLoop.NextCommodity` | `#E728` | для очередного товара сначала печатается наличие, затем выполняется пробная покупка, входная команда LD HL,(#E1E0) |
| `Game.Trade.BuyCargoLoop.PromptQuantity` | `#E737` | приглашение ввода количества приобретаемого товара |
| `Game.Trade.BuyCargoLoop.BuySuccess` | `#E74C` | подтверждение успешной покупки |
| `Game.Trade.BuyCargoLoop.RestoreCursor` | `#E74F` | восстановление курсора после ввода количества |
| `Game.Trade.BuyCargoLoop.AdvanceItem` | `#E752` | продвижение к следующему товару списка покупок |
| `Game.Trade.BuyCargoLoop.ReturnCargo` | `#E75B` | возврат к экрану грузового отсека |
| `Game.Trade.BuyCargoLoop.ClearAttrByte` | `#E769` | очистка очередного атрибута торгового экрана |
| `Game.Trade.BuyCargoLoop.UndoQuantity` | `#E76E` | отмена введённого количества и восстановление снимка сделки |

## [ChooseLaserDirection](../Source/Game/Trade/ChooseLaserDirection.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Trade.ChooseLaserDirection.LaserSuccess` | `#EB1C` | подтверждение установки лазера и возврат в магазин |
| `Game.Trade.ChooseLaserDirection.CancelLaser` | `#EB22` | отмена покупки лазера с восстановлением денежных средств |

## [ClearPressedKeyBits](../Source/Game/Trade/ClearPressedKeyBits.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Trade.ClearPressedKeyBits.ClearKeyByte` | `#E20B` | очистка очередного байта накопленных клавиш |

## [EquipmentAlreadyOwned](../Source/Game/Trade/EquipmentAlreadyOwned.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Trade.EquipmentAlreadyOwned.PrintItemError` | `#EB47` | при повторной покупке выводится отказ, далее используется общий денежный откат, входная команда LD A,#68 |
| `Game.Trade.EquipmentAlreadyOwned.ShowError` | `#EB4E` | вывод причины отказа в установке оборудования |
| `Game.Trade.EquipmentAlreadyOwned.ReturnStatus` | `#EB5B` | возврат к экрану состояния командира |

## [FillCharacterRowInterior](../Source/Game/Trade/FillCharacterRowInterior.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Trade.FillCharacterRowInterior.RasterRow` | `#E37F` | восемь растровых строк очищаются только между крайними ячейками рамки, входная команда PUSH BC |
| `Game.Trade.FillCharacterRowInterior.FillByte` | `#E383` | заполнение очередного байта внутренней части строки |

## [GenerateMarket](../Source/Game/Trade/GenerateMarket.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Trade.GenerateMarket.NextCommodity` | `#E154` | чтение базовой цены и знакового коэффициента, произведение экономики вычисляется сложением, входная команда PUSH BC |
| `Game.Trade.GenerateMarket.EconomyProduct` | `#E164` | произведение экономики и ценового коэффициента повторным сложением |
| `Game.Trade.GenerateMarket.StockAmount` | `#E167` | остаток товара строится из базового запаса, случайной маски и экономической поправки, входная команда LD E,A |
| `Game.Trade.GenerateMarket.ApplyStock` | `#E17B` | добавление экономической поправки к запасу товара |
| `Game.Trade.GenerateMarket.ClampStock` | `#E181` | шести битный остаток сохраняется на стеке до переключения в набор выходных указателей, входная команда AND #3F |
| `Game.Trade.GenerateMarket.PositivePrice` | `#E19A` | сложение положительных компонентов цены |
| `Game.Trade.GenerateMarket.ScalePrice` | `#E19E` | цена масштабируется в четыре раза с переносами в старший байт, входная команда LD B,E |

## [HandleEquipmentPurchase](../Source/Game/Trade/HandleEquipmentPurchase.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Trade.HandleEquipmentPurchase.CheckItemLimit` | `#EA05` | проверка введённого номера по границе доступного оборудования |
| `Game.Trade.HandleEquipmentPurchase.CheckPayment` | `#EA22` | проверка достаточности денег после списания цены |

## [IndirectTradeCallbackAndBuy](../Source/Game/Trade/IndirectTradeCallbackAndBuy.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Trade.IndirectTradeCallbackAndBuy.PayPrice` | `#E7EA` | списание полной стоимости приобретаемого количества |
| `Game.Trade.IndirectTradeCallbackAndBuy.AddCargo` | `#E808` | добавление оплаченного количества к грузу |
| `Game.Trade.IndirectTradeCallbackAndBuy.NotEnoughStock` | `#E818` | отказ покупки при нехватке товара на станции |

## [InputTradeQuantity](../Source/Game/Trade/InputTradeQuantity.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Trade.InputTradeQuantity.ClearQuantity` | `#E779` | адрес callback сохраняется отдельно, количество до первой цифры равно нулю, входная команда XOR A |
| `Game.Trade.InputTradeQuantity.FirstDigit` | `#E77D` | ожидание первой ненулевой цифры количества |
| `Game.Trade.InputTradeQuantity.SecondDigit` | `#E7A2` | ожидание второй цифры или подтверждения однозначного количества |
| `Game.Trade.InputTradeQuantity.SkipItem` | `#E7CB` | возврат служебного результата пропуска товара |
| `Game.Trade.InputTradeQuantity.InputError` | `#E7CD` | возврат ошибки ввода или пробной сделки с переносом |

## [InstallPurchasedEquipment](../Source/Game/Trade/InstallPurchasedEquipment.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Trade.InstallPurchasedEquipment.CheckCargoBay` | `#EA4C` | проверка пункта расширения грузового отсека |
| `Game.Trade.InstallPurchasedEquipment.AddCargoSpace` | `#EA57` | увеличение свободного трюма на 15 единиц при установке расширения |
| `Game.Trade.InstallPurchasedEquipment.CheckItemKind` | `#EA60` | общий предмет получает новый уровень, лазеры требуют выбора направления, входная команда CP #04 |
| `Game.Trade.InstallPurchasedEquipment.CheckOwned` | `#EA6C` | проверка наличия покупаемого оборудования |
| `Game.Trade.InstallPurchasedEquipment.InstallItem` | `#EA75` | установка уровня выбранного оборудования |
| `Game.Trade.InstallPurchasedEquipment.BuySuccess` | `#EA79` | подтверждение успешной покупки и возврат к выбору |
| `Game.Trade.InstallPurchasedEquipment.SelectLaser` | `#EA7F` | номер покупки переводится в тип устанавливаемого лазера, входная команда LD B,#01 |
| `Game.Trade.InstallPurchasedEquipment.LaserSelected` | `#EA90` | сохранение выбранного типа лазера и подготовка списка направлений |
| `Game.Trade.InstallPurchasedEquipment.ListDirection` | `#EAB6` | печать четырёх сторон корабля и их текущих лазеров, входная команда LD (#EB5F),A |

## [ListEquipmentChoices](../Source/Game/Trade/ListEquipmentChoices.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Trade.ListEquipmentChoices.SetItemLimit` | `#E99B` | ограничение доступного списка оборудования по технологии |
| `Game.Trade.ListEquipmentChoices.ListNextItem` | `#E99F` | печать очередного пункта оборудования |

## [MissionRegionMetric](../Source/Game/Trade/MissionRegionMetric.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Trade.MissionRegionMetric.ClearCargo` | `#E6E3` | очистка грузовых слотов перед размещением беженцев |
| `Game.Trade.MissionRegionMetric.ReturnCargo` | `#E6EB` | переход к экрану грузового отсека |

## [PrintCargoQuantity](../Source/Game/Trade/PrintCargoQuantity.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Trade.PrintCargoQuantity.EmptyCargo` | `#E290` | возврат переноса при пустом грузовом слоте |

## [PrintCommodityUnit](../Source/Game/Trade/PrintCommodityUnit.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Trade.PrintCommodityUnit.Tonnes` | `#E336` | выбор обозначения тонн |
| `Game.Trade.PrintCommodityUnit.Kilograms` | `#E33A` | выбор обозначения килограммов |
| `Game.Trade.PrintCommodityUnit.Grams` | `#E33F` | выбор обозначения граммов |
| `Game.Trade.PrintCommodityUnit.Kilometres` | `#E343` | начало печати обозначения километров |

## [PrintEmptyStockOrQuantity](../Source/Game/Trade/PrintEmptyStockOrQuantity.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Trade.PrintEmptyStockOrQuantity.PrintStock` | `#E254` | вывод доступного количества товара |

## [PrintEquipmentPrice](../Source/Game/Trade/PrintEquipmentPrice.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Trade.PrintEquipmentPrice.SelectItem` | `#E9DF` | вывод приглашения выбора оборудования |

## [PrintKilometreSuffix](../Source/Game/Trade/PrintKilometreSuffix.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Trade.PrintKilometreSuffix.PrintSuffix` | `#E349` | общий хвост дописывает M к выбранному префиксу единицы измерения, входная команда JP Game.Text.PrintMainToken.Entry |
| `Game.Trade.PrintKilometreSuffix.NoTonnage` | `#E358` | возврат без переноса для товаров вне тоннажного учёта |

## [PrintMainTokenColon](../Source/Game/Trade/PrintMainTokenColon.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Trade.PrintMainTokenColon.PrintColon` | `#E29A` | основной токен завершается двоеточием через общий принтер символа, входная команда LD A,#3A |

## [PrintMainTokenSpace](../Source/Game/Trade/PrintMainTokenSpace.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Trade.PrintMainTokenSpace.PrintSuffix` | `#E2A3` | к основному токену дописывается пробел, курсор сохраняется в глобальном состоянии, входная команда JP Game.Text.PrintMainToken.Entry |

## [ResetCloakingAndSeedFlightRandom](../Source/Game/Trade/ResetCloakingAndSeedFlightRandom.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Trade.ResetCloakingAndSeedFlightRandom.BusyCargo` | `#E6F2` | вход на байт #6A адреса D06A, выполняет LD L,D и RET NC при занятом миссией трюме |
| `Game.Trade.ResetCloakingAndSeedFlightRandom.OpenBuy` | `#E707` | открытие экрана покупки товаров |

## [ResetTextColumn](../Source/Game/Trade/ResetTextColumn.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Trade.ResetTextColumn.SetColumn` | `#E2B8` | запись заранее подготовленного номера текстовой колонки |

## [TradeErrorMessage](../Source/Game/Trade/TradeErrorMessage.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Trade.TradeErrorMessage.ShowError` | `#E822` | сообщение ошибки печатается перед восстановлением снимка и паузой, входная команда PUSH AF |

## [TradeTitleAndSellLoop](../Source/Game/Trade/TradeTitleAndSellLoop.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Trade.TradeTitleAndSellLoop.NextCommodity` | `#E8F9` | сброс указателей и обход только непустых грузовых слотов, входная команда LD HL,(#E1E2) |
| `Game.Trade.TradeTitleAndSellLoop.PromptQuantity` | `#E909` | приглашение количества продаваемого товара |
| `Game.Trade.TradeTitleAndSellLoop.FinishRow` | `#E917` | завершение строки после продажи или пропуска |
| `Game.Trade.TradeTitleAndSellLoop.AdvanceItem` | `#E91D` | продвижение к следующему грузовому слоту |
| `Game.Trade.TradeTitleAndSellLoop.ServiceResult` | `#E92C` | разбор служебного результата ввода количества |
| `Game.Trade.TradeTitleAndSellLoop.ReturnCargo` | `#E932` | возврат к экрану грузового отсека |
| `Game.Trade.TradeTitleAndSellLoop.PayUnit` | `#E953` | цена продажи начисляется по одной единице, у MINERAL LIFE её подменяет DE6A, входная команда PUSH BC |

## [Wait36Interrupts](../Source/Game/Trade/Wait36Interrupts.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Trade.Wait36Interrupts.WaitFrame` | `#E360` | B=36 задаёт более длинную паузу в том же цикле HALT, входная команда HALT |

## [WaitForKeyCode](../Source/Game/Trade/WaitForKeyCode.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Trade.WaitForKeyCode.AwaitKey` | `#E1FD` | пауза и сброс старых клавиш предшествуют ожиданию нового кода от обработчика ввода, входная команда LD A,(#FC0D) |

## [BuildStationGeometry](../Source/Game/Travel/BuildStationGeometry.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Travel.BuildStationGeometry.RotateAxis` | `#DD7D` | смещение выбранной координаты станции относительно планеты |
| `Game.Travel.BuildStationGeometry.NegativeBias` | `#DD92` | уменьшение модуля старшей координаты станции на два |
| `Game.Travel.BuildStationGeometry.LowerComponent` | `#DD93` | последний шаг уменьшения после проверки смены знака |
| `Game.Travel.BuildStationGeometry.PositiveBias` | `#DD96` | увеличение модуля старшей координаты станции |
| `Game.Travel.BuildStationGeometry.PackComponent` | `#DD97` | упаковка знака и нового модуля координаты станции |
| `Game.Travel.BuildStationGeometry.ClearAxes` | `#DDA5` | очистка матрицы ориентации станции |
| `Game.Travel.BuildStationGeometry.StoreSideAxis` | `#DDCD` | инверсия второй оси при расположении станции по другую сторону X |
| `Game.Travel.BuildStationGeometry.VerticalAxis` | `#DDD0` | построение ориентации по расположению станции вдоль Z |
| `Game.Travel.BuildStationGeometry.MissionStage` | `#DDE3` | сохранённый вход установки пятого состояния третьей миссии |
| `Game.Travel.BuildStationGeometry.AxisPositive` | `#DDE7` | положительные компоненты ориентации станции |
| `Game.Travel.BuildStationGeometry.StoreAxes` | `#DDE9` | запись обеих выбранных компонент ориентации |
| `Game.Travel.BuildStationGeometry.FinishGeometry` | `#DDEB` | завершение размещения станции |

## [ClearFlightEventsAndHandleJump](../Source/Game/Travel/ClearFlightEventsAndHandleJump.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Travel.ClearFlightEventsAndHandleJump.ClearEvent` | `#DB96` | очистка десяти событий перед разбором запроса обычного или галактического перехода, входная команда RES 7,(HL) |
| `Game.Travel.ClearFlightEventsAndHandleJump.CheckJumpKeys` | `#DBA2` | клавиши перехода читаются из маски FC0A и сразу погашаются после обработки, входная команда LD HL,#FC0A |
| `Game.Travel.ClearFlightEventsAndHandleJump.CheckDistance` | `#DBCF` | сверка ненулевого расстояния с остатком топлива перед запуском отсчёта, входная команда CALL Game.Galaxy.SelectNearestSystemWithCursor.Entry |
| `Game.Travel.ClearFlightEventsAndHandleJump.StartCountdown` | `#DBEB` | запуск обратного отсчёта гиперперехода |
| `Game.Travel.ClearFlightEventsAndHandleJump.JumpTooFar` | `#DC04` | сообщение о недопустимом расстоянии гиперперехода |
| `Game.Travel.ClearFlightEventsAndHandleJump.ShowCountdown` | `#DC0A` | очистка экрана и настройка вывода обратного отсчёта |

## [CommitJumpFuelAndMishap](../Source/Game/Travel/CommitJumpFuelAndMishap.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Travel.CommitJumpFuelAndMishap.Witchspace` | `#DCC0` | вход в особое пространство после нештатного гиперперехода |

## [EnterTargetSystem](../Source/Game/Travel/EnterTargetSystem.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Travel.EnterTargetSystem.ClearBodies` | `#DD18` | очистка координат небесных тел при входе в систему |

## [GetSalePriceAndMissionFlags](../Source/Game/Travel/GetSalePriceAndMissionFlags.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Travel.GetSalePriceAndMissionFlags.MineralGate` | `#DE6A` | изменяемая команда NOP/RET, разрешающая специальную цену MINERAL LIFE |
| `Game.Travel.GetSalePriceAndMissionFlags.GrantMission` | `#DE6F` | дополнительный вход выдачи первой, второй и третьей миссий по битовой маске, входная команда AND (HL) |
| `Game.Travel.GetSalePriceAndMissionFlags.SecondMission` | `#DE84` | проверка выдачи второй миссии по маске выполненных |
| `Game.Travel.GetSalePriceAndMissionFlags.ThirdMission` | `#DE8B` | проверка выдачи третьей миссии по маске выполненных |

## [LaserTypeAndArrivalEvents](../Source/Game/Travel/LaserTypeAndArrivalEvents.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Travel.LaserTypeAndArrivalEvents.StoreLaser` | `#DDF3` | сохранение выбранного кода лазера для установки |
| `Game.Travel.LaserTypeAndArrivalEvents.ArrivalEvents` | `#DDF7` | обработка миссионных состояний и счётчика прибытия в новую систему, входная команда LD A,(State.Galaxy) |
| `Game.Travel.LaserTypeAndArrivalEvents.CheckStage` | `#DE13` | проверка третьего этапа миссии перед посещением цели |
| `Game.Travel.LaserTypeAndArrivalEvents.CheckTarget` | `#DE18` | сравнение текущей системы с базовой целью миссии |
| `Game.Travel.LaserTypeAndArrivalEvents.StoreMission` | `#DE22` | сохранение нового этапа третьей миссии |
| `Game.Travel.LaserTypeAndArrivalEvents.CountArrival` | `#DE25` | увеличение счётчика посещённых систем |
| `Game.Travel.LaserTypeAndArrivalEvents.CheckGrant` | `#DE2F` | проверка старшего бита счётчика для выдачи миссий |
| `Game.Travel.LaserTypeAndArrivalEvents.RandomPolice` | `#DE39` | случайный выбор полицейского признака по правительству |
| `Game.Travel.LaserTypeAndArrivalEvents.FinishArrival` | `#DE4C` | запуск завершающего этапа прибытия в систему |

## [SelectQueuedFlightMessage](../Source/Game/Travel/SelectQueuedFlightMessage.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Travel.SelectQueuedFlightMessage.FindEvent` | `#DACE` | поиск одного из десяти событий по установленному старшему биту, входная команда BIT 7,(HL) |
| `Game.Travel.SelectQueuedFlightMessage.TakeEvent` | `#DAD7` | снятие признака ожидающего события и чтение его параметров |
| `Game.Travel.SelectQueuedFlightMessage.BeepMessage` | `#DADC` | звуковое уведомление о выбранном полётном сообщении |
| `Game.Travel.SelectQueuedFlightMessage.SetLifetime` | `#DAE1` | установка времени показа очередного сообщения |

## [SetFuelAndGauge](../Source/Game/Travel/SetFuelAndGauge.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Travel.SetFuelAndGauge.StoreFuel` | `#DEA8` | сохранение топлива и расчёт значения приборного индикатора |

## [SetMessageCoordinatesAndRender](../Source/Game/Travel/SetMessageCoordinatesAndRender.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Travel.SetMessageCoordinatesAndRender.TickMessage` | `#DAEF` | уменьшение таймера и проверка допустимого экрана для печати |
| `Game.Travel.SetMessageCoordinatesAndRender.PrintText` | `#DB0D` | печать основного текста сообщения |
| `Game.Travel.SetMessageCoordinatesAndRender.SpecialPrefix` | `#DB13` | выбор дополнительной части специального сообщения |
| `Game.Travel.SetMessageCoordinatesAndRender.PrintPrefix` | `#DB20` | печать дополнительного токена перед основным текстом |
| `Game.Travel.SetMessageCoordinatesAndRender.PrintFuel` | `#DB25` | печать численного параметра сообщения о топливе |

## [TickJumpCountdown](../Source/Game/Travel/TickJumpCountdown.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Travel.TickJumpCountdown.CommitJump` | `#DC44` | после завершения отсчёта разделяются обычный и галактический переходы, входная команда CALL Game.Travel.ClearFlightEventsAndHandleJump.Entry |
| `Game.Travel.TickJumpCountdown.ClearMissions` | `#DC4E` | сброс миссий при переходе в следующую галактику |
| `Game.Travel.TickJumpCountdown.UseGalDrive` | `#DC5F` | расход заряда галактического привода и смена галактики |

## [UpdateAmbientFlightMessage](../Source/Game/Travel/UpdateAmbientFlightMessage.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Travel.UpdateAmbientFlightMessage.TickAmbient` | `#DB60` | уменьшение периодического таймера предупреждений |
| `Game.Travel.UpdateAmbientFlightMessage.MissionWarning` | `#DB62` | предупреждение третьей миссии при её состоянии 1, токен #0F и длительность 3 |
| `Game.Travel.UpdateAmbientFlightMessage.DockingMessage` | `#DB67` | сообщение автоматической стыковки, токен #7B и длительность 5 |
| `Game.Travel.UpdateAmbientFlightMessage.CheckScooping` | `#DB6C` | проверка оборудования и пополнение топлива возле звезды |
| `Game.Travel.UpdateAmbientFlightMessage.DropCloak` | `#DB7D` | снятие маскировки и предупреждение при низкой энергии верхнего банка, входная команда XOR A |
| `Game.Travel.UpdateAmbientFlightMessage.QueueAmbient` | `#DB8E` | передача фонового сообщения общей очереди показа |

## [UpdateFlightMessages](../Source/Game/Travel/UpdateFlightMessages.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Travel.UpdateFlightMessages.RenderMessage` | `#DA93` | бит 7 старшего байта адреса экрана направляет печать в буфер C000, входная команда LD HL,#D50A |

## [AddSignedStarCoordinate](../Source/Game/Universe/AddSignedStarCoordinate.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Universe.AddSignedStarCoordinate.StoreSigned` | `#7A6C` | упаковка знака и модуля результата сложения координаты |
| `Game.Universe.AddSignedStarCoordinate.SubMagnitudes` | `#7A74` | расчёт разности модулей и выбор знака, входная команда AND #7F |
| `Game.Universe.AddSignedStarCoordinate.KeepSign` | `#7A81` | сохранение исходного знака координаты при вычитании меньшего модуля |

## [ApplyEnhancedFlightControl](../Source/Game/Universe/ApplyEnhancedFlightControl.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Universe.ApplyEnhancedFlightControl.AmplifyAxis` | `#7F92` | расчёт усиленных углов и скорости, входная команда LD A,(HL) |
| `Game.Universe.ApplyEnhancedFlightControl.ReturnPitch` | `#7F9D` | возврат актуального угла DU, входная команда LD A,(FlightState.Pitch) |
| `Game.Universe.ApplyEnhancedFlightControl.MarkResult` | `#7FB9` | обновление флага результата и формирование ненулевого признака для страницы D0, входная команда SET 0,(HL) |

## [CheckLinkedObjectInteraction](../Source/Game/Universe/CheckLinkedObjectInteraction.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Universe.CheckLinkedObjectInteraction.FindLink` | `#7B74` | поиск объекта и расширенной записи по упакованной ссылке |

## [CheckSpecialSystemOrRandom](../Source/Game/Universe/CheckSpecialSystemOrRandom.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Universe.CheckSpecialSystemOrRandom.ClearStation` | `#7F6F` | создание специального положения станции, входная команда LD (HL),#00 |

## [CompareObjectAxisDistance](../Source/Game/Universe/CompareObjectAxisDistance.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Universe.CompareObjectAxisDistance.CheckRange` | `#7B60` | расчёт суммарного расстояния при разных направлениях, входная команда CP #24 |
| `Game.Universe.CompareObjectAxisDistance.SameSign` | `#7B63` | расчёт модуля разности при одинаковых направлениях, входная команда SUB E |

## [DispatchLinkedObjectAction](../Source/Game/Universe/DispatchLinkedObjectAction.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Universe.DispatchLinkedObjectAction.LaserHitLinks` | `#7D64` | обработка связей объекта после лазерного попадания |
| `Game.Universe.DispatchLinkedObjectAction.FindTarget` | `#7D70` | поиск метаданных поражённого объекта по обратному номеру слота |
| `Game.Universe.DispatchLinkedObjectAction.CheckType` | `#7D76` | проверка типа поражённой записи, входная команда BIT 6,(HL) |
| `Game.Universe.DispatchLinkedObjectAction.UpdateLink` | `#7D7F` | обновление общих признаков и упакованной ссылки, входная команда LD A,(#B456) |

## [DivideBodyProjectionFraction](../Source/Game/Universe/DivideBodyProjectionFraction.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Universe.DivideBodyProjectionFraction.QuotientBit` | `#783F` | подготовка счётчика и расчёт дробных разрядов, входная команда SLA E |
| `Game.Universe.DivideBodyProjectionFraction.SubDivisor` | `#784C` | вычитание делителя и установка единичного разряда частного |

## [DivideCelestialAxis](../Source/Game/Universe/DivideCelestialAxis.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Universe.DivideCelestialAxis.Normalize` | `#77AD` | нормализация случая с большим числителем, входная команда POP HL |
| `Game.Universe.DivideCelestialAxis.ShiftTriple` | `#77B4` | нормализация трёхбайтовых числителя и делителя |
| `Game.Universe.DivideCelestialAxis.WordScale` | `#77C4` | нормализация двухбайтового диапазона, входная команда LD A,#08 |
| `Game.Universe.DivideCelestialAxis.ShiftWords` | `#77C6` | нормализация двухбайтового диапазона, входная команда ADD HL,HL |
| `Game.Universe.DivideCelestialAxis.ShiftHigh` | `#77D2` | заключительная нормализация старших байтов координаты и глубины |
| `Game.Universe.DivideCelestialAxis.CompareLow` | `#77DD` | сравнение младших разрядов при равных старших словах, входная команда PUSH BC |
| `Game.Universe.DivideCelestialAxis.FirstOutside` | `#77E8` | обновление дополнительных признаков положения, входная команда SET 2,B |
| `Game.Universe.DivideCelestialAxis.MarkOutside` | `#77ED` | обновление дополнительных признаков положения, входная команда EXX |
| `Game.Universe.DivideCelestialAxis.SmallNumerator` | `#77F3` | нормализация случая с меньшим числителем, входная команда INC C |
| `Game.Universe.DivideCelestialAxis.ShiftFraction` | `#77F8` | нормализация дроби при числителе меньше делителя |
| `Game.Universe.DivideCelestialAxis.AlignDivisor` | `#780A` | согласование масштаба после переполнения, входная команда SLA B |
| `Game.Universe.DivideCelestialAxis.SubtractAxis` | `#7820` | вычитание нормализованного делителя из координаты |
| `Game.Universe.DivideCelestialAxis.RejectDivide` | `#7828` | отказ со снятием сохранённого слова и внутреннего адреса возврата, входная команда POP HL |
| `Game.Universe.DivideCelestialAxis.RejectBody` | `#782A` | общий выход недопустимой проекции, входная команда XOR A |
| `Game.Universe.DivideCelestialAxis.CarryScale` | `#782C` | общий выход недопустимой проекции, входная команда SCF |
| `Game.Universe.DivideCelestialAxis.FinishScale` | `#7831` | завершение нормализации и подготовка дробного деления, входная команда POP AF |
| `Game.Universe.DivideCelestialAxis.ScaleDivisor` | `#7836` | восстановление масштаба делителя перед дробным делением |
| `Game.Universe.DivideCelestialAxis.SetupFraction` | `#7839` | перенос старших байтов координаты и глубины в параметры деления |

## [DrawSunAndPlanet](../Source/Game/Universe/DrawSunAndPlanet.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Universe.DrawSunAndPlanet.DrawPlanet` | `#75AD` | подготовка и проекция второго светила, входная команда LD HL,FlightState.Planet |

## [ExpandNovaRadius](../Source/Game/Universe/ExpandNovaRadius.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Universe.ExpandNovaRadius.GrowRadius` | `#75CE` | расчёт расширения и проверка предела, входная команда ADD A,#02 |
| `Game.Universe.ExpandNovaRadius.KillPlayer` | `#75D4` | установка гибели при достижении предельного радиуса, входная команда LD A,#01 |
| `Game.Universe.ExpandNovaRadius.StoreRadius` | `#75DA` | сохранение нового радиуса сверхновой в проекцию и состояние игры |

## [FindInteractingObject](../Source/Game/Universe/FindInteractingObject.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Universe.FindInteractingObject.CheckLinks` | `#7C2F` | проверка двух упакованных ссылок, входная команда LD A,B |
| `Game.Universe.FindInteractingObject.SearchSlot` | `#7C48` | проверка очередного слота общего поиска взаимодействия |
| `Game.Universe.FindInteractingObject.RestoreFlags` | `#7C5A` | возврат после проверки ссылки с восстановлением HL |
| `Game.Universe.FindInteractingObject.FoundSlot` | `#7C5C` | успешное завершение поиска с восстановлением стека, входная команда POP AF |

## [GetObjectMetadataAddress](../Source/Game/Universe/GetObjectMetadataAddress.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Universe.GetObjectMetadataAddress.FindSlot` | `#7ECE` | поиск соответствующей записи шагами 39 и 10, входная команда CP L |

## [HandleFastTravelStep](../Source/Game/Universe/HandleFastTravelStep.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Universe.HandleFastTravelStep.CheckShips` | `#7EFB` | запрет быстрого переноса при наличии обычных кораблей |
| `Game.Universe.HandleFastTravelStep.StorePhase` | `#7F18` | установка признака выполненного быстрого переноса |

## [InitializeExtendedObjectMetadata](../Source/Game/Universe/InitializeExtendedObjectMetadata.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Universe.InitializeExtendedObjectMetadata.FindBlueprint` | `#7AB1` | поиск указателя модели в четырёхбайтовом каталоге, входная команда LD E,(IX+FSpaceObject.Blueprint) |
| `Game.Universe.InitializeExtendedObjectMetadata.NextBlueprint` | `#7ABA` | проверка очередной четырёхбайтовой записи каталога моделей |
| `Game.Universe.InitializeExtendedObjectMetadata.CompareModel` | `#7AC5` | проверка совпадения адреса модели, входная команда INC HL |
| `Game.Universe.InitializeExtendedObjectMetadata.StoreFlags` | `#7ADD` | запись начальных признаков расширенных метаданных объекта |
| `Game.Universe.InitializeExtendedObjectMetadata.RandomBitFour` | `#7AF7` | случайная настройка бита 4 расширенных признаков |
| `Game.Universe.InitializeExtendedObjectMetadata.CheckBitFive` | `#7B03` | проверка бита 5 перед учётом наличия станции |
| `Game.Universe.InitializeExtendedObjectMetadata.ReadLaserPoint` | `#7B14` | чтение проекции лазерной вершины модели в расширенные метаданные |

## [MoveCoordinateDepthBy32](../Source/Game/Universe/MoveCoordinateDepthBy32.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Universe.MoveCoordinateDepthBy32.MoveNegative` | `#7F42` | увеличение модуля отрицательной глубины на 32 |
| `Game.Universe.MoveCoordinateDepthBy32.StoreDepth` | `#7F45` | сохранение перенесённой целой глубины объекта |
| `Game.Universe.MoveCoordinateDepthBy32.CrossOrigin` | `#7F4C` | расчёт отрицательной глубины после перехода через ноль, входная команда LD HL,#2000 |
| `Game.Universe.MoveCoordinateDepthBy32.DepthOverflow` | `#7F61` | передача переполнения общему обработчику, входная команда JP #5FD5 |

## [ProjectCelestialBody](../Source/Game/Universe/ProjectCelestialBody.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Universe.ProjectCelestialBody.DivideFrontX` | `#7612` | деление модуля горизонтальной координаты X на глубину Z |
| `Game.Universe.ProjectCelestialBody.DivideFrontY` | `#7634` | деление модуля вертикальной координаты Y на глубину Z |
| `Game.Universe.ProjectCelestialBody.RadiusFromZ` | `#7659` | проверка предельной глубины и нормализация делителя радиуса, входная команда LD HL,#A000 |
| `Game.Universe.ProjectCelestialBody.NormalizeZ` | `#7674` | согласованная нормализация глубины Z и масштаба радиуса |
| `Game.Universe.ProjectCelestialBody.DivideZRadius` | `#767F` | деление нормализованного масштаба радиуса на глубину Z |
| `Game.Universe.ProjectCelestialBody.ByteZRadius` | `#7688` | короткое деление радиуса при нулевом старшем байте глубины, входная команда LD A,(Game.Flight.MainGameLoop.BodyZ+FCoordinate.Low) |
| `Game.Universe.ProjectCelestialBody.CommitFront` | `#7692` | передача радиуса переднего или заднего вида общему сохранению |
| `Game.Universe.ProjectCelestialBody.RearView` | `#7695` | отдельная ветвь заднего вида, входная команда DEC A |
| `Game.Universe.ProjectCelestialBody.ReuseFrontX` | `#76C0` | общий вход горизонтальной проекции заднего вида |
| `Game.Universe.ProjectCelestialBody.SideView` | `#76C3` | отдельная ветвь первого бокового вида, входная команда DEC A |
| `Game.Universe.ProjectCelestialBody.DivideSideX` | `#76EC` | деление модуля горизонтальной координаты Z на боковую глубину X |
| `Game.Universe.ProjectCelestialBody.DivideSideY` | `#770E` | деление модуля вертикальной координаты Y на боковую глубину X |
| `Game.Universe.ProjectCelestialBody.RadiusFromX` | `#7733` | проверка боковой глубины X перед вычислением радиуса светила |
| `Game.Universe.ProjectCelestialBody.NormalizeX` | `#774E` | согласованная нормализация боковой глубины X и масштаба радиуса |
| `Game.Universe.ProjectCelestialBody.DivideXRadius` | `#775A` | деление нормализованного масштаба радиуса на глубину X |
| `Game.Universe.ProjectCelestialBody.ByteXRadius` | `#7763` | деление радиуса на однобайтовую глубину X |
| `Game.Universe.ProjectCelestialBody.CommitSide` | `#776D` | передача радиуса бокового вида общему сохранению |
| `Game.Universe.ProjectCelestialBody.OtherSide` | `#7770` | отдельная ветвь второго бокового вида, входная команда LD A,(Game.Flight.MainGameLoop.BodyX+FCoordinate.SignHigh) |
| `Game.Universe.ProjectCelestialBody.ReuseSideX` | `#7790` | общий вход горизонтальной проекции второго бокового вида |
| `Game.Universe.ProjectCelestialBody.StoreRadius` | `#7793` | сохранение радиуса и подтверждение допустимой проекции, входная команда LD (#861D),A |

## [SelectGalaxyOnJump](../Source/Game/Universe/SelectGalaxyOnJump.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Universe.SelectGalaxyOnJump.SelectGalaxy` | `#7A0D` | сохранение выбранного номера галактики для расчёта сдвигов семени |
| `Game.Universe.SelectGalaxyOnJump.CountRotations` | `#7A0E` | расчёт количества преобразований относительно прежнего номера, входная команда LD A,C |
| `Game.Universe.SelectGalaxyOnJump.StoreGalaxy` | `#7A14` | запись номера галактики и числа необходимых преобразований |
| `Game.Universe.SelectGalaxyOnJump.RotateGalaxy` | `#7A19` | преобразование исходных данных галактики тремя проходами на шаг, входная команда LD B,#03 |
| `Game.Universe.SelectGalaxyOnJump.RotateWord` | `#7A1E` | преобразование исходных данных галактики тремя проходами на шаг, входная команда CALL Game.Travel.RotateTwoSeedBytesAdvance.Entry |

## [SelectSpecialCargoText](../Source/Game/Universe/SelectSpecialCargoText.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Universe.SelectSpecialCargoText.SelectToken` | `#7A33` | выбор текста специального груза с сохранением переноса проверки |

## [SpawnDestructionContentsAndEffects](../Source/Game/Universe/SpawnDestructionContentsAndEffects.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Universe.SpawnDestructionContentsAndEffects.NormalLoot` | `#7DDD` | выбор обычного содержимого по полям модели, входная команда LD H,(IX+FSpaceObject.Blueprint+1) |
| `Game.Universe.SpawnDestructionContentsAndEffects.SpawnAction` | `#7DFF` | передача выбранного действия диспетчеру объектов, входная команда JP Game.Objects.DispatchObjectAction.Entry |
| `Game.Universe.SpawnDestructionContentsAndEffects.RenderEffects` | `#7E02` | выбор взрыва либо расширенного эффекта после проекции объекта |
| `Game.Universe.SpawnDestructionContentsAndEffects.CheckEffects` | `#7E0D` | проверка типа кругового либо энергетического эффекта, входная команда LD HL,(#B452) |
| `Game.Universe.SpawnDestructionContentsAndEffects.SelectBit` | `#7E38` | выбор разряда состояния по маске энергии |
| `Game.Universe.SpawnDestructionContentsAndEffects.FindMaskBit` | `#7E39` | поиск младшего установленного разряда энергетической маски |
| `Game.Universe.SpawnDestructionContentsAndEffects.ApplyEnergy` | `#7E40` | изменение энергии по выбранному биту расширенной записи |
| `Game.Universe.SpawnDestructionContentsAndEffects.CircleRadius` | `#7E4E` | расчёт радиуса и количества концентрических окружностей, входная команда LD A,(HL) |
| `Game.Universe.SpawnDestructionContentsAndEffects.MinimumRadius` | `#7E5C` | ограничение радиуса кругового эффекта снизу значением 4 |
| `Game.Universe.SpawnDestructionContentsAndEffects.CircleCenter` | `#7E5E` | подготовка центра и знаков кругового эффекта |
| `Game.Universe.SpawnDestructionContentsAndEffects.PackSigns` | `#7E6A` | упаковка знаков центра окружности |
| `Game.Universe.SpawnDestructionContentsAndEffects.CircleCount` | `#7E89` | определение числа концентрических окружностей по фазе |
| `Game.Universe.SpawnDestructionContentsAndEffects.DrawRing` | `#7E8C` | вывод очередной окружности и увеличение радиуса, входная команда PUSH BC |
| `Game.Universe.SpawnDestructionContentsAndEffects.CheckWireframe` | `#7E9D` | выбор обычного каркаса либо скрытого завершения, входная команда JP C,#A7D9 |
| `Game.Universe.SpawnDestructionContentsAndEffects.FinishObject` | `#7EA6` | завершение вывода объекта после специального эффекта |

## [TryObjectInteraction](../Source/Game/Universe/TryObjectInteraction.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Universe.TryObjectInteraction.CompareGroups` | `#7BA7` | проверка различия групп и разрешающих признаков, входная команда LD E,A |
| `Game.Universe.TryObjectInteraction.CheckDistance` | `#7BBE` | проверка близости по трём целым координатам, входная команда PUSH IY |
| `Game.Universe.TryObjectInteraction.SetEnergy` | `#7C0C` | установка единичной энергии взаимодействующего объекта |

## [UpdateAndDrawStarField](../Source/Game/Universe/UpdateAndDrawStarField.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Universe.UpdateAndDrawStarField.ClearStars` | `#78C0` | сброс шестнадцати знако-модульных координат звёзд |
| `Game.Universe.UpdateAndDrawStarField.ViewMotion` | `#78C5` | расчёт коэффициентов скорости и поворота для выбранного вида, входная команда LD B,#00 |
| `Game.Universe.UpdateAndDrawStarField.SelectTurn` | `#78D7` | выбор оси поворота по направлению обзора |
| `Game.Universe.UpdateAndDrawStarField.ReadTurn` | `#78DD` | чтение угла поворота и подготовка бокового масштаба |
| `Game.Universe.UpdateAndDrawStarField.StoreTurn` | `#78E9` | сохранение рассчитанного угла звёздного поля |
| `Game.Universe.UpdateAndDrawStarField.SelectCount` | `#790C` | выбор количества звёзд по режиму пространства, входная команда LD A,(FlightState.SpaceMode) |
| `Game.Universe.UpdateAndDrawStarField.StartStars` | `#7916` | подготовка прохода по выбранному количеству звёзд |
| `Game.Universe.UpdateAndDrawStarField.MoveStar` | `#791A` | начало пересчёта очередной знако-модульной пары, входная команда PUSH AF |
| `Game.Universe.UpdateAndDrawStarField.ApplyShift` | `#797B` | применение бокового переноса и проверка центральной области, входная команда POP DE |
| `Game.Universe.UpdateAndDrawStarField.AddJitter` | `#7992` | добавление дрожания по регистру R, входная команда LD A,R |
| `Game.Universe.UpdateAndDrawStarField.NextStar` | `#79A4` | завершение пересчёта звезды и переход к следующей паре координат |
| `Game.Universe.UpdateAndDrawStarField.CheckStar` | `#79AC` | проверка диапазона и пересоздание выбывших звёзд, входная команда PUSH AF |
| `Game.Universe.UpdateAndDrawStarField.RespawnStar` | `#79BA` | создание новых случайных координат звезды, вышедшей из поля |
| `Game.Universe.UpdateAndDrawStarField.NextCheck` | `#79C8` | продолжение проверки звёзд после обработки текущей пары |
| `Game.Universe.UpdateAndDrawStarField.DrawStar` | `#79CD` | расчёт экранных координат и вывод пикселей, входная команда PUSH BC |
| `Game.Universe.UpdateAndDrawStarField.PositiveX` | `#79DD` | положительная ветвь перевода X звезды в экранную координату |
| `Game.Universe.UpdateAndDrawStarField.ScreenX` | `#79DE` | ограничение экранной координаты X семью битами |
| `Game.Universe.UpdateAndDrawStarField.PositiveY` | `#79EB` | положительная ветвь перевода Y звезды в экранную координату |
| `Game.Universe.UpdateAndDrawStarField.DrawPixel` | `#79EE` | передача рассчитанной точки процедуре XOR-пикселя |
| `Game.Universe.UpdateAndDrawStarField.NextPixel` | `#79F4` | переход к следующей звезде после вывода или отсечения |

## [UpdateExtendedObjectEffects](../Source/Game/Universe/UpdateExtendedObjectEffects.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Universe.UpdateExtendedObjectEffects.StartSlots` | `#7C6D` | подготовка синхронного обхода восьми объектов, входная команда LD IX,#6048 |
| `Game.Universe.UpdateExtendedObjectEffects.ProcessSlot` | `#7C76` | проверка типа записи и таймера взаимодействия, входная команда PUSH AF |
| `Game.Universe.UpdateExtendedObjectEffects.TickTimer` | `#7C88` | уменьшение таймера расширенного эффекта |
| `Game.Universe.UpdateExtendedObjectEffects.CheckEnergy` | `#7CB8` | проверка энергии и случайных условий запуска эффекта, входная команда LD A,(IX+FSpaceObject.Energy) |
| `Game.Universe.UpdateExtendedObjectEffects.ExactChance` | `#7CCC` | дополнительная проверка точного совпадения случайного числа с порогом |
| `Game.Universe.UpdateExtendedObjectEffects.MaskChance` | `#7CD2` | проверка случайного числа через выбранную маску |
| `Game.Universe.UpdateExtendedObjectEffects.CheckChance` | `#7CD6` | выбор кругового эффекта по сохранённому нулевому результату |
| `Game.Universe.UpdateExtendedObjectEffects.FindPartner` | `#7CD8` | поиск участника взаимодействия с временным снятием bit7, входная команда RES 7,(HL) |
| `Game.Universe.UpdateExtendedObjectEffects.CheckCarry` | `#7CDF` | продолжение по переносу, указывающему успешное взаимодействие |
| `Game.Universe.UpdateExtendedObjectEffects.LoopOrDraw` | `#7CE1` | двойной вход продолжения итерации либо вывода эффекта, входная команда JR NC,#7C76 |
| `Game.Universe.UpdateExtendedObjectEffects.CheckEndpoint` | `#7D10` | проверка допустимости второго экранного конца эффекта |
| `Game.Universe.UpdateExtendedObjectEffects.PackLine` | `#7D1C` | упаковка знаков и вывод линии эффекта, входная команда LD A,B |
| `Game.Universe.UpdateExtendedObjectEffects.RestoreRecord` | `#7D28` | восстановление адреса расширенной записи после вывода линии |
| `Game.Universe.UpdateExtendedObjectEffects.NextSlot` | `#7D29` | переход к следующему объекту и записи, входная команда LD DE,#0027 |
| `Game.Universe.UpdateExtendedObjectEffects.StartCircle` | `#7D37` | создание кругового эффекта A0, входная команда LD (HL),#A0 |

## [UpdateStationCoordinates](../Source/Game/Universe/UpdateStationCoordinates.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Universe.UpdateStationCoordinates.UpdateStation` | `#7874` | пересчёт станции и проверка старших разрядов координат, входная команда CALL Game.Extensions.UpdateStationAndSpecialShips.Entry |
| `Game.Universe.UpdateStationCoordinates.CheckNearFlag` | `#7889` | проверка особого старшего флага перед переводом станции в ближний режим |

## [AddRotatedVertexCoordinate](../Source/Game/Wireframe/AddRotatedVertexCoordinate.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Wireframe.AddRotatedVertexCoordinate.SubtractVertex` | `#AB5B` | вычитание вершины с противоположным знаком |
| `Game.Wireframe.AddRotatedVertexCoordinate.CheckFraction` | `#AB66` | проверка коррекции дробной части разности |

## [AddSignedByteMagnitudes](../Source/Game/Wireframe/AddSignedByteMagnitudes.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Wireframe.AddSignedByteMagnitudes.SubtractTerms` | `#AB03` | вычитание модулей с противоположными знаками |

## [AdvanceNormalFlags](../Source/Game/Wireframe/AdvanceNormalFlags.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Wireframe.AdvanceNormalFlags.StoreFlags` | `#AE2D` | сохранение указателя следующей записи признаков |

## [BuildProjectedVertexTable](../Source/Game/Wireframe/BuildProjectedVertexTable.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Wireframe.BuildProjectedVertexTable.ProjectVertex` | `#A9DE` | обработка очередной вершины модели |
| `Game.Wireframe.BuildProjectedVertexTable.CheckFaces` | `#A9F7` | проверка видимости пар граней вершины |
| `Game.Wireframe.BuildProjectedVertexTable.SelectVertex` | `#AA03` | выбор пропуска или проекции по флагам проверки граней |

## [CorrectYAxisComponent](../Source/Game/Wireframe/CorrectYAxisComponent.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Wireframe.CorrectYAxisComponent.SubtractTerm` | `#AEB6` | вычитание корректирующего произведения из оси Y |
| `Game.Wireframe.CorrectYAxisComponent.PackComponent` | `#AEBD` | упаковка исправленной компоненты оси Y |

## [CrossProductComponent](../Source/Game/Wireframe/CrossProductComponent.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Wireframe.CrossProductComponent.SubtractTerms` | `#AF51` | вычитание произведений с одинаковыми знаками |
| `Game.Wireframe.CrossProductComponent.PackProduct` | `#AF5E` | упаковка знака компоненты векторного произведения |
| `Game.Wireframe.CrossProductComponent.AddCrossTerm` | `#AF88` | добавление второго перекрёстного произведения |
| `Game.Wireframe.CrossProductComponent.AddHighWord` | `#AF9B` | добавление старших разрядов произведения |

## [DivideFractionAndProjectVertex](../Source/Game/Wireframe/DivideFractionAndProjectVertex.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Wireframe.DivideFractionAndProjectVertex.SubtractDiv` | `#AC98` | вычитание делителя и установка очередного бита частного |
| `Game.Wireframe.DivideFractionAndProjectVertex.Project` | `#ACA2` | отдельный вход проекции вершины |
| `Game.Wireframe.DivideFractionAndProjectVertex.FindScale` | `#ACB8` | поиск предварительного масштаба ближней вершины |
| `Game.Wireframe.DivideFractionAndProjectVertex.AddObjectPos` | `#ACDF` | переход к сложению вершины с координатами объекта |
| `Game.Wireframe.DivideFractionAndProjectVertex.ProjectSide` | `#AD82` | расчёт бокового вида вершины |
| `Game.Wireframe.DivideFractionAndProjectVertex.PackSigns` | `#ADB5` | упаковка знаков и зеркалирование проекции |
| `Game.Wireframe.DivideFractionAndProjectVertex.StoreSigns` | `#ADC5` | сохранение знаков и вычисление адреса записи вершины |
| `Game.Wireframe.DivideFractionAndProjectVertex.StorePosition` | `#ADD4` | запись двух экранных координат вершины |
| `Game.Wireframe.DivideFractionAndProjectVertex.StoreHidden` | `#ADEE` | запись признака скрытой вершины |
| `Game.Wireframe.DivideFractionAndProjectVertex.NextVertex` | `#ADF2` | переход к следующей вершине модели |

## [DivideProjectionRatio](../Source/Game/Wireframe/DivideProjectionRatio.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Wireframe.DivideProjectionRatio.NormalizeRatio` | `#AC6B` | согласование масштаба делимого и делителя |
| `Game.Wireframe.DivideProjectionRatio.UndoOverflow` | `#AC80` | отмена переполнившего сдвига делителя |
| `Game.Wireframe.DivideProjectionRatio.CheckSaturate` | `#AC84` | проверка насыщения перед дробным делением |

## [DivideSlopeAndDrawScanner](../Source/Game/Wireframe/DivideSlopeAndDrawScanner.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Wireframe.DivideSlopeAndDrawScanner.Normalize` | `#B2B0` | нормирование знаменателя до масштаба числителя |
| `Game.Wireframe.DivideSlopeAndDrawScanner.CarryKeep` | `#B2B9` | перекрывающаяся инструкция LD A,#A7, сохраняющая перенос нормирования |
| `Game.Wireframe.DivideSlopeAndDrawScanner.ClearCarry` | `#B2BA` | вход AND A во второй байт инструкции LD A,#A7 |
| `Game.Wireframe.DivideSlopeAndDrawScanner.DivideInteger` | `#B2BB` | деление очередного разряда целой части наклона |
| `Game.Wireframe.DivideSlopeAndDrawScanner.DivideFraction` | `#B2CB` | расчёт дробной части наклона |
| `Game.Wireframe.DivideSlopeAndDrawScanner.FractionBit` | `#B2D5` | деление очередного дробного разряда наклона |
| `Game.Wireframe.DivideSlopeAndDrawScanner.SubtractDiv` | `#B2E3` | вычитание знаменателя и установка бита частного |
| `Game.Wireframe.DivideSlopeAndDrawScanner.RatioReady` | `#B2E9` | возврат наклона в формате 8.8 |
| `Game.Wireframe.DivideSlopeAndDrawScanner.DrawMarker` | `#B2EF` | отдельный вход альтернативного маркера сканера |
| `Game.Wireframe.DivideSlopeAndDrawScanner.NormalizeAxes` | `#B2F9` | нормирование координат маркера по длине вектора |
| `Game.Wireframe.DivideSlopeAndDrawScanner.AddCenterY` | `#B31C` | прибавление вертикального смещения к центру сканера |
| `Game.Wireframe.DivideSlopeAndDrawScanner.StoreRow` | `#B31D` | учёт смещения сканера и сохранение строки маркера |
| `Game.Wireframe.DivideSlopeAndDrawScanner.SubtractX` | `#B332` | вычитание горизонтального смещения из центра |
| `Game.Wireframe.DivideSlopeAndDrawScanner.StoreColumn` | `#B333` | учёт смещения сканера и сохранение столбца маркера |
| `Game.Wireframe.DivideSlopeAndDrawScanner.CheckMidRange` | `#B342` | проверка средних разрядов дальности для размера маркера |
| `Game.Wireframe.DivideSlopeAndDrawScanner.CheckNearRange` | `#B349` | проверка младших разрядов дальности для размера маркера |
| `Game.Wireframe.DivideSlopeAndDrawScanner.SpreadMarkers` | `#B34F` | разведение маркеров по адресу слота |
| `Game.Wireframe.DivideSlopeAndDrawScanner.DrawCenter` | `#B35A` | настройка прямого экрана и вывод центра маркера |
| `Game.Wireframe.DivideSlopeAndDrawScanner.RearMarker` | `#B37B` | вывод развёрнутого маркера задней полусферы |
| `Game.Wireframe.DivideSlopeAndDrawScanner.LastSegment` | `#B389` | вывод последнего отрезка и восстановление пиксельного обработчика |

## [DrawClippedLine](../Source/Game/Wireframe/DrawClippedLine.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Wireframe.DrawClippedLine.CheckXSide` | `#B05D` | проверка общей внешней стороны отрезка по X |
| `Game.Wireframe.DrawClippedLine.SubtractY` | `#B07A` | разность модулей Y концов с одинаковыми знаками |
| `Game.Wireframe.DrawClippedLine.IncludeLastY` | `#B07F` | учёт последней строки в вертикальной протяжённости |
| `Game.Wireframe.DrawClippedLine.StoreYSpan` | `#B081` | сохранение вертикальной протяжённости отрезка |
| `Game.Wireframe.DrawClippedLine.SubtractX` | `#B08A` | разность модулей X концов с одинаковыми знаками |
| `Game.Wireframe.DrawClippedLine.StoreXSpan` | `#B090` | сохранение горизонтальной протяжённости отрезка |
| `Game.Wireframe.DrawClippedLine.SubtractYClip` | `#B0D1` | уменьшение модуля Y при отсечении по X |
| `Game.Wireframe.DrawClippedLine.StoreYClip` | `#B0D7` | сохранение Y без перехода через ось |
| `Game.Wireframe.DrawClippedLine.FlipYSign` | `#B0DA` | смена знака Y после пересечения оси |
| `Game.Wireframe.DrawClippedLine.ClipXDone` | `#B0DF` | установка горизонтальной границы и повторное отсечение |
| `Game.Wireframe.DrawClippedLine.MeasureYClip` | `#B0EE` | расчёт выхода за вертикальную границу |
| `Game.Wireframe.DrawClippedLine.SubtractXClip` | `#B111` | уменьшение модуля X при отсечении по Y |
| `Game.Wireframe.DrawClippedLine.StoreXClip` | `#B117` | сохранение X без перехода через ось |
| `Game.Wireframe.DrawClippedLine.FlipXSign` | `#B11A` | смена знака X после пересечения оси |
| `Game.Wireframe.DrawClippedLine.ClipYDone` | `#B11F` | установка вертикальной границы и повторное отсечение |
| `Game.Wireframe.DrawClippedLine.CompareX` | `#B12D` | сравнение модулей X при одинаковых знаках |
| `Game.Wireframe.DrawClippedLine.CheckSwap` | `#B133` | проверка необходимости перестановки концов |
| `Game.Wireframe.DrawClippedLine.CompareY` | `#B147` | сравнение модулей Y для направления строк |
| `Game.Wireframe.DrawClippedLine.SelectRowStep` | `#B14D` | выбор растрового шага вверх или вниз |
| `Game.Wireframe.DrawClippedLine.SaveDirection` | `#B153` | сохранение кода направления растрового шага |
| `Game.Wireframe.DrawClippedLine.AddCenterY` | `#B15E` | прибавление вертикального модуля к центру обзора |
| `Game.Wireframe.DrawClippedLine.PixelYReady` | `#B15F` | сохранение пиксельной строки конца отрезка |
| `Game.Wireframe.DrawClippedLine.SubtractPixelX` | `#B169` | вычитание горизонтального модуля из центра обзора |
| `Game.Wireframe.DrawClippedLine.PixelXReady` | `#B16A` | сохранение пиксельного столбца конца отрезка |
| `Game.Wireframe.DrawClippedLine.PrepareSlope` | `#B180` | подготовка дробного наклона растрового отрезка |
| `Game.Wireframe.DrawClippedLine.PatchSteep` | `#B19D` | настройка дробного шага крутого отрезка |
| `Game.Wireframe.DrawClippedLine.SteepRowJump` | `#B1C6` | изменяемая ветвь направления смены знакоместа |
| `Game.Wireframe.DrawClippedLine.AddRunError` | `#B211` | добавление дробного остатка длины группы |
| `Game.Wireframe.DrawClippedLine.GroupReady` | `#B216` | сохранение ошибки и расчёт границы следующей группы |
| `Game.Wireframe.DrawClippedLine.SelectRunMask` | `#B22B` | выбор маски конечного байта группы пикселей |
| `Game.Wireframe.DrawClippedLine.NextRunByte` | `#B255` | переход к байту начала следующей группы |
| `Game.Wireframe.DrawClippedLine.LoadNextBit` | `#B25C` | восстановление начального бита следующей строки |

## [DrawScannerMarkerSegment](../Source/Game/Wireframe/DrawScannerMarkerSegment.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Wireframe.DrawScannerMarkerSegment.DrawPixel` | `#B446` | изменяемый шаг координат и вывод очередного пикселя отрезка |

## [DrawWireframeObject](../Source/Game/Wireframe/DrawWireframeObject.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Wireframe.DrawWireframeObject.SubtractDetail` | `#A861` | вычитание базового смещения уровня детализации |
| `Game.Wireframe.DrawWireframeObject.StoreDetail` | `#A867` | сохранение уровня детализации и подготовка геометрии |
| `Game.Wireframe.DrawWireframeObject.CheckLaser` | `#A878` | проверка одноразового запроса лазерного луча |
| `Game.Wireframe.DrawWireframeObject.DrawLaser` | `#A884` | отдельный вход вывода лазерного луча объекта |
| `Game.Wireframe.DrawWireframeObject.ClearLaser` | `#A8A7` | сброс одноразового запроса лазерного луча |

## [LocateFaceNormalData](../Source/Game/Wireframe/LocateFaceNormalData.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Wireframe.LocateFaceNormalData.StoreStream` | `#AE16` | сохранение указателя потока признаков нормалей |

## [MultiplyBytesApprox](../Source/Game/Wireframe/MultiplyBytesApprox.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Wireframe.MultiplyBytesApprox.HalfDifference` | `#AB3A` | расчёт индекса половины разности для таблицы квадратов |

## [MultiplyClippingDistance](../Source/Game/Wireframe/MultiplyClippingDistance.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Wireframe.MultiplyClippingDistance.CheckBits` | `#B28C` | проверка остатка множителя расстояния |
| `Game.Wireframe.MultiplyClippingDistance.MultiplyBit` | `#B28F` | добавление вклада очередного бита расстояния |
| `Game.Wireframe.MultiplyClippingDistance.ShiftProduct` | `#B297` | сдвиг частичного произведения |
| `Game.Wireframe.MultiplyClippingDistance.Saturate` | `#B29A` | насыщение произведения при переполнении |
| `Game.Wireframe.MultiplyClippingDistance.OverflowSkip` | `#B29B` | перекрывающаяся инструкция CP, сохраняющая насыщенный результат |
| `Game.Wireframe.MultiplyClippingDistance.ProductHigh` | `#B29C` | вход LD A,D во второй байт инструкции CP |

## [MultiplyHighByteApprox](../Source/Game/Wireframe/MultiplyHighByteApprox.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Wireframe.MultiplyHighByteApprox.HalfDifference` | `#AB11` | расчёт индекса половины разности для таблицы квадратов |

## [MultiplyScaledVertexComponent](../Source/Game/Wireframe/MultiplyScaledVertexComponent.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Wireframe.MultiplyScaledVertexComponent.ScaleComponent` | `#AB21` | предварительное масштабирование компоненты вершины |

## [ReadProjectedVertex](../Source/Game/Wireframe/ReadProjectedVertex.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Wireframe.ReadProjectedVertex.AddThirdIndex` | `#AE58` | расчёт трёхбайтового смещения вершины |
| `Game.Wireframe.ReadProjectedVertex.AddTableBase` | `#AE5C` | добавление базы таблицы проекций |
| `Game.Wireframe.ReadProjectedVertex.ReadPosition` | `#AE61` | чтение экранной позиции и признака скрытой вершины |

## [RefreshScannerBackground](../Source/Game/Wireframe/RefreshScannerBackground.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Wireframe.RefreshScannerBackground.ReadControl` | `#B3C2` | чтение управляющего байта восстановления фона |
| `Game.Wireframe.RefreshScannerBackground.FindBlock` | `#B3CD` | поиск блока по младшему установленному биту |
| `Game.Wireframe.RefreshScannerBackground.CopyBlockRow` | `#B3D1` | перенос очередной строки блока фона |
| `Game.Wireframe.RefreshScannerBackground.CopyBackground` | `#B3EA` | восстановление обычного фона сканера |
| `Game.Wireframe.RefreshScannerBackground.SetAttributes` | `#B3EF` | обновление атрибутов индикатора |
| `Game.Wireframe.RefreshScannerBackground.NextAttribute` | `#B3F4` | чтение следующей позиции таблицы атрибутов |

## [RotateDistantVertex](../Source/Game/Wireframe/RotateDistantVertex.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Wireframe.RotateDistantVertex.RebuildCache` | `#AB90` | полный расчёт дальней вершины |
| `Game.Wireframe.RotateDistantVertex.StoreZ` | `#AB9F` | сохранение третьей компоненты дальней вершины |

## [RotateNearVertexComponent](../Source/Game/Wireframe/RotateNearVertexComponent.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Wireframe.RotateNearVertexComponent.RebuildCache` | `#AA8B` | полный расчёт трёх произведений ближней вершины |
| `Game.Wireframe.RotateNearVertexComponent.RestoreScale` | `#AAE3` | обратное масштабирование ближней компоненты |
| `Game.Wireframe.RotateNearVertexComponent.ShiftFraction` | `#AAEB` | возврат разрядов компоненты с сохранением дробной части |
| `Game.Wireframe.RotateNearVertexComponent.RestoreSign` | `#AAF5` | восстановление знака повёрнутой компоненты |

## [StartObjectExplosion](../Source/Game/Wireframe/StartObjectExplosion.asm)

| Метка | Адрес | Назначение |
|---|---|---|
| `Game.Wireframe.StartObjectExplosion.PackCenterSign` | `#A8CA` | упаковка знаков центра взрыва |

