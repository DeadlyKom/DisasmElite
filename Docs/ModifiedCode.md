# Изменяемый код и непрямое управление

Перечень построен по окончательной разметке инструкций и дополняет пояснения
в исходниках. Он перечисляет абсолютные `LD (nn),...`, попадающие в код.
Записи через регистровые указатели и перестройку стека нужно смотреть
в описании соответствующего алгоритма.

## Абсолютные записи в код

| Команда | Запись | Изменяемый участок |
|---|---|---|
| [`#5E24`](../Source/Game/Extensions/HandleSpecialMessageToken.asm) | `LD (#7013),A` | [`#7013`, AttributeVectorAndEnergyBomb](../Source/Game/Extensions/AttributeVectorAndEnergyBomb.asm) |
| [`#5E27`](../Source/Game/Extensions/HandleSpecialMessageToken.asm) | `LD (#DE6A),A` | [`#DE6A`, GetSalePriceAndMissionFlags](../Source/Game/Travel/GetSalePriceAndMissionFlags.asm) |
| [`#6F36`](../Source/Game/Extensions/PrintEquipmentAndSelectIcon.asm) | `LD (#FD0A),A` | [`#FD0A`, ToggleSecondaryCoordinateObject](../Source/Game/Input/ToggleSecondaryCoordinateObject.asm) |
| [`#6F44`](../Source/Game/Extensions/DrawCompressedEdges.asm) | `LD (#6F42),A` | [`#6F42`, DrawCompressedEdges](../Source/Game/Extensions/DrawCompressedEdges.asm) |
| [`#6F58`](../Source/Game/Extensions/DrawCompressedEdges.asm) | `LD (#AA1E),A` | [`#AA1E`, AnyPackedFaceVisible](../Source/Game/Wireframe/AnyPackedFaceVisible.asm) |
| [`#6FE7`](../Source/Game/Extensions/DrawCompressedEdges.asm) | `LD (#AA1E),A` | [`#AA1E`, AnyPackedFaceVisible](../Source/Game/Wireframe/AnyPackedFaceVisible.asm) |
| [`#78B6`](../Source/Game/Universe/UpdateAndDrawStarField.asm) | `LD (#78B5),A` | [`#78B5`, UpdateAndDrawStarField](../Source/Game/Universe/UpdateAndDrawStarField.asm) |
| [`#7F0E`](../Source/Game/Universe/HandleFastTravelStep.asm) | `LD (#7F0B),A` | [`#7F0B`, HandleFastTravelStep](../Source/Game/Universe/HandleFastTravelStep.asm) |
| [`#8150`](../Source/Game/Screen/DispatchMenu.asm) | `LD (#8154),HL` | [`#8154`, DispatchMenu](../Source/Game/Screen/DispatchMenu.asm) |
| [`#8542`](../Source/Game/Screen/DrawIndicatorMarker.asm) | `LD (#8597),A` | [`#8597`, DrawIndicatorBar](../Source/Game/Screen/DrawIndicatorBar.asm) |
| [`#8545`](../Source/Game/Screen/DrawIndicatorMarker.asm) | `LD (#85B9),A` | [`#85B9`, DrawIndicatorBar](../Source/Game/Screen/DrawIndicatorBar.asm) |
| [`#854A`](../Source/Game/Screen/DrawIndicatorMarker.asm) | `LD (#856D),A` | [`#856D`, DrawIndicatorBar](../Source/Game/Screen/DrawIndicatorBar.asm) |
| [`#8552`](../Source/Game/Screen/DrawIndicatorBar.asm) | `LD (#856D),A` | [`#856D`, DrawIndicatorBar](../Source/Game/Screen/DrawIndicatorBar.asm) |
| [`#8555`](../Source/Game/Screen/DrawIndicatorBar.asm) | `LD (#8597),A` | [`#8597`, DrawIndicatorBar](../Source/Game/Screen/DrawIndicatorBar.asm) |
| [`#8558`](../Source/Game/Screen/DrawIndicatorBar.asm) | `LD (#85B9),A` | [`#85B9`, DrawIndicatorBar](../Source/Game/Screen/DrawIndicatorBar.asm) |
| [`#8A3A`](../Source/Game/Circles/PrepareBothClippedMasksAndFillRows.asm) | `LD (#8A85),HL` | [`#8A85`, PrepareBothClippedMasksAndFillRows](../Source/Game/Circles/PrepareBothClippedMasksAndFillRows.asm) |
| [`#8A40`](../Source/Game/Circles/PrepareBothClippedMasksAndFillRows.asm) | `LD (#8A92),HL` | [`#8A92`, PrepareBothClippedMasksAndFillRows](../Source/Game/Circles/PrepareBothClippedMasksAndFillRows.asm) |
| [`#8A46`](../Source/Game/Circles/PrepareBothClippedMasksAndFillRows.asm) | `LD (#8A98),HL` | [`#8A98`, PrepareBothClippedMasksAndFillRows](../Source/Game/Circles/PrepareBothClippedMasksAndFillRows.asm) |
| [`#8A51`](../Source/Game/Circles/PrepareBothClippedMasksAndFillRows.asm) | `LD (#8A85),HL` | [`#8A85`, PrepareBothClippedMasksAndFillRows](../Source/Game/Circles/PrepareBothClippedMasksAndFillRows.asm) |
| [`#8A57`](../Source/Game/Circles/PrepareBothClippedMasksAndFillRows.asm) | `LD (#8A92),HL` | [`#8A92`, PrepareBothClippedMasksAndFillRows](../Source/Game/Circles/PrepareBothClippedMasksAndFillRows.asm) |
| [`#8A5D`](../Source/Game/Circles/PrepareBothClippedMasksAndFillRows.asm) | `LD (#8A98),HL` | [`#8A98`, PrepareBothClippedMasksAndFillRows](../Source/Game/Circles/PrepareBothClippedMasksAndFillRows.asm) |
| [`#8A63`](../Source/Game/Circles/PrepareBothClippedMasksAndFillRows.asm) | `LD (#8A9E),HL` | [`#8A9E`, PrepareBothClippedMasksAndFillRows](../Source/Game/Circles/PrepareBothClippedMasksAndFillRows.asm) |
| [`#8BCA`](../Source/Game/Circles/SetCabinHeatAndContinueFilledCircle.asm) | `LD (#8BD3),A` | [`#8BD3`, SetCabinHeatAndContinueFilledCircle](../Source/Game/Circles/SetCabinHeatAndContinueFilledCircle.asm) |
| [`#8CCA`](../Source/Game/Circles/SelectJumpAndContinueLeftFill.asm) | `LD (#8CD3),A` | [`#8CD3`, SelectJumpAndContinueLeftFill](../Source/Game/Circles/SelectJumpAndContinueLeftFill.asm) |
| [`#8DC0`](../Source/Game/Circles/PrintShipAndContinueRightFill.asm) | `LD (#8DC9),A` | [`#8DC9`, PrintShipAndContinueRightFill](../Source/Game/Circles/PrintShipAndContinueRightFill.asm) |
| [`#8F14`](../Source/Game/Circles/DrawPendingObjectExplosions.asm) | `LD (#8A4A),A` | [`#8A4A`, PrepareBothClippedMasksAndFillRows](../Source/Game/Circles/PrepareBothClippedMasksAndFillRows.asm) |
| [`#8F19`](../Source/Game/Circles/DrawPendingObjectExplosions.asm) | `LD (#8F9B),A` | [`#8F9B`, PatchCircleScreenTarget](../Source/Game/Circles/PatchCircleScreenTarget.asm) |
| [`#8F1E`](../Source/Game/Circles/DrawPendingObjectExplosions.asm) | `LD (#8FA6),A` | [`#8FA6`, PatchCircleScreenTarget](../Source/Game/Circles/PatchCircleScreenTarget.asm) |
| [`#8F76`](../Source/Game/Circles/SelectCircleBackBuffer.asm) | `LD (#8A4A),A` | [`#8A4A`, PrepareBothClippedMasksAndFillRows](../Source/Game/Circles/PrepareBothClippedMasksAndFillRows.asm) |
| [`#8F7B`](../Source/Game/Circles/SelectCircleBackBuffer.asm) | `LD (#8F9B),A` | [`#8F9B`, PatchCircleScreenTarget](../Source/Game/Circles/PatchCircleScreenTarget.asm) |
| [`#8F80`](../Source/Game/Circles/SelectCircleBackBuffer.asm) | `LD (#8FA6),A` | [`#8FA6`, PatchCircleScreenTarget](../Source/Game/Circles/PatchCircleScreenTarget.asm) |
| [`#8F88`](../Source/Game/Circles/PatchCircleScreenTarget.asm) | `LD (#89DA),HL` | [`#89DA`, ComputeLeftEdgeMask](../Source/Game/Circles/ComputeLeftEdgeMask.asm) |
| [`#8F8B`](../Source/Game/Circles/PatchCircleScreenTarget.asm) | `LD (#89FB),HL` | [`#89FB`, ComputeRightEdgeMask](../Source/Game/Circles/ComputeRightEdgeMask.asm) |
| [`#8F8E`](../Source/Game/Circles/PatchCircleScreenTarget.asm) | `LD (#8A6E),HL` | [`#8A6E`, PrepareBothClippedMasksAndFillRows](../Source/Game/Circles/PrepareBothClippedMasksAndFillRows.asm) |
| [`#8F94`](../Source/Game/Circles/PatchCircleScreenTarget.asm) | `LD (#8A61),A` | [`#8A61`, PrepareBothClippedMasksAndFillRows](../Source/Game/Circles/PrepareBothClippedMasksAndFillRows.asm) |
| [`#8F97`](../Source/Game/Circles/PatchCircleScreenTarget.asm) | `LD (#8E18),A` | [`#8E18`, CrossCircleCharacterRowDown](../Source/Game/Circles/CrossCircleCharacterRowDown.asm) |
| [`#8F9C`](../Source/Game/Circles/PatchCircleScreenTarget.asm) | `LD (#8D0D),A` | [`#8D0D`, SelectJumpAndContinueLeftFill](../Source/Game/Circles/SelectJumpAndContinueLeftFill.asm) |
| [`#8F9F`](../Source/Game/Circles/PatchCircleScreenTarget.asm) | `LD (#8B09),A` | [`#8B09`, BeginFilledUnclippedHalf](../Source/Game/Circles/BeginFilledUnclippedHalf.asm) |
| [`#8FA2`](../Source/Game/Circles/PatchCircleScreenTarget.asm) | `LD (#8C0D),A` | [`#8C0D`, SetCabinHeatAndContinueFilledCircle](../Source/Game/Circles/SetCabinHeatAndContinueFilledCircle.asm) |
| [`#8FA7`](../Source/Game/Circles/PatchCircleScreenTarget.asm) | `LD (#8D06),A` | [`#8D06`, SelectJumpAndContinueLeftFill](../Source/Game/Circles/SelectJumpAndContinueLeftFill.asm) |
| [`#8FAA`](../Source/Game/Circles/PatchCircleScreenTarget.asm) | `LD (#8B02),A` | [`#8B02`, BeginFilledUnclippedHalf](../Source/Game/Circles/BeginFilledUnclippedHalf.asm) |
| [`#8FAD`](../Source/Game/Circles/PatchCircleScreenTarget.asm) | `LD (#8C06),A` | [`#8C06`, SetCabinHeatAndContinueFilledCircle](../Source/Game/Circles/SetCabinHeatAndContinueFilledCircle.asm) |
| [`#8FB0`](../Source/Game/Circles/PatchCircleScreenTarget.asm) | `LD (#8DFE),A` | [`#8DFE`, CrossCircleCharacterRowUp](../Source/Game/Circles/CrossCircleCharacterRowUp.asm) |
| [`#92C4`](../Source/Game/Flight/AnimateTransitionTunnel.asm) | `LD (#92FA),HL` | [`#92FA`, AnimateTransitionTunnel](../Source/Game/Flight/AnimateTransitionTunnel.asm) |
| [`#92CE`](../Source/Game/Flight/AnimateTransitionTunnel.asm) | `LD (#9326),A` | [`#9326`, AnimateTransitionTunnel](../Source/Game/Flight/AnimateTransitionTunnel.asm) |
| [`#92D3`](../Source/Game/Flight/AnimateTransitionTunnel.asm) | `LD (#932B),A` | [`#932B`, AnimateTransitionTunnel](../Source/Game/Flight/AnimateTransitionTunnel.asm) |
| [`#92DE`](../Source/Game/Flight/AnimateTransitionTunnel.asm) | `LD (#9318),A` | [`#9318`, AnimateTransitionTunnel](../Source/Game/Flight/AnimateTransitionTunnel.asm) |
| [`#92E5`](../Source/Game/Flight/AnimateTransitionTunnel.asm) | `LD (#9318),A` | [`#9318`, AnimateTransitionTunnel](../Source/Game/Flight/AnimateTransitionTunnel.asm) |
| [`#93F5`](../Source/Game/Flight/LaunchOrDockShip.asm) | `LD (#92FA),HL` | [`#92FA`, AnimateTransitionTunnel](../Source/Game/Flight/AnimateTransitionTunnel.asm) |
| [`#93FF`](../Source/Game/Flight/LaunchOrDockShip.asm) | `LD (#9326),A` | [`#9326`, AnimateTransitionTunnel](../Source/Game/Flight/AnimateTransitionTunnel.asm) |
| [`#9415`](../Source/Game/Flight/LaunchOrDockShip.asm) | `LD (#932B),A` | [`#932B`, AnimateTransitionTunnel](../Source/Game/Flight/AnimateTransitionTunnel.asm) |
| [`#9474`](../Source/Game/Flight/LaunchOrDockShip.asm) | `LD (#932B),A` | [`#932B`, AnimateTransitionTunnel](../Source/Game/Flight/AnimateTransitionTunnel.asm) |
| [`#95D6`](../Source/Game/Sound/StartExplosionNoise.asm) | `LD (#95AE),A` | [`#95AE`, StepNoise](../Source/Game/Sound/StepNoise.asm) |
| [`#964D`](../Source/Game/Sound/StepPitchSweep.asm) | `LD (#962B),A` | [`#962B`, StepPitchSweep](../Source/Game/Sound/StepPitchSweep.asm) |
| [`#9666`](../Source/Game/Sound/StepPitchSweep.asm) | `LD (#95F2),HL` | [`#95F2`, StepDataTone](../Source/Game/Sound/StepDataTone.asm) |
| [`#9688`](../Source/Game/Sound/StepPitchSweep.asm) | `LD (#95BD),A` | [`#95BD`, StepNoise](../Source/Game/Sound/StepNoise.asm) |
| [`#968C`](../Source/Game/Sound/StepPitchSweep.asm) | `LD (#95AE),A` | [`#95AE`, StepNoise](../Source/Game/Sound/StepNoise.asm) |
| [`#9CD1`](../Source/Game/Combat/UpdateAllSpaceObjects.asm) | `LD (#B1B7),A` | [`#B1B7`, DrawClippedLine](../Source/Game/Wireframe/DrawClippedLine.asm) |
| [`#9CD4`](../Source/Game/Combat/UpdateAllSpaceObjects.asm) | `LD (#B232),A` | [`#B232`, DrawClippedLine](../Source/Game/Wireframe/DrawClippedLine.asm) |
| [`#9CD7`](../Source/Game/Combat/UpdateAllSpaceObjects.asm) | `LD (#B244),A` | [`#B244`, DrawClippedLine](../Source/Game/Wireframe/DrawClippedLine.asm) |
| [`#9CDA`](../Source/Game/Combat/UpdateAllSpaceObjects.asm) | `LD (#B252),A` | [`#B252`, DrawClippedLine](../Source/Game/Wireframe/DrawClippedLine.asm) |
| [`#9D33`](../Source/Game/Combat/UpdateAllSpaceObjects.asm) | `LD (#6F42),A` | [`#6F42`, DrawCompressedEdges](../Source/Game/Extensions/DrawCompressedEdges.asm) |
| [`#AA24`](../Source/Game/Wireframe/ReadFaceVisibilityNibble.asm) | `LD (#AA28),A` | [`#AA28`, ReadFaceVisibilityNibble](../Source/Game/Wireframe/ReadFaceVisibilityNibble.asm) |
| [`#B19D`](../Source/Game/Wireframe/DrawClippedLine.asm) | `LD (#B1BD),A` | [`#B1BD`, DrawClippedLine](../Source/Game/Wireframe/DrawClippedLine.asm) |
| [`#B1A4`](../Source/Game/Wireframe/DrawClippedLine.asm) | `LD (#B1B5),A` | [`#B1B5`, DrawClippedLine](../Source/Game/Wireframe/DrawClippedLine.asm) |
| [`#B1A8`](../Source/Game/Wireframe/DrawClippedLine.asm) | `LD (#B1C7),A` | [`#B1C7`, DrawClippedLine](../Source/Game/Wireframe/DrawClippedLine.asm) |
| [`#B1EF`](../Source/Game/Wireframe/DrawClippedLine.asm) | `LD (#B20F),A` | [`#B20F`, DrawClippedLine](../Source/Game/Wireframe/DrawClippedLine.asm) |
| [`#B1F3`](../Source/Game/Wireframe/DrawClippedLine.asm) | `LD (#B212),A` | [`#B212`, DrawClippedLine](../Source/Game/Wireframe/DrawClippedLine.asm) |
| [`#B1F8`](../Source/Game/Wireframe/DrawClippedLine.asm) | `LD (#B20D),A` | [`#B20D`, DrawClippedLine](../Source/Game/Wireframe/DrawClippedLine.asm) |
| [`#B1FC`](../Source/Game/Wireframe/DrawClippedLine.asm) | `LD (#B25F),A` | [`#B25F`, DrawClippedLine](../Source/Game/Wireframe/DrawClippedLine.asm) |
| [`#B21B`](../Source/Game/Wireframe/DrawClippedLine.asm) | `LD (#B25D),A` | [`#B25D`, DrawClippedLine](../Source/Game/Wireframe/DrawClippedLine.asm) |
| [`#B222`](../Source/Game/Wireframe/DrawClippedLine.asm) | `LD (#B231),A` | [`#B231`, DrawClippedLine](../Source/Game/Wireframe/DrawClippedLine.asm) |
| [`#B35D`](../Source/Game/Wireframe/DivideSlopeAndDrawScanner.asm) | `LD (#A849),HL` | [`#A849`, XorFarObjectPixel](../Source/Game/Motion/XorFarObjectPixel.asm) |
| [`#B38F`](../Source/Game/Wireframe/DivideSlopeAndDrawScanner.asm) | `LD (#A849),HL` | [`#A849`, XorFarObjectPixel](../Source/Game/Motion/XorFarObjectPixel.asm) |
| [`#B443`](../Source/Game/Wireframe/DrawScannerMarkerSegment.asm) | `LD (#B446),HL` | [`#B446`, DrawScannerMarkerSegment](../Source/Game/Wireframe/DrawScannerMarkerSegment.asm) |
| [`#D9CB`](../Source/Game/Disk/TransferDiskSectors.asm) | `LD (#D9E5),IX` | [`#D9E5`, TransferDiskSectors](../Source/Game/Disk/TransferDiskSectors.asm) |
| [`#DA21`](../Source/Game/Disk/ReactionOnPrivateStack.asm) | `LD (#DA2C),SP` | [`#DA2C`, ReactionOnPrivateStack](../Source/Game/Disk/ReactionOnPrivateStack.asm) |
| [`#DA54`](../Source/Game/Disk/DrawScreenStripsAndPrivateStack.asm) | `LD (#DA60),SP` | [`#DA60`, DrawScreenStripsAndPrivateStack](../Source/Game/Disk/DrawScreenStripsAndPrivateStack.asm) |
| [`#E3D0`](../Source/Game/Charts/BeginTextInput.asm) | `LD (#E413),A` | [`#E413`, TextInputLoop](../Source/Game/Charts/TextInputLoop.asm) |
| [`#EC75`](../Source/Game/Menus/OpenLocalChart.asm) | `LD (#ECDF),A` | [`#ECDF`, VisitLocalChartSystems](../Source/Game/Menus/VisitLocalChartSystems.asm) |
| [`#EC80`](../Source/Game/Menus/OpenLocalChart.asm) | `LD (#ECE3),A` | [`#ECE3`, VisitLocalChartSystems](../Source/Game/Menus/VisitLocalChartSystems.asm) |
| [`#EC8B`](../Source/Game/Menus/OpenLocalChart.asm) | `LD (#ECEA),A` | [`#ECEA`, VisitLocalChartSystems](../Source/Game/Menus/VisitLocalChartSystems.asm) |
| [`#EC96`](../Source/Game/Menus/OpenLocalChart.asm) | `LD (#ECEE),A` | [`#ECEE`, VisitLocalChartSystems](../Source/Game/Menus/VisitLocalChartSystems.asm) |
| [`#ECD2`](../Source/Game/Menus/VisitLocalChartSystems.asm) | `LD (#ECF2),HL` | [`#ECF2`, VisitLocalChartSystems](../Source/Game/Menus/VisitLocalChartSystems.asm) |
| [`#F8B8`](../Source/Game/Extensions/PrintCargoAndMessageBanks.asm) | `LD (#A79D),A` | [`#A79D`, ProjectObjectAndSelectDetail](../Source/Game/Motion/ProjectObjectAndSelectDetail.asm) |
| [`#F8BD`](../Source/Game/Extensions/PrintCargoAndMessageBanks.asm) | `LD (#FEFE),A` | [`#FEFE`, InterruptGateAndAcceleration](../Source/Game/Input/InterruptGateAndAcceleration.asm) |
| [`#F8C1`](../Source/Game/Extensions/PrintCargoAndMessageBanks.asm) | `LD (#F8CC),SP` | [`#F8CC`, PrintCargoAndMessageBanks](../Source/Game/Extensions/PrintCargoAndMessageBanks.asm) |
| [`#F8D0`](../Source/Game/Extensions/PrintCargoAndMessageBanks.asm) | `LD (#FEFE),A` | [`#FEFE`, InterruptGateAndAcceleration](../Source/Game/Input/InterruptGateAndAcceleration.asm) |
| [`#F8E7`](../Source/Game/Extensions/DrawCircleAndProtectScratchStack.asm) | `LD (#F90A),SP` | [`#F90A`, DrawCircleAndProtectScratchStack](../Source/Game/Extensions/DrawCircleAndProtectScratchStack.asm) |
| [`#FD06`](../Source/Game/Input/ToggleSecondaryCoordinateObject.asm) | `LD (#FD03),A` | [`#FD03`, ToggleSecondaryCoordinateObject](../Source/Game/Input/ToggleSecondaryCoordinateObject.asm) |

## Косвенные JP

Такие переходы используют адрес в регистре. Их таблицы и вызывающий
контекст разобраны в указанных исходниках.

| Адрес | Команда | Исходник |
|---|---|---|
| `#959E` | `JP (HL)` | [UpdateSound](../Source/Game/Sound/UpdateSound.asm) |
| `#D7F0` | `JP (HL)` | [DrawProjectedSunAndTextDispatch](../Source/Game/Text/DrawProjectedSunAndTextDispatch.asm) |
| `#E7DA` | `JP (HL)` | [IndirectTradeCallbackAndBuy](../Source/Game/Trade/IndirectTradeCallbackAndBuy.asm) |

## Перекрывающиеся входы

В [CodeTargets.json](../Tools/Disasm/Reports/CodeTargets.json) отдельно перечислены переходы внутрь
другой инструкции и в литерально сохранённые перекрытия. Наличие
записи в этом списке само по себе не означает ошибку исходника.
Проверка всех найденных входов зафиксирована в [CodeTargetReview.json](../Tools/Disasm/Reports/CodeTargetReview.json).

| Вход | Источник | Объяснение |
|---|---|---|
| [`#733E`](../Source/Game/Flight/IndexPauseCommandAndHandlers.asm) | `#72E7` | Старший байт DF команды CALL #DFEE по #733C исполняется как RST #18. Это путь команды перестановки лазеров без Mk4. ROM GET_CHAR возвращает текущий символ, LD (HL),A по #733F записывает его обратно. Параметр #FC0E на этом пути не переключается. |
| [`#83FE`](../Source/Game/Screen/PlanetDistanceHint.asm) | `#5F1C`, `#7376`, `#8E6C` | Байты 21 10 2E образуют LD HL,#2E10. Продолжение #8401 исполняет 07 как RLCA, затем LD H,#71 выбирает координаты планеты #7110. RLCA не влияет на дальнейший результат, A затем загружается заново. |
| [`#8400`](../Source/Game/Screen/SunDistanceHint.asm) | `#5F3F`, `#8E64` | Байты 2E 07 образуют LD L,#07. Вместе с LD H,#71 по #8402 выбирается солнце #7107. Байт 2E одновременно входит в операнд команды по #83FE. |
| [`#B29C`](../Source/Game/Wireframe/MultiplyClippingDistance.asm) | `#B28D` | Байт 7A является LD A,D при обычном завершении умножения. При переполнении предыдущий FE читает его как операнд CP #7A, сохраняя насыщенное A=#FF. |
| [`#B2BA`](../Source/Game/Wireframe/DivideSlopeAndDrawScanner.asm) | `#B2B1`, `#B2C3` | Байт A7 является AND A при входе из условных ветвей деления. При последовательном исполнении от #B2B9 он служит операндом LD A,#A7. |
| [`#D7E2`](../Source/Game/Text/DrawProjectedSunAndTextDispatch.asm) | `#D427` | LD HL,#2EF2, затем NOP и DEC L/LD H,#D7 выбирают базу #D7F1. Код управляющего символа прибавляется к ней, байт таблицы задаёт младшую часть адреса обработчика в странице #D8. |
| [`#D7E4`](../Source/Game/Text/DrawProjectedSunAndTextDispatch.asm) | `#D47B` | LD L,#00 перекрывает старший операнд LD HL по #D7E2. Следующие DEC L/LD H,#D7 задают базу второй таблицы #D7FF. |
| [`#E6F2`](../Source/Game/Trade/ResetCloakingAndSeedFlightRandom.asm) | `#E6B3` | Байты 6A D0 внутри LD A,(#D06A) выполняются как LD L,D и RET NC. Переход #E6B3 запрещает покупку при занятом миссией трюме. Диспетчер #813E входит с C=0, поэтому этот путь возвращается через RET NC. |
| [`#FB31`](../Source/Game/Extensions/DrawSmallSilhouetteAlternate.asm) | `#86D0` | Байты 3E AF образуют LD A,#AF и выбирают альтернативный профиль. Следующий EX AF,AF' сохраняет выбор для общего рендера. |
| [`#FB32`](../Source/Game/Extensions/DrawSmallSilhouette.asm) | `#86DE` | Байт AF выполняется как XOR A при прямом входе и выбирает обычный профиль. При входе #FB31 тот же байт является операндом LD A,#AF. |
