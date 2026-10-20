# Указатель игрового исходника

Файловый диапазон `#4000..#FFFF` покрыт 598 фрагментами.
Это число файлов, а не число логических процедур. Отдельные файлы содержат
дополнительные входы, таблицы или продолжения соседних процедур.
В исходниках указаны регистры, алгоритм, специальные входы и изменяемые данные.

Исходные адреса сохранены. Имена обозначают проверенное действие, смысловые
метки переходов и контрольные ASSERT позволяют сопоставить код с оригиналом.

В текущей разметке 15165 инструкций, 28972 байтов кода,
8548 байтов литеральных данных и перекрытий, 11632 байтов внешних ресурсов.

| Подсистема | Файлов |
|---|---:|
| Charts | 9 |
| Circles | 42 |
| Combat | 35 |
| Data | 5 |
| Disk | 8 |
| Economy | 13 |
| Extensions | 39 |
| Flight | 41 |
| Galaxy | 19 |
| Input | 13 |
| Interface | 8 |
| Math | 5 |
| Menus | 29 |
| Missions | 8 |
| Motion | 32 |
| Objects | 26 |
| Resources | 5 |
| Scanner | 13 |
| Screen | 54 |
| Sound | 14 |
| Text | 31 |
| Trade | 60 |
| Travel | 16 |
| Universe | 33 |
| Wireframe | 40 |

## Charts

| Адреса | Исходник | Назначение |
|---|---|---|
| `#E398..#E3CB` | [FindSystemNameDialog](../Source/Game/Charts/FindSystemNameDialog.asm) | Диалог поиска планеты по введённому имени |
| `#E3CC..#E3E6` | [BeginTextInput](../Source/Game/Charts/BeginTextInput.asm) | Подготовка строкового ввода с ограничением длины |
| `#E3E7..#E46E` | [TextInputLoop](../Source/Game/Charts/TextInputLoop.asm) | Обработка букв, цифр, удаления и завершения ввода |
| `#E46F..#E52D` | [MapCursorTransformAndKeys](../Source/Game/Charts/MapCursorTransformAndKeys.asm) | Преобразование координат малого курсора и обработчики его движения |
| `#E52E..#E610` | [XorMapCrosshair](../Source/Game/Charts/XorMapCrosshair.asm) | Рисование горизонтальной и вертикальной частей перекрестия |
| `#E611..#E618` | [BuildHighBitRun](../Source/Game/Charts/BuildHighBitRun.asm) | Построение маски из старших единичных битов |
| `#E619..#E620` | [BuildLowBitRun](../Source/Game/Charts/BuildLowBitRun.asm) | Построение маски из младших единичных битов |
| `#E621..#E6A2` | [PixelAddressAndVerticalCrosshair](../Source/Game/Charts/PixelAddressAndVerticalCrosshair.asm) | Пиксельный адрес Spectrum и вертикальная часть перекрестия |
| `#E6A3..#E6C5` | [NextScreenCharacterRowAndRefugees](../Source/Game/Charts/NextScreenCharacterRowAndRefugees.asm) | Переход между восьмистрочными блоками экрана |

## Circles

| Адреса | Исходник | Назначение |
|---|---|---|
| `#86EE..#87BE` | [DispatchClippedCircle](../Source/Game/Circles/DispatchClippedCircle.asm) | выбор участка круга по четырём границам области обзора |
| `#87C8..#87D3` | [DrawUnclippedCircle](../Source/Game/Circles/DrawUnclippedCircle.asm) | вывод двух половин круга без бокового отсечения |
| `#87D4..#87F3` | [PrepareUnclippedCircle](../Source/Game/Circles/PrepareUnclippedCircle.asm) | адреса и маски строки диаметра неотсечённого круга |
| `#87F4..#883F` | [DrawWideCircleAcrossBothSides](../Source/Game/Circles/DrawWideCircleAcrossBothSides.asm) | широкий круг с обеими боковыми границами внутри круга |
| `#8840..#888D` | [DrawCornerWideCircle](../Source/Game/Circles/DrawCornerWideCircle.asm) | широкий круг с вертикальным и боковым отсечением |
| `#888E..#88B7` | [DrawOneSideClippedCircle](../Source/Game/Circles/DrawOneSideClippedCircle.asm) | две половины круга с единственным боковым отсечением |
| `#88B8..#893E` | [DrawCornerClippedArc](../Source/Game/Circles/DrawCornerClippedArc.asm) | дуга круга при одновременном вертикальном и боковом отсечении |
| `#893F..#8984` | [DrawVerticalClippedCircle](../Source/Game/Circles/DrawVerticalClippedCircle.asm) | дуга с вертикальным отсечением без бокового отсечения |
| `#8985..#89A0` | [PrepareRightClippedCircle](../Source/Game/Circles/PrepareRightClippedCircle.asm) | подготовка строки круга с отсечённым правым краем |
| `#89A1..#89C2` | [PrepareLeftClippedCircle](../Source/Game/Circles/PrepareLeftClippedCircle.asm) | подготовка строки круга с отсечённым левым краем |
| `#89C3..#89D3` | [LoadCircleIterationCoordinates](../Source/Game/Circles/LoadCircleIterationCoordinates.asm) | загрузка исходных координат итератора дуги |
| `#89D4..#89EE` | [ComputeLeftEdgeMask](../Source/Game/Circles/ComputeLeftEdgeMask.asm) | расчёт экранного адреса и маски левой границы |
| `#89EF..#8A15` | [ComputeRightEdgeMask](../Source/Game/Circles/ComputeRightEdgeMask.asm) | расчёт экранного адреса и маски правой границы |
| `#8A16..#8A24` | [PrepareBothClippedCoordinates](../Source/Game/Circles/PrepareBothClippedCoordinates.asm) | координаты итератора для двух отсечённых боковых границ |
| `#8A25..#8AA2` | [PrepareBothClippedMasksAndFillRows](../Source/Game/Circles/PrepareBothClippedMasksAndFillRows.asm) | маски двух отсечённых краёв и общий заполнитель полных строк |
| `#8AA3..#8ACC` | [UpdateThargoidAndBodyCoords](../Source/Game/Circles/UpdateThargoidAndBodyCoords.asm) | счётчик поражений Thargoid и координаты двух далёких тел |
| `#8ACD..#8AF6` | [IntegerCircleCathetus](../Source/Game/Circles/IntegerCircleCathetus.asm) | целочисленный катет по радиусу и смещению |
| `#8AF7..#8B29` | [BeginFilledUnclippedHalf](../Source/Game/Circles/BeginFilledUnclippedHalf.asm) | вход заливки половины круга без бокового отсечения |
| `#8B2A..#8B3E` | [ScanUpgradeKeyRow](../Source/Game/Circles/ScanUpgradeKeyRow.asm) | проверка пяти клавиш ряда для улучшенного корабля |
| `#8B3F..#8C28` | [SetCabinHeatAndContinueFilledCircle](../Source/Game/Circles/SetCabinHeatAndContinueFilledCircle.asm) | сохранение нагрева и продолжения заливки круга |
| `#8C29..#8C3B` | [DetachMissileTarget](../Source/Game/Circles/DetachMissileTarget.asm) | снятие цели ракеты после исчезновения объекта |
| `#8C3C..#8D2A` | [SelectJumpAndContinueLeftFill](../Source/Game/Circles/SelectJumpAndContinueLeftFill.asm) | выбор условия гиперперехода и продолжение левой заливки |
| `#8D2B..#8D37` | [CheckSystemCoordinateBand](../Source/Game/Circles/CheckSystemCoordinateBand.asm) | проверка близости координат системы к диагональной полосе |
| `#8D38..#8DED` | [PrintShipAndContinueRightFill](../Source/Game/Circles/PrintShipAndContinueRightFill.asm) | печать названия улучшенного корабля и продолжение правой заливки |
| `#8DEE..#8DF2` | [StepCircleRowUp](../Source/Game/Circles/StepCircleRowUp.asm) | переход обоих краёв окружности на строку выше |
| `#8DF3..#8E07` | [CrossCircleCharacterRowUp](../Source/Game/Circles/CrossCircleCharacterRowUp.asm) | переход вверх через границу восьмистрочного блока |
| `#8E08..#8E0C` | [StepCircleRowDown](../Source/Game/Circles/StepCircleRowDown.asm) | переход обоих краёв окружности на строку ниже |
| `#8E0D..#8E28` | [CrossCircleCharacterRowDown](../Source/Game/Circles/CrossCircleCharacterRowDown.asm) | переход вниз через границу восьмистрочного блока |
| `#8E29..#8E63` | [DrawChartCircleWithPatchedViewport](../Source/Game/Circles/DrawChartCircleWithPatchedViewport.asm) | рисование окружности карты с временной заменой геометрии экрана |
| `#8E64..#8E76` | [CheckBodiesAndRestoreViewport](../Source/Game/Circles/CheckBodiesAndRestoreViewport.asm) | проверка оценок расстояний и вход восстановления патчей |
| `#8E77..#8F0C` | [ApplyCircleViewportPatches](../Source/Game/Circles/ApplyCircleViewportPatches.asm) | применение байтовой таблицы патчей окружности |
| `#8F0D..#8F73` | [DrawPendingObjectExplosions](../Source/Game/Circles/DrawPendingObjectExplosions.asm) | рисование ожидающих взрывов восьми объектов |
| `#8F74..#8F87` | [SelectCircleBackBuffer](../Source/Game/Circles/SelectCircleBackBuffer.asm) | переключение построителя окружности на экранный буфер |
| `#8F88..#8FB7` | [PatchCircleScreenTarget](../Source/Game/Circles/PatchCircleScreenTarget.asm) | применение режима прямого экрана или буфера |
| `#8FB8..#8FCB` | [DrawCornerRightContour](../Source/Game/Circles/DrawCornerRightContour.asm) | контур угловой дуги с отсечённым правым краем |
| `#8FCC..#8FD9` | [DrawCornerLeftContour](../Source/Game/Circles/DrawCornerLeftContour.asm) | контур угловой дуги с отсечённым левым краем |
| `#8FDA..#8FE2` | [SetRightContourBoundary](../Source/Game/Circles/SetRightContourBoundary.asm) | правая фиксированная граница контура |
| `#8FE3..#8FEC` | [BuildLeftContourPixelMask](../Source/Game/Circles/BuildLeftContourPixelMask.asm) | однобитовая маска левого пикселя |
| `#8FED..#8FF8` | [BuildRightContourPixelMask](../Source/Game/Circles/BuildRightContourPixelMask.asm) | однобитовая маска правого пикселя |
| `#8FF9..#9003` | [SetBothContourBoundaries](../Source/Game/Circles/SetBothContourBoundaries.asm) | две фиксированные границы контура |
| `#9004..#9031` | [SkipViewportRowsUp](../Source/Game/Circles/SkipViewportRowsUp.asm) | пропуск строк вверх без заполнения пикселей |
| `#9032..#928B` | [SkipRowsDownAndDrawCircleContours](../Source/Game/Circles/SkipRowsDownAndDrawCircleContours.asm) | пропуск строк вниз и три контурных построителя |

## Combat

| Адреса | Исходник | Назначение |
|---|---|---|
| `#9A40..#9A58` | [ProcessCombatControls](../Source/Game/Combat/ProcessCombatControls.asm) | обработка ракет, спасательной капсулы и дополнительных боевых команд |
| `#9A59..#9A8C` | [ApplyPlayerDamage](../Source/Game/Combat/ApplyPlayerDamage.asm) | восстановление и расход энергии игрока за такт |
| `#9A8D..#9AA6` | [DrainEnergyBanks](../Source/Game/Combat/DrainEnergyBanks.asm) | расход энергии по четырём банкам с обработкой гибели |
| `#9AA7..#9ADA` | [DamageShieldAndEnergy](../Source/Game/Combat/DamageShieldAndEnergy.asm) | применение урона к щиту с передачей расхода энергии |
| `#9ADB..#9AE1` | [RecoverPlayerEnergy](../Source/Game/Combat/RecoverPlayerEnergy.asm) | восстановление энергии с учётом установленного энергоблока |
| `#9AE2..#9AFA` | [RecoverOneEnergyUnit](../Source/Game/Combat/RecoverOneEnergyUnit.asm) | восстановление единицы энергии либо двух щитов |
| `#9AFB..#9B00` | [RecoverShieldUnit](../Source/Game/Combat/RecoverShieldUnit.asm) | увеличение одного щита с ограничением A0 |
| `#9B01..#9B13` | [UpdateEcmAndDriveIndicators](../Source/Game/Combat/UpdateEcmAndDriveIndicators.asm) | обновление двух индикаторов в полётном виде |
| `#9B14..#9B40` | [SetIndicatorAndPrintMissileStock](../Source/Game/Combat/SetIndicatorAndPrintMissileStock.asm) | установка атрибута индикатора и отдельная печать запаса ракет |
| `#9B41..#9B82` | [UpdateClockAndRotateDistantBodies](../Source/Game/Combat/UpdateClockAndRotateDistantBodies.asm) | обновление накопителя времени и отдельное вращение далёких тел |
| `#9B83..#9BA6` | [CalculateFuelPurchasePrice](../Source/Game/Combat/CalculateFuelPurchasePrice.asm) | расчёт цены недостающего топлива |
| `#9BA7..#9C17` | [HandleMissileControls](../Source/Game/Combat/HandleMissileControls.asm) | захват цели, постановка ракеты на боевой взвод и пуск |
| `#9C18..#9C1B` | [PrintMissileStock](../Source/Game/Combat/PrintMissileStock.asm) | совместимый вход печати запаса ракет |
| `#9C1C..#9C7F` | [HandleEscapeCapsule](../Source/Game/Combat/HandleEscapeCapsule.asm) | запуск спасательной капсулы и отсчёт до завершения эвакуации |
| `#9C80..#9C82` | [UpdateObjectsAndWeapons](../Source/Game/Combat/UpdateObjectsAndWeapons.asm) | совместимый вход обновления объектов и оружия |
| `#9C83..#9C85` | [ApplyPlayerMotion](../Source/Game/Combat/ApplyPlayerMotion.asm) | совместимый вход пересчёта координат по движению игрока |
| `#9C86..#9C88` | [SquareRootVectorLength](../Source/Game/Combat/SquareRootVectorLength.asm) | совместимый вход приближённого квадратного корня |
| `#9C89..#9C9B` | [DivideAndCombatState](../Source/Game/Combat/DivideAndCombatState.asm) | совместимый вход деления и рабочие поля боевого цикла |
| `#9C9C..#9C9E` | [DispatchObjectAction](../Source/Game/Combat/DispatchObjectAction.asm) | совместимый вход диспетчера действий объектов |
| `#9C9F..#9CAE` | [CreateWreckAndDamageState](../Source/Game/Combat/CreateWreckAndDamageState.asm) | совместимый вход создания обломков и рабочие поля урона |
| `#9CAF..#9CBA` | [AnimateIntroAndObjectPipeline](../Source/Game/Combat/AnimateIntroAndObjectPipeline.asm) | вход демонстрационного вращения и общий конвейер боевого кадра |
| `#9CBB..#9E65` | [UpdateAllSpaceObjects](../Source/Game/Combat/UpdateAllSpaceObjects.asm) | полный такт восьми объектов, их поведения, уничтожения и проекции |
| `#9E66..#9E72` | [FinishObjectFrame](../Source/Game/Combat/FinishObjectFrame.asm) | завершение объектного кадра и сброс опасности пустой сцены |
| `#B4D8..#B5DE` | [HandleObjectCollision](../Source/Game/Combat/HandleObjectCollision.asm) | столкновение, захват груза и проверка стыковки |
| `#B5DF..#B617` | [ReleaseMissileTargets](../Source/Game/Combat/ReleaseMissileTargets.asm) | снятие ракетных целей при удалении объекта |
| `#B618..#B63B` | [CreatePlayerWreckScene](../Source/Game/Combat/CreatePlayerWreckScene.asm) | очистка объектных слотов и создание сцены обломков |
| `#B63C..#B70E` | [FirePlayerLaser](../Source/Game/Combat/FirePlayerLaser.asm) | охлаждение лазера, проверка выстрела и нанесение урона цели |
| `#B70F..#B711` | [SpawnDestroyedObjectContents](../Source/Game/Combat/SpawnDestroyedObjectContents.asm) | совместимый вход создания содержимого уничтоженного объекта |
| `#B712..#B71B` | [BeginObjectMetadataPass](../Source/Game/Combat/BeginObjectMetadataPass.asm) | сохранение числа кораблей и начало обхода метаданных |
| `#B71C..#B73C` | [InitializeSpawnedObjectLinks](../Source/Game/Combat/InitializeSpawnedObjectLinks.asm) | инициализация дочернего объекта и его расширенных связей |
| `#B73D..#B742` | [MarkRemovedAndReleaseTargets](../Source/Game/Combat/MarkRemovedAndReleaseTargets.asm) | пометка изменения сцены и снятие ракетных целей |
| `#B743..#B798` | [SetObjectEnergyAndDrawMissedLaser](../Source/Game/Combat/SetObjectEnergyAndDrawMissedLaser.asm) | запись энергии объекта и отдельный рисунок свободного лазерного луча |
| `#B799..#B7AB` | [NextRandomByte](../Source/Game/Combat/NextRandomByte.asm) | обновление двухбайтового генератора псевдослучайных чисел |
| `#B7AC..#B7B3` | [ClearLaserDisplayState](../Source/Game/Combat/ClearLaserDisplayState.asm) | сброс двух полей отображения лазера после гибели |
| `#B7B4..#B82B` | [ProcessLaserAndEcm](../Source/Game/Combat/ProcessLaserAndEcm.asm) | вывод прицела, обработка лазерного огня и ECM |

## Data

| Адреса | Исходник | Назначение |
|---|---|---|
| `#6000..#61DC` | [SystemBoundaryAndObjects](../Source/Game/Data/SystemBoundaryAndObjects.asm) | продолжение смены системы, восемь объектов и индекс 23 моделей |
| `#AFF0..#B043` | [LegacyClipTables](../Source/Game/Data/LegacyClipTables.asm) | сохранившиеся таблицы предыдущего алгоритма отсечения |
| `#BE00..#BFFF` | [SquareTables](../Source/Game/Data/SquareTables.asm) | младшие и старшие байты квадратов аргументов 0..255 |
| `#D000..#D014` | [MenuDispatchTable](../Source/Game/Data/MenuDispatchTable.asm) | семь исполняемых JP основных экранов |
| `#E07A..#E07F` | [LaunchCounter](../Source/Game/Data/LaunchCounter.asm) | отложенный флаг и счётчик вылетов |

## Disk

| Адреса | Исходник | Назначение |
|---|---|---|
| `#D907..#D974` | [LoadDiskMenuOverlay](../Source/Game/Disk/LoadDiskMenuOverlay.asm) | Загрузка первого оверлея cl.C и вызов меню |
| `#D975..#D9C0` | [BlackAttributesAndOverlayState](../Source/Game/Disk/BlackAttributesAndOverlayState.asm) | Гашение 768 атрибутов экрана и состояние загрузки оверлеев |
| `#D9C1..#DA13` | [TransferDiskSectors](../Source/Game/Disk/TransferDiskSectors.asm) | Посекторное чтение или запись через внутренние процедуры TR-DOS |
| `#DA14..#DA16` | [ConvertTrackForDrive](../Source/Game/Disk/ConvertTrackForDrive.asm) | Преобразование номера дорожки при выбранном типе устройства |
| `#DA17..#DA19` | [CallDosWithDriveParameter](../Source/Game/Disk/CallDosWithDriveParameter.asm) | Подстановка параметра устройства перед внутренним вызовом TR-DOS |
| `#DA1A..#DA20` | [CallDosInternal](../Source/Game/Disk/CallDosInternal.asm) | Шлюз к внутренней процедуре TR-DOS |
| `#DA21..#DA2E` | [ReactionOnPrivateStack](../Source/Game/Disk/ReactionOnPrivateStack.asm) | Вызов реакции объекта на отдельном стеке |
| `#DA2F..#DA79` | [DrawScreenStripsAndPrivateStack](../Source/Game/Disk/DrawScreenStripsAndPrivateStack.asm) | Копирование полос экрана и альтернативный стек сортировки |

## Economy

| Адреса | Исходник | Назначение |
|---|---|---|
| `#D2DE..#D2E0` | [PrintBytePrice](../Source/Game/Economy/PrintBytePrice.asm) | Печать байта с десятичной точкой перед последней цифрой |
| `#D2E1..#D2E4` | [PrintByteInteger](../Source/Game/Economy/PrintByteInteger.asm) | Печать беззнакового байта без дробной части |
| `#D2E5..#D31C` | [PrintWordDecimal](../Source/Game/Economy/PrintWordDecimal.asm) | Печать беззнакового HL в десятичной записи |
| `#D31D..#D333` | [FinishWordDecimal](../Source/Game/Economy/FinishWordDecimal.asm) | Вывод единиц и сброс режима числовой печати |
| `#D334..#D356` | [PrintSplitCash](../Source/Game/Economy/PrintSplitCash.asm) | Печать числа в двух группах с основанием 10000 |
| `#D357..#D370` | [PrintDecimalPlace](../Source/Game/Economy/PrintDecimalPlace.asm) | Получение и печать одного десятичного разряда |
| `#D371..#D37C` | [PrintDigitOrLeadingZero](../Source/Game/Economy/PrintDigitOrLeadingZero.asm) | Печать цифры и условное подавление ведущего нуля |
| `#D37D..#D3CD` | [PrintNumberPadding](../Source/Game/Economy/PrintNumberPadding.asm) | Выравнивание числового поля пробелами или нулями |
| `#D3CE..#D3D2` | [CompareWordPreserveHL](../Source/Game/Economy/CompareWordPreserveHL.asm) | Вычитательное сравнение с сохранением HL |
| `#D3D3..#D3E6` | [AddCashLow](../Source/Game/Economy/AddCashLow.asm) | Прибавление суммы в десятых кредита |
| `#D3E7..#D3EE` | [AddCashThousands](../Source/Game/Economy/AddCashThousands.asm) | Прибавление целых тысяч кредитов |
| `#D3EF..#D3FC` | [SubtractCashThousands](../Source/Game/Economy/SubtractCashThousands.asm) | Списание целых тысяч кредитов |
| `#D3FD..#D420` | [SubtractCashLow](../Source/Game/Economy/SubtractCashLow.asm) | Списание суммы в десятых кредита |

## Extensions

| Адреса | Исходник | Назначение |
|---|---|---|
| `#5D70..#5DC7` | [ConsumeGalacticDriveCharge](../Source/Game/Extensions/ConsumeGalacticDriveCharge.asm) | расход заряда галактического гиперпривода |
| `#5DC8..#5DFA` | [UpdateStationAndFinishGlyph](../Source/Game/Extensions/UpdateStationAndFinishGlyph.asm) | обновление станции и отдельный хвост вывода знака |
| `#5DFB..#5E19` | [SelectCharacterFont](../Source/Game/Extensions/SelectCharacterFont.asm) | выбор банка знакогенератора по коду символа |
| `#5E1A..#5E35` | [HandleSpecialMessageToken](../Source/Game/Extensions/HandleSpecialMessageToken.asm) | обработка токена #DC и разрешение двух дополнительных проверок |
| `#5E36..#5E77` | [FillBackwardAndCountDemo](../Source/Game/Extensions/FillBackwardAndCountDemo.asm) | обратное заполнение буфера и учёт завершений демонстрации |
| `#5E78..#5EC4` | [UpdateInvasionOnRatingOverflow](../Source/Game/Extensions/UpdateInvasionOnRatingOverflow.asm) | обработка старшего байта рейтинга и запуск вторжения |
| `#5EC5..#5F10` | [CreateMissileOrMissionCraft](../Source/Game/Extensions/CreateMissileOrMissionCraft.asm) | создание объекта с расходом ракеты либо специального груза |
| `#5F11..#5FA0` | [UpdateStationAndSpecialShips](../Source/Game/Extensions/UpdateStationAndSpecialShips.asm) | обновление станции, появление особых кораблей и перенос станции к солнцу |
| `#5FA1..#5FFF` | [OfferUpgradeAndCorrectPosition](../Source/Game/Extensions/OfferUpgradeAndCorrectPosition.asm) | предложение улучшения корабля и коррекция координат второго объекта |
| `#61DD..#6EBB` | [DrawModelAndResources](../Source/Game/Extensions/DrawModelAndResources.asm) | отрисовка дополнительного формата рёбер и ресурсы моделей |
| `#6EBC..#6ED3` | [UpdateSpecialCargoStatus](../Source/Game/Extensions/UpdateSpecialCargoStatus.asm) | обновление состояния специального груза после меню |
| `#6ED4..#6EE7` | [PrintPlanetInvasionStatus](../Source/Game/Extensions/PrintPlanetInvasionStatus.asm) | замена описания планеты на статус оккупации либо сопротивления |
| `#6EE8..#6F40` | [PrintEquipmentAndSelectIcon](../Source/Game/Extensions/PrintEquipmentAndSelectIcon.asm) | дополнительная строка оборудования и выбор значка режима |
| `#6F41..#6FF1` | [DrawCompressedEdges](../Source/Game/Extensions/DrawCompressedEdges.asm) | вывод упакованных рёбер дополнительной модели |
| `#6FF2..#6FF7` | [EnergyBombAndFlashVectors](../Source/Game/Extensions/EnergyBombAndFlashVectors.asm) | векторы энергетической бомбы и вспышки атрибутов |
| `#6FF8..#70A8` | [AttributeVectorAndEnergyBomb](../Source/Game/Extensions/AttributeVectorAndEnergyBomb.asm) | вектор атрибутов, подтверждение меню и энергетическая бомба |
| `#70A9..#70AF` | [FlashViewAttributes](../Source/Game/Extensions/FlashViewAttributes.asm) | двухфазная смена атрибутов области обзора |
| `#F0EB..#F8D6` | [PrintCargoAndMessageBanks](../Source/Game/Extensions/PrintCargoAndMessageBanks.asm) | список груза, два банка сообщений и защита рабочего стека |
| `#F8D7..#F90D` | [DrawCircleAndProtectScratchStack](../Source/Game/Extensions/DrawCircleAndProtectScratchStack.asm) | вывод кругового объекта и защищённый вызов боевого обработчика |
| `#F90E..#F915` | [SetExtendedTextCursor](../Source/Game/Extensions/SetExtendedTextCursor.asm) | установка координат текстового курсора |
| `#F916..#F92C` | [MarkObjectEventAndUpdateMetadata](../Source/Game/Extensions/MarkObjectEventAndUpdateMetadata.asm) | пометка события объекта и условная повторная инициализация его метаданных |
| `#F92D..#F944` | [StorePairedObjectDirections](../Source/Game/Extensions/StorePairedObjectDirections.asm) | запись двух связанных троек направлений в метаданные объекта |
| `#F945..#F959` | [GetViewAdjustedProjectedPoint](../Source/Game/Extensions/GetViewAdjustedProjectedPoint.asm) | перестановка проекционных координат с поправкой на вид |
| `#F95A..#F97D` | [FindLiveTrackedObject](../Source/Game/Extensions/FindLiveTrackedObject.asm) | поиск живого объекта по идентификатору захвата |
| `#F97E..#F9A7` | [ResolveSpecialObjectCollision](../Source/Game/Extensions/ResolveSpecialObjectCollision.asm) | фильтр столкновения и обнуление энергии выбранного участника |
| `#F9A8..#F9AA` | [SetSceneFlagAndResetMetadata](../Source/Game/Extensions/SetSceneFlagAndResetMetadata.asm) | сохранение флага сцены перед сбросом метаданных |
| `#F9AB..#F9C8` | [ResetObjectMetadata](../Source/Game/Extensions/ResetObjectMetadata.asm) | инициализация общей области метаданных объектов |
| `#F9C9..#F9E0` | [SetObjectAggressionFlag](../Source/Game/Extensions/SetObjectAggressionFlag.asm) | разрешение агрессивного поведения объекта |
| `#F9E1..#F9E6` | [SetAggressionThenContinue](../Source/Game/Extensions/SetAggressionThenContinue.asm) | установка поведения с продолжением основного обновления |
| `#F9E7..#F9E7` | [ValidateTargetWithFlags](../Source/Game/Extensions/ValidateTargetWithFlags.asm) | вход проверки ссылки с обязательными ненулевыми флагами |
| `#F9E8..#FA0C` | [ValidatePackedObjectTarget](../Source/Game/Extensions/ValidatePackedObjectTarget.asm) | проверка упакованного номера живого объекта |
| `#FA0D..#FA83` | [ChooseLinkedObjectTarget](../Source/Game/Extensions/ChooseLinkedObjectTarget.asm) | выбор цели по связям и флагам метаданных объекта |
| `#FA84..#FAC9` | [ScheduleLinkedObjectLaser](../Source/Game/Extensions/ScheduleLinkedObjectLaser.asm) | разрешение лазерного луча и обновление случайного порога связанного объекта |
| `#FACA..#FAFF` | [AllocateVariantObjectSlot](../Source/Game/Extensions/AllocateVariantObjectSlot.asm) | поиск свободного слота с выбором варианта корабля |
| `#FB00..#FB02` | [OrSpriteByte](../Source/Game/Extensions/OrSpriteByte.asm) | наложение байта силуэта на экранный буфер |
| `#FB03..#FB30` | [BuildSmallCircleProfile](../Source/Game/Extensions/BuildSmallCircleProfile.asm) | подготовка строчного профиля малого силуэта |
| `#FB31..#FB31` | [DrawSmallSilhouetteAlternate](../Source/Game/Extensions/DrawSmallSilhouetteAlternate.asm) | перекрывающийся вход выбора альтернативного профиля |
| `#FB32..#FBDF` | [DrawSmallSilhouette](../Source/Game/Extensions/DrawSmallSilhouette.asm) | рисование малого силуэта с горизонтальным отсечением |
| `#FBE0..#FC0F` | [CompareObjectCoordinateDepth](../Source/Game/Extensions/CompareObjectCoordinateDepth.asm) | сравнение модулей координат двух объектов |

## Flight

| Адреса | Исходник | Назначение |
|---|---|---|
| `#70B0..#70B9` | [SetViewAttributesWithCloaking](../Source/Game/Flight/SetViewAttributesWithCloaking.asm) | Выбор атрибутов обзорного окна с учётом маскировки |
| `#70BA..#7118` | [FillViewAttributesAndFlightState](../Source/Game/Flight/FillViewAttributesAndFlightState.asm) | Заливка внутренних атрибутов окна и состояние полёта |
| `#7119..#7120` | [DispatchChartCircle](../Source/Game/Flight/DispatchChartCircle.asm) | Вектор рисования окружности карты |
| `#7121..#7124` | [DispatchDangerIndicator](../Source/Game/Flight/DispatchDangerIndicator.asm) | Вектор обновления индикатора опасности |
| `#7125..#7129` | [DispatchSoundEffect](../Source/Game/Flight/DispatchSoundEffect.asm) | Вектор звукового эффекта |
| `#712A..#712C` | [DispatchAppendDecimalDigit](../Source/Game/Flight/DispatchAppendDecimalDigit.asm) | Вектор присоединения десятичной цифры |
| `#712D..#713B` | [DispatchDeviceAndAppendDigit](../Source/Game/Flight/DispatchDeviceAndAppendDigit.asm) | Вектор атрибутов приборов и ввод второй цифры |
| `#713C..#717A` | [UpdateFlightControlGauges](../Source/Game/Flight/UpdateFlightControlGauges.asm) | Перенос управления в скорость и шкалы вращения |
| `#717B..#71BF` | [TryAutomaticDocking](../Source/Game/Flight/TryAutomaticDocking.asm) | Проверка запроса автоматической стыковки |
| `#71C0..#71CD` | [RebaseSunAgainstStation](../Source/Game/Flight/RebaseSunAgainstStation.asm) | Перевод трёх координат светила относительно станции |
| `#71CE..#71E3` | [RebaseCoordinateAxis](../Source/Game/Flight/RebaseCoordinateAxis.asm) | Перевод одной оси относительно станции |
| `#71E4..#71F2` | [HalfCoordinateDifference](../Source/Game/Flight/HalfCoordinateDifference.asm) | Половина разности старших слов координат |
| `#71F3..#7221` | [HandleMapCursorKeys](../Source/Game/Flight/HandleMapCursorKeys.asm) | Диспетчер клавиш карты при выключенном гиперпереходе |
| `#7222..#725B` | [ToggleCloakingDevice](../Source/Game/Flight/ToggleCloakingDevice.asm) | Переключение маскировки клавишей Y |
| `#725C..#7264` | [ApplyMissionViewColour](../Source/Game/Flight/ApplyMissionViewColour.asm) | Выбор цвета обзорного окна для первой миссии |
| `#7265..#726B` | [ApplyCloakingViewColour](../Source/Game/Flight/ApplyCloakingViewColour.asm) | Повторное применение цвета маскировки |
| `#726C..#7277` | [MarkMissionViewInitialized](../Source/Game/Flight/MarkMissionViewInitialized.asm) | Инициализация признака специального вида первой миссии |
| `#7278..#728C` | [DispatchThirdMissionStage](../Source/Game/Flight/DispatchThirdMissionStage.asm) | Диспетчер экранов этапов третьей миссии |
| `#728D..#72A2` | [ReportBoardingAndReturnToTitle](../Source/Game/Flight/ReportBoardingAndReturnToTitle.asm) | Сообщение о посадке и возврат к выбору корабля |
| `#72A3..#72D3` | [HandlePauseMenu](../Source/Game/Flight/HandlePauseMenu.asm) | Меню паузы с изменением настроек и возвратом в игру |
| `#72D4..#72D4` | [IndexNextPauseTable](../Source/Game/Flight/IndexNextPauseTable.asm) | Переход к следующей таблице команд паузы |
| `#72D5..#7343` | [IndexPauseCommandAndHandlers](../Source/Game/Flight/IndexPauseCommandAndHandlers.asm) | Поиск команды паузы и обработчики её действий |
| `#7344..#736F` | [PlaySweepingBeeperAndBootstrap](../Source/Game/Flight/PlaySweepingBeeperAndBootstrap.asm) | Тональный сигнал с меняющейся задержкой и вход начальной подготовки |
| `#7370..#7393` | [TryColonizeMinerals](../Source/Game/Flight/TryColonizeMinerals.asm) | Попытка появления живых минералов при подборе груза |
| `#7394..#742F` | [ShowTitleAndSelectControls](../Source/Game/Flight/ShowTitleAndSelectControls.asm) | Начальный экран с вращающимися кораблями и выбором управления |
| `#7430..#7446` | [DrawTitleCaption](../Source/Game/Flight/DrawTitleCaption.asm) | Печать подписи начального экрана в буфере вида |
| `#7447..#7460` | [DrawDemoHeading](../Source/Game/Flight/DrawDemoHeading.asm) | Печать общего заголовка демонстрации |
| `#7461..#7466` | [InitializeViewAttributes](../Source/Game/Flight/InitializeViewAttributes.asm) | Инициализация 480 атрибутов верхней области |
| `#7467..#7470` | [Fill240Attributes](../Source/Game/Flight/Fill240Attributes.asm) | Заливка 240 атрибутов белыми чернилами |
| `#7471..#7583` | [MainGameLoop](../Source/Game/Flight/MainGameLoop.asm) | Основной цикл полёта, меню и последовательности гибели |
| `#928C..#9295` | [DrawTransitionTunnelIfActive](../Source/Game/Flight/DrawTransitionTunnelIfActive.asm) | Обновление сообщения и активного тоннеля перехода |
| `#9296..#9380` | [AnimateTransitionTunnel](../Source/Game/Flight/AnimateTransitionTunnel.asm) | Анимация тоннеля гиперперехода и стыковки |
| `#9381..#9388` | [PrintMessageAfterMetadataReset](../Source/Game/Flight/PrintMessageAfterMetadataReset.asm) | Печать токена после сброса объектных метаданных |
| `#9389..#9390` | [RaiseLaserThreshold](../Source/Game/Flight/RaiseLaserThreshold.asm) | Повышение вероятностного порога лазера при маскировке |
| `#9391..#93AB` | [SetSelectedLineMetadata](../Source/Game/Flight/SetSelectedLineMetadata.asm) | Изменение выбранной десятибайтовой записи линий |
| `#93AC..#93EC` | [DivideByteFractionForTunnel](../Source/Game/Flight/DivideByteFractionForTunnel.asm) | Восемь разрядов частного для радиуса тоннеля |
| `#93ED..#94F3` | [LaunchOrDockShip](../Source/Game/Flight/LaunchOrDockShip.asm) | Постановочная последовательность старта либо стыковки |
| `#94F4..#94FD` | [ResetFlightControls](../Source/Game/Flight/ResetFlightControls.asm) | Сброс управления, метаданных и начальной скорости |
| `#94FE..#9502` | [ClearFlightKeyEvents](../Source/Game/Flight/ClearFlightKeyEvents.asm) | Очистка пяти накопленных клавиатурных масок |
| `#9503..#9508` | [ClearBytes](../Source/Game/Flight/ClearBytes.asm) | Обнуление заданного диапазона |
| `#9509..#9526` | [ClearNearbyShipSlots](../Source/Game/Flight/ClearNearbyShipSlots.asm) | Удаление семи соседних объектов |

## Galaxy

| Адреса | Исходник | Назначение |
|---|---|---|
| `#DF03..#DF19` | [AdvanceGalaxySeed](../Source/Game/Galaxy/AdvanceGalaxySeed.asm) | Выбор следующей из восьми галактик |
| `#DF1A..#DF23` | [RotateSeedPair](../Source/Game/Galaxy/RotateSeedPair.asm) | Циклический поворот двух байтов семени |
| `#DF24..#DF5F` | [FindSystemByExactName](../Source/Game/Galaxy/FindSystemByExactName.asm) | Поиск системы по полному имени среди 256 планет |
| `#DF60..#DF73` | [SelectNearestSystemWithCursor](../Source/Game/Galaxy/SelectNearestSystemWithCursor.asm) | Выбор ближайшей системы с удалением и возвратом XOR-курсора |
| `#DF74..#DFC3` | [FindNearestSystem](../Source/Game/Galaxy/FindNearestSystem.asm) | Поиск системы с минимальной метрикой до курсора |
| `#DFC4..#DFCD` | [AdvanceSystemSeed](../Source/Game/Galaxy/AdvanceSystemSeed.asm) | Переход к семени следующей планеты |
| `#DFCE..#DFE9` | [SquaredDistanceToTarget](../Source/Game/Galaxy/SquaredDistanceToTarget.asm) | Квадратичная метрика от заданной точки до выбранной |
| `#DFEA..#DFF1` | [OnesComplementDifference](../Source/Game/Galaxy/OnesComplementDifference.asm) | Разность координат в однобайтовой арифметике |
| `#DFF2..#E008` | [DistanceMetricToFuel](../Source/Game/Galaxy/DistanceMetricToFuel.asm) | Преобразование квадрата расстояния в расход топлива |
| `#E009..#E01B` | [MultiplyBytes](../Source/Game/Galaxy/MultiplyBytes.asm) | Беззнаковое умножение двух байтов |
| `#E01C..#E03C` | [GenerateSystemName](../Source/Game/Galaxy/GenerateSystemName.asm) | Генерация имени планеты из трёх или четырёх слогов |
| `#E03D..#E062` | [AppendSystemNameSyllable](../Source/Game/Galaxy/AppendSystemNameSyllable.asm) | Добавление слога в создаваемое имя |
| `#E080..#E08B` | [CopySystemNameToTarget](../Source/Game/Galaxy/CopySystemNameToTarget.asm) | Копирование имени в буфер назначения |
| `#E08C..#E106` | [DeriveSystemProperties](../Source/Game/Galaxy/DeriveSystemProperties.asm) | Расчёт экономики, правительства, технологии, населения и производительности |
| `#E107..#E122` | [PrintTargetDistance](../Source/Game/Galaxy/PrintTargetDistance.asm) | Печать ненулевого расстояния до выбранной планеты |
| `#E123..#E125` | [FinishDistanceLine](../Source/Game/Galaxy/FinishDistanceLine.asm) | Общий хвост перевода строки после расстояния |
| `#E126..#E12D` | [LoadGalaxySeed](../Source/Game/Galaxy/LoadGalaxySeed.asm) | Копирование базового семени галактики в рабочее |
| `#E12E..#E135` | [SaveWorkingSystemSeed](../Source/Game/Galaxy/SaveWorkingSystemSeed.asm) | Сохранение рабочего семени планеты |
| `#E136..#E141` | [RestoreWorkingSystemSeed](../Source/Game/Galaxy/RestoreWorkingSystemSeed.asm) | Восстановление рабочего семени планеты |

## Input

| Адреса | Исходник | Назначение |
|---|---|---|
| `#FC10..#FC24` | [FinishKeyboardRowAndSelectJoystick](../Source/Game/Input/FinishKeyboardRowAndSelectJoystick.asm) | переход к следующему ряду клавиатуры и выбор схемы направлений |
| `#FC25..#FC32` | [MarkModelVisibilityMask](../Source/Game/Input/MarkModelVisibilityMask.asm) | добавление маски видимости для особой модели |
| `#FC33..#FCB9` | [ResetDemoAndNormalizeControls](../Source/Game/Input/ResetDemoAndNormalizeControls.asm) | сброс флага демонстрации и нормализация направлений управления |
| `#FCBA..#FCE9` | [SetPressedKeyAssignment](../Source/Game/Input/SetPressedKeyAssignment.asm) | преобразование позиции нажатой клавиши в символ и игровую команду |
| `#FCEA..#FD01` | [CheckMissionSystem](../Source/Game/Input/CheckMissionSystem.asm) | проверка особой системы по координатам и состоянию задания |
| `#FD02..#FD68` | [ToggleSecondaryCoordinateObject](../Source/Game/Input/ToggleSecondaryCoordinateObject.asm) | переключение двух наборов координат для дополнительного вида |
| `#FD69..#FE00` | [ScanKeyboardMatrix](../Source/Game/Input/ScanKeyboardMatrix.asm) | опрос восьми рядов клавиатуры Spectrum |
| `#FE01..#FEFD` | [IntegrateFlightControls](../Source/Game/Input/IntegrateFlightControls.asm) | интегрирование поворота, тангажа и скорости по клавишам |
| `#FEFE..#FF0D` | [InterruptGateAndAcceleration](../Source/Game/Input/InterruptGateAndAcceleration.asm) | изменяемый вход IM2 и продолжение увеличения скорости |
| `#FF0E..#FF24` | [ClampAndStoreFlightSpeed](../Source/Game/Input/ClampAndStoreFlightSpeed.asm) | ограничение скорости и общий выход управления |
| `#FF25..#FF4B` | [KeyboardControlInterrupt](../Source/Game/Input/KeyboardControlInterrupt.asm) | обработчик IM2 с отдельным стеком |
| `#FF4C..#FF52` | [EnableInterruptMode2](../Source/Game/Input/EnableInterruptMode2.asm) | выбор режима IM2 с таблицей в странице #FD00 |
| `#FF53..#FFFF` | [EnableInterruptMode1AndKeyboardMap](../Source/Game/Input/EnableInterruptMode1AndKeyboardMap.asm) | возврат в IM1, сохранённый SP и карта назначений клавиш |

## Interface

| Адреса | Исходник | Назначение |
|---|---|---|
| `#D015..#D032` | [DispatchStatusAndChartKeys](../Source/Game/Interface/DispatchStatusAndChartKeys.asm) | Таблица переходов обработчиков экранов и карты |
| `#D033..#D035` | [DispatchResetCommander](../Source/Game/Interface/DispatchResetCommander.asm) | Вектор восстановления начального командира |
| `#D036..#D038` | [DispatchClearView](../Source/Game/Interface/DispatchClearView.asm) | Вектор очистки обзорного окна |
| `#D039..#D03B` | [DispatchDescriptionToken](../Source/Game/Interface/DispatchDescriptionToken.asm) | Вектор печати токена второй таблицы |
| `#D03C..#D041` | [DispatchFlightMessage](../Source/Game/Interface/DispatchFlightMessage.asm) | Вектор обновления сообщений полётного экрана |
| `#D042..#D047` | [DispatchJumpKey](../Source/Game/Interface/DispatchJumpKey.asm) | Вектор обработки запроса гиперперехода |
| `#D048..#D04D` | [DispatchTextToken](../Source/Game/Interface/DispatchTextToken.asm) | Вектор печати токена основной таблицы |
| `#D04E..#D0D9` | [DispatchDiskAndCommanderState](../Source/Game/Interface/DispatchDiskAndCommanderState.asm) | Вектор дискового меню и область состояния пилота |

## Math

| Адреса | Исходник | Назначение |
|---|---|---|
| `#87BF..#87C7` | [Square](../Source/Game/Math/Square.asm) | квадрат беззнакового восьмибитного числа |
| `#9EF1..#9F40` | [SquareRoot](../Source/Game/Math/SquareRoot.asm) | приближённый квадратный корень беззнакового шестнадцатибитного числа |
| `#AFA8..#AFC8` | [Divide](../Source/Game/Math/Divide.asm) | шестнадцать двоичных разрядов беззнакового частного |
| `#AFC9..#AFEF` | [AddSigned](../Source/Game/Math/AddSigned.asm) | половина разности координат в формате знак и модуль |
| `#E063..#E079` | [NextRandom](../Source/Game/Math/NextRandom.asm) | следующий шаг генератора последовательности планет |

## Menus

| Адреса | Исходник | Назначение |
|---|---|---|
| `#EB63..#EBED` | [MapCaptionAndGalaxyChart](../Source/Game/Menus/MapCaptionAndGalaxyChart.asm) | Заголовок карты и экран всей галактики |
| `#EBEE..#EC13` | [ClearCharacterRowsBackward](../Source/Game/Menus/ClearCharacterRowsBackward.asm) | Очистка нескольких символьных строк перед данным адресом |
| `#EC14..#EC3A` | [PlotGalaxySystem](../Source/Game/Menus/PlotGalaxySystem.asm) | Вывод одной точки на общей карте галактики |
| `#EC3B..#EC3C` | [ReturnZero](../Source/Game/Menus/ReturnZero.asm) | Нулевое значение для насыщения координаты |
| `#EC3D..#EC3F` | [Return255](../Source/Game/Menus/Return255.asm) | Значение 255 для насыщения координаты |
| `#EC40..#EC4A` | [CheckMissionRegionBand](../Source/Game/Menus/CheckMissionRegionBand.asm) | Проверка полосы между двумя специальными границами |
| `#EC4B..#EC57` | [RedirectDuplicateEquipment](../Source/Game/Menus/RedirectDuplicateEquipment.asm) | Подмена возврата при специальном конфликте оборудования |
| `#EC58..#ECD1` | [OpenLocalChart](../Source/Game/Menus/OpenLocalChart.asm) | Построение местной карты с двумя проходами по системам |
| `#ECD2..#ECFC` | [VisitLocalChartSystems](../Source/Game/Menus/VisitLocalChartSystems.asm) | Перебор 256 систем с отсечением по местному прямоугольнику |
| `#ECFD..#ED5F` | [LocalSystemPixelPosition](../Source/Game/Menus/LocalSystemPixelPosition.asm) | Экранная позиция планеты на местной карте |
| `#ED60..#ED68` | [DrawExplosionAndScanner](../Source/Game/Menus/DrawExplosionAndScanner.asm) | Общий вызов взрыва, копирования экрана и сканера |
| `#ED69..#ED77` | [ReadVisibleObjectByte](../Source/Game/Menus/ReadVisibleObjectByte.asm) | Чтение поля объекта с отсечением адреса записи |
| `#ED78..#EDC4` | [PlaceLocalSystemLabel](../Source/Game/Menus/PlaceLocalSystemLabel.asm) | Поиск свободной строки для имени планеты на местной карте |
| `#EDC5..#EE3B` | [PrintLabelOnUnusedRow](../Source/Game/Menus/PrintLabelOnUnusedRow.asm) | Печать имени только на ещё не занятой строке |
| `#EE3C..#EE9C` | [PrintSystemStatistics](../Source/Game/Menus/PrintSystemStatistics.asm) | Вывод производительности, радиуса и описания планеты |
| `#EE9D..#EEA1` | [PrintTokenAndBlankLine](../Source/Game/Menus/PrintTokenAndBlankLine.asm) | Печать токена с пустой строкой после него |
| `#EEA2..#EEDA` | [BlankLineAndEconomyText](../Source/Game/Menus/BlankLineAndEconomyText.asm) | Два перевода строки и обработчики описания экономики |
| `#EEDB..#EF00` | [ApplyMissionMarketRestrictions](../Source/Game/Menus/ApplyMissionMarketRestrictions.asm) | Коррекция рынка и миссионного состояния в особых системах |
| `#EF01..#EF20` | [ChooseEncounterVariant](../Source/Game/Menus/ChooseEncounterVariant.asm) | Случайная замена типа объекта для группы 13..17 |
| `#EF21..#EF36` | [PrintSystemRadius](../Source/Game/Menus/PrintSystemRadius.asm) | Вычисление и печать радиуса планеты |
| `#EF37..#EF86` | [CompareSystemSeedToGalaxyBase](../Source/Game/Menus/CompareSystemSeedToGalaxyBase.asm) | Побайтное сравнение шести байтов с базовым семенем галактики |
| `#EF87..#EFC4` | [OpenCommanderStatus](../Source/Game/Menus/OpenCommanderStatus.asm) | Экран состояния командира |
| `#EFC5..#EFDF` | [PrintLegalStatus](../Source/Game/Menus/PrintLegalStatus.asm) | Печать правового состояния и подписи рейтинга |
| `#EFE0..#F067` | [PrintCombatRankAndEquipment](../Source/Game/Menus/PrintCombatRankAndEquipment.asm) | Печать боевого звания и установленного оборудования |
| `#F068..#F06E` | [PrintInlineTokenIfNonzero](../Source/Game/Menus/PrintInlineTokenIfNonzero.asm) | Условная печать токена из потока команд |
| `#F06F..#F071` | [PrintEquipmentLine](../Source/Game/Menus/PrintEquipmentLine.asm) | Печать токена отдельной строкой оборудования |
| `#F072..#F079` | [NextEquipmentLine](../Source/Game/Menus/NextEquipmentLine.asm) | Следующая строка списка оборудования |
| `#F07A..#F0A0` | [PrintDirectionalLaser](../Source/Game/Menus/PrintDirectionalLaser.asm) | Печать одного установленного лазера |
| `#F0A1..#F0EA` | [PrintStatusFieldAndCargoScreen](../Source/Game/Menus/PrintStatusFieldAndCargoScreen.asm) | Вывод поля состояния и начало экрана трюма |

## Missions

| Адреса | Исходник | Назначение |
|---|---|---|
| `#D0DA..#D0E9` | [DispatchMissionEvents](../Source/Game/Missions/DispatchMissionEvents.asm) | векторы очереди сообщений, предложения миссии, потери топлива, подбора и денежной награды |
| `#D0EA..#D0F2` | [DispatchRatingAndMissionEnd](../Source/Game/Missions/DispatchRatingAndMissionEnd.asm) | векторы начисления рейтинга и завершения третьей миссии |
| `#D0F3..#D0F5` | [DispatchEquipmentDamage](../Source/Game/Missions/DispatchEquipmentDamage.asm) | совместимый вход повреждения топлива, устройства либо единицы груза |
| `#D0F6..#D122` | [ShowBoardingMessage](../Source/Game/Missions/ShowBoardingMessage.asm) | сообщение о захвате корабля с общим хвостом ожидания |
| `#D123..#D14C` | [OfferThirdMission](../Source/Game/Missions/OfferThirdMission.asm) | предложение третьей миссии и обработка ответа |
| `#D14D..#D161` | [CompleteThirdMission](../Source/Game/Missions/CompleteThirdMission.asm) | выдача награды за третью миссию |
| `#D162..#D1C6` | [SpecialMessageAndScoopReward](../Source/Game/Missions/SpecialMessageAndScoopReward.asm) | окно специального сообщения, подбор груза и правовой статус |
| `#D1C7..#D2DD` | [RatingBountyDamageAndNewCommander](../Source/Game/Missions/RatingBountyDamageAndNewCommander.asm) | рейтинг, денежные награды, повреждения и восстановление командира |

## Motion

| Адреса | Исходник | Назначение |
|---|---|---|
| `#9E73..#9E97` | [NormalizeVector16](../Source/Game/Motion/NormalizeVector16.asm) | нормализация вектора и расчёт его приближённой длины |
| `#9E98..#9ECE` | [SquareVectorComponent](../Source/Game/Motion/SquareVectorComponent.asm) | приближённый квадрат одной знако-модульной компоненты |
| `#9ECF..#9EF0` | [DivideVectorComponent](../Source/Game/Motion/DivideVectorComponent.asm) | деление одной компоненты на длину вектора |
| `#9F41..#9F67` | [RenormalizeAxisHighBytes](../Source/Game/Motion/RenormalizeAxisHighBytes.asm) | коррекция длины оси по старшим байтам её компонент |
| `#9F68..#9F81` | [ScaleAxisHighByte](../Source/Game/Motion/ScaleAxisHighByte.asm) | масштабирование старшего байта компоненты оси |
| `#9F82..#9FFC` | [UpdateObjectCoordinatesAndRotation](../Source/Game/Motion/UpdateObjectCoordinatesAndRotation.asm) | пересчёт положения и базиса объекта за один такт |
| `#9FFD..#A04A` | [AdvanceObjectAlongLocalAxis](../Source/Game/Motion/AdvanceObjectAlongLocalAxis.asm) | собственное вращение объекта и перемещение по скорости |
| `#A04B..#A075` | [AdvanceOneCoordinate](../Source/Game/Motion/AdvanceOneCoordinate.asm) | прибавление смещения от скорости к одной координате объекта |
| `#A076..#A097` | [VelocityComponentDelta](../Source/Game/Motion/VelocityComponentDelta.asm) | расчёт смещения из скорости и компоненты направления |
| `#A098..#A0AA` | [AddCoordinateDelta](../Source/Game/Motion/AddCoordinateDelta.asm) | сложение координаты и смещения со знаком и отдельным модулем |
| `#A0AB..#A0FC` | [RotateAxisByPlayer](../Source/Game/Motion/RotateAxisByPlayer.asm) | поворот одной оси объекта вслед за управлением игрока |
| `#A0FD..#A126` | [AddSignedAngularProduct](../Source/Game/Motion/AddSignedAngularProduct.asm) | прибавление произведения угла и компоненты к знако-модульному байту |
| `#A127..#A172` | [RotateBasisByObject](../Source/Game/Motion/RotateBasisByObject.asm) | поворот одной компоненты трёх осей собственным вращением объекта |
| `#A173..#A1E9` | [ApplyPlayerMotionToObject](../Source/Game/Motion/ApplyPlayerMotionToObject.asm) | поворот и перенос относительных координат при движении игрока |
| `#A1EA..#A280` | [AddScaledCoordinate](../Source/Game/Motion/AddScaledCoordinate.asm) | прибавление к координате объекта другой координаты с коэффициентом |
| `#A281..#A28C` | [DoubleSignedAngle](../Source/Game/Motion/DoubleSignedAngle.asm) | подготовка удвоенного коэффициента поворота перестановкой битов |
| `#A28D..#A2BF` | [AnimateIntroObject](../Source/Game/Motion/AnimateIntroObject.asm) | поворот и вывод демонстрационного корабля в последнем слоте |
| `#A2C0..#A402` | [ProcessObjectEnergyAndTactics](../Source/Game/Motion/ProcessObjectEnergyAndTactics.asm) | восстановление энергии и выбор тактического действия объекта |
| `#A403..#A40E` | [CallObjectActionPreservingPointers](../Source/Game/Motion/CallObjectActionPreservingPointers.asm) | вызов расширенного действия объекта с сохранением указателей |
| `#A40F..#A4B4` | [CheckObjectBoxAndChooseCourse](../Source/Game/Motion/CheckObjectBoxAndChooseCourse.asm) | проверка близости объекта и выбор курса приближения либо удаления |
| `#A4B5..#A536` | [GuideMissileAndCheckImpact](../Source/Game/Motion/GuideMissileAndCheckImpact.asm) | наведение ракеты на цель и проверка попадания |
| `#A537..#A53E` | [IsSmallSignedDistance](../Source/Game/Motion/IsSmallSignedDistance.asm) | проверка малого модуля знако-модульного расстояния |
| `#A53F..#A567` | [QuarterCoordinateDifference](../Source/Game/Motion/QuarterCoordinateDifference.asm) | разность координат цели и ракеты в масштабе четверти |
| `#A568..#A56E` | [NegatedQuarterCoordinate](../Source/Game/Motion/NegatedQuarterCoordinate.asm) | получение координаты с обратным знаком в масштабе четверти |
| `#A56F..#A586` | [QuarterCoordinate](../Source/Game/Motion/QuarterCoordinate.asm) | получение координаты в масштабе четверти |
| `#A587..#A69C` | [SteerObjectAndTryLaser](../Source/Game/Motion/SteerObjectAndTryLaser.asm) | расчёт команд наведения, ускорения и возможности лазерного выстрела |
| `#A69D..#A6AB` | [SignedByteProductPair](../Source/Game/Motion/SignedByteProductPair.asm) | приближённое произведение двух знако-модульных байтов |
| `#A6AC..#A6DE` | [DotProductAxisHighBytes](../Source/Game/Motion/DotProductAxisHighBytes.asm) | приближённое скалярное произведение по старшим байтам векторов |
| `#A6DF..#A83B` | [ProjectObjectAndSelectDetail](../Source/Game/Motion/ProjectObjectAndSelectDetail.asm) | проекция объекта, отсечение и выбор каркаса либо дальней точки |
| `#A83C..#A84C` | [XorFarObjectPixel](../Source/Game/Motion/XorFarObjectPixel.asm) | вывод пикселя далёкого объекта в теневой буфер |
| `#BD95..#BDB3` | [MultiplySignedWordByByte](../Source/Game/Motion/MultiplySignedWordByByte.asm) | приближённое произведение знако-модульного слова на байт |
| `#BDB4..#BDFF` | [TransformNormalWithObjectCoordinate](../Source/Game/Motion/TransformNormalWithObjectCoordinate.asm) | преобразование нормали с добавлением координаты объекта |

## Objects

| Адреса | Исходник | Назначение |
|---|---|---|
| `#B82C..#B866` | [ActivateEnemyECM](../Source/Game/Objects/ActivateEnemyECM.asm) | включение ECM по ненулевому запросу C и разрешающему биту 4 регистра B |
| `#B867..#B869` | [DispatchObjectAction](../Source/Game/Objects/DispatchObjectAction.asm) | передача упакованной команды объекта обработчику #DA51 |
| `#B86A..#B897` | [SelectObjectAction](../Source/Game/Objects/SelectObjectAction.asm) | диспетчер создания объектов по младшей тетраде команды |
| `#B898..#B91D` | [InitializeObject](../Source/Game/Objects/InitializeObject.asm) | инициализация слота по индексу четырёхбайтового каталога моделей |
| `#B91E..#B935` | [SpawnFromObject](../Source/Game/Objects/SpawnFromObject.asm) | создание дочернего объекта с копией координат и осей родителя |
| `#B936..#B949` | [FindFreeObjectSlot](../Source/Game/Objects/FindFreeObjectSlot.asm) | поиск свободного слота среди шести обычных объектов |
| `#B94A..#B94F` | [SpawnAtPlayer](../Source/Game/Objects/SpawnAtPlayer.asm) | поиск слота и общий вход создания объекта около игрока |
| `#B950..#B96A` | [InitializeAtPlayer](../Source/Game/Objects/InitializeAtPlayer.asm) | инициализация выбранного слота около игрока с эффектами версии |
| `#B96B..#B99E` | [SpawnThargonWave](../Source/Game/Objects/SpawnThargonWave.asm) | создание от трёх до шести таргонов до исчерпания слотов |
| `#B99F..#B9E6` | [SpawnMissile](../Source/Game/Objects/SpawnMissile.asm) | создание ракеты игрока либо ракеты исходного объекта |
| `#B9E7..#BA26` | [SpawnShipClass](../Source/Game/Objects/SpawnShipClass.asm) | выбор модели запускаемого корабля по параметру класса |
| `#BA27..#BA3E` | [AlternateSpawnAxes](../Source/Game/Objects/AlternateSpawnAxes.asm) | чередование двух вариантов изменения ориентации нового объекта |
| `#BA3F..#BA82` | [RotateSpawnAxisComponent](../Source/Game/Objects/RotateSpawnAxisComponent.asm) | перестановка старших компонент осей при создании объекта |
| `#BA83..#BA93` | [RandomizeSpawnDirection](../Source/Game/Objects/RandomizeSpawnDirection.asm) | выбор двух случайных старших компонент направления |
| `#BA94..#BA9B` | [SpawnTwoAlloys](../Source/Game/Objects/SpawnTwoAlloys.asm) | создание двух обломков сплава от игрока или исходного объекта |
| `#BA9C..#BAE7` | [SpawnPlayerDebris](../Source/Game/Objects/SpawnPlayerDebris.asm) | создание выбрасываемого около игрока обломка или груза |
| `#BAE8..#BAF1` | [SpawnTwoShipAlloys](../Source/Game/Objects/SpawnTwoShipAlloys.asm) | две попытки создать сплав у исходного объекта |
| `#BAF2..#BAF9` | [SpawnCargo](../Source/Game/Objects/SpawnCargo.asm) | выбор создания груза у игрока или исходного объекта |
| `#BAFA..#BB2E` | [SpawnEscapePod](../Source/Game/Objects/SpawnEscapePod.asm) | создание спасательной капсулы либо оставленного корабля игрока |
| `#BB2F..#BB4C` | [SpawnShipCargoOrPod](../Source/Game/Objects/SpawnShipCargoOrPod.asm) | создание капсулы или контейнера с сохранением указателя родителя |
| `#BB4D..#BB54` | [SpawnTwoMinerals](../Source/Game/Objects/SpawnTwoMinerals.asm) | создание двух минералов у исходного объекта |
| `#BB55..#BB74` | [SpawnShipDebris](../Source/Game/Objects/SpawnShipDebris.asm) | создание одного обломка с изменением ориентации и сохранением родителя |
| `#BB75..#BBB9` | [InitializeIntroModel](../Source/Game/Objects/InitializeIntroModel.asm) | инициализация демонстрационной модели в выделенном ракетном слоте |
| `#BBBA..#BCD3` | [GenerateSpaceTraffic](../Source/Game/Objects/GenerateSpaceTraffic.asm) | генерация случайных встреч с учётом опасности системы и миссий |
| `#BCD4..#BD5E` | [ComputeFaceVisibility](../Source/Game/Objects/ComputeFaceVisibility.asm) | расчёт признаков видимости нормалей модели |
| `#BD5F..#BD94` | [DotProduct16By8](../Source/Game/Objects/DotProduct16By8.asm) | масштабированное скалярное произведение 16-битного и 8-битного векторов |

## Resources

| Адреса | Исходник | Назначение |
|---|---|---|
| `#4000..#5AFF` | [LoadingScreen](../Source/Game/Resources/LoadingScreen.asm) | загрузочный экран ZX Spectrum, 6144 байта пикселей и 768 атрибутов |
| `#5B00..#5BFF` | [CockpitAttrs](../Source/Game/Resources/CockpitAttrs.asm) | буфер 256 атрибутов нижней трети экрана, восемь строк по 32 ячейки |
| `#5C00..#5D6F` | [SystemShadow](../Source/Game/Resources/SystemShadow.asm) | сохранённый участок низкой памяти игры, загружаемый через временную область |
| `#C000..#C7FF` | [CockpitPixels](../Source/Game/Resources/CockpitPixels.asm) | буфер 2048 пиксельных байтов нижней трети экрана, строки 128..191 |
| `#C800..#CFFF` | [SkippedSectors](../Source/Game/Resources/SkippedSectors.asm) | 2048 байтов исходного игрового файла, пропускаемых штатным загрузчиком |

## Scanner

| Адреса | Исходник | Назначение |
|---|---|---|
| `#96D6..#96D8` | [AdvanceScannerObject](../Source/Game/Scanner/AdvanceScannerObject.asm) | Общий переход к следующему объекту сканера |
| `#96D9..#9869` | [DrawScannerObjects](../Source/Game/Scanner/DrawScannerObjects.asm) | Вывод восьми объектов на плоскость сканера |
| `#986A..#987B` | [StepScannerStemDown](../Source/Game/Scanner/StepScannerStemDown.asm) | Переход ножки сканера через нижнюю границу знакоместа |
| `#987C..#988D` | [StepScannerStemUp](../Source/Game/Scanner/StepScannerStemUp.asm) | Переход ножки сканера через верхнюю границу знакоместа |
| `#988E..#98A1` | [SetYellowFlightStatus](../Source/Game/Scanner/SetYellowFlightStatus.asm) | Выбор жёлтого индикатора при наличии обычного живого объекта |
| `#98A2..#98CC` | [SaveScannerBackground](../Source/Game/Scanner/SaveScannerBackground.asm) | Сохранение чистого фона сканера в линейный буфер |
| `#98CD..#9923` | [RestoreScannerBackground](../Source/Game/Scanner/RestoreScannerBackground.asm) | Восстановление фона и удаление предыдущих отметок |
| `#9924..#9945` | [ScaleValueAndFinishBackground](../Source/Game/Scanner/ScaleValueAndFinishBackground.asm) | Масштабирование байта и общий хвост копирования фона |
| `#9946..#9973` | [ResetCockpitForLaunch](../Source/Game/Scanner/ResetCockpitForLaunch.asm) | Начальные щиты, энергия и состояния приборов после старта |
| `#9974..#9994` | [SetCockpitDeviceAttributes](../Source/Game/Scanner/SetCockpitDeviceAttributes.asm) | Цвета двух панелей приборов по наличию спасательной капсулы |
| `#9995..#99A3` | [FillCockpitAttributePanel](../Source/Game/Scanner/FillCockpitAttributePanel.asm) | Заливка панели атрибутов размером пять на семь |
| `#99A4..#9A39` | [DrawDangerAndMissileIndicators](../Source/Game/Scanner/DrawDangerAndMissileIndicators.asm) | Индикаторы опасности и готовности ракеты для разных экранов |
| `#9A3A..#9A3F` | [ResetDangerIndicator](../Source/Game/Scanner/ResetDangerIndicator.asm) | Базовый зелёный сигнал для следующего кадра |

## Screen

| Адреса | Исходник | Назначение |
|---|---|---|
| `#7FBE..#7FCC` | [CopyFlightView](../Source/Game/Screen/CopyFlightView.asm) | вывод 120 строк буфера вида в экран начиная со строки 8 |
| `#7FCD..#7FCE` | [CopySixtyRows](../Source/Game/Screen/CopySixtyRows.asm) | подготовка копирования 60 строк через одну |
| `#7FCF..#7FE2` | [CopyAlternateRows](../Source/Game/Screen/CopyAlternateRows.asm) | копирование строк с шагом две строки Spectrum |
| `#7FE3..#7FE6` | [SwapAndSkipRow](../Source/Game/Screen/SwapAndSkipRow.asm) | обмен указателей и пропуск одной строки у прежнего DE |
| `#7FE7..#7FEF` | [NextScanline](../Source/Game/Screen/NextScanline.asm) | переход HL на следующую пиксельную строку Spectrum |
| `#7FF0..#801F` | [SelectTrafficType](../Source/Game/Screen/SelectTrafficType.asm) | уточнение типа случайного корабля по геометрии системы и особым областям |
| `#8020..#8041` | [MatchTargetPlanet](../Source/Game/Screen/MatchTargetPlanet.asm) | проверка совпадения перебираемой планеты с целевыми координатами |
| `#8042..#804A` | [RestoreCockpitIfNeeded](../Source/Game/Screen/RestoreCockpitIfNeeded.asm) | восстановление кабины при уходе с текстового экрана |
| `#804B..#807F` | [RestoreCockpit](../Source/Game/Screen/RestoreCockpit.asm) | восстановление приборной панели и боковых границ атрибутов |
| `#8080..#80B3` | [ClearFlightBuffer](../Source/Game/Screen/ClearFlightBuffer.asm) | очистка буфера вида и построение прямоугольной рамки |
| `#80B4..#80C0` | [CargoTripleOffset](../Source/Game/Screen/CargoTripleOffset.asm) | расчёт смещения трёхбайтной записи для индекса товара |
| `#80C1..#80D2` | [ResetCargoCapacity](../Source/Game/Screen/ResetCargoCapacity.asm) | установка свободного места по типу грузового отсека |
| `#80D3..#813D` | [HandleScreenKeys](../Source/Game/Screen/HandleScreenKeys.asm) | выбор вида, экрана меню или команды вылета по событиям клавиатуры |
| `#813E..#815C` | [DispatchMenu](../Source/Game/Screen/DispatchMenu.asm) | вызов обработчика меню через самомодифицируемую команду CALL |
| `#815D..#817D` | [SelectScreen](../Source/Game/Screen/SelectScreen.asm) | смена экранного режима с сохранением кабины |
| `#817E..#8199` | [SaveCockpit](../Source/Game/Screen/SaveCockpit.asm) | сохранение приборной панели перед информационным экраном |
| `#819A..#81A8` | [RestrictDockingView](../Source/Game/Screen/RestrictDockingView.asm) | ограничение вида в активном стыковочном туннеле |
| `#81A9..#8216` | [UpdateCelestialProximity](../Source/Game/Screen/UpdateCelestialProximity.asm) | обновление близости солнца, температуры, высоты и компаса |
| `#8217..#8270` | [WriteStridedTriple](../Source/Game/Screen/WriteStridedTriple.asm) | запись трёх значений с шагом DE и общий хвост ближнего компаса |
| `#8271..#82AF` | [CompassNearAxis](../Source/Game/Screen/CompassNearAxis.asm) | нормирование координаты близкого объекта для компаса |
| `#82B0..#82D0` | [CompassFarAxis](../Source/Game/Screen/CompassFarAxis.asm) | нормирование дальней координаты и восстановление её знака |
| `#82D1..#82D6` | [SetGameOver](../Source/Game/Screen/SetGameOver.asm) | установка признака гибели игрока |
| `#82D7..#8301` | [ScaleProximity](../Source/Game/Screen/ScaleProximity.asm) | масштабирование расстояния и выбор состояния опасности |
| `#8302..#8314` | [LoadVectorWords](../Source/Game/Screen/LoadVectorWords.asm) | чтение трёх слов вектора с шагом три байта |
| `#8315..#8321` | [LengthHighWords](../Source/Game/Screen/LengthHighWords.asm) | длина вектора по старшим словам знаковых координат |
| `#8322..#83FD` | [VectorLength](../Source/Game/Screen/VectorLength.asm) | приближённая длина трёхмерного вектора с нормированием |
| `#83FE..#83FF` | [PlanetDistanceHint](../Source/Game/Screen/PlanetDistanceHint.asm) | перекрывающийся вход оценки положения планеты |
| `#8400..#8419` | [SunDistanceHint](../Source/Game/Screen/SunDistanceHint.asm) | быстрая оценка старших координат солнца или планеты |
| `#841A..#8428` | [ChooseEncounterCode](../Source/Game/Screen/ChooseEncounterCode.asm) | выбор кода события по миссии и старшему биту записи |
| `#8429..#8441` | [CheckDockingAlignment](../Source/Game/Screen/CheckDockingAlignment.asm) | проверка ориентации и положения относительно стыковочного проёма |
| `#8442..#8444` | [CompassShape](../Source/Game/Screen/CompassShape.asm) | переход к выбору изображения указателя компаса |
| `#8445..#844E` | [NextCharacterRow](../Source/Game/Screen/NextCharacterRow.asm) | коррекция адреса после перехода вниз через восемь пиксельных строк |
| `#844F..#8480` | [PreviousCharacterRow](../Source/Game/Screen/PreviousCharacterRow.asm) | коррекция адреса после перехода вверх через границу знакоместа |
| `#8481..#8489` | [RepeatEnergyRecovery](../Source/Game/Screen/RepeatEnergyRecovery.asm) | повторное восстановление энергии до переполнения счётчика A |
| `#848A..#84B4` | [ConsumeEscapePod](../Source/Game/Screen/ConsumeEscapePod.asm) | расход спасательной капсулы и сброс ожидаемого счётчика вылета |
| `#84B5..#84D8` | [RestoreCompassBackground](../Source/Game/Screen/RestoreCompassBackground.asm) | восстановление фона компаса размером 24 на 23 пикселя |
| `#84D9..#853F` | [UpdateIndicators](../Source/Game/Screen/UpdateIndicators.asm) | перерисовка только изменившихся полос приборной панели |
| `#8540..#854E` | [DrawIndicatorMarker](../Source/Game/Screen/DrawIndicatorMarker.asm) | настройка общего рисования на отдельный маркер |
| `#854F..#85CB` | [DrawIndicatorBar](../Source/Game/Screen/DrawIndicatorBar.asm) | рисование пятистрочной шкалы шириной пять байтов |
| `#85CC..#85E0` | [DrawShortIndicator](../Source/Game/Screen/DrawShortIndicator.asm) | рисование шкалы, целиком помещающейся в первом байте |
| `#85E1..#85F4` | [DrawEmptyIndicator](../Source/Game/Screen/DrawEmptyIndicator.asm) | рисование пустой шкалы с правой границей |
| `#85F5..#8605` | [IndicatorMarkerMask](../Source/Game/Screen/IndicatorMarkerMask.asm) | расчёт маски маркера внутри текущего байта шкалы |
| `#8606..#862A` | [WriteIndicatorMask](../Source/Game/Screen/WriteIndicatorMask.asm) | запись граничного байта шкалы с коррекцией маркера |
| `#862B..#8642` | [RightArcDown](../Source/Game/Screen/RightArcDown.asm) | подготовка половины окружности справа, движение вниз |
| `#8643..#8659` | [RightArcUp](../Source/Game/Screen/RightArcUp.asm) | подготовка половины окружности справа, движение вверх |
| `#865A..#8671` | [LeftArcDown](../Source/Game/Screen/LeftArcDown.asm) | подготовка половины окружности слева, движение вниз |
| `#8672..#8688` | [LeftArcUp](../Source/Game/Screen/LeftArcUp.asm) | подготовка половины окружности слева, движение вверх |
| `#8689..#86A0` | [UnclippedArcDown](../Source/Game/Screen/UnclippedArcDown.asm) | подготовка половины окружности без бокового отсечения, движение вниз |
| `#86A1..#86B7` | [UnclippedArcUp](../Source/Game/Screen/UnclippedArcUp.asm) | подготовка половины окружности без бокового отсечения, движение вверх |
| `#86B8..#86C3` | [FillRowsUp](../Source/Game/Screen/FillRowsUp.asm) | выбор заполнения или пропуска строк при движении вверх |
| `#86C4..#86CF` | [FillRowsDown](../Source/Game/Screen/FillRowsDown.asm) | выбор заполнения или пропуска строк при движении вниз |
| `#86D0..#86DD` | [DrawFilledCircle](../Source/Game/Screen/DrawFilledCircle.asm) | рисование заполненного круга с быстрым путём для малого радиуса |
| `#86DE..#86E3` | [DrawCircleOutline](../Source/Game/Screen/DrawCircleOutline.asm) | рисование контура окружности с быстрым путём для малого радиуса |
| `#86E4..#86ED` | [DrawLargeOutline](../Source/Game/Screen/DrawLargeOutline.asm) | установка контурного режима и общий выход построителя окружности |

## Sound

| Адреса | Исходник | Назначение |
|---|---|---|
| `#9527..#953C` | [PlayLaunchSound](../Source/Game/Sound/PlayLaunchSound.asm) | синхронный звук старта с проверкой настройки звука |
| `#953D..#9547` | [PlayHyperjumpSound](../Source/Game/Sound/PlayHyperjumpSound.asm) | синхронный звук гиперперехода |
| `#9548..#9578` | [PlayDestructionSound](../Source/Game/Sound/PlayDestructionSound.asm) | синхронное воспроизведение шума разрушения и таблица эффектов |
| `#9579..#95A5` | [UpdateSound](../Source/Game/Sound/UpdateSound.asm) | выбор запроса звука и обработка одного пакета активного эффекта |
| `#95A6..#95CE` | [StepNoise](../Source/Game/Sound/StepNoise.asm) | воспроизведение одного пакета шумовых отсчётов из памяти |
| `#95CF..#95E6` | [StartExplosionNoise](../Source/Game/Sound/StartExplosionNoise.asm) | инициализация заключительного шума разрушения |
| `#95E7..#9623` | [StepDataTone](../Source/Game/Sound/StepDataTone.asm) | воспроизведение пакета тона с периодом из байтов памяти |
| `#9624..#969A` | [StepPitchSweep](../Source/Game/Sound/StepPitchSweep.asm) | воспроизведение 15 периодов тона с изменяемой частотой |
| `#969B..#96B6` | [StartLaunchNoise](../Source/Game/Sound/StartLaunchNoise.asm) | инициализация шума старта и общий параметризованный вход |
| `#96B7..#96C4` | [StartHyperjumpNoise](../Source/Game/Sound/StartHyperjumpNoise.asm) | подготовка шумовых параметров гиперперехода |
| `#96C5..#96C8` | [DivideBC16](../Source/Game/Sound/DivideBC16.asm) | логическое деление беззнакового BC на 16 |
| `#96C9..#96CC` | [DivideBC8](../Source/Game/Sound/DivideBC8.asm) | логическое деление беззнакового BC на 8 |
| `#96CD..#96D0` | [DivideBC4](../Source/Game/Sound/DivideBC4.asm) | логическое деление беззнакового BC на 4 |
| `#96D1..#96D5` | [DivideBC2](../Source/Game/Sound/DivideBC2.asm) | логическое деление беззнакового BC на 2 |

## Text

| Адреса | Исходник | Назначение |
|---|---|---|
| `#D421..#D424` | [PrintInlineToken](../Source/Game/Text/PrintInlineToken.asm) | Печать токена, записанного непосредственно после CALL |
| `#D425..#D45E` | [PrintMainToken](../Source/Game/Text/PrintMainToken.asm) | Рекурсивное раскрытие токенов основной текстовой таблицы |
| `#D45F..#D46F` | [PrintDescriptionToken](../Source/Game/Text/PrintDescriptionToken.asm) | Раскрытие токена второй таблицы сообщений |
| `#D470..#D48D` | [PrintDescriptionByte](../Source/Game/Text/PrintDescriptionByte.asm) | Выбор способа интерпретации байта описания |
| `#D48E..#D498` | [PrintDescriptionString](../Source/Game/Text/PrintDescriptionString.asm) | Печать строки с нулевым завершителем и токенами |
| `#D499..#D4E0` | [ApplyTextCase](../Source/Game/Text/ApplyTextCase.asm) | Выбор регистра букв перед рисованием символа |
| `#D4E1..#D545` | [DrawCharacter8x8](../Source/Game/Text/DrawCharacter8x8.asm) | Вывод восьмистрочного символа в экран Spectrum |
| `#D546..#D54E` | [XorCharacterScanlines](../Source/Game/Text/XorCharacterScanlines.asm) | Наложение глифа по вертикальным строкам экрана |
| `#D54F..#D553` | [SetPromptAttributes](../Source/Game/Text/SetPromptAttributes.asm) | Установка зелёных атрибутов строки приглашения |
| `#D554..#D55E` | [FillInnerAttributeRow](../Source/Game/Text/FillInnerAttributeRow.asm) | Заполнение внутренней части строки атрибутов |
| `#D55F..#D562` | [DrawFullWidthRule](../Source/Game/Text/DrawFullWidthRule.asm) | Горизонтальная сплошная линия шириной 256 пикселей |
| `#D563..#D567` | [FillBytes](../Source/Game/Text/FillBytes.asm) | Заполнение последовательной области памяти |
| `#D568..#D594` | [ApplyAttributeRuns](../Source/Game/Text/ApplyAttributeRuns.asm) | Установка атрибутов по компактному списку строк |
| `#D595..#D5B3` | [PrintTwoLetterSyllable](../Source/Game/Text/PrintTwoLetterSyllable.asm) | Печать одного или двух символов слоговой таблицы |
| `#D5B4..#D5CA` | [CheckMineralLifeColony](../Source/Game/Text/CheckMineralLifeColony.asm) | Проверка жизнеспособности колонии MINERAL LIFE |
| `#D5CB..#D5E0` | [InitializeSixTriples](../Source/Game/Text/InitializeSixTriples.asm) | Инициализация шести трёхбайтовых записей |
| `#D5E1..#D60A` | [NextDescriptionRandom](../Source/Game/Text/NextDescriptionRandom.asm) | Детерминированный генератор вариантов описания планеты |
| `#D60B..#D61C` | [CheckObjectRandomGate](../Source/Game/Text/CheckObjectRandomGate.asm) | Вероятностный фильтр действия объекта |
| `#D61D..#D645` | [ClearViewAndFrame](../Source/Game/Text/ClearViewAndFrame.asm) | Очистка обзорной области и восстановление её рамки |
| `#D646..#D674` | [DrawViewFrame](../Source/Game/Text/DrawViewFrame.asm) | Рисование верхней, боковых и нижней границ окна |
| `#D675..#D679` | [CheckSavedSystemRegion](../Source/Game/Text/CheckSavedSystemRegion.asm) | Проверка области для сохранённого семени планеты |
| `#D67A..#D6A9` | [CheckMissionRegion](../Source/Game/Text/CheckMissionRegion.asm) | Геометрическая проверка области миссии со встроенным порогом |
| `#D6AA..#D6F8` | [HandleSpecialObjectMission](../Source/Game/Text/HandleSpecialObjectMission.asm) | Изменение миссионных флагов при событии объекта |
| `#D6F9..#D754` | [OfferRegionDependentMission](../Source/Game/Text/OfferRegionDependentMission.asm) | Проверка условий выдачи специальных миссионных сообщений |
| `#D755..#D7A9` | [PrintRankWithMissionSuffix](../Source/Game/Text/PrintRankWithMissionSuffix.asm) | Печать боевого звания и дополнительных миссионных отметок |
| `#D7AA..#D7B8` | [InvalidateObjectLineCache](../Source/Game/Text/InvalidateObjectLineCache.asm) | Пометка двух частей кэша объекта недействительными |
| `#D7B9..#D87E` | [DrawProjectedSunAndTextDispatch](../Source/Game/Text/DrawProjectedSunAndTextDispatch.asm) | Вывод проекции светила и таблица управляющих кодов текста |
| `#D87F..#D8CD` | [CapitalizeNextLetterAndTextCommands](../Source/Game/Text/CapitalizeNextLetterAndTextCommands.asm) | Однократная заглавная буква и хвост таблицы текстовых команд |
| `#D8CE..#D8DC` | [EquipmentMenuLimit](../Source/Game/Text/EquipmentMenuLimit.asm) | Получение допустимого предела номера оборудования |
| `#D8DD..#D8E4` | [BeginSystemLaunchState](../Source/Game/Text/BeginSystemLaunchState.asm) | Установка маркера прибытия и возврат указателя семени |
| `#D8E5..#D906` | [SetDescriptionModeAndHelpers](../Source/Game/Text/SetDescriptionModeAndHelpers.asm) | Выбор режима второй текстовой таблицы |

## Trade

| Адреса | Исходник | Назначение |
|---|---|---|
| `#E142..#E147` | [RefreshMarketRandom](../Source/Game/Trade/RefreshMarketRandom.asm) | Обновление случайного параметра рынка |
| `#E148..#E1E7` | [GenerateMarket](../Source/Game/Trade/GenerateMarket.asm) | Расчёт цен и запасов 17 товаров |
| `#E1E8..#E1F6` | [OptionalBeep](../Source/Game/Trade/OptionalBeep.asm) | Звуковой сигнал по разрешению настройки |
| `#E1F7..#E204` | [WaitForKeyCode](../Source/Game/Trade/WaitForKeyCode.asm) | Ожидание кода клавиши после паузы |
| `#E205..#E211` | [ClearPressedKeyBits](../Source/Game/Trade/ClearPressedKeyBits.asm) | Очистка четырёх байтов нажатий |
| `#E212..#E224` | [PrintMarketRow](../Source/Game/Trade/PrintMarketRow.asm) | Печать строки товара на рынке |
| `#E225..#E24C` | [PrintMarketPriceAndStock](../Source/Game/Trade/PrintMarketPriceAndStock.asm) | Вывод цены и количества товара |
| `#E24D..#E267` | [PrintEmptyStockOrQuantity](../Source/Game/Trade/PrintEmptyStockOrQuantity.asm) | Окончание строки рыночного остатка |
| `#E268..#E27E` | [PrintNonemptyCargoRow](../Source/Game/Trade/PrintNonemptyCargoRow.asm) | Печать непустого слота трюма |
| `#E27F..#E291` | [PrintCargoQuantity](../Source/Game/Trade/PrintCargoQuantity.asm) | Печать количества в текущем слоте трюма |
| `#E292..#E296` | [PrintDescriptionColon](../Source/Game/Trade/PrintDescriptionColon.asm) | Сообщение второй таблицы с двоеточием |
| `#E297..#E29D` | [PrintMainTokenColon](../Source/Game/Trade/PrintMainTokenColon.asm) | Основной токен с двоеточием |
| `#E29E..#E2A5` | [PrintMainTokenSpace](../Source/Game/Trade/PrintMainTokenSpace.asm) | Основной токен с пробелом |
| `#E2A6..#E2A8` | [PrintTokenNewline](../Source/Game/Trade/PrintTokenNewline.asm) | Токен с переводом строки |
| `#E2A9..#E2B0` | [Newline](../Source/Game/Trade/Newline.asm) | Перевод текстового курсора на новую строку |
| `#E2B1..#E2B6` | [IncrementTextRow](../Source/Game/Trade/IncrementTextRow.asm) | Увеличение строки текстового курсора |
| `#E2B7..#E2BB` | [ResetTextColumn](../Source/Game/Trade/ResetTextColumn.asm) | Установка нулевой колонки печати |
| `#E2BC..#E2BF` | [SetInlineTextColumn](../Source/Game/Trade/SetInlineTextColumn.asm) | Установка X из байта после CALL |
| `#E2C0..#E2C7` | [SetTextColumn](../Source/Game/Trade/SetTextColumn.asm) | Установка колонки с контролем ширины |
| `#E2C8..#E2D4` | [SetTextRow](../Source/Game/Trade/SetTextRow.asm) | Установка строки с циклическим ограничением |
| `#E2D5..#E2F7` | [ErasePreviousCharacter](../Source/Game/Trade/ErasePreviousCharacter.asm) | Удаление предыдущего символа ввода |
| `#E2F8..#E305` | [PrintDecoratedToken](../Source/Game/Trade/PrintDecoratedToken.asm) | Печать токена между управляющими кодами 6 и 8 |
| `#E306..#E310` | [PrintScreenCaption](../Source/Game/Trade/PrintScreenCaption.asm) | Печать заголовка с обновлением полос экрана |
| `#E311..#E31D` | [PrintZeroTerminatedString](../Source/Game/Trade/PrintZeroTerminatedString.asm) | Печать основной токенизированной строки |
| `#E31E..#E346` | [PrintCommodityUnit](../Source/Game/Trade/PrintCommodityUnit.asm) | Печать единицы измерения товара |
| `#E347..#E359` | [PrintKilometreSuffix](../Source/Game/Trade/PrintKilometreSuffix.asm) | Окончание единицы KM и проверка тоннажа |
| `#E35A..#E35D` | [Wait20Interrupts](../Source/Game/Trade/Wait20Interrupts.asm) | Задержка на 20 прерываний |
| `#E35E..#E363` | [Wait36Interrupts](../Source/Game/Trade/Wait36Interrupts.asm) | Задержка на 36 прерываний |
| `#E364..#E36A` | [SaveTextPosition](../Source/Game/Trade/SaveTextPosition.asm) | Сохранение координат печати |
| `#E36B..#E379` | [ClearPromptRows](../Source/Game/Trade/ClearPromptRows.asm) | Очистка двух строк ввода |
| `#E37A..#E37C` | [ClearSecondPromptRow](../Source/Game/Trade/ClearSecondPromptRow.asm) | Очистка второй строки приглашения |
| `#E37D..#E38C` | [FillCharacterRowInterior](../Source/Game/Trade/FillCharacterRowInterior.asm) | Заполнение пикселей внутри символьной строки |
| `#E38D..#E397` | [RestoreTextPosition](../Source/Game/Trade/RestoreTextPosition.asm) | Восстановление печатного курсора |
| `#E6C6..#E6ED` | [MissionRegionMetric](../Source/Game/Trade/MissionRegionMetric.asm) | Метрика специальной области миссии |
| `#E6EE..#E710` | [ResetCloakingAndSeedFlightRandom](../Source/Game/Trade/ResetCloakingAndSeedFlightRandom.asm) | Состояние маскировки и полётный случайный параметр |
| `#E711..#E775` | [BuyCargoLoop](../Source/Game/Trade/BuyCargoLoop.asm) | Последовательная покупка 17 товаров |
| `#E776..#E7CE` | [InputTradeQuantity](../Source/Game/Trade/InputTradeQuantity.asm) | Ввод количества с пробной операцией |
| `#E7CF..#E7D6` | [ShowTradeSuccess](../Source/Game/Trade/ShowTradeSuccess.asm) | Подтверждение торговой операции |
| `#E7D7..#E7D9` | [TradeFeedback](../Source/Game/Trade/TradeFeedback.asm) | Звуковое подтверждение торговли |
| `#E7DA..#E81B` | [IndirectTradeCallbackAndBuy](../Source/Game/Trade/IndirectTradeCallbackAndBuy.asm) | Косвенный вызов и обработчик покупки груза |
| `#E81C..#E82E` | [TradeErrorMessage](../Source/Game/Trade/TradeErrorMessage.asm) | Сообщение ошибки торговли перед откатом |
| `#E82F..#E831` | [RollbackFailedTrade](../Source/Game/Trade/RollbackFailedTrade.asm) | Откат неудачной операции и сигнал |
| `#E832..#E83B` | [TradeBeepAndPause](../Source/Game/Trade/TradeBeepAndPause.asm) | Сигнал и пауза с кодом повторного ввода |
| `#E83C..#E85C` | [SnapshotTrade](../Source/Game/Trade/SnapshotTrade.asm) | Снимок изменяемых полей транзакции |
| `#E85D..#E87D` | [RestoreTradeSnapshot](../Source/Game/Trade/RestoreTradeSnapshot.asm) | Восстановление состояния до операции |
| `#E87E..#E8D8` | [PromptCargoQuantityAndRefugees](../Source/Game/Trade/PromptCargoQuantityAndRefugees.asm) | Приглашение количества товара и условия миссии |
| `#E8D9..#E8E4` | [PrepareTradeScreen](../Source/Game/Trade/PrepareTradeScreen.asm) | Подготовка торгового экрана |
| `#E8E5..#E961` | [TradeTitleAndSellLoop](../Source/Game/Trade/TradeTitleAndSellLoop.asm) | Заголовок торговли и цикл продажи груза |
| `#E962..#E972` | [ResetTradeIterators](../Source/Game/Trade/ResetTradeIterators.asm) | Начальные указатели обхода товаров |
| `#E973..#E986` | [OpenEquipmentShop](../Source/Game/Trade/OpenEquipmentShop.asm) | Заголовок меню покупки оборудования |
| `#E987..#E9BE` | [ListEquipmentChoices](../Source/Game/Trade/ListEquipmentChoices.asm) | Перечень оборудования по технологии мира |
| `#E9BF..#E9E5` | [PrintEquipmentPrice](../Source/Game/Trade/PrintEquipmentPrice.asm) | Цена оборудования и продолжение списка |
| `#E9E6..#EA3A` | [HandleEquipmentPurchase](../Source/Game/Trade/HandleEquipmentPurchase.asm) | Проверка пункта и списание цены оборудования |
| `#EA3B..#EADF` | [InstallPurchasedEquipment](../Source/Game/Trade/InstallPurchasedEquipment.asm) | Выдача оборудования и выбор направления лазера |
| `#EAE0..#EB26` | [ChooseLaserDirection](../Source/Game/Trade/ChooseLaserDirection.asm) | Замена лазера с возвратом цены прежнего |
| `#EB27..#EB2E` | [EquipmentPaymentFailed](../Source/Game/Trade/EquipmentPaymentFailed.asm) | Откат покупки при недостатке денег |
| `#EB2F..#EB37` | [GetEquipmentPriceAddress](../Source/Game/Trade/GetEquipmentPriceAddress.asm) | Адрес трёхбайтной цены оборудования |
| `#EB38..#EB3D` | [GetEquipmentStateAddress](../Source/Game/Trade/GetEquipmentStateAddress.asm) | Адрес состояния оборудования |
| `#EB3E..#EB42` | [AddByteOffsetToHL](../Source/Game/Trade/AddByteOffsetToHL.asm) | Прибавление байтового смещения к HL |
| `#EB43..#EB62` | [EquipmentAlreadyOwned](../Source/Game/Trade/EquipmentAlreadyOwned.asm) | Отказ повторной установки и откат |

## Travel

| Адреса | Исходник | Назначение |
|---|---|---|
| `#DA7A..#DAB3` | [UpdateFlightMessages](../Source/Game/Travel/UpdateFlightMessages.asm) | Обновление сообщений поверх обзорного окна |
| `#DAB4..#DAE5` | [SelectQueuedFlightMessage](../Source/Game/Travel/SelectQueuedFlightMessage.asm) | Выбор следующего события из очереди сообщений |
| `#DAE6..#DB2D` | [SetMessageCoordinatesAndRender](../Source/Game/Travel/SetMessageCoordinatesAndRender.asm) | Установка сообщения и обслуживание его времени жизни |
| `#DB2E..#DB90` | [UpdateAmbientFlightMessage](../Source/Game/Travel/UpdateAmbientFlightMessage.asm) | Выбор предупреждений и сообщения о заправке |
| `#DB91..#DC28` | [ClearFlightEventsAndHandleJump](../Source/Game/Travel/ClearFlightEventsAndHandleJump.asm) | Очистка десяти событий и обработка клавиш гиперперехода |
| `#DC29..#DC82` | [TickJumpCountdown](../Source/Game/Travel/TickJumpCountdown.asm) | Уменьшение и отображение отсчёта гиперперехода |
| `#DC83..#DC8D` | [RotateTwoSeedBytesAdvance](../Source/Game/Travel/RotateTwoSeedBytesAdvance.asm) | Циклический поворот двух байтов семени с продвижением указателя |
| `#DC8E..#DCE8` | [CommitJumpFuelAndMishap](../Source/Game/Travel/CommitJumpFuelAndMishap.asm) | Списание топлива и выбор обычного выхода либо межзвёздной встречи |
| `#DCE9..#DD47` | [EnterTargetSystem](../Source/Game/Travel/EnterTargetSystem.asm) | Установка новой текущей системы после гиперперехода |
| `#DD48..#DD52` | [BuildPlanetCoordinateByte](../Source/Game/Travel/BuildPlanetCoordinateByte.asm) | Формирование очередного байта координаты планеты |
| `#DD53..#DD5F` | [BuildPlanetCoordinateMagnitude](../Source/Game/Travel/BuildPlanetCoordinateMagnitude.asm) | Формирование величины из пары соседних байтов семени |
| `#DD60..#DDEB` | [BuildStationGeometry](../Source/Game/Travel/BuildStationGeometry.asm) | Размещение станции относительно новой планеты |
| `#DDEC..#DE66` | [LaserTypeAndArrivalEvents](../Source/Game/Travel/LaserTypeAndArrivalEvents.asm) | Выбор типа лазера и обработка прибытия |
| `#DE67..#DE96` | [GetSalePriceAndMissionFlags](../Source/Game/Travel/GetSalePriceAndMissionFlags.asm) | Чтение цены продажи с переключаемой специальной надбавкой |
| `#DE97..#DEA1` | [EmptyFuelWithWarning](../Source/Game/Travel/EmptyFuelWithWarning.asm) | Обнуление топлива с постановкой предупреждения |
| `#DEA2..#DF02` | [SetFuelAndGauge](../Source/Game/Travel/SetFuelAndGauge.asm) | Ограничение топлива и обновление указателя прибора |

## Universe

| Адреса | Исходник | Назначение |
|---|---|---|
| `#7584..#75BF` | [DrawSunAndPlanet](../Source/Game/Universe/DrawSunAndPlanet.asm) | проекция и вывод солнца и планеты |
| `#75C0..#75E0` | [ExpandNovaRadius](../Source/Game/Universe/ExpandNovaRadius.asm) | расширение экранного радиуса солнца при сверхновой |
| `#75E1..#7798` | [ProjectCelestialBody](../Source/Game/Universe/ProjectCelestialBody.asm) | перспективная проекция светила для четырёх направлений обзора |
| `#7799..#779F` | [ShiftSmallBodyProjectionOperands](../Source/Game/Universe/ShiftSmallBodyProjectionOperands.asm) | перегруппировка младших координат перед проекцией светила |
| `#77A0..#783A` | [DivideCelestialAxis](../Source/Game/Universe/DivideCelestialAxis.asm) | нормализация и деление одной координаты проекции светила |
| `#783B..#783C` | [DivideBodyRadiusByte](../Source/Game/Universe/DivideBodyRadiusByte.asm) | подготовка деления восьмибитного радиуса |
| `#783D..#7852` | [DivideBodyProjectionFraction](../Source/Game/Universe/DivideBodyProjectionFraction.asm) | восемь разрядов дробного деления для светила |
| `#7853..#7860` | [UpdateCelestialCoordinates](../Source/Game/Universe/UpdateCelestialCoordinates.asm) | пересчёт координат небесных тел по движению игрока |
| `#7861..#7891` | [UpdateStationCoordinates](../Source/Game/Universe/UpdateStationCoordinates.asm) | обновление станционного слота и проверка его рабочего диапазона |
| `#7892..#7897` | [SetStationEnergy](../Source/Game/Universe/SetStationEnergy.asm) | установка исходной энергии станционного объекта |
| `#7898..#78B0` | [DrawStarsWithJumpEffect](../Source/Game/Universe/DrawStarsWithJumpEffect.asm) | вывод звёзд с дополнительными проходами при ускоренном перемещении |
| `#78B1..#79F8` | [UpdateAndDrawStarField](../Source/Game/Universe/UpdateAndDrawStarField.asm) | пересчёт и вывод звёздного поля по углам, скорости и направлению вида |
| `#79F9..#7A26` | [SelectGalaxyOnJump](../Source/Game/Universe/SelectGalaxyOnJump.asm) | выбор номера галактики при завершении межгалактического перехода |
| `#7A27..#7A58` | [SelectSpecialCargoText](../Source/Game/Universe/SelectSpecialCargoText.asm) | выбор варианта текста специального груза |
| `#7A59..#7A9D` | [AddSignedStarCoordinate](../Source/Game/Universe/AddSignedStarCoordinate.asm) | прибавление знако-модульного смещения к координате звезды |
| `#7A9E..#7B36` | [InitializeExtendedObjectMetadata](../Source/Game/Universe/InitializeExtendedObjectMetadata.asm) | инициализация расширенных признаков и связей объекта по каталогу модели |
| `#7B37..#7B49` | [PrepareRandomLaserEndpoint](../Source/Game/Universe/PrepareRandomLaserEndpoint.asm) | подготовка метаданных и случайной конечной точки луча |
| `#7B4A..#7B69` | [CompareObjectAxisDistance](../Source/Game/Universe/CompareObjectAxisDistance.asm) | проверка разности одной целой координаты двух объектов |
| `#7B6A..#7B80` | [CheckLinkedObjectInteraction](../Source/Game/Universe/CheckLinkedObjectInteraction.asm) | поиск объекта по упакованному номеру и проверка взаимодействия |
| `#7B81..#7C12` | [TryObjectInteraction](../Source/Game/Universe/TryObjectInteraction.asm) | проверка совместимости и близости двух объектов с нанесением урона |
| `#7C13..#7C5F` | [FindInteractingObject](../Source/Game/Universe/FindInteractingObject.asm) | поиск цели для расширенного взаимодействия объекта |
| `#7C60..#7D3D` | [UpdateExtendedObjectEffects](../Source/Game/Universe/UpdateExtendedObjectEffects.asm) | обновление связей объектов и вывод расширенных лучевых эффектов |
| `#7D3E..#7D4C` | [ApplyEcmToStandardMissile](../Source/Game/Universe/ApplyEcmToStandardMissile.asm) | проверка типа ракеты и установка запроса уничтожения от ECM |
| `#7D4D..#7DA3` | [DispatchLinkedObjectAction](../Source/Game/Universe/DispatchLinkedObjectAction.asm) | диспетчер действий с назначением цели новой ракете и обработкой лазерной связи |
| `#7DA4..#7DB4` | [AwardUnlinkedDestructionBounty](../Source/Game/Universe/AwardUnlinkedDestructionBounty.asm) | денежная награда за уничтожение без связанного участника |
| `#7DB5..#7DC4` | [AwardOrStoreLinkedDestruction](../Source/Game/Universe/AwardOrStoreLinkedDestruction.asm) | приращение рейтинга либо сохранение номера участника уничтожения |
| `#7DC5..#7EA8` | [SpawnDestructionContentsAndEffects](../Source/Game/Universe/SpawnDestructionContentsAndEffects.asm) | создание содержимого уничтоженного объекта и расширенные эффекты его проекции |
| `#7EA9..#7EC7` | [AdvanceCircularObjectEffect](../Source/Game/Universe/AdvanceCircularObjectEffect.asm) | продвижение восьмифазного кругового эффекта объекта |
| `#7EC8..#7EDD` | [GetObjectMetadataAddress](../Source/Game/Universe/GetObjectMetadataAddress.asm) | вычисление адреса расширенной записи по адресу основного слота |
| `#7EDE..#7F2C` | [HandleFastTravelStep](../Source/Game/Universe/HandleFastTravelStep.asm) | быстрый перенос небесных тел и станции по команде движения |
| `#7F2D..#7F63` | [MoveCoordinateDepthBy32](../Source/Game/Universe/MoveCoordinateDepthBy32.asm) | перенос знако-модульной глубины на 32 единицы |
| `#7F64..#7F80` | [CheckSpecialSystemOrRandom](../Source/Game/Universe/CheckSpecialSystemOrRandom.asm) | особая инициализация станционного слота при Z от #FCEA, иначе получение случайного байта |
| `#7F81..#7FBD` | [ApplyEnhancedFlightControl](../Source/Game/Universe/ApplyEnhancedFlightControl.asm) | усиление углов и скорости по дополнительной клавише |

## Wireframe

| Адреса | Исходник | Назначение |
|---|---|---|
| `#A84D..#A8AB` | [DrawWireframeObject](../Source/Game/Wireframe/DrawWireframeObject.asm) | построение каркаса и вывод необязательного лазерного луча |
| `#A8AC..#A8DD` | [StartObjectExplosion](../Source/Game/Wireframe/StartObjectExplosion.asm) | преобразование полей движения объекта в параметры экранного взрыва |
| `#A8DE..#A8EB` | [FinishObjectAndDrawLaser](../Source/Game/Wireframe/FinishObjectAndDrawLaser.asm) | завершение вывода объекта и условный вывод его лазерного луча |
| `#A8EC..#A9C8` | [AdvanceObjectMetadata](../Source/Game/Wireframe/AdvanceObjectMetadata.asm) | переход к следующей расширенной записи объекта |
| `#A9C9..#AA0F` | [BuildProjectedVertexTable](../Source/Game/Wireframe/BuildProjectedVertexTable.asm) | обход вершин с отбором по детализации и признакам граней |
| `#AA10..#AA1F` | [AnyPackedFaceVisible](../Source/Game/Wireframe/AnyPackedFaceVisible.asm) | объединение видимости двух граней из упакованного байта |
| `#AA20..#AA2A` | [ReadFaceVisibilityNibble](../Source/Game/Wireframe/ReadFaceVisibilityNibble.asm) | чтение видимости грани по младшей тетраде номера |
| `#AA2B..#AA30` | [SavePreviousVertexFlags](../Source/Game/Wireframe/SavePreviousVertexFlags.asm) | сохранение предыдущего байта признаков вершины |
| `#AA31..#AA3C` | [ReadVertexFlags](../Source/Game/Wireframe/ReadVertexFlags.asm) | чтение признаков вершины через текущий указатель модели |
| `#AA3D..#AAFA` | [RotateNearVertexComponent](../Source/Game/Wireframe/RotateNearVertexComponent.asm) | поворот компоненты ближней вершины с повышенной точностью |
| `#AAFB..#AB0A` | [AddSignedByteMagnitudes](../Source/Game/Wireframe/AddSignedByteMagnitudes.asm) | сложение двух байтовых модулей с отдельными знаками |
| `#AB0B..#AB1D` | [MultiplyHighByteApprox](../Source/Game/Wireframe/MultiplyHighByteApprox.asm) | приближённый старший байт произведения двух беззнаковых байтов |
| `#AB1E..#AB33` | [MultiplyScaledVertexComponent](../Source/Game/Wireframe/MultiplyScaledVertexComponent.asm) | умножение масштабированной компоненты вершины на элемент матрицы |
| `#AB34..#AB4E` | [MultiplyBytesApprox](../Source/Game/Wireframe/MultiplyBytesApprox.asm) | приближённое 16-битное произведение байтов по четверть-квадратам |
| `#AB4F..#AB72` | [AddRotatedVertexCoordinate](../Source/Game/Wireframe/AddRotatedVertexCoordinate.asm) | сложение координаты объекта и преобразованной координаты вершины |
| `#AB73..#ABAE` | [RotateDistantVertex](../Source/Game/Wireframe/RotateDistantVertex.asm) | поворот обычной вершины без дополнительного увеличения точности |
| `#ABAF..#ABBF` | [GetSystemVariationByte](../Source/Game/Wireframe/GetSystemVariationByte.asm) | смешивание координаты системы и полётного параметра |
| `#ABC0..#AC00` | [SumCachedVertexProducts](../Source/Game/Wireframe/SumCachedVertexProducts.asm) | пересчёт компоненты вершины по сохранённым произведениям и новым знакам |
| `#AC01..#AC68` | [RotateCoordinateAndCacheProducts](../Source/Game/Wireframe/RotateCoordinateAndCacheProducts.asm) | вычисление одной компоненты повёрнутого вектора и кэширование произведений |
| `#AC69..#AC8A` | [DivideProjectionRatio](../Source/Game/Wireframe/DivideProjectionRatio.asm) | нормализация и дробное деление перспективной проекции |
| `#AC8B..#AE00` | [DivideFractionAndProjectVertex](../Source/Game/Wireframe/DivideFractionAndProjectVertex.asm) | дробное деление и общий расчёт экранной вершины |
| `#AE01..#AE0D` | [LocateVertexCoordinateData](../Source/Game/Wireframe/LocateVertexCoordinateData.asm) | подготовка адреса координат вершин и потока их признаков |
| `#AE0E..#AE1C` | [LocateFaceNormalData](../Source/Game/Wireframe/LocateFaceNormalData.asm) | подготовка адреса нормалей и потока признаков граней |
| `#AE1D..#AE25` | [AdvanceVertexFlags](../Source/Game/Wireframe/AdvanceVertexFlags.asm) | переход к следующей трёхбайтовой записи признаков вершины |
| `#AE26..#AE34` | [AdvanceNormalFlags](../Source/Game/Wireframe/AdvanceNormalFlags.asm) | переход к следующему байту признаков нормали |
| `#AE35..#AE4F` | [InitializeObjectFromModelNumber](../Source/Game/Wireframe/InitializeObjectFromModelNumber.asm) | инициализация объекта по номеру в общем каталоге моделей |
| `#AE50..#AE68` | [ReadProjectedVertex](../Source/Game/Wireframe/ReadProjectedVertex.asm) | чтение экранных координат и признаков вершины |
| `#AE69..#AE89` | [OrthogonalizeObjectYAxis](../Source/Game/Wireframe/OrthogonalizeObjectYAxis.asm) | приближённое восстановление перпендикулярности осей X и Y |
| `#AE8A..#AECB` | [CorrectYAxisComponent](../Source/Game/Wireframe/CorrectYAxisComponent.asm) | коррекция одной компоненты Y для ортогональности к X |
| `#AECC..#AF21` | [BuildObjectRotationMatrix](../Source/Game/Wireframe/BuildObjectRotationMatrix.asm) | восстановление оси Z и построение матрицы поворота объекта |
| `#AF22..#AFA7` | [CrossProductComponent](../Source/Game/Wireframe/CrossProductComponent.asm) | разность двух знаковых произведений для компоненты векторного произведения |
| `#B044..#B285` | [DrawClippedLine](../Source/Game/Wireframe/DrawClippedLine.asm) | арифметическое отсечение и два самомодифицируемых цикла линий OR/XOR |
| `#B286..#B29E` | [MultiplyClippingDistance](../Source/Game/Wireframe/MultiplyClippingDistance.asm) | умножение расстояния до границы на коэффициент 8.8 |
| `#B29F..#B2A9` | [UnscaleClippingRatio](../Source/Game/Wireframe/UnscaleClippingRatio.asm) | восстановление старших разрядов разностей перед делением |
| `#B2AA..#B3B1` | [DivideSlopeAndDrawScanner](../Source/Game/Wireframe/DivideSlopeAndDrawScanner.asm) | деление разностей линии и альтернативная проекция сканерного маркера |
| `#B3B2..#B43F` | [RefreshScannerBackground](../Source/Game/Wireframe/RefreshScannerBackground.asm) | обновление фона сканера и атрибутов индикаторной области |
| `#B440..#B4B0` | [DrawScannerMarkerSegment](../Source/Game/Wireframe/DrawScannerMarkerSegment.asm) | вывод отрезка маркера сканера с изменяемыми командами шага |
| `#B4B1..#B4B9` | [SetTargetDisplayState](../Source/Game/Wireframe/SetTargetDisplayState.asm) | сохранение состояния цели и сброс старшего флага метаданных |
| `#B4BA..#B4C3` | [MergeInverseHostilityFlag](../Source/Game/Wireframe/MergeInverseHostilityFlag.asm) | добавление бита 2 к A при сброшенном бите исходного байта |
| `#B4C4..#B4D7` | [ReadObjectTacticsGates](../Source/Game/Wireframe/ReadObjectTacticsGates.asm) | чтение двух независимых условий допуска тактического обновления |
