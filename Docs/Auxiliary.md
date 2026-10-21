# Руководство, загрузчик и дисковые оверлеи

Исходники здесь сохраняют собственные адреса исполнения через `DISP/ENT`.
Положение внутри файла и адрес команды в памяти различаются.
Встроенные байты после CALL, текстовые токены, таблицы и секторные хвосты
отмечены отдельно. Команды ROM/TR-DOS остаются внешними вызовами.

Полное устройство просмотрщика описано в [его README](../Source/Manual/README.md).
Главный [указатель игрового блока](Functions.md) находится отдельно.

## Commanders

| Исходник | Назначение |
|---|---|
| [Deadly](../Source/Commanders/Deadly.asm) | сохранённый командир DEADLY, структура FCommander, 102 байта |
| [QS1](../Source/Commanders/QS1.asm) | сохранённый командир QS1, структура FCommander, 102 байта |

## DiskUtility/Demo

| Исходник | Назначение |
|---|---|
| [ActionTimer](../Source/DiskUtility/Demo/ActionTimer.asm) | Таймер изменения поведения и экрана |
| [AddByteOffset](../Source/DiskUtility/Demo/AddByteOffset.asm) | Прибавление беззнакового индекса к указателю |
| [AdvanceObjectCursor](../Source/DiskUtility/Demo/AdvanceObjectCursor.asm) | Циклический переход по семи слотам после станции |
| [AimAtNearBody](../Source/DiskUtility/Demo/AimAtNearBody.asm) | Выбор станции или планеты для ближнего наведения |
| [ApplyAccelerationKey](../Source/DiskUtility/Demo/ApplyAccelerationKey.asm) | Виртуальное ускорение и команда прыжка |
| [ApplyBrakeKey](../Source/DiskUtility/Demo/ApplyBrakeKey.asm) | Виртуальная команда уменьшения скорости |
| [ApplyDefenceKeys](../Source/DiskUtility/Demo/ApplyDefenceKeys.asm) | Решение об энергетической бомбе и маскировке |
| [ApplyPitchKeys](../Source/DiskUtility/Demo/ApplyPitchKeys.asm) | Выбор тангажа по знаку Y цели |
| [ApplyRollKeys](../Source/DiskUtility/Demo/ApplyRollKeys.asm) | Выбор крена по знакам X и Y цели |
| [ApproachCelestialBody](../Source/DiskUtility/Demo/ApproachCelestialBody.asm) | Полёт к солнцу с проверкой близкой станции |
| [AttackSelectedTarget](../Source/DiskUtility/Demo/AttackSelectedTarget.asm) | Сценарий переключения сканера и атаки цели |
| [BeepAndWait](../Source/DiskUtility/Demo/BeepAndWait.asm) | Звуковое действие с задержкой |
| [BombDelayCounter](../Source/DiskUtility/Demo/BombDelayCounter.asm) | Делитель частоты команды энергетической бомбы |
| [BrakeForDistantTarget](../Source/DiskUtility/Demo/BrakeForDistantTarget.asm) | Торможение по старшим разрядам удаления Z |
| [CheckAttackTarget](../Source/DiskUtility/Demo/CheckAttackTarget.asm) | Допуск объекта к боевому преследованию |
| [CheckDemoRestart](../Source/DiskUtility/Demo/CheckDemoRestart.asm) | Перезапуск сценария при сброшенном маркере |
| [CheckInterruptedHalt](../Source/DiskUtility/Demo/CheckInterruptedHalt.asm) | Проверка остановки игрового потока на HALT |
| [CheckInvasionBand](../Source/DiskUtility/Demo/CheckInvasionBand.asm) | Проверка полосы вторжения с двумя порогами |
| [ChooseCelestialTarget](../Source/DiskUtility/Demo/ChooseCelestialTarget.asm) | Выбор солнца либо станции в качестве ориентира |
| [ChooseDemoAction](../Source/DiskUtility/Demo/ChooseDemoAction.asm) | Выбор боевого режима или смены обзорного экрана |
| [ChooseObjectAimPrecision](../Source/DiskUtility/Demo/ChooseObjectAimPrecision.asm) | Выбор точности наведения на объект |
| [ChooseRollFromSign](../Source/DiskUtility/Demo/ChooseRollFromSign.asm) | Выбор крена по знаку текущего вращения |
| [ClearMainKeyboardRows](../Source/DiskUtility/Demo/ClearMainKeyboardRows.asm) | Очистка семи строк виртуальной клавиатуры |
| [CollectFloatingCargo](../Source/DiskUtility/Demo/CollectFloatingCargo.asm) | Наведение для подбора допустимого груза |
| [CollectNearbyTarget](../Source/DiskUtility/Demo/CollectNearbyTarget.asm) | Точное доведение близкой цели |
| [CompareCoordinateSum](../Source/DiskUtility/Demo/CompareCoordinateSum.asm) | Порог суммы модулей трёх целых координат |
| [CompareWords](../Source/DiskUtility/Demo/CompareWords.asm) | Беззнаковое сравнение суммы с порогом без изменения HL |
| [CoroutineDispatch](../Source/DiskUtility/Demo/CoroutineDispatch.asm) | Переключаемый вход первого запуска и возобновления |
| [CoroutineResumePoint](../Source/DiskUtility/Demo/CoroutineResumePoint.asm) | Возврат в место последней уступки кадра |
| [CoroutineStackPointers](../Source/DiskUtility/Demo/CoroutineStackPointers.asm) | Сохранённые указатели двух стеков |
| [CountCollectableMetadata](../Source/DiskUtility/Demo/CountCollectableMetadata.asm) | Подсчёт объектов по признакам собираемого груза |
| [CountHostileTargets](../Source/DiskUtility/Demo/CountHostileTargets.asm) | Подсчёт враждебных боевых целей |
| [CountPlayerSeekingMissiles](../Source/DiskUtility/Demo/CountPlayerSeekingMissiles.asm) | Подсчёт ракет с целью игрока |
| [DemoMarkCellMap](../Source/DiskUtility/Demo/DemoMarkCellMap.asm) | Битовая сетка графического знака |
| [DemoMarkCellShapes](../Source/DiskUtility/Demo/DemoMarkCellShapes.asm) | Индексы фигур занятых клеток |
| [DemoMarkShapeMasks](../Source/DiskUtility/Demo/DemoMarkShapeMasks.asm) | Начальные маски пяти клеточных фигур |
| [DemoMarkTail](../Source/DiskUtility/Demo/DemoMarkTail.asm) | Последний индекс фигуры и сохранённый хвост оверлея |
| [DrawDemoFlightView](../Source/DiskUtility/Demo/DrawDemoFlightView.asm) | Вывод сферы сканера и наложение маркеров |
| [DrawDemoMarkXor](../Source/DiskUtility/Demo/DrawDemoMarkXor.asm) | Рисование знака демо из сетки клеток и пяти фигур |
| [FindAttackTarget](../Source/DiskUtility/Demo/FindAttackTarget.asm) | Поиск подходящей цели за девять проверок |
| [FollowStation](../Source/DiskUtility/Demo/FollowStation.asm) | Сопровождение станции с переходом к новому старту |
| [InitializeDemoScenario](../Source/DiskUtility/Demo/InitializeDemoScenario.asm) | Начальные паузы, разгон и команда старта |
| [ManualKeyboardMode](../Source/DiskUtility/Demo/ManualKeyboardMode.asm) | Ручной режим внутри корутины |
| [ObjectCursor](../Source/DiskUtility/Demo/ObjectCursor.asm) | Указатель последнего просмотренного объекта |
| [ObjectMetadataCache](../Source/DiskUtility/Demo/ObjectMetadataCache.asm) | Кеш восьми флагов объектных метаданных |
| [PauseWithDemoMark](../Source/DiskUtility/Demo/PauseWithDemoMark.asm) | Пауза сценария с временным графическим знаком |
| [PitchWindowCounter](../Source/DiskUtility/Demo/PitchWindowCounter.asm) | Оставшееся окно управления тангажом |
| [PreservedSteeringEntry](../Source/DiskUtility/Demo/PreservedSteeringEntry.asm) | Совместимый вход крена и сохранённый старый выбор тангажа |
| [PrintFormattingToken](../Source/DiskUtility/Demo/PrintFormattingToken.asm) | Совместимая подстановка форматирующего токена |
| [ReadObjectMetadata](../Source/DiskUtility/Demo/ReadObjectMetadata.asm) | Снимок метаданных и выбор флага конкретного объекта |
| [ReadPhysicalKeyboard](../Source/DiskUtility/Demo/ReadPhysicalKeyboard.asm) | Чтение восьми физических строк клавиатуры |
| [RejectCargoTarget](../Source/DiskUtility/Demo/RejectCargoTarget.asm) | Отказ от объекта как собираемого груза |
| [ReservedDemoBytes](../Source/DiskUtility/Demo/ReservedDemoBytes.asm) | Сохранённое нулевое дополнение сценария |
| [RestoreFlightState](../Source/DiskUtility/Demo/RestoreFlightState.asm) | Восстановление состояния старта под демонстрацией |
| [ResumeDemoBeforeKeyboard](../Source/DiskUtility/Demo/ResumeDemoBeforeKeyboard.asm) | Кадровый вызов корутины перед опросом клавиатуры |
| [ResumeDemoCoroutine](../Source/DiskUtility/Demo/ResumeDemoCoroutine.asm) | Возобновление сохранённой корутины |
| [ReverseCourse](../Source/DiskUtility/Demo/ReverseCourse.asm) | Разворот к цели за кораблём |
| [RollWindowCounter](../Source/DiskUtility/Demo/RollWindowCounter.asm) | Оставшееся окно управления креном |
| [StartDemoCoroutine](../Source/DiskUtility/Demo/StartDemoCoroutine.asm) | Первый запуск корутины на отдельном стеке |
| [SteerTowardTarget](../Source/DiskUtility/Demo/SteerTowardTarget.asm) | Наведение с чередованием крена и тангажа |
| [YieldToGame](../Source/DiskUtility/Demo/YieldToGame.asm) | Уступка кадра с сохранением состояния корутины |
| [YieldWithSteeringBrake](../Source/DiskUtility/Demo/YieldWithSteeringBrake.asm) | Согласование виртуальной скорости с поворотами и сбором груза |

## DiskUtility/DemoSetup

| Исходник | Назначение |
|---|---|
| [EnterDemoInstaller](../Source/DiskUtility/DemoSetup/EnterDemoInstaller.asm) | Вход установщика демонстрационного оверлея |
| [InstallDemoOverlay](../Source/DiskUtility/DemoSetup/InstallDemoOverlay.asm) | Установка корутины и виртуальной клавиатуры демо |
| [PreservedMenuExit](../Source/DiskUtility/DemoSetup/PreservedMenuExit.asm) | Сохранённый выход прежнего дискового оверлея |
| [RestartPatch](../Source/DiskUtility/DemoSetup/RestartPatch.asm) | Шаблон восстановления демо после гибели |
| [VirtualInputPatches](../Source/DiskUtility/DemoSetup/VirtualInputPatches.asm) | Три шаблона подмены прямого ввода и проверки объекта |

## DiskUtility/Menu

| Исходник | Назначение |
|---|---|
| [AllocateSaveRecord](../Source/DiskUtility/Menu/AllocateSaveRecord.asm) | выделение одного сектора и создание TR-DOS-записи нового командира |
| [BuildCommanderCatalog](../Source/DiskUtility/Menu/BuildCommanderCatalog.asm) | чтение каталога, отбор командиров и построение списка меню |
| [BuildTrackStream](../Source/DiskUtility/Menu/BuildTrackStream.asm) | создание шестнадцати идентификаторов секторов и дополнительного сектора 17 |
| [CheckMenuAbort](../Source/DiskUtility/Menu/CheckMenuAbort.asm) | опрос SPACE с аварийным возвратом к завершению меню |
| [ClearWorkBuffer](../Source/DiskUtility/Menu/ClearWorkBuffer.asm) | очистка рабочего буфера и области непосредственно под текущим стеком |
| [ComputeNamePosition](../Source/DiskUtility/Menu/ComputeNamePosition.asm) | расчёт позиции имени в сетке из трёх столбцов и восьми строк |
| [ConfirmAndPrepareCopy](../Source/DiskUtility/Menu/ConfirmAndPrepareCopy.asm) | подтверждение, чтение и преобразование трёх секторов перед переходом в CopyEntry |
| [CopyCommanderName](../Source/DiskUtility/Menu/CopyCommanderName.asm) | подстановка текущего имени командира для пустого нового имени |
| [CopyServiceMessages](../Source/DiskUtility/Menu/CopyServiceMessages.asm) | изменяемые сообщения служебного меню копирования |
| [CopyServicePointers](../Source/DiskUtility/Menu/CopyServicePointers.asm) | указатели приёмного и форматируемого потоков и параметр дальнейшего перехода |
| [DispatchMenuCommand](../Source/DiskUtility/Menu/DispatchMenuCommand.asm) | клавиатурный цикл выбора загрузки, сохранения, демонстрации и командира |
| [DrawCommanderNames](../Source/DiskUtility/Menu/DrawCommanderNames.asm) | вывод до 24 восьмибайтовых имён в трёх столбцах |
| [EditSaveName](../Source/DiskUtility/Menu/EditSaveName.asm) | ввод имени сохранения и удаление конечных пробелов либо нулей |
| [EmitRepeatedByte](../Source/DiskUtility/Menu/EmitRepeatedByte.asm) | повторение байта до исчерпания счётчика либо достижения Memory.Attributes |
| [EmitSectorPattern](../Source/DiskUtility/Menu/EmitSectorPattern.asm) | развёртывание шаблона дорожки из пар количество/байт |
| [EnterDiskMenu](../Source/DiskUtility/Menu/EnterDiskMenu.asm) | вход в дисковое меню, восстановление обработчиков и очистка пула объектов |
| [FormatDecimalDigit](../Source/DiskUtility/Menu/FormatDecimalDigit.asm) | выделение одной десятичной цифры повторным вычитанием веса |
| [FormatDecimalNumber](../Source/DiskUtility/Menu/FormatDecimalNumber.asm) | вывод беззнакового слова пятью десятичными цифрами |
| [FormatTrack](../Source/DiskUtility/Menu/FormatTrack.asm) | форматирование потока дорожки с временным переносом стека и проверкой чтения |
| [GetSaveRecord](../Source/DiskUtility/Menu/GetSaveRecord.asm) | расчёт адреса 16-байтовой каталожной записи и проверка её наличия |
| [GetSelectedSave](../Source/DiskUtility/Menu/GetSelectedSave.asm) | получение каталожной записи выбранного командира |
| [HighlightSelectedSave](../Source/DiskUtility/Menu/HighlightSelectedSave.asm) | вывод либо снятие подсветки выбранной строки каталога |
| [LoadCommander](../Source/DiskUtility/Menu/LoadCommander.asm) | загрузка выбранного командира и общий хвост обновления его резервной копии |
| [MeasureTrackMarker](../Source/DiskUtility/Menu/MeasureTrackMarker.asm) | измерение положения пары #A1 после чтения дорожки |
| [MenuBeep](../Source/DiskUtility/Menu/MenuBeep.asm) | короткий звуковой сигнал 65 переключениями бита динамика |
| [MenuMessages](../Source/DiskUtility/Menu/MenuMessages.asm) | текст команд меню, запрос имени и шаблон каталожной записи сохранения |
| [PreservedMenuTail](../Source/DiskUtility/Menu/PreservedMenuTail.asm) | сохранённые десять байтов после конечного RET служебной подготовки |
| [PreservedSectorOrder](../Source/DiskUtility/Menu/PreservedSectorOrder.asm) | сохранённая последовательность номеров секторов от 1 до 16 |
| [PreservedSectorReader](../Source/DiskUtility/Menu/PreservedSectorReader.asm) | строка NO SPACE! с перекрывающейся сохранённой последовательностью чтения сектора |
| [PrintMenuCharacter](../Source/DiskUtility/Menu/PrintMenuCharacter.asm) | вывод одного символа с сохранением указателя списка и счётчиков |
| [ReadSector](../Source/DiskUtility/Menu/ReadSector.asm) | выбор команды чтения сектора и обработчика входного потока |
| [ReadWorkBuffer](../Source/DiskUtility/Menu/ReadWorkBuffer.asm) | чтение сектора в общий буфер DiskBuffer.Work |
| [SaveNamedCommander](../Source/DiskUtility/Menu/SaveNamedCommander.asm) | поиск совпадающего сохранения либо подготовка создания новой записи |
| [SectorFormatPattern](../Source/DiskUtility/Menu/SectorFormatPattern.asm) | шаблон байтовых серий для команды форматирования дорожки |
| [SelectNextSave](../Source/DiskUtility/Menu/SelectNextSave.asm) | выбор следующего командира с проверкой конца списка |
| [SelectPreviousSave](../Source/DiskUtility/Menu/SelectPreviousSave.asm) | выбор предыдущего командира с прокруткой страницы на восемь записей |
| [SelectTrackAndSide](../Source/DiskUtility/Menu/SelectTrackAndSide.asm) | выбор цилиндра и стороны Beta Disk по логическому номеру дорожки |
| [ShowCopyServiceMenu](../Source/DiskUtility/Menu/ShowCopyServiceMenu.asm) | служебное меню счётчиков защитной отметки и допуска копирования |
| [ShowDiskFullError](../Source/DiskUtility/Menu/ShowDiskFullError.asm) | вывод сообщения об отсутствии места и ожидание подтверждения |
| [TransferSector](../Source/DiskUtility/Menu/TransferSector.asm) | обмен одним сектором с проверкой фактически переданных 256 байтов |
| [TransformProtectionMark](../Source/DiskUtility/Menu/TransformProtectionMark.asm) | обратимое XOR-преобразование 256 байтов буфера защитного сектора |
| [UpdateProtectionMark](../Source/DiskUtility/Menu/UpdateProtectionMark.asm) | обновление служебной отметки после проверки и форматирования дорожки |
| [VerifyProtectionMark](../Source/DiskUtility/Menu/VerifyProtectionMark.asm) | проверка временного признака и двух контрольных слов защитного сектора |
| [VerifyProtectionTiming](../Source/DiskUtility/Menu/VerifyProtectionTiming.asm) | проверка измеренного маркера случайной дорожки по сохранённой таблице |
| [WaitMenuKey](../Source/DiskUtility/Menu/WaitMenuKey.asm) | ожидание ненулевого кода клавиши от обработчика прерываний |
| [WriteFdcStream](../Source/DiskUtility/Menu/WriteFdcStream.asm) | передача буфера в выходной обработчик ПЗУ TR-DOS |
| [WriteSector](../Source/DiskUtility/Menu/WriteSector.asm) | выбор команды записи сектора и обработчика выходного потока |
| [WriteWorkBuffer](../Source/DiskUtility/Menu/WriteWorkBuffer.asm) | запись сектора из общего буфера #606F |

## Loader

| Исходник | Назначение |
|---|---|
| [Basic](../Source/Loader/Basic.asm) | исходная токенизированная строка BASIC 10, запускающая машинный загрузчик |
| [Bootstrap](../Source/Loader/Bootstrap.asm) | перенос загрузчика из строки REM в исходную область #C800 |
| [ExchangeState](../Source/Loader/ExchangeState.asm) | взаимный обмен 1024 байт между #5C00..#5FFF и #CC00..#CFFF |
| [Load](../Source/Loader/Load.asm) | поиск ELITE3.C, загрузка рабочих областей 48 КБ снимка и запуск игры |
| [MutateMemory](../Source/Loader/MutateMemory.asm) | снятие побитового кодирования файла игры перед входом Loader.GAME_START |
| [Restart](../Source/Loader/Restart.asm) | сохранённая точка Loader.Restart к Loader.GAME_RESTART |
| [SaveState](../Source/Loader/SaveState.asm) | сохранение позиции дисковых операций и переключение на системную область игры |

## Manual

| Исходник | Назначение |
|---|---|
| [AdvanceText](../Source/Manual/AdvanceText.asm) | переход к следующей или предыдущей строке после восьми растров |
| [BasicTail](../Source/Manual/BasicTail.asm) | токенизированные строки BASIC после машинного кода и ресурсов руководства |
| [Bootstrap](../Source/Manual/Bootstrap.asm) | перенос просмотрщика и упакованного текста из строки REM в исходные адреса |
| [CheckBoundary](../Source/Manual/CheckBoundary.asm) | проверка ограничения области текста в текущем режиме просмотра |
| [ClearAndTitle](../Source/Manual/ClearAndTitle.asm) | очистка экрана ROM и печать заголовка |
| [Data](../Source/Manual/Data.asm) | исходные строки интерфейса, BASIC-команда и состояние просмотрщика |
| [Initialize](../Source/Manual/Initialize.asm) | подготовка шрифта и распаковка руководства перед входом в меню |
| [Interrupt](../Source/Manual/Interrupt.asm) | кадровый обработчик клавиатуры и пиксельной прокрутки |
| [LegacyLimit](../Source/Manual/LegacyLimit.asm) | сохранённый дополнительный путь проверки маркера первого раздела |
| [LoadGame](../Source/Manual/LoadGame.asm) | запуск токенизированной команды загрузки ELITE3 через TR-DOS |
| [Menu](../Source/Manual/Menu.asm) | вывод оглавления и выбор раздела или загрузки ELITE3 |
| [NextScanline](../Source/Manual/NextScanline.asm) | переход к следующей пиксельной строке Spectrum с обменом указателей |
| [PrevScanline](../Source/Manual/PrevScanline.asm) | переход к предыдущей пиксельной строке Spectrum с обменом указателей |
| [PrintString](../Source/Manual/PrintString.asm) | вывод строки ROM до ограничителя #FF |
| [ReadControls](../Source/Manual/ReadControls.asm) | управление паузой, скоростью, направлением и выходом |
| [RenderEdge](../Source/Manual/RenderEdge.asm) | вывод одного или двух растровых срезов текста у края окна |
| [RenderGlyph](../Source/Manual/RenderGlyph.asm) | запись одной растровой строки одного символа |
| [ResumePixel](../Source/Manual/ResumePixel.asm) | немедленное продолжение сдвига до границы знакоместа |
| [ScrollFrame](../Source/Manual/ScrollFrame.asm) | подготовка края и сдвиг окна высотой 152 пиксельные строки |
| [ShowSection](../Source/Manual/ShowSection.asm) | поиск раздела и управление просмотром через прерывания IM 2 |
| [State](../Source/Manual/State.asm) | исходные строки интерфейса, BASIC-команда и состояние просмотрщика |
| [UndoDirection](../Source/Manual/UndoDirection.asm) | переключение направления обратно после недопустимого изменения |
| [UnpackText](../Source/Manual/UnpackText.asm) | распаковка текста с литералами, словарём пар и обратными ссылками |
| [UpdateKeys](../Source/Manual/UpdateKeys.asm) | опрос управления и согласование указателя при смене направления |

## Данные и BASIC

| Исходник | Назначение |
|---|---|
| [Include](../Source/Boot/Include.inc) | начальный BASIC-файл диска |
| [Robot](../Source/DiskUtility/Robot.asm) | сектор состояния ROBOT между двумя исполняемыми оверлеями |

## Последовательное исполнение между файлами

Если последняя ветвь обработчика продолжается без команды перехода, в конце файла стоит
комментарий `; JP имя, продолжение в файл.asm`. Это указатель следующей команды, дополнительных
байтов он не создаёт. В соответствующем `Include.inc` непрерывная цепочка отмечена `(0)`, `(1)`
и далее, её файлы должны сохранять этот порядок. У некоторых файлов есть и другие выходы через
`RET` или явный переход, таблица ниже описывает только ветвь, достигающую следующего файла.

| Исходный файл | Следующий обработчик |
|---|---|
| [WriteWorkBuffer](../Source/DiskUtility/Menu/WriteWorkBuffer.asm) | [WriteSector](../Source/DiskUtility/Menu/WriteSector.asm) |
| [ReadWorkBuffer](../Source/DiskUtility/Menu/ReadWorkBuffer.asm) | [ReadSector](../Source/DiskUtility/Menu/ReadSector.asm) |
| [ReadSector](../Source/DiskUtility/Menu/ReadSector.asm) | [SectorTransfer](../Source/DiskUtility/Menu/TransferSector.asm) |
| [BuildCommanderCatalog](../Source/DiskUtility/Menu/BuildCommanderCatalog.asm) | [MenuInput](../Source/DiskUtility/Menu/DispatchMenuCommand.asm) |
| [SelectNextSave](../Source/DiskUtility/Menu/SelectNextSave.asm) | [DrawSaveNames](../Source/DiskUtility/Menu/DrawCommanderNames.asm) |
| [DrawCommanderNames](../Source/DiskUtility/Menu/DrawCommanderNames.asm) | [PrintMenuChar](../Source/DiskUtility/Menu/PrintMenuCharacter.asm) |
| [GetSelectedSave](../Source/DiskUtility/Menu/GetSelectedSave.asm) | [GetSaveRecord](../Source/DiskUtility/Menu/GetSaveRecord.asm) |
| [CopyCommanderName](../Source/DiskUtility/Menu/CopyCommanderName.asm) | [SaveCommander](../Source/DiskUtility/Menu/SaveNamedCommander.asm) |
| [BuildTrackStream](../Source/DiskUtility/Menu/BuildTrackStream.asm) | [EmitFillByte](../Source/DiskUtility/Menu/EmitRepeatedByte.asm) |
| [FormatDecimalNumber](../Source/DiskUtility/Menu/FormatDecimalNumber.asm) | [DecimalDigit](../Source/DiskUtility/Menu/FormatDecimalDigit.asm) |
| [YieldWithSteeringBrake](../Source/DiskUtility/Demo/YieldWithSteeringBrake.asm) | [YieldToGame](../Source/DiskUtility/Demo/YieldToGame.asm) |
| [InitializeDemoScenario](../Source/DiskUtility/Demo/InitializeDemoScenario.asm) | [ApproachBody](../Source/DiskUtility/Demo/ApproachCelestialBody.asm) |
| [ChooseCelestialTarget](../Source/DiskUtility/Demo/ChooseCelestialTarget.asm) | [AimNearBody](../Source/DiskUtility/Demo/AimAtNearBody.asm) |
| [ChooseObjectAimPrecision](../Source/DiskUtility/Demo/ChooseObjectAimPrecision.asm) | [SteerToTarget](../Source/DiskUtility/Demo/SteerTowardTarget.asm) |
| [BrakeForDistantTarget](../Source/DiskUtility/Demo/BrakeForDistantTarget.asm) | [Brake](../Source/DiskUtility/Demo/ApplyBrakeKey.asm) |
| [PauseWithDemoMark](../Source/DiskUtility/Demo/PauseWithDemoMark.asm) | [XorDemoMark](../Source/DiskUtility/Demo/DrawDemoMarkXor.asm) |
| [Initialize](../Source/Manual/Initialize.asm) | [ShowMenu](../Source/Manual/Menu.asm) |
| [ClearAndTitle](../Source/Manual/ClearAndTitle.asm) | [PrintString](../Source/Manual/PrintString.asm) |

## Данные и изменяемый код

[RestartPatch](../Source/DiskUtility/DemoSetup/RestartPatch.asm) содержит шесть байтов команд,
которые [InstallDemo](../Source/DiskUtility/DemoSetup/InstallDemoOverlay.asm) переносит в
`OverlayTrack`. При гибели они сохраняют `A` в `LaunchPending` и передают управление игровому
ожиданию отпускания клавиш. Это шаблон исполняемого кода, расположенный среди данных установщика.
[InputPatches](../Source/DiskUtility/DemoSetup/VirtualInputPatches.asm) аналогично хранит три
шаблона длиной 5, 4 и 3 байта для чтения виртуальных клавиш и `FSpaceObject.Energy`.

[SlotFlagCache](../Source/DiskUtility/Demo/ObjectMetadataCache.asm) хранит восемь копий
`FEffectRecord10.TypeFlags`. [ReadSlotFlags](../Source/DiskUtility/Demo/ReadObjectMetadata.asm)
обновляет их только если прерванный игровой поток остановлен на `HALT`. Разряд 1, проверяемый
при выборе боевой цели, является старшим битом числовой группы 0..3. Он допускает группы 2 и 3,
а отдельным логическим флагом не является. Схема кеша и проверяемые маски приведены рядом с данными.

[MutateMemory](../Source/Loader/MutateMemory.asm) восстанавливает изменённые биты команд и данных
игры. Её комментарий показывает исходные и восстановленные машинные байты, изменение состояния
генератора и причину использования 244 сохранённых XOR-поправок при обратной сборке.
Проверки физической дорожки и защитного сектора находятся отдельно в
[VerifyTiming](../Source/DiskUtility/Menu/VerifyProtectionTiming.asm) и
[VerifyMark](../Source/DiskUtility/Menu/VerifyProtectionMark.asm).

## Основания проверки

- [AuxiliaryCommentReferences.json](../Tools/Disasm/Reports/AuxiliaryCommentReferences.json) — проверка смысловых ссылок, 18 межфайловых продолжений и пяти эквивалентных замен номеров битов
- [ManualLoaderDocumentationAudit.json](../Tools/Disasm/Reports/ManualLoaderDocumentationAudit.json) — повторное чтение 31 ASM-файла, уточнение контрактов и проверка неизменности команд
- [DiskUtilityMenuSemantics.json](../Tools/Disasm/Reports/DiskUtilityMenuSemantics.json) — описание всех файлов первого оверлея
- [DiskUtilityDemoSemantics.json](../Tools/Disasm/Reports/DiskUtilityDemoSemantics.json) — описание установщика и корутины демонстрации
- [InterfaceWorld.json](../Tools/Disasm/Reports/Semantics/InterfaceWorld.json) — формат двух сохранённых командиров
- [ManualBasic.json](../Tools/Disasm/Reports/ManualBasic.json) — исходные строки BASIC в файле руководства
- [BuildVerification.json](../Tools/Disasm/Reports/BuildVerification.json) — результаты сборки и совпадения каждого логического файла
