# Переменные, поля и изменяемые операнды

Имена получены по коду этого TRD. Объявления `STRUCT` задают смещения и размеры,
`Includes/Variables` связывает имена с физическими метками в исходниках.
Размещение памяти не меняется. Операнды команд и экранные оверлеи отмечены отдельно.

`DB #00` обозначает исходное значение, оно само по себе не означает мусор или свободную память.
Например, `GalaxyState.NameCursor` указывает на следующее место записи имени,
`FlightState.SoundRequests` содержит запросы звука, а `Keyboard.RowPOIUY` — полуряд клавиш.

Схемы битов находятся рядом с полями в `Includes/Structs`, номера клавиш — в `Includes/Const`.
Для `IX/IY` назначение поля определяется текущей базой регистра, а не только смещением.

Проверено привязок к символам сборки: 636. Ошибок адресов: 0.
Подробные прямые обращения и доказательства находятся в [VariableAudit.json](../Tools/Disasm/Reports/VariableAudit.json).

## [Disk](../Includes/Variables/Disk.inc)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskBuffer.Catalog` | `#5000` | представление буфера | каталог TR-DOS в экранном буфере |
| `DiskBuffer.Work` | `#606F` | представление буфера | повторное использование игрового пула как буфера сектора |
| `DiskMark.NextValue` | `#6071` | представление буфера | следующее контрольное слово защитного сектора |
| `DiskMark.TimingKey` | `#6073` | представление буфера | слово измерения и ключа XOR |
| `DiskMark.Counters` | `#6075` | представление буфера | три печатаемых счётчика |
| `DiskMark.Suffix` | `#607B` | представление буфера | дополнительное слово служебного вывода |
| `DiskService.FreeSector` | `#6150` | представление буфера | следующие свободные сектор и дорожка |
| `DiskService.FileCount` | `#6153` | представление буфера | число записей каталога |
| `DiskService.FreeCount` | `#6154` | представление буфера | число свободных секторов |
| `DiskMark.OpenKey` | `#6161` | представление буфера | открытый байт ключа |
| `SaveName` | `#DED0` | представление буфера | восемь байтов имени в общем строковом буфере игры |
| `SaveName.Extension` | `#DED8` | представление буфера | расширение файла непосредственно после имени |
| `DiskBuffer.SavedSP` | `#FFFE` | представление буфера | место сохранения SP на время форматирования |

## [DiskGame](../Includes/Variables/DiskGame.inc)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DosDriveInit` | `#1FF3` | вход ROM | вход подготовки устройства, вызывается с A=DiskParameter |
| `DosInlineCall` | `#20B8` | вход ROM | внутренний вход с C,D из потока после CALL и B=1 |
| `DosWriteSector` | `#2D73` | вход ROM | внутренний вход TR-DOS для записи сектора |
| `DosBaseSide` | `#2F0A` | вход ROM | вход перед выбором стороны и позиционированием дорожки |
| `DosAltSide` | `#2F17` | вход ROM | дополнительный вход для нечётной логической дорожки |
| `DosReadSector` | `#2F1B` | вход ROM | внутренний вход TR-DOS для чтения сектора |
| `DosSeekTrack` | `#2F50` | вход ROM | вход позиционирования, A содержит физический номер дорожки |
| `DosPrepareIO` | `#2FC1` | вход ROM | вход подготовки перед циклом передачи секторов |
| `DosReadTrack` | `#3FE5` | вход ROM | внутренний вход приёма дорожки, C=#7F, DE=0 |

## [Keyboard](../Includes/Variables/Keyboard.inc)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `Keyboard` | `#4700` | представление буфера | матрица восьми полурядов в экранной памяти |
| `Keyboard.RowShiftZXCV` | `#4700` | поле буфера | полуряд виртуальной матрицы, младшие пять бит соответствуют клавишам |
| `Keyboard.RowASDFG` | `#4701` | поле буфера | полуряд виртуальной матрицы, младшие пять бит соответствуют клавишам |
| `Keyboard.RowQWERT` | `#4702` | поле буфера | полуряд виртуальной матрицы, младшие пять бит соответствуют клавишам |
| `Keyboard.Row12345` | `#4703` | поле буфера | полуряд виртуальной матрицы, младшие пять бит соответствуют клавишам |
| `Keyboard.Row09876` | `#4704` | поле буфера | полуряд виртуальной матрицы, младшие пять бит соответствуют клавишам |
| `Keyboard.RowPOIUY` | `#4705` | поле буфера | полуряд виртуальной матрицы, младшие пять бит соответствуют клавишам |
| `Keyboard.RowEnterLKJH` | `#4706` | поле буфера | полуряд виртуальной матрицы, младшие пять бит соответствуют клавишам |
| `Keyboard.RowSpaceSMNB` | `#4707` | поле буфера | полуряд виртуальной матрицы, младшие пять бит соответствуют клавишам |
| `Keyboard.ScannedMarker` | `#4708` | представление буфера | маркер после восьми полурядов, ReadKeyboard записывает 1 |

## [Sound](../Includes/Variables/Sound.inc)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `NoiseRomData` | `#0127` | адрес данных ROM | начало шумовых отсчётов в ПЗУ BASIC |

## [ActionTimer](../Source/DiskUtility/Demo/ActionTimer.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Demo.ActionTimer` | `#EA80` | данные | число уступок кадра до смены поведения |

## [BombDelayCounter](../Source/DiskUtility/Demo/BombDelayCounter.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Demo.BombDelay` | `#EA34` | данные | данные #EA34..#EA34 |

## [CoroutineStackPointers](../Source/DiskUtility/Demo/CoroutineStackPointers.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Demo.SavedStacks` | `#E6DC` | данные | SP игрового обработчика прерывания |
| `DiskUtility.Demo.DemoStack` | `#E6DE` | данные | SP сохранённых регистров корутины |

## [DemoMarkCellMap](../Source/DiskUtility/Demo/DemoMarkCellMap.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Demo.MarkCellMap` | `#ED2F` | данные | данные #ED2F..#ED36 |

## [DemoMarkCellShapes](../Source/DiskUtility/Demo/DemoMarkCellShapes.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Demo.MarkShapes` | `#ED5C` | данные | данные #ED5C..#ED63 |

## [DemoMarkShapeMasks](../Source/DiskUtility/Demo/DemoMarkShapeMasks.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Demo.ShapeMasks` | `#ED2A` | данные | данные #ED2A..#ED2E |

## [DemoMarkTail](../Source/DiskUtility/Demo/DemoMarkTail.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Demo.MarkTail` | `#EDCE` | данные | данные #EDCE..#EDD5 |

## [DrawDemoMarkXor](../Source/DiskUtility/Demo/DrawDemoMarkXor.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Demo.ShapeIndex` | `#0000` | операнд или смещение | нулевое смещение текущего индекса фигуры, IX является курсором потока |

## [ObjectCursor](../Source/DiskUtility/Demo/ObjectCursor.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Demo.ObjectCursor` | `#EB9A` | данные | адрес текущей записи FSpaceObject, начально станция |

## [ObjectMetadataCache](../Source/DiskUtility/Demo/ObjectMetadataCache.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Demo.SlotFlagCache` | `#EBE1` | данные | данные #EBE1..#EBE8 |

## [PitchWindowCounter](../Source/DiskUtility/Demo/PitchWindowCounter.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Demo.PitchWindow` | `#E992` | данные | данные #E992..#E992 |

## [ReservedDemoBytes](../Source/DiskUtility/Demo/ReservedDemoBytes.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Demo.ReservedBytes` | `#E825` | данные | данные #E825..#E82C |

## [RollWindowCounter](../Source/DiskUtility/Demo/RollWindowCounter.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Demo.RollWindow` | `#E939` | данные | данные #E939..#E939 |

## [InstallDemoOverlay](../Source/DiskUtility/DemoSetup/InstallDemoOverlay.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `Game.Flight.MainGameLoop.DrawCall` | `#7503` | операнд внешнего патча | исходная точка записи установщика демонстрации |
| `Game.Flight.MainGameLoop.DeathTarget` | `#7576` | операнд внешнего патча | исходная точка записи установщика демонстрации |
| `Game.Universe.ApplyEnhancedFlightControl.DirectKeyRead` | `#7F87` | операнд внешнего патча | исходная точка записи установщика демонстрации |
| `Game.Universe.ApplyEnhancedFlightControl.InvasionCall` | `#7FB2` | операнд внешнего патча | исходная точка записи установщика демонстрации |
| `Game.Screen.SelectTrafficType.InvasionCall` | `#800D` | операнд внешнего патча | операнд CALL проверки полосы вторжения |
| `Game.Flight.LaunchOrDockShip.RestoreCall` | `#9470` | операнд внешнего патча | исходная точка записи установщика демонстрации |
| `Game.Combat.UpdateAllSpaceObjects.EnergyRead` | `#9D3D` | операнд внешнего патча | исходная точка записи установщика демонстрации |
| `DiskUtility.DemoSetup.DemoPayload` | `#C8D6` | источник оверлея | исходная точка записи установщика демонстрации |
| `Game.Missions.RatingBountyDamageAndNewCommander.CargoOffset` | `#D223` | операнд внешнего патча | исходная точка записи установщика демонстрации |
| `OverlayTrack` | `#D983` | источник оверлея | исходная точка записи установщика демонстрации |
| `Game.Menus.OpenCommanderStatus.FormatCall` | `#EF8D` | операнд внешнего патча | исходная точка записи установщика демонстрации |
| `Game.Menus.PrintStatusFieldAndCargoScreen.FormatCall` | `#F0BE` | операнд внешнего патча | исходная точка записи установщика демонстрации |
| `Game.Input.ToggleSecondaryCoordinateObject.InvasionCall` | `#FD2C` | операнд внешнего патча | исходная точка записи установщика демонстрации |
| `Game.Input.ScanKeyboardMatrix.RowPort` | `#FD72` | операнд внешнего патча | исходная точка записи установщика демонстрации |
| `Game.Input.ScanKeyboardMatrix.ScanRow` | `#FD76` | операнд внешнего патча | исходная точка записи установщика демонстрации |
| `Game.Input.ScanKeyboardMatrix.KeyReadTail` | `#FD78` | операнд внешнего патча | исходная точка записи установщика демонстрации |
| `Game.Input.KeyboardControlInterrupt.KeyboardCall` | `#FF36` | операнд внешнего патча | исходная точка записи установщика демонстрации |

## [RestartPatch](../Source/DiskUtility/DemoSetup/RestartPatch.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.DemoSetup.RestartPatch` | `#C8C4` | данные | данные #C8C4..#C8C9 |

## [VirtualInputPatches](../Source/DiskUtility/DemoSetup/VirtualInputPatches.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.DemoSetup.InputPatches` | `#C8CA` | данные | данные #C8CA..#C8D1 |

## [AllocateSaveRecord](../Source/DiskUtility/Menu/AllocateSaveRecord.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Menu.ReadCatalogID` | `#CD67` | данные | номер сектора каталога для новой записи |
| `DiskUtility.Menu.WriteCatalogID` | `#CD8A` | данные | номер изменённого сектора каталога |

## [BuildCommanderCatalog](../Source/DiskUtility/Menu/BuildCommanderCatalog.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Menu.CatalogSector` | `#CA97` | данные | номер читаемого сектора каталога, изменяет ReadCatalog |

## [ConfirmAndPrepareCopy](../Source/DiskUtility/Menu/ConfirmAndPrepareCopy.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Menu.CopySector` | `#CFC8` | данные | номер одного из трёх секторов копировщика |

## [Constants](../Source/DiskUtility/Menu/Constants.inc)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Menu.ROM_SEED_BASE` | `#0000` | адресная константа | начало ПЗУ, откуда в защитный сектор копируются #F2 исходных байта |
| `DiskUtility.Menu.ROM_FDC_WRITE` | `#3FCA` | адресная константа | обработчик вывода потока TR-DOS, вызывается через шлюз и стек |
| `DiskUtility.Menu.ListAttributes` | `#5820` | адресная константа | начало второй символьной строки, заливка внутренних столбцов рамки |
| `DiskUtility.Menu.CopyAttributes` | `#5900` | адресная константа | адрес в IY при передаче копировщику, атрибутная строка 8 |
| `DiskUtility.Menu.CopyEntry` | `#C500` | адресная константа | первый из трёх секторов копировщика, адрес последующего RET |
| `DiskUtility.Menu.CopyReadPage` | `#C700` | адресная константа | адрес первого прочитанного сектора 3, далее страницы #C600/#C500 |
| `DiskUtility.Menu.CopyEntryHL` | `#E000` | адресная константа | значение HL при RET в CopyEntry, последующее использование не подтверждено |

## [CopyServiceMessages](../Source/DiskUtility/Menu/CopyServiceMessages.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Menu.CopyText` | `#CEB0` | данные | начало сообщения служебных счётчиков |
| `DiskUtility.Menu.CounterText` | `#CEB1` | данные | изменяемая строка трёх чисел и суффиксов |
| `DiskUtility.Menu.MissingText` | `#CECF` | данные | сообщение о недостающем количестве |
| `DiskUtility.Menu.MissingDigits` | `#CEEC` | данные | три изменяемые десятичные цифры |
| `DiskUtility.Menu.ConfirmText` | `#CEFA` | данные | запрос подтверждения Y/N |

## [CopyServicePointers](../Source/DiskUtility/Menu/CopyServicePointers.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Menu.ReadTrackBuffer` | `#CF96` | данные | начало принимаемого потока дорожки |
| `DiskUtility.Menu.TrackBuffer` | `#CF98` | данные | начало потока форматируемой дорожки |
| `DiskUtility.Menu.CopyParameter` | `#CF9A` | данные | подтверждённый параметр для перехода в копировщик |

## [EmitRepeatedByte](../Source/DiskUtility/Menu/EmitRepeatedByte.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Menu.TrackByte` | `#0000` | операнд или смещение | нулевое смещение выходного байта, IX является курсором потока дорожки |

## [FormatDecimalDigit](../Source/DiskUtility/Menu/FormatDecimalDigit.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Menu.DigitByte` | `#0000` | операнд или смещение | нулевое смещение текущей цифры, IX является курсором строки |

## [FormatTrack](../Source/DiskUtility/Menu/FormatTrack.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Menu.VerifySectorID` | `#CDCE` | данные | номер сектора после форматирования |

## [HighlightSelectedSave](../Source/DiskUtility/Menu/HighlightSelectedSave.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `Memory.Attributes` | `#5800` | адресное выражение | база расчёта атрибутов выбранной каталожной записи |

## [MenuMessages](../Source/DiskUtility/Menu/MenuMessages.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Menu.MenuText` | `#C82C` | данные | команды загрузки, сохранения и демонстрации |
| `DiskUtility.Menu.NamePrompt` | `#C84B` | данные | запрос имени командира |
| `DiskUtility.Menu.SaveFormat` | `#C854` | данные | параметр 0, длина #0066, один сектор |

## [PreservedMenuTail](../Source/DiskUtility/Menu/PreservedMenuTail.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Menu.PreservedTail` | `#CFF6` | данные |  |

## [PreservedSectorOrder](../Source/DiskUtility/Menu/PreservedSectorOrder.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Menu.SectorIds` | `#CE77` | данные |  |

## [PreservedSectorReader](../Source/DiskUtility/Menu/PreservedSectorReader.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Menu.LegacyNoSpace` | `#C859` | данные |  |

## [SaveNamedCommander](../Source/DiskUtility/Menu/SaveNamedCommander.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Menu.SaveSector` | `#CCE7` | данные | номер записываемого сектора, изменяет OverwriteSave |

## [SectorFormatPattern](../Source/DiskUtility/Menu/SectorFormatPattern.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Menu.FormatPattern` | `#CE55` | данные | пары количество и значение, начало шаблона дорожки |
| `DiskUtility.Menu.TrackID` | `#CE5E` | данные | байт дорожки внутри серии идентификатора |
| `DiskUtility.Menu.SidePattern` | `#CE5F` | данные | серии стороны и количества байтов номера сектора |
| `DiskUtility.Menu.SectorID` | `#CE62` | данные | байт номера сектора внутри серии идентификатора |
| `DiskUtility.Menu.SizePattern` | `#CE63` | данные | длина серии кода размера сектора |
| `DiskUtility.Menu.SectorSize` | `#CE64` | данные | код размера сектора в идентификаторе |
| `DiskUtility.Menu.DataPattern` | `#CE65` | данные | серии CRC, промежутка, синхронизации и маркера данных |
| `DiskUtility.Menu.SectorFill` | `#CE6F` | данные | значение заполнителя 256 байтов данных |
| `DiskUtility.Menu.CrcPattern` | `#CE70` | данные | серия завершения CRC |
| `DiskUtility.Menu.GapCount` | `#CE73` | данные | число байтов промежутка после сектора |
| `DiskUtility.Menu.PatternEnd` | `#CE74` | данные | заполнитель промежутка и пара завершителя |

## [SelectTrackAndSide](../Source/DiskUtility/Menu/SelectTrackAndSide.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Menu.SideValue` | `#C88F` | данные | значение выбора стороны, изменяет SetTrackSide |
| `DiskUtility.Menu.Cylinder` | `#C894` | данные | номер цилиндра, логическая дорожка делённая на два |

## [ShowCopyServiceMenu](../Source/DiskUtility/Menu/ShowCopyServiceMenu.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Menu.TextByte` | `#0000` | операнд или смещение | нулевое смещение текущего символа, IX является курсором строки |

## [TransferSector](../Source/DiskUtility/Menu/TransferSector.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Menu.TransferID` | `#C8C6` | данные | номер сектора, извлекается из потока после CALL |
| `DiskUtility.Menu.TransferCmd` | `#C8CB` | данные | команда #84 чтение либо #A4 запись |
| `DiskUtility.Menu.TransferCall` | `#C8CF` | операнд или смещение | адрес обработчика потока в операнде следующего CALL |

## [TransformProtectionMark](../Source/DiskUtility/Menu/TransformProtectionMark.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskUtility.Menu.KeyNext` | `#0001` | операнд или смещение | следующий элемент таблицы относительно IY |
| `DiskUtility.Menu.KeyAfterNext` | `#0002` | операнд или смещение | элемент таблицы через один относительно IY |

## [FindSystemNameDialog](../Source/Game/Charts/FindSystemNameDialog.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `InputPrompt` | `#E3C9` | данные | токен приглашения строкового редактора |
| `InputBuffer` | `#E3CA` | данные | адрес начала редактируемой строки |

## [MapCursorTransformAndKeys](../Source/Game/Charts/MapCursorTransformAndKeys.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `MapViewport.CrosshairSize` | `#E52B` | данные | полуширина перекрестия карты в пикселях |
| `MapViewport.Top` | `#E52C` | данные | верхняя строка области карты |
| `MapViewport.Bottom` | `#E52D` | данные | нижняя строка области карты |

## [TextInputLoop](../Source/Game/Charts/TextInputLoop.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `InputLimit` | `#E413` | операнд команды | изменяемый предел длины строки в операнде CP |

## [ApplyCircleViewportPatches](../Source/Game/Circles/ApplyCircleViewportPatches.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `CircleViewport.Chart` | `#8E8D` | таблица | 32 значения патчей полного экрана карты |
| `CircleViewport.Flight` | `#8EAD` | таблица | 32 значения патчей области обзора |
| `CircleViewport.Addresses` | `#8ECD` | таблица | 32 адреса однобайтовых патчей |

## [BeginFilledUnclippedHalf](../Source/Game/Circles/BeginFilledUnclippedHalf.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `CircleRaster.BothTop` | `#8B02` | операнд команды | верхний предел заполнения круга без бокового отсечения |
| `CircleRaster.BothBottom` | `#8B09` | операнд команды | нижний предел заполнения круга без бокового отсечения |

## [ComputeLeftEdgeMask](../Source/Game/Circles/ComputeLeftEdgeMask.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `CircleRaster.LeftBuffer` | `#89DA` | операнд команды | двухбайтовый SET 7,H либо NOP/NOP, выбор буфера левого края |

## [ComputeRightEdgeMask](../Source/Game/Circles/ComputeRightEdgeMask.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `CircleRaster.RightBuffer` | `#89FB` | операнд команды | двухбайтовый SET 7,H либо NOP/NOP, выбор буфера правого края |

## [CrossCircleCharacterRowDown](../Source/Game/Circles/CrossCircleCharacterRowDown.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `CircleRaster.NextRow` | `#8E18` | операнд команды | нижний предел при переходе на следующее знакоместо |

## [CrossCircleCharacterRowUp](../Source/Game/Circles/CrossCircleCharacterRowUp.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `CircleRaster.PreviousRow` | `#8DFE` | операнд команды | верхний предел при переходе на предыдущее знакоместо |

## [PatchCircleScreenTarget](../Source/Game/Circles/PatchCircleScreenTarget.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `CircleRaster.TargetBottom` | `#8F9B` | операнд команды | нижний предел, который патчер распространяет на три обработчика |
| `CircleRaster.TargetTop` | `#8FA6` | операнд команды | верхний предел, который патчер распространяет на четыре обработчика |
| `CircleFillWord` | `#8FB6` | данные | образец #FFFF для заполнения двух экранных байтов через PUSH AF |

## [PrepareBothClippedMasksAndFillRows](../Source/Game/Circles/PrepareBothClippedMasksAndFillRows.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `CircleRaster.FillTop` | `#8A4A` | операнд команды | верхний предел в младшем байте пары предела и кода JR |
| `CircleRaster.FillBottom` | `#8A61` | операнд команды | нижний предел в младшем байте пары предела и кода JR |
| `CircleRaster.FillBuffer` | `#8A6E` | операнд команды | двухбайтовый SET 7,H либо NOP/NOP для заполнения строк |
| `CircleRaster.RowStep` | `#8A85` | операнд команды | пара LD A,H/DEC H либо INC H/LD A,H, направление обхода |
| `CircleRaster.CellStep` | `#8A92` | операнд команды | пара SUB #20 либо ADD A,#20, переход между знакоместами |
| `CircleRaster.ThirdStep` | `#8A98` | операнд команды | пара ADD A,#08 либо SUB #08, коррекция трети экрана |
| `CircleRaster.LimitBranch` | `#8A9E` | операнд команды | операнд CP и код следующего JR, предел и условие продолжения |

## [PrintShipAndContinueRightFill](../Source/Game/Circles/PrintShipAndContinueRightFill.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `CircleRaster.RightPairJump` | `#8DC9` | операнд команды | смещение JR, число пар внутренних байтов при правом отсечении |

## [SelectJumpAndContinueLeftFill](../Source/Game/Circles/SelectJumpAndContinueLeftFill.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `CircleRaster.LeftPairJump` | `#8CD3` | операнд команды | смещение JR, число пар внутренних байтов при левом отсечении |
| `CircleRaster.RightTop` | `#8D06` | операнд команды | верхний предел заполнения круга с правым отсечением |
| `CircleRaster.RightBottom` | `#8D0D` | операнд команды | нижний предел заполнения круга с правым отсечением |

## [SetCabinHeatAndContinueFilledCircle](../Source/Game/Circles/SetCabinHeatAndContinueFilledCircle.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `CircleRaster.BothPairJump` | `#8BD3` | операнд команды | смещение JR, выбор числа пар байтов для заполнения через PUSH AF |
| `CircleRaster.LeftTop` | `#8C06` | операнд команды | верхний предел заполнения круга с левым отсечением |
| `CircleRaster.LeftBottom` | `#8C0D` | операнд команды | нижний предел заполнения круга с левым отсечением |

## [UpdateThargoidAndBodyCoords](../Source/Game/Circles/UpdateThargoidAndBodyCoords.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DistantBodies.First.X` | `#8ABA` | данные | три байта координаты X далёкого тела First |
| `DistantBodies.First.Y` | `#8ABD` | данные | три байта координаты Y далёкого тела First |
| `DistantBodies.First.Z` | `#8AC0` | данные | три байта координаты Z далёкого тела First |
| `DistantBodies.First.Z + FCoordinate.SignHigh` | `#8AC2` | поле данных | старший знаковый байт Z далёкого тела |
| `DistantBodies.Second.X` | `#8AC3` | данные | три байта координаты X далёкого тела Second |
| `DistantBodies.Second.Y` | `#8AC6` | данные | три байта координаты Y далёкого тела Second |
| `DistantBodies.Second.Z` | `#8AC9` | данные | три байта координаты Z далёкого тела Second |
| `DistantBodies.Second.Z + FCoordinate.SignHigh` | `#8ACB` | поле данных | старший знаковый байт Z далёкого тела |

## [AnimateIntroAndObjectPipeline](../Source/Game/Combat/AnimateIntroAndObjectPipeline.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `MissionPhase` | `#9CB2` | данные | фаза появления особых кораблей второй миссии |
| `ActiveShips` | `#9CB3` | данные | число живых управляемых кораблей среди шести обычных слотов |
| `ObjectIndex` | `#9CB4` | данные | номер обрабатываемого объекта, 8..1 |

## [CreateWreckAndDamageState](../Source/Game/Combat/CreateWreckAndDamageState.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `CombatState.EnergyDrain` | `#9CA2` | данные | накопленный расход энергии за объектный кадр, включая лазер и ECM |
| `CombatState.FrontDamage` | `#9CA3` | данные | накопленный урон передней защите от лазеров и столкновений |
| `CombatState.RearDamage` | `#9CA4` | данные | накопленный урон задней защите от лазеров и столкновений |
| `OrdinarySeen` | `#9CAE` | данные | энергия последнего живого объекта без Flags2.bit2, ноль если таких объектов нет |

## [DamageShieldAndEnergy](../Source/Game/Combat/DamageShieldAndEnergy.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `ShieldHits` | `#9ADA` | данные | накопитель пробитий щитов, прибавка 5, повреждение оборудования при значении от 13 |

## [DivideAndCombatState](../Source/Game/Combat/DivideAndCombatState.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `CombatState.SpawnCounter` | `#9C93` | данные | счётчик появления, уменьшение до нуля запускает диспетчер объектов |
| `CombatState.ShipsPresent` | `#9C94` | данные | флаг, в текущем обходе найден объект без ObjectFlag2.NotShip |
| `CombatState.DestroyAll` | `#9C95` | данные | массовый запрос уничтожения от энергетической бомбы, снимается в конце кадра |
| `CombatState.ObjectsPresent` | `#9C96` | данные | ненулевой байт последнего занятого слота, допускает сканер и обход взрывов |
| `CombatState.CrosshairTarget` | `#9C97` | данные | номер цели прицела, 0 без цели, патч проекции данной версии пишет только 0 |
| `CombatState.Danger` | `#9C99` | данные | флаг, обнаружен опасный враждебный объект, сбрасывается при пустой сцене |
| `CombatState.DockRequest` | `#9C9A` | данные | запрос стыковки после совмещения со станцией, обходящий клавиатурные допуски |
| `CombatState.EcmTimer` | `#9C9B` | данные | оставшиеся такты ECM, влияет на ракеты, индикатор и расход энергии |

## [NextRandomByte](../Source/Game/Combat/NextRandomByte.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `RandomState` | `#B7AA` | данные | 16-битное состояние генератора NextRandomByte |

## [PrintMissileStock](../Source/Game/Combat/PrintMissileStock.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `MissileCount` | `#9C1B` | данные | сохранённое число ракет для обновления панели |

## [UpdateAllSpaceObjects](../Source/Game/Combat/UpdateAllSpaceObjects.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `Game.Combat.UpdateAllSpaceObjects.EnergyRead` | `#9D3D` | операнд команды | CALL проверки энергии слота, демо заменяет прямым чтением поля объекта |

## [LaunchCounter](../Source/Game/Data/LaunchCounter.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `LaunchPending` | `#E07A` | данные | флаг, при следующем вылете увеличить счётчик |
| `LaunchCount` | `#E07B` | данные | число вылетов после отмеченного перехода в систему |
| `TimingFailures` | `#E07D` | данные | число отказов временной проверки маркера дорожки |
| `MarkFailures` | `#E07E` | данные | число отказов VerifyMark, порог отказа равен 8 |
| `ProtectPassed` | `#E07F` | данные | результат проверки дисковой защиты, #FF допуск, 0 отказ |

## [SystemBoundaryAndObjects](../Source/Game/Data/SystemBoundaryAndObjects.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `Memory.Objects + FSpaceObject.Energy` | `#6091` | данные | энергия первого обычного слота |
| `Memory.Objects + FSpaceObject.Flags2` | `#6095` | данные | дополнительные флаги первого обычного слота |

## [BlackAttributesAndOverlayState](../Source/Game/Disk/BlackAttributesAndOverlayState.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `OverlayTrack` | `#D983` | данные | сектор и дорожка дискового оверлея cl.C |
| `DemoTrack` | `#D985` | данные | сектор и дорожка файла демонстрации |
| `DriveFlags` | `#D9BF` | данные | параметр диска, бит 1 включает пересчёт дорожки и стороны |
| `DiskParameter` | `#D9C0` | данные | параметр внутреннего вызова TR-DOS |

## [DrawScreenStripsAndPrivateStack](../Source/Game/Disk/DrawScreenStripsAndPrivateStack.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `ScreenStack` | `#DA60` | операнд команды | сохранённый SP в операнде восстановления стека после вывода |
| `SaveSelection` | `#DA70` | данные | индекс выбранного командира в дисковом меню |
| `SavePageStart` | `#DA71` | данные | индекс первого командира отображаемой страницы |
| `FlightMessage.RepeatTimer` | `#DA72` | данные | таймер повторного предупреждения |
| `FlightMessage.Frames` | `#DA73` | данные | оставшееся время показа сообщения |
| `FlightMessage.QueuePhase` | `#DA74` | данные | фаза чередования очереди и фоновых сообщений |
| `FlightMessage.Column` | `#DA75` | данные | столбец текущего сообщения |
| `FlightMessage.Token` | `#DA76` | данные | токен текущего сообщения |
| `FlightMessage.Reward` | `#DA77` | данные | денежная награда для сообщения о премии |
| `FlightMessage.DamagedItem` | `#DA79` | данные | код повреждённого оборудования |

## [ReactionOnPrivateStack](../Source/Game/Disk/ReactionOnPrivateStack.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `ReactionStack` | `#DA2C` | операнд команды | сохранённый SP в операнде восстановления стека |

## [TransferDiskSectors](../Source/Game/Disk/TransferDiskSectors.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DiskSavedIX` | `#D9E5` | операнд команды | сохранённый IX в операнде LD IX после TR-DOS |

## [SubtractCashLow](../Source/Game/Economy/SubtractCashLow.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `TextDecodeMode` | `#D420` | данные | режим декодирования текста, 0 основная таблица, 1 описания |

## [AllocateVariantObjectSlot](../Source/Game/Extensions/AllocateVariantObjectSlot.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `SmallProfile` | `#FAF7` | код и данные | таблица профиля начинается двумя байтами XOR A, RET, затем следуют маски |

## [AttributeVectorAndEnergyBomb](../Source/Game/Extensions/AttributeVectorAndEnergyBomb.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `MarketTable.Base` | `#701B` | данные | 17 записей параметров товаров |
| `MarketTable.FirearmPrice` | `#7043` | данные | базовая цена оружия |
| `MarketTable.FirearmEconomy` | `#7044` | данные | коэффициент экономики оружия |
| `EquipmentTable.Base` | `#705F` | данные | 14 цен оборудования |
| `EquipmentTable.FuelPrice` | `#7060` | данные | цена недостающего топлива |

## [CompareObjectCoordinateDepth](../Source/Game/Extensions/CompareObjectCoordinateDepth.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `InputState.SystemKeys` | `#FC08` | данные | маска клавиш Y, 0, I, O, P, K, L, ENTER |
| `InputState.FlightKeys` | `#FC09` | данные | нормализованные направления и изменение скорости |
| `InputState.ViewJumpKeys` | `#FC0A` | данные | виды кабины, переходы и CAPS SHIFT |
| `InputState.DeviceKeys` | `#FC0B` | данные | маска команд C, Q, W, E, U, F, T, A |
| `InputState.ChartKeys` | `#FC0C` | данные | маска клавиш R, D, B |
| `InputState.LastKey` | `#FC0D` | данные | последний символ, #FF нет клавиши, #FE сочетание 0 и CAPS SHIFT |
| `InputState.Config` | `#FC0E` | данные | режим источника, настройки направлений и звук |
| `InputState.NumberKeys` | `#FC0F` | данные | цифровые направления до нормализации |

## [CreateMissileOrMissionCraft](../Source/Game/Extensions/CreateMissileOrMissionCraft.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `Game.Extensions.CreateMissileOrMissionCraft.DirectKeyRead` | `#5EF8` | код команды | начало опроса D, подменяется демо |

## [DrawCircleAndProtectScratchStack](../Source/Game/Extensions/DrawCircleAndProtectScratchStack.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `Game.Extensions.DrawCircleAndProtectScratchStack.SavedSP` | `#F90A` | операнд команды | сохранённый SP в операнде LD SP |

## [DrawCompressedEdges](../Source/Game/Extensions/DrawCompressedEdges.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `Game.Extensions.DrawCompressedEdges.FrameCounter` | `#6F42` | операнд команды | счётчик вызовов в операнде LD A |
| `Game.Extensions.DrawCompressedEdges.FlagsStream` | `#6FEB` | указатель | текущий указатель потока признаков граней и вершин |

## [DrawModelAndResources](../Source/Game/Extensions/DrawModelAndResources.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `Blueprint.Missile` | `#61E3` | заголовок модели | заголовок FModel, ракета |
| `Blueprint.EscapePod` | `#61FA` | заголовок модели | заголовок FModel, спасательная капсула |
| `Blueprint.Alloys` | `#6211` | заголовок модели | заголовок FModel, обломки сплавов |
| `Blueprint.Cargo` | `#6228` | заголовок модели | заголовок FModel, грузовой контейнер |
| `Blueprint.Minerals` | `#623F` | заголовок модели | заголовок FModel, минеральный обломок |
| `Blueprint.Asteroid` | `#6256` | заголовок модели | заголовок FModel, обычный астероид |
| `Blueprint.AsteroidArmed` | `#626D` | заголовок модели | заголовок FModel, особый астероид с запускаемыми объектами |
| `Blueprint.Viper` | `#6284` | заголовок модели | заголовок FModel, полицейский Viper |
| `Blueprint.CobraTrader` | `#629B` | заголовок модели | заголовок FModel, торговая Cobra Mk III |
| `Blueprint.PythonTrader` | `#62B2` | заголовок модели | заголовок FModel, торговый Python |
| `Blueprint.PythonPirate` | `#62C9` | заголовок модели | заголовок FModel, пиратский Python |
| `Blueprint.CobraPirate` | `#62E0` | заголовок модели | заголовок FModel, пиратская Cobra Mk III |
| `Blueprint.Asp` | `#62F7` | заголовок модели | заголовок FModel, Asp Mk II |
| `Blueprint.FerDeLance` | `#630E` | заголовок модели | заголовок FModel, Fer-de-Lance |
| `Blueprint.Thargoid` | `#6325` | заголовок модели | заголовок FModel, Thargoid |
| `Blueprint.Sidewinder` | `#633C` | заголовок модели | заголовок FModel, Sidewinder |
| `Blueprint.Adder` | `#6353` | заголовок модели | заголовок FModel, Adder |
| `Blueprint.Tharglet` | `#636A` | заголовок модели | заголовок FModel, малый Tharglet |
| `Blueprint.Thargoid6` | `#6381` | заголовок модели | заголовок FModel, шестигранный Thargoid |
| `Blueprint.Fighter1` | `#6398` | заголовок модели | заголовок FModel, дополнительный истребитель 1 |
| `Blueprint.Fighter2` | `#63AF` | заголовок модели | заголовок FModel, дополнительный истребитель 2 |
| `Blueprint.Coriolis` | `#63C6` | заголовок модели | заголовок FModel, станция Coriolis |
| `Blueprint.Krait` | `#63DD` | заголовок модели | заголовок FModel, Krait |

## [PrintCargoAndMessageBanks](../Source/Game/Extensions/PrintCargoAndMessageBanks.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `MessageTable.Main` | `#F11A` | указатель | указатель основного банка |
| `MessageTable.Description` | `#F11C` | указатель | указатель банка описаний |
| `Game.Extensions.PrintCargoAndMessageBanks.PulseLaserTail` | `#F3D8` | данные | S и нулевой конец сообщения #6D, также цель записи LegacyLatch |
| `Game.Extensions.PrintCargoAndMessageBanks.SavedSP` | `#F8CC` | операнд команды | сохранённый SP в операнде LD SP |

## [PrintEquipmentAndSelectIcon](../Source/Game/Extensions/PrintEquipmentAndSelectIcon.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `Game.Extensions.PrintEquipmentAndSelectIcon.ModeIcons` | `#6F11` | данные | три восьмибайтовых значка режима |

## [ScheduleLinkedObjectLaser](../Source/Game/Extensions/ScheduleLinkedObjectLaser.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `LaserThreshold` | `#FABA` | операнд команды | порог CP и сдвигаемая история случайных проверок |

## [SelectCharacterFont](../Source/Game/Extensions/SelectCharacterFont.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `RomFont` | `#3D00` | адрес ROM | знакогенератор ROM, глиф пробела |
| `ExtraFontBase` | `#5D70` | база индексирования | база индексирования дополнительных глифов, на 12 глифов до ExtraGlyphs |

## [UpdateStationAndFinishGlyph](../Source/Game/Extensions/UpdateStationAndFinishGlyph.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `Game.Extensions.UpdateStationAndFinishGlyph.ExtraGlyphs` | `#5DD0` | данные | четыре восьмибайтовых глифа дополнительного шрифта |
| `Game.Extensions.UpdateStationAndFinishGlyph.AuxPortFirst` | `#5DF3` | код команды | отключаемая команда OUT |
| `Game.Extensions.UpdateStationAndFinishGlyph.AuxPortNext` | `#5DF8` | код команды | отключаемая команда OUT |

## [AnimateTransitionTunnel](../Source/Game/Flight/AnimateTransitionTunnel.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `TunnelDepths` | `#92FA` | операнд команды | адрес текущей таблицы глубин в операнде LD HL |
| `TunnelPhase` | `#9318` | операнд команды | смещение JR Z, выбор этапа изменения туннеля |
| `TunnelLimit` | `#9326` | операнд команды | изменяемая глубина завершения в операнде CP |
| `TunnelFinish` | `#932B` | операнд команды | смещение JR C, выбор завершения старта либо гипертуннеля |

## [ClearNearbyShipSlots](../Source/Game/Flight/ClearNearbyShipSlots.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `SoundState.Mode` | `#9522` | данные | 0 тишина, 1 скользящий тон, 2 тон из данных, остальные значения шум |
| `SoundState.Duration` | `#9523` | данные | сохранённые DE, назначение D/E зависит от звукового режима |
| `SoundState.DataCursor` | `#9525` | данные | сохранённый HL, адрес следующего отсчёта либо параметр тона |

## [DispatchChartCircle](../Source/Game/Flight/DispatchChartCircle.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `FlightState.StationZone` | `#711C` | данные | ближняя станционная зона, разрешает стыковку и запрещает появление кораблей |
| `FlightState.StationFar` | `#711D` | данные | #FF для дальних координат станции, 0 для ближних |
| `FlightState.SunScooping` | `#711E` | данные | признак зоны черпаков, сбрасывается при входе в систему и на заставке |
| `FlightState.PlayerDead` | `#711F` | данные | флаг, главный цикл должен показать гибель игрока |
| `FlightState.XorObjects` | `#7120` | данные | нуль выбирает OR, ненулевое значение выбирает XOR при выводе объектов |

## [DispatchDangerIndicator](../Source/Game/Flight/DispatchDangerIndicator.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `FlightState.ControlsLocked` | `#7124` | данные | флаг, главный цикл пропускает ручное обновление крена, тангажа и скорости |

## [DispatchSoundEffect](../Source/Game/Flight/DispatchSoundEffect.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `Game.Flight.DispatchSoundEffect.Requests` | `#7128` | данные | маска ожидающих звуковых запросов, бит 0 имеет наивысший приоритет |
| `Game.Flight.DispatchSoundEffect.AutoDock` | `#7129` | данные | флаг, ненулевое значение включает автоматическую стыковку |

## [DivideByteFractionForTunnel](../Source/Game/Flight/DivideByteFractionForTunnel.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `TunnelRings` | `#93D0` | данные | число колец туннеля, 8 либо 16 |
| `TunnelLeft` | `#93D1` | данные | число ещё не обработанных колец кадра |
| `TunnelFrames` | `#93D2` | данные | число кадров до смены фазы туннеля |
| `HyperDepths` | `#93D3` | данные | шестнадцать глубин колец гиперперехода |
| `DockDepths` | `#93E3` | данные | восемь глубин колец стыковки и старта |

## [Fill240Attributes](../Source/Game/Flight/Fill240Attributes.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DemoModel` | `#7470` | данные | номер демонстрационной модели, младшая тетрада с пропуском 12..15 |

## [FillViewAttributesAndFlightState](../Source/Game/Flight/FillViewAttributesAndFlightState.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `Game.Flight.FillViewAttributesAndFlightState.InvasionClock` | `#70DC` | данные | хранение FlightState.InvasionClock |
| `Game.Flight.FillViewAttributesAndFlightState.View` | `#70E3` | данные | хранение FlightState.View |
| `Game.Flight.FillViewAttributesAndFlightState.Roll` | `#70E4` | данные | хранение FlightState.Roll |
| `Game.Flight.FillViewAttributesAndFlightState.Pitch` | `#70E5` | данные | хранение FlightState.Pitch |
| `Game.Flight.FillViewAttributesAndFlightState.Speed` | `#70E6` | данные | хранение FlightState.Speed |
| `Game.Flight.FillViewAttributesAndFlightState.FrontShieldPrev` | `#70E7` | данные | хранение GaugeState + FGaugeState.FrontShield.Previous |
| `Game.Flight.FillViewAttributesAndFlightState.FrontShieldNow` | `#70E8` | данные | хранение GaugeState + FGaugeState.FrontShield.Current |
| `Game.Flight.FillViewAttributesAndFlightState.RearShieldPrev` | `#70E9` | данные | хранение GaugeState + FGaugeState.RearShield.Previous |
| `Game.Flight.FillViewAttributesAndFlightState.RearShieldNow` | `#70EA` | данные | хранение GaugeState + FGaugeState.RearShield.Current |
| `Game.Flight.FillViewAttributesAndFlightState.FuelPrev` | `#70EB` | данные | хранение GaugeState + FGaugeState.Fuel.Previous |
| `Game.Flight.FillViewAttributesAndFlightState.FuelNow` | `#70EC` | данные | хранение GaugeState + FGaugeState.Fuel.Current |
| `Game.Flight.FillViewAttributesAndFlightState.CabinHeatPrev` | `#70ED` | данные | хранение GaugeState + FGaugeState.CabinHeat.Previous |
| `Game.Flight.FillViewAttributesAndFlightState.CabinHeatNow` | `#70EE` | данные | хранение GaugeState + FGaugeState.CabinHeat.Current |
| `Game.Flight.FillViewAttributesAndFlightState.LaserHeatPrev` | `#70EF` | данные | хранение GaugeState + FGaugeState.LaserHeat.Previous |
| `Game.Flight.FillViewAttributesAndFlightState.LaserHeatNow` | `#70F0` | данные | хранение GaugeState + FGaugeState.LaserHeat.Current |
| `Game.Flight.FillViewAttributesAndFlightState.AltitudePrev` | `#70F1` | данные | хранение GaugeState + FGaugeState.Altitude.Previous |
| `Game.Flight.FillViewAttributesAndFlightState.AltitudeNow` | `#70F2` | данные | хранение GaugeState + FGaugeState.Altitude.Current |
| `Game.Flight.FillViewAttributesAndFlightState.SpeedPrev` | `#70F3` | данные | хранение GaugeState + FGaugeState.Speed.Previous |
| `Game.Flight.FillViewAttributesAndFlightState.SpeedNow` | `#70F4` | данные | хранение GaugeState + FGaugeState.Speed.Current |
| `Game.Flight.FillViewAttributesAndFlightState.Energy1Prev` | `#70F5` | данные | хранение GaugeState + FGaugeState.Energy1.Previous |
| `Game.Flight.FillViewAttributesAndFlightState.Energy1Now` | `#70F6` | данные | хранение GaugeState + FGaugeState.Energy1.Current |
| `Game.Flight.FillViewAttributesAndFlightState.Energy2Prev` | `#70F7` | данные | хранение GaugeState + FGaugeState.Energy2.Previous |
| `Game.Flight.FillViewAttributesAndFlightState.Energy2Now` | `#70F8` | данные | хранение GaugeState + FGaugeState.Energy2.Current |
| `Game.Flight.FillViewAttributesAndFlightState.Energy3Prev` | `#70F9` | данные | хранение GaugeState + FGaugeState.Energy3.Previous |
| `Game.Flight.FillViewAttributesAndFlightState.Energy3Now` | `#70FA` | данные | хранение GaugeState + FGaugeState.Energy3.Current |
| `Game.Flight.FillViewAttributesAndFlightState.Energy4Prev` | `#70FB` | данные | хранение GaugeState + FGaugeState.Energy4.Previous |
| `Game.Flight.FillViewAttributesAndFlightState.Energy4Now` | `#70FC` | данные | хранение GaugeState + FGaugeState.Energy4.Current |
| `Game.Flight.FillViewAttributesAndFlightState.RollPrev` | `#70FD` | данные | хранение GaugeState + FGaugeState.Roll.Previous |
| `Game.Flight.FillViewAttributesAndFlightState.RollNow` | `#70FE` | данные | хранение GaugeState + FGaugeState.Roll.Current |
| `Game.Flight.FillViewAttributesAndFlightState.PitchPrev` | `#70FF` | данные | хранение GaugeState + FGaugeState.Pitch.Previous |
| `Game.Flight.FillViewAttributesAndFlightState.PitchNow` | `#7100` | данные | хранение GaugeState + FGaugeState.Pitch.Current |
| `Game.Flight.FillViewAttributesAndFlightState.SpaceMode` | `#7103` | данные | хранение FlightState.SpaceMode |
| `Game.Flight.FillViewAttributesAndFlightState.FlightStatus` | `#7104` | данные | хранение FlightState.FlightStatus |
| `Game.Flight.FillViewAttributesAndFlightState.RandomByte` | `#7105` | данные | хранение FlightState.RandomByte |
| `Game.Flight.FillViewAttributesAndFlightState.Sun` | `#7107` | данные | хранение FlightState.Sun |
| `Game.Flight.FillViewAttributesAndFlightState.Planet` | `#7110` | данные | хранение FlightState.Planet |

## [HandleMapCursorKeys](../Source/Game/Flight/HandleMapCursorKeys.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `CloakDivider` | `#7221` | данные | делитель проверки маскировки, после срабатывания загружается 2 |

## [IndexPauseCommandAndHandlers](../Source/Game/Flight/IndexPauseCommandAndHandlers.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `PauseKeyMap` | `#72FB` | данные | пары код клавиши и маска изменяемой настройки, завершение нулём |

## [LaunchOrDockShip](../Source/Game/Flight/LaunchOrDockShip.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `Game.Flight.LaunchOrDockShip.RestoreCall` | `#9470` | операнд команды | операнд CALL восстановления маскировки и случайного параметра полёта |

## [MainGameLoop](../Source/Game/Flight/MainGameLoop.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `Game.Flight.MainGameLoop.DrawCall` | `#7503` | операнд команды | операнд CALL перерисовки индикаторов, демо добавляет обработчик кадра |
| `Game.Flight.MainGameLoop.DeathTarget` | `#7576` | операнд команды | операнд JP после задержки гибели, демо перенаправляет завершение |

## [ReportBoardingAndReturnToTitle](../Source/Game/Flight/ReportBoardingAndReturnToTitle.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `JoystickMode` | `#72A2` | данные | выбранный режим управления джойстиком |

## [TryColonizeMinerals](../Source/Game/Flight/TryColonizeMinerals.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DistantSigns` | `#738E` | данные | шесть старших знако-модульных байтов координат двух дальних светил |

## [FindSystemByExactName](../Source/Game/Galaxy/FindSystemByExactName.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `NearestMetric` | `#DF5E` | данные | наименьшая квадратичная метрика до курсора |

## [EnableInterruptMode1AndKeyboardMap](../Source/Game/Input/EnableInterruptMode1AndKeyboardMap.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `InputStack` | `#FF56` | данные | сохранённый SP для обработчика клавиатуры и IM1 |
| `KeyAssignments` | `#FF58` | данные | 40 пар смещение и маска, назначение клавиш в InputState |
| `ScratchBackup` | `#FFD0` | наложение в памяти | 48 байтов в конце RAM под сохранение экранной области |

## [InterruptGateAndAcceleration](../Source/Game/Input/InterruptGateAndAcceleration.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `InterruptGate` | `#FEFE` | код команды | JR либо RET в точке входа IM2 |
| `InputMotion.Roll` | `#FF08` | данные | крен, знако-модульное слово с дробной частью в младшем байте |
| `InputMotion.Pitch` | `#FF0A` | данные | тангаж, знако-модульное слово с дробной частью в младшем байте |
| `InputMotion.Speed` | `#FF0C` | данные | неотрицательная скорость, дробная часть в младшем байте |

## [KeyboardControlInterrupt](../Source/Game/Input/KeyboardControlInterrupt.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `Game.Input.KeyboardControlInterrupt.KeyboardCall` | `#FF36` | операнд команды | операнд CALL опроса клавиатуры, демо подставляет обработчик кадра |

## [ScanKeyboardMatrix](../Source/Game/Input/ScanKeyboardMatrix.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `Game.Input.ScanKeyboardMatrix.RowPort` | `#FD72` | операнд команды | операнд LD BC, демо заменяет порт адресом восьми виртуальных рядов |
| `Game.Input.ScanKeyboardMatrix.KeyReadTail` | `#FD78` | операнд команды | первые два байта чтения ряда, демо заменяет их CPL и INC BC |
| `LaserTariffs` | `#FD8A` | данные | четыре номера тарифов оборудования для лазеров типов 1..4 |
| `StatusFormat` | `#FD8E` | данные | параметры атрибутов экрана командира |
| `CargoFormat` | `#FD96` | данные | параметры атрибутов дополнительного экрана |
| `TextSyllables` | `#FD99` | данные | двухсимвольные слоги описаний, начало перед общей таблицей имён |
| `NameSyllables` | `#FDB3` | данные | 32 пары символов для генератора имён и текстовых токенов |
| `CaptionFormat` | `#FDF3` | данные | параметры атрибутов строки подписи |
| `GalaxyFormat` | `#FDFB` | данные | параметры атрибутов строки сравнения семени галактики |

## [ToggleSecondaryCoordinateObject](../Source/Game/Input/ToggleSecondaryCoordinateObject.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `InputPhase` | `#FD03` | операнд команды | изменяемый операнд LD A, фаза чередующегося обновления координат |
| `InputViewSkip` | `#FD0A` | операнд команды | смещение условного пропуска LD A,9 |
| `Game.Input.ToggleSecondaryCoordinateObject.InvasionCall` | `#FD2C` | операнд команды | операнд CALL проверки вторжения при автопилоте |
| `KeyCharacters` | `#FD41` | данные | 40 кодов символов, индекс по позиции клавиши в матрице |

## [DispatchDiskAndCommanderState](../Source/Game/Interface/DispatchDiskAndCommanderState.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `MapCircleX` | `#D051` | данные | координата X окружности карты |
| `MapCircleY` | `#D052` | данные | координата Y окружности карты |
| `MapRadius` | `#D053` | данные | радиус окружности дальности на карте |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.Name` | `#D054` | данные | поле FCommander.Name |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.LegalStatus` | `#D05F` | данные | поле FCommander.LegalStatus |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.Rating` | `#D060` | данные | поле FCommander.Rating |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.RankState` | `#D062` | данные | поле FCommander.RankState |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.JumpCount` | `#D063` | данные | поле FCommander.JumpCount |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.JumpFlags` | `#D064` | данные | поле FCommander.JumpFlags |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.Galaxy` | `#D065` | данные | поле FCommander.Galaxy |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.CashHigh` | `#D066` | данные | поле FCommander.CashHigh |
| `State.CashHigh + 1` | `#D067` | данные | старший байт числа тысяч кредитов |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.CashLow` | `#D068` | данные | поле FCommander.CashLow |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.MarketRandom` | `#D06A` | данные | поле FCommander.MarketRandom |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.Cargo` | `#D06B` | данные | поле FCommander.Cargo |
| `State.Cargo + FGoods.AlienItems` | `#D07B` | данные | количество инопланетного груза |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.FreeCargo` | `#D07C` | данные | поле FCommander.FreeCargo |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.FrontLaser` | `#D07D` | данные | поле FCommander.FrontLaser |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.RearLaser` | `#D07E` | данные | поле FCommander.RearLaser |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.LeftLaser` | `#D07F` | данные | поле FCommander.LeftLaser |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.RightLaser` | `#D080` | данные | поле FCommander.RightLaser |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.Mission1` | `#D081` | данные | поле FCommander.Mission1 |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.Fuel` | `#D082` | данные | поле FCommander.Fuel |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.Missiles` | `#D083` | данные | поле FCommander.Missiles |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.LargeCargo` | `#D084` | данные | поле FCommander.LargeCargo |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.ECM` | `#D085` | данные | поле FCommander.ECM |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.AlienComputer` | `#D086` | данные | поле FCommander.AlienComputer |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.MineralLife` | `#D087` | данные | поле FCommander.MineralLife |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.FuelScoops` | `#D088` | данные | поле FCommander.FuelScoops |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.EscapePod` | `#D089` | данные | поле FCommander.EscapePod |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.EnergyBomb` | `#D08A` | данные | поле FCommander.EnergyBomb |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.EnergyUnit` | `#D08B` | данные | поле FCommander.EnergyUnit |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.DockComputer` | `#D08C` | данные | поле FCommander.DockComputer |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.GalacticDrive` | `#D08D` | данные | поле FCommander.GalacticDrive |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.ShipUpgrade` | `#D08E` | данные | поле FCommander.ShipUpgrade |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.Invasion` | `#D08F` | данные | поле FCommander.Invasion |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.GalaxySeed` | `#D090` | данные | поле FCommander.GalaxySeed |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.SystemSeed` | `#D096` | данные | поле FCommander.SystemSeed |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.Technology` | `#D09C` | данные | поле FCommander.Technology |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.Government` | `#D09D` | данные | поле FCommander.Government |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.MarketStock` | `#D09E` | данные | поле FCommander.MarketStock |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.Mission3` | `#D0AF` | данные | поле FCommander.Mission3 |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.MissionFlags` | `#D0B0` | данные | поле FCommander.MissionFlags |
| `Game.Interface.DispatchDiskAndCommanderState.Commander.SunPosition` | `#D0B1` | данные | поле FCommander.SunPosition |
| `MissionNotice` | `#D0BA` | данные | флаг, повторное миссионное предупреждение уже подготовлено |
| `TargetX` | `#D0BB` | данные | галактическая координата X выбранной цели |
| `TargetY` | `#D0BC` | данные | галактическая координата Y выбранной цели |
| `FlightEvents` | `#D0BD` | данные | десять пар очереди, координата с битом ожидания и токен |
| `IncomingEvent` | `#D0BF` | данные | вторая пара очереди, сообщение после запуска вражеской ракеты |
| `CargoEvent` | `#D0C7` | данные | шестая пара очереди сообщений |
| `ZeroSuppress` | `#D0CC` | данные | подавление ведущих нулей, одновременно токен восьмой пары очереди |
| `NumberWidth` | `#D0CE` | данные | минимальная ширина числа, одновременно токен девятой пары очереди |
| `LetterCase` | `#D0D1` | данные | регистр букв, 1 заглавные, 2 строчные |
| `WordStart` | `#D0D2` | данные | флаг, следующий символ начинает слово |
| `CapitalNext` | `#D0D3` | данные | флаг, следующая буква должна стать заглавной |
| `TextMode` | `#D0D4` | данные | сохранённый режим текста, его проверка нейтрализована NOP |
| `TextBasePatch` | `#D0D5` | данные | сохранённый адрес команды загрузки экранной базы текста |

## [DispatchFlightMessage](../Source/Game/Interface/DispatchFlightMessage.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `JumpMode` | `#D03F` | данные | режим перехода, 0 нет, 1 обычный, 2 галактический |
| `ViewKeyLock` | `#D040` | данные | флаг, блокировка повторной обработки клавиши смены вида |
| `CloakActive` | `#D041` | данные | флаг, включена маскировка корабля |

## [DispatchJumpKey](../Source/Game/Interface/DispatchJumpKey.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `TextColumn` | `#D045` | данные | столбец печати текста |
| `TextRow` | `#D046` | данные | строка печати текста |
| `AimState` | `#D047` | данные | состояние прицела и выбранной цели |

## [DispatchTextToken](../Source/Game/Interface/DispatchTextToken.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `GlyphPatch` | `#D04B` | данные | сохранённый адрес изменяемой команды рисования глифа |

## [LocalSystemPixelPosition](../Source/Game/Menus/LocalSystemPixelPosition.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `CircleProfile` | `#ED57` | база индексирования | база StarProfile - 2 для индекса радиуса от 2 |
| `StarProfile` | `#ED59` | данные | семь параметров малого круга, индексы радиуса 2..8 |

## [OpenCommanderStatus](../Source/Game/Menus/OpenCommanderStatus.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `Game.Menus.OpenCommanderStatus.FormatCall` | `#EF8D` | операнд команды | операнд CALL форматирования экрана командира |

## [PlotGalaxySystem](../Source/Game/Menus/PlotGalaxySystem.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `GalaxyDotMask` | `#EC36` | операнд команды | второй байт SET n,B, номер пиксельного бита задаётся результатом ROM |

## [PrintDirectionalLaser](../Source/Game/Menus/PrintDirectionalLaser.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DeviceFields` | `#F09B` | данные | шесть младших адресных байтов полей оборудования командира |

## [PrintStatusFieldAndCargoScreen](../Source/Game/Menus/PrintStatusFieldAndCargoScreen.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `RankLowLimits` | `#F0AE` | данные | пороги младшего байта боевого рейтинга |
| `RankHighLimits` | `#F0B4` | данные | пороги старшего байта боевого рейтинга |
| `Game.Menus.PrintStatusFieldAndCargoScreen.FormatCall` | `#F0BE` | операнд команды | операнд CALL форматирования экрана груза |

## [ReadVisibleObjectByte](../Source/Game/Menus/ReadVisibleObjectByte.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `MapNameLength` | `#ED77` | данные | длина имени системы при размещении подписи на карте |

## [VisitLocalChartSystems](../Source/Game/Menus/VisitLocalChartSystems.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `LocalMapLeft` | `#ECDF` | операнд команды | изменяемая включённая левая граница X в CP |
| `LocalMapRight` | `#ECE3` | операнд команды | изменяемая исключённая правая граница X в CP |
| `LocalMapTop` | `#ECEA` | операнд команды | изменяемая включённая верхняя граница Y в CP |
| `LocalMapBottom` | `#ECEE` | операнд команды | изменяемая исключённая нижняя граница Y в CP |
| `LocalMapVisit` | `#ECF2` | операнд команды | адрес обработчика видимой системы в операнде CALL |

## [DispatchMissionEvents](../Source/Game/Missions/DispatchMissionEvents.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `MissileTarget` | `#D0E3` | данные | код захваченной цели ракеты |

## [RatingBountyDamageAndNewCommander](../Source/Game/Missions/RatingBountyDamageAndNewCommander.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `Game.Missions.RatingBountyDamageAndNewCommander.CargoOffset` | `#D223` | операнд команды | операнд CALL прибавления индекса к адресу груза |
| `DecimalRest` | `#D2DC` | данные | остаток десятичного преобразования числа |

## [AnimateIntroObject](../Source/Game/Motion/AnimateIntroObject.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `SteeringVector.X` | `#A2B8` | данные | знаковая X-компонента вектора к цели |
| `SteeringVector.Y` | `#A2BA` | данные | знаковая Y-компонента вектора к цели |
| `SteeringVector.Z` | `#A2BC` | данные | знаковая Z-компонента вектора к цели |
| `SteeringVector.Length` | `#A2BE` | данные | длина вектора к цели перед нормированием |

## [ApplyPlayerMotionToObject](../Source/Game/Motion/ApplyPlayerMotionToObject.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `MotionRaster.TranslateGate` | `#A1AD` | операнд команды | код LD A либо RET, временное отключение поступательного сдвига |

## [DotProductAxisHighBytes](../Source/Game/Motion/DotProductAxisHighBytes.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `ProjectedRadius` | `#A6DE` | данные | экранный радиус объекта после деления на глубину |

## [ProjectObjectAndSelectDetail](../Source/Game/Motion/ProjectObjectAndSelectDetail.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `ObjectRaster.TargetValue` | `#A79D` | операнд команды | операнд LD A,0, значение записи в номер цели прицела |

## [ScaleAxisHighByte](../Source/Game/Motion/ScaleAxisHighByte.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `RotationState.Roll` | `#9F80` | данные | угол крена, знак в бите 7, модуль в битах 6..0 |
| `RotationState.Pitch` | `#9F81` | данные | угол тангажа, знак в бите 7, модуль в битах 6..0 |

## [XorFarObjectPixel](../Source/Game/Motion/XorFarObjectPixel.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `ObjectRaster.PixelMode` | `#A849` | операнд команды | два байта конца SET 7,H и XOR (HL), патч прямого экрана |

## [ActivateEnemyECM](../Source/Game/Objects/ActivateEnemyECM.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `ObjectTemplate` | `#B83E` | данные | шаблон первых 31 байта объекта, копируется в поля X..Pitch |
| `IntroMatrix` | `#B85D` | данные | девять старших байтов осей модели заставки |
| `SpawnAxis` | `#B866` | данные | переключатель чередования осей при создании объекта |

## [GenerateSpaceTraffic](../Source/Game/Objects/GenerateSpaceTraffic.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `FaceState.Object` | `#BCC8` | данные | сохранённый адрес исходного объекта из IX |
| `FaceState.Scale` | `#BCCA` | данные | сдвиг нормали из FModel.NormalScale |
| `FaceState.PositionX` | `#BCCB` | данные | знако-модульная координата X для скалярного произведения |
| `FaceState.PositionY` | `#BCCD` | данные | знако-модульная координата Y для скалярного произведения |
| `FaceState.PositionZ` | `#BCCF` | данные | знако-модульная координата Z для скалярного произведения |
| `FaceState.NormalX` | `#BCD1` | данные | преобразованная знаковая компонента нормали X |
| `FaceState.NormalY` | `#BCD2` | данные | преобразованная знаковая компонента нормали Y |
| `FaceState.NormalZ` | `#BCD3` | данные | преобразованная знаковая компонента нормали Z |

## [LoadingScreen](../Source/Game/Resources/LoadingScreen.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `ScratchStack` | `#40F0` | наложение в памяти | 48 байтов экранной области под временный стек |

## [DrawScannerObjects](../Source/Game/Scanner/DrawScannerObjects.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `ScannerRaster.Mode` | `#972F` | операнд команды | код AND A либо SCF, выбор обычной или альтернативной проекции |

## [FillCockpitAttributePanel](../Source/Game/Scanner/FillCockpitAttributePanel.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `CockpitBlink` | `#99A3` | данные | счётчик мигания аварийного индикатора, бит 1 выбирает красную фазу |

## [RestoreScannerBackground](../Source/Game/Scanner/RestoreScannerBackground.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `ScannerCopy.SelectSource` | `#9912` | операнд команды | код EX DE,HL либо NOP, выбор источника |
| `ScannerCopy.SaveCharRow` | `#9915` | операнд команды | код PUSH HL либо PUSH DE, сохранение экранной базы знакоместа |
| `ScannerCopy.SavePixelRow` | `#991A` | операнд команды | код PUSH HL либо PUSH DE, сохранение экранной строки |

## [ScaleValueAndFinishBackground](../Source/Game/Scanner/ScaleValueAndFinishBackground.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `ScannerMap` | `#992B` | таблица | байты прежнего кода, используемые как поток альтернативного фона |
| `ScannerCopy.RestoreRow` | `#9935` | операнд команды | код POP HL либо POP DE, восстановление экранной строки |
| `ScannerCopy.AdvanceRow` | `#9936` | операнд команды | код INC H либо INC D, следующая пиксельная строка |
| `ScannerCopy.SelectScreen` | `#9939` | операнд команды | код EX DE,HL либо NOP перед переходом к знакоместу |
| `ScannerCopy.SelectTarget` | `#9940` | операнд команды | код NOP либо EX DE,HL, возврат направления копирования |

## [CargoTripleOffset](../Source/Game/Screen/CargoTripleOffset.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `LegacyPrice` | `#0667` | адрес чтения ROM | исходный адрес чтения трёхбайтовой цены для индекса от 14, содержимое ROM не объявляется переменной игры |

## [ConsumeEscapePod](../Source/Game/Screen/ConsumeEscapePod.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `CompassBitmap` | `#8491` | таблица | фон компаса, 12 строк по три байта |

## [DispatchMenu](../Source/Game/Screen/DispatchMenu.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `MenuDispatch.Target` | `#8154` | операнд команды | адрес вызываемого обработчика меню в операнде CALL |

## [DrawIndicatorBar](../Source/Game/Screen/DrawIndicatorBar.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `IndicatorDraw.BoundaryMask` | `#856D` | операнд команды | маска границы, #FF для полосы и #03 для маркера |
| `IndicatorDraw.BodyFill` | `#8597` | операнд команды | заполнитель полных байтов полосы, #FF либо #00 |
| `IndicatorDraw.FullFill` | `#85B9` | операнд команды | заполнитель полной шкалы, #FF либо #00 |

## [ResetCargoCapacity](../Source/Game/Screen/ResetCargoCapacity.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `MenuDispatch.SavedSP` | `#80D1` | данные | реальный стек, сохранённый перед вызовом меню |

## [RestrictDockingView](../Source/Game/Screen/RestrictDockingView.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `CompassState.SunNear` | `#81A4` | данные | флаг, солнце прошло проверку ближнего диапазона координат |
| `CompassState.PlanetNear` | `#81A5` | данные | флаг, планета обрабатывается в ближнем диапазоне |
| `CompassState.X` | `#81A6` | данные | нормированная горизонтальная координата указателя |
| `CompassState.Y` | `#81A7` | данные | нормированная вертикальная координата указателя |
| `CompassState.Behind` | `#81A8` | данные | флаг, объект компаса находится позади корабля |

## [SelectTrafficType](../Source/Game/Screen/SelectTrafficType.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `Game.Screen.SelectTrafficType.InvasionCall` | `#800D` | операнд команды | адрес обработчика проверки особой области в CALL |

## [SwapAndSkipRow](../Source/Game/Screen/SwapAndSkipRow.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `Game.Screen.SwapAndSkipRow.NextRowCall` | `#7FE4` | код команды | CALL либо JP, один или два перехода к следующей строке |

## [UpdateIndicators](../Source/Game/Screen/UpdateIndicators.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `IndicatorDraw.MarkerMode` | `#8523` | данные | режим прибора, 0 полоса, 1 подвижный маркер |
| `GaugeAddresses` | `#8524` | данные | экранные адреса шкал, UpdateIndicators использует первые 13 слов |

## [WriteIndicatorMask](../Source/Game/Screen/WriteIndicatorMask.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `CircleState.OffsetY` | `#861A` | данные | модуль вертикального смещения центра |
| `CircleState.OffsetX` | `#861B` | данные | модуль горизонтального смещения центра |
| `CircleState.Flags` | `#861C` | данные | знаки и признаки диапазона центра, схема в FCircleState |
| `CircleState.Radius` | `#861D` | данные | радиус окружности в пикселях |
| `CircleState.ClipY` | `#861E` | данные | рабочий модуль Y или расстояние до вертикальной границы |
| `CircleState.ClipX` | `#861F` | данные | рабочий модуль X или расстояние до боковой границы |
| `CircleState.ScreenY` | `#8620` | данные | экранная строка центра или начало отсечённой дуги |
| `CircleState.ScreenX` | `#8621` | данные | экранный столбец центра |
| `CircleState.Cathetus` | `#8622` | данные | катет точки пересечения круга с границей |
| `CircleState.SavedSP` | `#8623` | данные | реальный стек до временного заполнения или чтения таблицы |
| `CircleState.Radicand` | `#8625` | данные | подкоренное значение r*r - d*d - входной перенос |
| `CircleState.LeftMask` | `#8627` | данные | маска левого края перед заполнением строки |
| `CircleState.DirectionDown` | `#8628` | данные | направление дуги, 0 вверх, 1 вниз |
| `CircleState.OutlineOnly` | `#8629` | данные | режим окружности, 0 заливка, 1 только контур |
| `CircleState.PatchCount` | `#862A` | данные | число байтов патча области обзора |

## [StartHyperjumpNoise](../Source/Game/Sound/StartHyperjumpNoise.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `SoundRequest` | `#96BF` | данные | номер выбранного звукового запроса, 0..7 |
| `Game.Sound.StartHyperjumpNoise.ScaledX` | `#96C0` | данные | масштабированная координата X объекта для сканера |
| `ScannerState.ScaledX` | `#96C0` | данные | масштабированная X, знак в бите 7 |
| `Game.Sound.StartHyperjumpNoise.ScaledY` | `#96C1` | данные | масштабированная высота Y объекта для сканера |
| `ScannerState.ScaledY` | `#96C1` | данные | масштабированная высота Y, знак в бите 7 |
| `Game.Sound.StartHyperjumpNoise.ScaledZ` | `#96C2` | данные | масштабированная глубина Z объекта для сканера |
| `ScannerState.ScaledZ` | `#96C2` | данные | масштабированная глубина Z, знак в бите 7 |
| `Game.Sound.StartHyperjumpNoise.ObjectIndex` | `#96C3` | данные | номер обрабатываемого слота сканера |
| `ScannerState.ObjectIndex` | `#96C3` | данные | обратный номер обрабатываемого слота, 8..1 |
| `Game.Sound.StartHyperjumpNoise.Redraw` | `#96C4` | данные | флаг, фон сканера требуется восстановить |
| `ScannerState.Redraw` | `#96C4` | данные | флаг, фон сканера изменён и требует восстановления |

## [StepDataTone](../Source/Game/Sound/StepDataTone.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `ToneShift` | `#95F2` | операнд команды | изменяемая двухбайтовая команда преобразования отсчёта тона |

## [StepNoise](../Source/Game/Sound/StepNoise.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `NoiseSamples` | `#95AE` | операнд команды | изменяемый операнд LD C, число отсчётов шумового пакета |
| `NoiseStep` | `#95BD` | операнд команды | изменяемый операнд ADD A, шаг задержки шумового пакета |

## [StepPitchSweep](../Source/Game/Sound/StepPitchSweep.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `PitchStep` | `#962B` | операнд команды | изменяемый операнд ADD A, шаг периода скользящего тона |

## [DrawCharacter8x8](../Source/Game/Text/DrawCharacter8x8.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `TextScreenHigh` | `#D50A` | операнд команды | старший байт базового адреса текста, #40 либо #C0 |

## [NextDescriptionRandom](../Source/Game/Text/NextDescriptionRandom.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `Game.Text.NextDescriptionRandom.InvasionCall` | `#D5FF` | операнд команды | операнд вызова проверки региона |

## [XorCharacterScanlines](../Source/Game/Text/XorCharacterScanlines.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `Game.Text.XorCharacterScanlines.XorOpcode` | `#D548` | код команды | XOR C либо NOP при выводе глифа |

## [EquipmentAlreadyOwned](../Source/Game/Trade/EquipmentAlreadyOwned.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `EquipmentWork.ItemLimit` | `#EB5E` | данные | наибольший номер разрешённого оборудования |
| `EquipmentWork.ItemIndex` | `#EB5F` | данные | номер пункта при выводе списка оборудования |
| `EquipmentWork.PriceCursor` | `#EB60` | данные | адрес текущей трёхбайтовой цены оборудования |
| `EquipmentWork.LaserType` | `#EB62` | данные | код выбранного типа лазера |

## [GenerateMarket](../Source/Game/Trade/GenerateMarket.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `MarketStore` | `#E1B0` | операнд команды | изменяемая команда LD (HL),A, NOP сохраняет остатки рынка нового командира |
| `BeforePrices` | `#E1BB` | данные | нулевое слово перед ценами, обход сначала увеличивает указатель на 2 |
| `MarketPrices` | `#E1BD` | данные | семнадцать двухбайтовых рыночных цен |
| `MarketWork.Commodity` | `#E1DF` | данные | номер текущего товара, 0..16 |
| `MarketWork.CargoCursor` | `#E1E0` | данные | адрес количества выбранного товара в трюме |
| `MarketWork.PriceCursor` | `#E1E2` | данные | адрес двухбайтовой цены выбранного товара |
| `MarketWork.StockCursor` | `#E1E4` | данные | адрес остатка выбранного товара на станции |
| `MarketWork.TextPosition` | `#E1E6` | данные | сохранённые столбец и строка печати |

## [PromptCargoQuantityAndRefugees](../Source/Game/Trade/PromptCargoQuantityAndRefugees.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `TradeSnapshot.CashHigh` | `#E8A4` | данные | сохранённое старшее слово денег перед сделкой |
| `TradeSnapshot.CashLow` | `#E8A6` | данные | сохранённое младшее слово денег перед сделкой |
| `TradeSnapshot.CargoCount` | `#E8A8` | данные | сохранённое количество товара в трюме |
| `TradeSnapshot.StockCount` | `#E8A9` | данные | сохранённый остаток товара станции |
| `TradeSnapshot.FreeCargo` | `#E8AA` | данные | сохранённый свободный объём трюма |
| `TradeSnapshot.Selection` | `#E8AB` | данные | введённое количество товара либо номер покупаемого оборудования |
| `TradeSnapshot.Validator` | `#E8AC` | данные | адрес проверки очередного изменения количества |
| `TradeAttrs` | `#E8D8` | данные | однобайтовая последовательность настройки атрибутов торговли |

## [ResetCloakingAndSeedFlightRandom](../Source/Game/Trade/ResetCloakingAndSeedFlightRandom.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `BuyAttributes` | `#E6F8` | данные | двухбайтовая последовательность настройки атрибутов экрана покупки |

## [RestoreTextPosition](../Source/Game/Trade/RestoreTextPosition.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `TextInput.Length` | `#E394` | данные | число введённых символов |
| `TextInput.Cursor` | `#E395` | данные | адрес следующего символа в буфере ввода |
| `TextInput.LastKey` | `#E397` | данные | последний принятый код клавиши |

## [ClearFlightEventsAndHandleJump](../Source/Game/Travel/ClearFlightEventsAndHandleJump.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `JumpCountdown` | `#DBA1` | данные | остаток отсчёта гиперперехода, ноль означает отсутствие отсчёта |

## [LaserTypeAndArrivalEvents](../Source/Game/Travel/LaserTypeAndArrivalEvents.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `ArrivalGate` | `#DDFB` | операнд команды | изменяемый JR Z событий прибытия, временный RET подавляет этот хвост |

## [SetFuelAndGauge](../Source/Game/Travel/SetFuelAndGauge.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `Game.Travel.SetFuelAndGauge.SeedPrefix` | `#DEB9` | данные | сохранённый байт перед семенами систем |
| `GalaxyState.TargetSeed` | `#DEBA` | данные | шестибайтовое семя выбранной цели |
| `GalaxyState.WorkingSeed` | `#DEC0` | данные | рабочее семя перебора и генерации имени |
| `GalaxyState.SavedSeed` | `#DEC6` | данные | копия рабочего семени на время вложенного перебора |
| `GalaxyState.TextSeed` | `#DECC` | данные | четыре байта генератора описаний |
| `GalaxyState.InputBuffer` | `#DED0` | данные | десять вводимых символов и завершающий ноль |
| `GalaxyState.GeneratedName` | `#DEDB` | данные | восемь букв имени и завершающий ноль |
| `GalaxyState.CurrentName` | `#DEE4` | данные | сохранённое имя текущей системы |
| `GalaxyState.TargetName` | `#DEED` | данные | сохранённое имя выбранной цели |
| `GalaxyState.Distance` | `#DEF6` | данные | расстояние до цели в десятых светового года |
| `GalaxyState.Economy` | `#DEF8` | данные | экономика выбранной системы, индекс 0..7 |
| `GalaxyState.Government` | `#DEF9` | данные | правительство выбранной системы, индекс 0..7 |
| `GalaxyState.Technology` | `#DEFA` | данные | технологический уровень, счёт с нуля |
| `GalaxyState.Population` | `#DEFB` | данные | население в десятых миллиарда |
| `GalaxyState.Productivity` | `#DEFC` | данные | производительность системы |
| `GalaxyState.Reserved` | `#DEFE` | данные | сохранённые байты образа, обращений к полю не найдено |
| `GalaxyState.ScanIndex` | `#DF00` | данные | индекс перебора, переполнение завершает 256 систем |
| `GalaxyState.NameCursor` | `#DF01` | данные | адрес следующего символа в GeneratedName |

## [ApplyEnhancedFlightControl](../Source/Game/Universe/ApplyEnhancedFlightControl.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `Game.Universe.ApplyEnhancedFlightControl.DirectKeyRead` | `#7F87` | операнд команды | начало прямого чтения клавиши, демо подставляет виртуальную строку |
| `Game.Universe.ApplyEnhancedFlightControl.InvasionCall` | `#7FB2` | операнд команды | операнд CALL проверки области вторжения, демо подставляет перенесённую копию |

## [GetObjectMetadataAddress](../Source/Game/Universe/GetObjectMetadataAddress.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `FastTravel` | `#7EDD` | данные | флаг, выполнен ускоренный перенос звёздного поля |

## [HandleFastTravelStep](../Source/Game/Universe/HandleFastTravelStep.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `FastSpawnPhase` | `#7F0B` | операнд команды | чередующаяся маска #55/#AA в операнде LD A |

## [SelectSpecialCargoText](../Source/Game/Universe/SelectSpecialCargoText.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `StarPoints` | `#7A39` | данные | 16 пар знако-модульных координат звёзд |

## [UpdateAndDrawStarField](../Source/Game/Universe/UpdateAndDrawStarField.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `StarView` | `#78B5` | операнд команды | предыдущий номер вида в операнде CP, смена вида очищает звёзды |

## [AdvanceObjectMetadata](../Source/Game/Wireframe/AdvanceObjectMetadata.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `ProjectedVerts` | `#A8FA` | данные | 46 экранных вершин по три байта, X, Y, признаки |
| `ProjectedVerts + 16` | `#A90A` | смещение в буфере | переиспользуемая область поиска планет в буфере экранных вершин |
| `FaceVisibility` | `#A984` | данные | 16 байтов видимости граней |
| `ObjectMatrix` | `#A994` | данные | матрица поворота, три строки по три знаковых слова |
| `VertexProducts` | `#A9A6` | данные | девять кэшированных произведений модулей вершины и матрицы |
| `ProjectionState.Depth` | `#A9B8` | данные | глубина объекта, младший байт затем переиспользуется как уровень детализации |
| `ProjectionState.VertexOffset` | `#A9BA` | данные | смещение трёхбайтовой записи в таблице экранных вершин |
| `ProjectionState.X` | `#A9BB` | данные | повёрнутая X-компонента, затем X с добавленным положением объекта |
| `ProjectionState.Y` | `#A9BD` | данные | повёрнутая Y-компонента, затем Y с добавленным положением объекта |
| `ProjectionState.Z` | `#A9BF` | данные | повёрнутая Z-компонента, затем Z с добавленным положением объекта |
| `ProjectionState.ScreenX` | `#A9C1` | данные | модуль горизонтальной проекции центра или вершины |
| `ProjectionState.ScreenY` | `#A9C2` | данные | модуль вертикальной проекции центра или вершины |
| `ProjectionState.Flags` | `#A9C3` | данные | бит 1 знак X, бит 0 знак Y, схема в FProjectionState |
| `ProjectionState.SignX` | `#A9C4` | данные | знаковый старший байт пространственной координаты X |
| `ProjectionState.SignY` | `#A9C5` | данные | знаковый старший байт пространственной координаты Y |
| `ProjectionState.SignZ` | `#A9C6` | данные | знаковый старший байт пространственной координаты Z |
| `ProjectionState.Scale` | `#A9C7` | данные | число левых сдвигов для повышенной точности ближней вершины |
| `ProjectionState.NoCache` | `#A9C8` | данные | флаг, произведения предыдущей вершины нельзя использовать |

## [AnyPackedFaceVisible](../Source/Game/Wireframe/AnyPackedFaceVisible.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `VertexRaster.FaceCombine` | `#AA1E` | операнд команды | код OR B, объединение видимости двух граней |

## [BuildProjectedVertexTable](../Source/Game/Wireframe/BuildProjectedVertexTable.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `VertexFlags.Previous` | `#AA0E` | данные | предыдущие признаки знаков для повторного использования произведений |
| `VertexFlags.Current` | `#AA0F` | данные | текущие признаки координат из потока вершин |

## [DivideFractionAndProjectVertex](../Source/Game/Wireframe/DivideFractionAndProjectVertex.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `VertexFraction.X` | `#AC9F` | данные | дополнительные дробные разряды повёрнутой X-компоненты |
| `VertexFraction.Y` | `#ACA0` | данные | дополнительные дробные разряды повёрнутой Y-компоненты |
| `VertexFraction.Z` | `#ACA1` | данные | дополнительные дробные разряды повёрнутой Z-компоненты |

## [DivideSlopeAndDrawScanner](../Source/Game/Wireframe/DivideSlopeAndDrawScanner.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `ScannerBlocks - 9` | `#B38C` | смещение в буфере | база на один шаг до первого блока альтернативного фона |
| `ScannerBlocks` | `#B395` | таблица | блоки альтернативного фона сканера с шагом выбора 9 байтов |

## [DrawClippedLine](../Source/Game/Wireframe/DrawClippedLine.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `LineRaster.SteepStep` | `#B1B5` | операнд команды | код INC H либо DEC H для крутого отрезка |
| `LineRaster.SteepPixel` | `#B1B7` | операнд команды | код OR (HL) либо XOR (HL), наложение одиночного пикселя |
| `LineRaster.SteepFraction` | `#B1BD` | операнд команды | дробный шаг X в операнде ADD A для крутого отрезка |
| `LineRaster.SteepRowOffset` | `#B1C7` | операнд команды | смещение JR к направлению смены знакоместа крутого отрезка |
| `LineRaster.RunStep` | `#B20D` | операнд команды | код INC H либо DEC H для пологого отрезка |
| `LineRaster.RunLength` | `#B20F` | операнд команды | целая часть числа пикселей на строку в операнде LD D |
| `LineRaster.RunFraction` | `#B212` | операнд команды | дробная часть числа пикселей на строку в операнде ADD A |
| `LineRaster.MaskOffset` | `#B231` | операнд команды | смещение IX при выборе маски первого байта группы |
| `LineRaster.FirstPixel` | `#B232` | операнд команды | код OR (HL) либо XOR (HL), наложение первого байта группы |
| `LineRaster.FullPixel` | `#B244` | операнд команды | код OR (HL) либо XOR (HL), наложение полного байта группы |
| `LineRaster.LastPixel` | `#B252` | операнд команды | код OR (HL) либо XOR (HL), наложение последнего байта группы |
| `LineRaster.NextBit` | `#B25D` | операнд команды | номер первого пикселя следующей строки в операнде LD C |
| `LineRaster.RunRowOffset` | `#B25F` | операнд команды | смещение JR к направлению смены знакоместа пологого отрезка |

## [DrawScannerMarkerSegment](../Source/Game/Wireframe/DrawScannerMarkerSegment.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `ScannerRaster.StepOpcodes` | `#B446` | операнд команды | два кода INC/DEC B/C либо NOP, шаг отрезка маркера |
| `ObjectEffects.Records - FEffectRecord10` | `#B44D` | смещение в буфере | база на одну запись до первого слота для индексации от 1 |
| `ObjectEffects.Current` | `#B452` | данные | указатель текущей десятибайтовой записи расширенного эффекта |
| `ObjectEffects.Phase` | `#B454` | данные | фаза распределения объектов, младшие два бита проходят 1, 2, 3 |
| `ObjectEffects.Remaining` | `#B455` | данные | обратный номер текущего слота, счётчик обхода от 8 до 1 |
| `ObjectEffects.Flags` | `#B456` | данные | общие флаги режима расширенных эффектов |
| `ObjectEffects.Records` | `#B457` | данные | восемь десятибайтовых записей FEffectRecord10 |
| `ObjectEffects.Records + 1` | `#B458` | смещение в буфере | второй байт массива, назначение LDIR при обнулении |
| `ObjectEffects.Records + FEffectRecord10` | `#B461` | смещение в буфере | расширенная запись первого обычного объекта после станции |
| `ObjectEffects.Scratch` | `#B4A7` | данные | дополнительная запись, исходная цель указателя Current |

## [DrawWireframeObject](../Source/Game/Wireframe/DrawWireframeObject.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `ScannerAttrs` | `#A89C` | таблица | смещения изменяемых атрибутов сканера, #FF завершает таблицу |

## [InitializeObjectFromModelNumber](../Source/Game/Wireframe/InitializeObjectFromModelNumber.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `DemoModels` | `#AE3C` | таблица | двенадцать номеров моделей демонстрационного экрана |

## [ReadFaceVisibilityNibble](../Source/Game/Wireframe/ReadFaceVisibilityNibble.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `VertexRaster.FaceAddress` | `#AA28` | операнд команды | младший байт адреса чтения флага выбранной грани |

## [ReadObjectTacticsGates](../Source/Game/Wireframe/ReadObjectTacticsGates.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `LaserRaster.Signs` | `#B4D6` | данные | биты 3/2 знаков центральной точки свободного лазерного луча |
| `LaserRaster.TriggerHeld` | `#B4D7` | данные | флаг, спуск лазера был активен на предыдущем обновлении |

## [RefreshScannerBackground](../Source/Game/Wireframe/RefreshScannerBackground.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `ScannerRaster.BackdropMode` | `#B3B3` | операнд команды | операнд LD A, 7 обычный фон и атрибут, 0 альтернативный фон |

## [Constants](../Source/Loader/Constants.inc)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `Loader.START_STACK` | `#4120` | адресная константа | исходный стек перед передачей управления игре |
| `Loader.MUTATE_BASE` | `#5B00` | адресная константа | нижняя граница выбираемых адресов XOR-преобразования |
| `Loader.RAM_LIMIT` | `#5FFF` | адресная константа | восстанавливаемая верхняя граница памяти BASIC |
| `Loader.SNAP_MIDDLE` | `#6000` | адресная константа | начало загружаемого блока снимка #6000..#C7FF |
| `Loader.SNAP_HIGH` | `#D000` | адресная константа | начало загружаемого блока снимка #D000..#FFFF |

## [Constants](../Source/Manual/Constants.inc)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `Manual.STACK_TOP` | `#0000` | адресная константа | верх памяти с 16-битным оборотом, первый PUSH записывает #FFFE/#FFFF |
| `Manual.ROM_FONT` | `#3C00` | адресная константа | исходная база CHARS стандартного шрифта ПЗУ |
| `Manual.VIEW_TOP` | `#4040` | адресная константа | левая граница растровой строки 16, верх окна |
| `Manual.VIEW_NEXT` | `#4140` | адресная константа | растровая строка 17, источник сдвига вверх на один пиксель |
| `Manual.EDGE_PREV` | `#4620` | адресная константа | растровая строка 14, второй верхний срез при двойном шаге |
| `Manual.EDGE_TOP` | `#4720` | адресная константа | растровая строка 15, новый верхний край перед сдвигом вниз |
| `Manual.EDGE_BOTTOM` | `#50A0` | адресная константа | растровая строка 168, новый нижний край перед сдвигом вверх |
| `Manual.EDGE_NEXT` | `#51A0` | адресная константа | растровая строка 169, второй нижний срез при двойном шаге |
| `Manual.VIEW_PREV` | `#5680` | адресная константа | растровая строка 166, источник сдвига вниз на один пиксель |
| `Manual.VIEW_BOTTOM` | `#5780` | адресная константа | левая граница растровой строки 167, низ окна |
| `Manual.SPEED_ATTR` | `#5AE0` | адресная константа | атрибутная строка 23, индикатор скорости прокрутки |
| `Manual.BOOT_STACK` | `#5C00` | адресная константа | временный стек переноса, верхняя граница исходной области #5B00..#5BFF |
| `Manual.PACK_LAST` | `#FFFF` | адресная константа | последний байт назначения LDDR, конец упакованного текста и словаря |

## [Data](../Source/Manual/Data.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `Manual.Title` | `#977F` | данные | заголовок с управляющими кодами ROM и ограничителем 255 |
| `Manual.MenuHint` | `#97C2` | данные | подсказка выбора раздела |
| `Manual.ScrollHint` | `#97E4` | данные | подсказка клавиш скорости, остановки и выхода |
| `Manual.LoadCommand` | `#982D` | данные | токенизированная команда REM, двоеточие, LOAD ELITE3 и ENTER |
| `Manual.DoubleStep` | `#9839` | данные | режим шага, 0 одна строка и 1 две строки |
| `Manual.FrameDelay` | `#983A` | данные | задержка между сдвигами в кадрах |
| `Manual.ScrollTimer` | `#983B` | данные | счётчик кадров, 0 означает паузу |
| `Manual.KeyTimer` | `#983C` | данные | счётчик до очередного опроса клавиатуры |
| `Manual.UnusedState` | `#983D` | данные | исходный байт 8, обращений из кода просмотрщика не найдено |
| `Manual.GlyphRow` | `#983E` | данные | номер растровой строки символа, 0-7 |
| `Manual.Reverse` | `#983F` | данные | направление просмотра, 0 обычное и 1 обратное |

## [ReadControls](../Source/Manual/ReadControls.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `Manual.ReturnSP` | `#9AE6` | операнд команды | сохранённый SP вызова ShowSection в операнде LD SP |

## [State](../Source/Manual/State.asm)

| Имя или поле | Адрес | Представление | Назначение |
|---|---|---|---|
| `Manual.Selection` | `#9768` | данные | ASCII-код выбранного раздела |
| `Manual.ViewState` | `#9769` | данные | состояние просмотра, 255 продолжение |
| `Manual.TextPointer` | `#976A` | данные | адрес текущей строки распакованного текста |
