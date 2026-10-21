                ifndef _ELITE_GAME_INCLUDE_
                define _ELITE_GAME_INCLUDE_
                module Game
; -----------------------------------------
; цепочки include с номерами (0), (1) продолжают код без перехода, порядок жёсткий
; полный файловый диапазон #4000..#FFFF
; инструкции представлены после восстановления XOR-кодирования
; исходные семена генератора сохранены для штатного загрузчика
; кодирование 244 файловых байтов выполняет упаковщик sjasmplus
; назначение и контракты описаны в исходниках и реестрах Tools/Disasm/Reports/Semantics
; -----------------------------------------
                ASSERT $ == #4000
                include "Resources/LoadingScreen.asm"
                include "Resources/CockpitAttrs.asm"
                include "Resources/SystemShadow.asm"
                include "Extensions/ConsumeGalacticDriveCharge.asm"
                include "Extensions/UpdateStationAndFinishGlyph.asm"
                include "Extensions/SelectCharacterFont.asm"
                include "Extensions/HandleSpecialMessageToken.asm"
                include "Extensions/FillBackwardAndCountDemo.asm"
                include "Extensions/UpdateInvasionOnRatingOverflow.asm"
                include "Extensions/CreateMissileOrMissionCraft.asm"
                include "Extensions/UpdateStationAndSpecialShips.asm"
                include "Extensions/OfferUpgradeAndCorrectPosition.asm"         ; (0)
                include "Data/SystemBoundaryAndObjects.asm"                     ; (1)
                include "Extensions/DrawModelAndResources.asm"
                include "Extensions/UpdateSpecialCargoStatus.asm"
                include "Extensions/PrintPlanetInvasionStatus.asm"
                include "Extensions/PrintEquipmentAndSelectIcon.asm"
                include "Extensions/DrawCompressedEdges.asm"
                include "Extensions/EnergyBombAndFlashVectors.asm"
                include "Extensions/AttributeVectorAndEnergyBomb.asm"
                include "Extensions/FlashViewAttributes.asm"                    ; (0)
                include "Flight/SetViewAttributesWithCloaking.asm"              ; (1)
                include "Flight/FillViewAttributesAndFlightState.asm"           ; (2)
                include "Flight/DispatchChartCircle.asm"
                include "Flight/DispatchDangerIndicator.asm"
                include "Flight/DispatchSoundEffect.asm"
                include "Flight/DispatchAppendDecimalDigit.asm"
                include "Flight/DispatchDeviceAndAppendDigit.asm"
                include "Flight/UpdateFlightControlGauges.asm"
                include "Flight/TryAutomaticDocking.asm"
                include "Flight/RebaseSunAgainstStation.asm"                    ; (0)
                include "Flight/RebaseCoordinateAxis.asm"                       ; (1)
                include "Flight/HalfCoordinateDifference.asm"
                include "Flight/HandleMapCursorKeys.asm"
                include "Flight/ToggleCloakingDevice.asm"
                include "Flight/ApplyMissionViewColour.asm"
                include "Flight/ApplyCloakingViewColour.asm"
                include "Flight/MarkMissionViewInitialized.asm"
                include "Flight/DispatchThirdMissionStage.asm"
                include "Flight/ReportBoardingAndReturnToTitle.asm"
                include "Flight/HandlePauseMenu.asm"
                include "Flight/IndexNextPauseTable.asm"                        ; (0)
                include "Flight/IndexPauseCommandAndHandlers.asm"               ; (1)
                include "Flight/PlaySweepingBeeperAndBootstrap.asm"             ; (2)
                include "Flight/TryColonizeMinerals.asm"                        ; (3)
                include "Flight/ShowTitleAndSelectControls.asm"
                include "Flight/DrawTitleCaption.asm"
                include "Flight/DrawDemoHeading.asm"
                include "Flight/InitializeViewAttributes.asm"                   ; (0)
                include "Flight/Fill240Attributes.asm"                          ; (1)
                include "Flight/MainGameLoop.asm"
                include "Universe/DrawSunAndPlanet.asm"
                include "Universe/ExpandNovaRadius.asm"
                include "Universe/ProjectCelestialBody.asm"
                include "Universe/ShiftSmallBodyProjectionOperands.asm"
                include "Universe/DivideCelestialAxis.asm"                      ; (0)
                include "Universe/DivideBodyRadiusByte.asm"                     ; (1)
                include "Universe/DivideBodyProjectionFraction.asm"             ; (2)
                include "Universe/UpdateCelestialCoordinates.asm"
                include "Universe/UpdateStationCoordinates.asm"                 ; (0)
                include "Universe/SetStationEnergy.asm"                         ; (1)
                include "Universe/DrawStarsWithJumpEffect.asm"                  ; (0)
                include "Universe/UpdateAndDrawStarField.asm"                   ; (1)
                include "Universe/SelectGalaxyOnJump.asm"
                include "Universe/SelectSpecialCargoText.asm"
                include "Universe/AddSignedStarCoordinate.asm"
                include "Universe/InitializeExtendedObjectMetadata.asm"
                include "Universe/PrepareRandomLaserEndpoint.asm"
                include "Universe/CompareObjectAxisDistance.asm"
                include "Universe/CheckLinkedObjectInteraction.asm"             ; (0)
                include "Universe/TryObjectInteraction.asm"                     ; (1)
                include "Universe/FindInteractingObject.asm"
                include "Universe/UpdateExtendedObjectEffects.asm"
                include "Universe/ApplyEcmToStandardMissile.asm"
                include "Universe/DispatchLinkedObjectAction.asm"
                include "Universe/AwardUnlinkedDestructionBounty.asm"
                include "Universe/AwardOrStoreLinkedDestruction.asm"
                include "Universe/SpawnDestructionContentsAndEffects.asm"
                include "Universe/AdvanceCircularObjectEffect.asm"
                include "Universe/GetObjectMetadataAddress.asm"
                include "Universe/HandleFastTravelStep.asm"                     ; (0)
                include "Universe/MoveCoordinateDepthBy32.asm"                  ; (1)
                include "Universe/CheckSpecialSystemOrRandom.asm"
                include "Universe/ApplyEnhancedFlightControl.asm"
                include "Screen/CopyFlightView.asm"                             ; (0)
                include "Screen/CopySixtyRows.asm"                              ; (1)
                include "Screen/CopyAlternateRows.asm"                          ; (2)
                include "Screen/SwapAndSkipRow.asm"                             ; (0)
                include "Screen/NextScanline.asm"                               ; (1)
                include "Screen/SelectTrafficType.asm"
                include "Screen/MatchTargetPlanet.asm"
                include "Screen/RestoreCockpitIfNeeded.asm"                     ; (0)
                include "Screen/RestoreCockpit.asm"                             ; (1)
                include "Screen/ClearFlightBuffer.asm"
                include "Screen/CargoTripleOffset.asm"
                include "Screen/ResetCargoCapacity.asm"
                include "Screen/HandleScreenKeys.asm"
                include "Screen/DispatchMenu.asm"
                include "Screen/SelectScreen.asm"                               ; (0)
                include "Screen/SaveCockpit.asm"                                ; (1)
                include "Screen/RestrictDockingView.asm"
                include "Screen/UpdateCelestialProximity.asm"
                include "Screen/WriteStridedTriple.asm"
                include "Screen/CompassNearAxis.asm"
                include "Screen/CompassFarAxis.asm"
                include "Screen/SetGameOver.asm"
                include "Screen/ScaleProximity.asm"
                include "Screen/LoadVectorWords.asm"
                include "Screen/LengthHighWords.asm"
                include "Screen/VectorLength.asm"
                include "Screen/PlanetDistanceHint.asm"
                include "Screen/SunDistanceHint.asm"
                include "Screen/ChooseEncounterCode.asm"
                include "Screen/CheckDockingAlignment.asm"
                include "Screen/CompassShape.asm"
                include "Screen/NextCharacterRow.asm"
                include "Screen/PreviousCharacterRow.asm"
                include "Screen/RepeatEnergyRecovery.asm"
                include "Screen/ConsumeEscapePod.asm"
                include "Screen/RestoreCompassBackground.asm"
                include "Screen/UpdateIndicators.asm"
                include "Screen/DrawIndicatorMarker.asm"
                include "Screen/DrawIndicatorBar.asm"
                include "Screen/DrawShortIndicator.asm"
                include "Screen/DrawEmptyIndicator.asm"
                include "Screen/IndicatorMarkerMask.asm"
                include "Screen/WriteIndicatorMask.asm"
                include "Screen/RightArcDown.asm"
                include "Screen/RightArcUp.asm"
                include "Screen/LeftArcDown.asm"
                include "Screen/LeftArcUp.asm"
                include "Screen/UnclippedArcDown.asm"
                include "Screen/UnclippedArcUp.asm"
                include "Screen/FillRowsUp.asm"
                include "Screen/FillRowsDown.asm"
                include "Screen/DrawFilledCircle.asm"
                include "Screen/DrawCircleOutline.asm"                          ; (0)
                include "Screen/DrawLargeOutline.asm"                           ; (1)
                include "Circles/DispatchClippedCircle.asm"
                include "Math/Square.asm"
                include "Circles/DrawUnclippedCircle.asm"
                include "Circles/PrepareUnclippedCircle.asm"
                include "Circles/DrawWideCircleAcrossBothSides.asm"
                include "Circles/DrawCornerWideCircle.asm"
                include "Circles/DrawOneSideClippedCircle.asm"
                include "Circles/DrawCornerClippedArc.asm"
                include "Circles/DrawVerticalClippedCircle.asm"
                include "Circles/PrepareRightClippedCircle.asm"
                include "Circles/PrepareLeftClippedCircle.asm"
                include "Circles/LoadCircleIterationCoordinates.asm"
                include "Circles/ComputeLeftEdgeMask.asm"
                include "Circles/ComputeRightEdgeMask.asm"
                include "Circles/PrepareBothClippedCoordinates.asm"
                include "Circles/PrepareBothClippedMasksAndFillRows.asm"
                include "Circles/UpdateThargoidAndBodyCoords.asm"
                include "Circles/IntegerCircleCathetus.asm"
                include "Circles/BeginFilledUnclippedHalf.asm"
                include "Circles/ScanUpgradeKeyRow.asm"
                include "Circles/SetCabinHeatAndContinueFilledCircle.asm"
                include "Circles/DetachMissileTarget.asm"
                include "Circles/SelectJumpAndContinueLeftFill.asm"
                include "Circles/CheckSystemCoordinateBand.asm"
                include "Circles/PrintShipAndContinueRightFill.asm"
                include "Circles/StepCircleRowUp.asm"                           ; (0)
                include "Circles/CrossCircleCharacterRowUp.asm"                 ; (1)
                include "Circles/StepCircleRowDown.asm"                         ; (0)
                include "Circles/CrossCircleCharacterRowDown.asm"               ; (1)
                include "Circles/DrawChartCircleWithPatchedViewport.asm"
                include "Circles/CheckBodiesAndRestoreViewport.asm"             ; (0)
                include "Circles/ApplyCircleViewportPatches.asm"                ; (1)
                include "Circles/DrawPendingObjectExplosions.asm"               ; (0)
                include "Circles/SelectCircleBackBuffer.asm"                    ; (1)
                include "Circles/PatchCircleScreenTarget.asm"                   ; (2)
                include "Circles/DrawCornerRightContour.asm"
                include "Circles/DrawCornerLeftContour.asm"
                include "Circles/SetRightContourBoundary.asm"
                include "Circles/BuildLeftContourPixelMask.asm"
                include "Circles/BuildRightContourPixelMask.asm"
                include "Circles/SetBothContourBoundaries.asm"
                include "Circles/SkipViewportRowsUp.asm"
                include "Circles/SkipRowsDownAndDrawCircleContours.asm"
                include "Flight/DrawTransitionTunnelIfActive.asm"
                include "Flight/AnimateTransitionTunnel.asm"
                include "Flight/PrintMessageAfterMetadataReset.asm"
                include "Flight/RaiseLaserThreshold.asm"
                include "Flight/SetSelectedLineMetadata.asm"
                include "Flight/DivideByteFractionForTunnel.asm"
                include "Flight/LaunchOrDockShip.asm"                           ; (0)
                include "Flight/ResetFlightControls.asm"                        ; (1)
                include "Flight/ClearFlightKeyEvents.asm"                       ; (2)
                include "Flight/ClearBytes.asm"                                 ; (3)
                include "Flight/ClearNearbyShipSlots.asm"
                include "Sound/PlayLaunchSound.asm"
                include "Sound/PlayHyperjumpSound.asm"
                include "Sound/PlayDestructionSound.asm"
                include "Sound/UpdateSound.asm"                                 ; (0)
                include "Sound/StepNoise.asm"                                   ; (1)
                include "Sound/StartExplosionNoise.asm"                         ; (2)
                include "Sound/StepDataTone.asm"
                include "Sound/StepPitchSweep.asm"
                include "Sound/StartLaunchNoise.asm"
                include "Sound/StartHyperjumpNoise.asm"
                include "Sound/DivideBC16.asm"                                  ; (0)
                include "Sound/DivideBC8.asm"                                   ; (1)
                include "Sound/DivideBC4.asm"                                   ; (2)
                include "Sound/DivideBC2.asm"                                   ; (3)
                include "Scanner/AdvanceScannerObject.asm"
                include "Scanner/DrawScannerObjects.asm"
                include "Scanner/StepScannerStemDown.asm"
                include "Scanner/StepScannerStemUp.asm"
                include "Scanner/SetYellowFlightStatus.asm"
                include "Scanner/SaveScannerBackground.asm"
                include "Scanner/RestoreScannerBackground.asm"
                include "Scanner/ScaleValueAndFinishBackground.asm"
                include "Scanner/ResetCockpitForLaunch.asm"                     ; (0)
                include "Scanner/SetCockpitDeviceAttributes.asm"                ; (1)
                include "Scanner/FillCockpitAttributePanel.asm"                 ; (2)
                include "Scanner/DrawDangerAndMissileIndicators.asm"            ; (0)
                include "Scanner/ResetDangerIndicator.asm"                      ; (1)
                include "Combat/ProcessCombatControls.asm"                      ; (0)
                include "Combat/ApplyPlayerDamage.asm"                          ; (1)
                include "Combat/DrainEnergyBanks.asm"                           ; (2)
                include "Combat/DamageShieldAndEnergy.asm"
                include "Combat/RecoverPlayerEnergy.asm"                        ; (0)
                include "Combat/RecoverOneEnergyUnit.asm"                       ; (1)
                include "Combat/RecoverShieldUnit.asm"                          ; (2)
                include "Combat/UpdateEcmAndDriveIndicators.asm"                ; (0)
                include "Combat/SetIndicatorAndPrintMissileStock.asm"           ; (1)
                include "Combat/UpdateClockAndRotateDistantBodies.asm"
                include "Combat/CalculateFuelPurchasePrice.asm"
                include "Combat/HandleMissileControls.asm"                      ; (0)
                include "Combat/PrintMissileStock.asm"                          ; (1)
                include "Combat/HandleEscapeCapsule.asm"
                include "Combat/UpdateObjectsAndWeapons.asm"
                include "Combat/ApplyPlayerMotion.asm"
                include "Combat/SquareRootVectorLength.asm"
                include "Combat/DivideAndCombatState.asm"
                include "Combat/DispatchObjectAction.asm"
                include "Combat/CreateWreckAndDamageState.asm"
                include "Combat/AnimateIntroAndObjectPipeline.asm"
                include "Combat/UpdateAllSpaceObjects.asm"
                include "Combat/FinishObjectFrame.asm"
                include "Motion/NormalizeVector16.asm"
                include "Motion/SquareVectorComponent.asm"
                include "Motion/DivideVectorComponent.asm"
                include "Math/SquareRoot.asm"
                include "Motion/RenormalizeAxisHighBytes.asm"
                include "Motion/ScaleAxisHighByte.asm"
                include "Motion/UpdateObjectCoordinatesAndRotation.asm"         ; (0)
                include "Motion/AdvanceObjectAlongLocalAxis.asm"                ; (1)
                include "Motion/AdvanceOneCoordinate.asm"
                include "Motion/VelocityComponentDelta.asm"
                include "Motion/AddCoordinateDelta.asm"
                include "Motion/RotateAxisByPlayer.asm"
                include "Motion/AddSignedAngularProduct.asm"
                include "Motion/RotateBasisByObject.asm"
                include "Motion/ApplyPlayerMotionToObject.asm"
                include "Motion/AddScaledCoordinate.asm"
                include "Motion/DoubleSignedAngle.asm"
                include "Motion/AnimateIntroObject.asm"
                include "Motion/ProcessObjectEnergyAndTactics.asm"              ; (0)
                include "Motion/CallObjectActionPreservingPointers.asm"         ; (1)
                include "Motion/CheckObjectBoxAndChooseCourse.asm"
                include "Motion/GuideMissileAndCheckImpact.asm"
                include "Motion/IsSmallSignedDistance.asm"
                include "Motion/QuarterCoordinateDifference.asm"
                include "Motion/NegatedQuarterCoordinate.asm"
                include "Motion/QuarterCoordinate.asm"
                include "Motion/SteerObjectAndTryLaser.asm"
                include "Motion/SignedByteProductPair.asm"
                include "Motion/DotProductAxisHighBytes.asm"
                include "Motion/ProjectObjectAndSelectDetail.asm"
                include "Motion/XorFarObjectPixel.asm"
                include "Wireframe/DrawWireframeObject.asm"
                include "Wireframe/StartObjectExplosion.asm"
                include "Wireframe/FinishObjectAndDrawLaser.asm"
                include "Wireframe/AdvanceObjectMetadata.asm"
                include "Wireframe/BuildProjectedVertexTable.asm"
                include "Wireframe/AnyPackedFaceVisible.asm"
                include "Wireframe/ReadFaceVisibilityNibble.asm"
                include "Wireframe/SavePreviousVertexFlags.asm"                 ; (0)
                include "Wireframe/ReadVertexFlags.asm"                         ; (1)
                include "Wireframe/RotateNearVertexComponent.asm"
                include "Wireframe/AddSignedByteMagnitudes.asm"
                include "Wireframe/MultiplyHighByteApprox.asm"
                include "Wireframe/MultiplyScaledVertexComponent.asm"
                include "Wireframe/MultiplyBytesApprox.asm"
                include "Wireframe/AddRotatedVertexCoordinate.asm"
                include "Wireframe/RotateDistantVertex.asm"
                include "Wireframe/GetSystemVariationByte.asm"
                include "Wireframe/SumCachedVertexProducts.asm"
                include "Wireframe/RotateCoordinateAndCacheProducts.asm"
                include "Wireframe/DivideProjectionRatio.asm"                   ; (0)
                include "Wireframe/DivideFractionAndProjectVertex.asm"          ; (1)
                include "Wireframe/LocateVertexCoordinateData.asm"
                include "Wireframe/LocateFaceNormalData.asm"
                include "Wireframe/AdvanceVertexFlags.asm"
                include "Wireframe/AdvanceNormalFlags.asm"
                include "Wireframe/InitializeObjectFromModelNumber.asm"
                include "Wireframe/ReadProjectedVertex.asm"
                include "Wireframe/OrthogonalizeObjectYAxis.asm"
                include "Wireframe/CorrectYAxisComponent.asm"
                include "Wireframe/BuildObjectRotationMatrix.asm"
                include "Wireframe/CrossProductComponent.asm"
                include "Math/Divide.asm"
                include "Math/AddSigned.asm"
                include "Data/LegacyClipTables.asm"
                include "Wireframe/DrawClippedLine.asm"
                include "Wireframe/MultiplyClippingDistance.asm"
                include "Wireframe/UnscaleClippingRatio.asm"                    ; (0)
                include "Wireframe/DivideSlopeAndDrawScanner.asm"               ; (1)
                include "Wireframe/RefreshScannerBackground.asm"
                include "Wireframe/DrawScannerMarkerSegment.asm"
                include "Wireframe/SetTargetDisplayState.asm"
                include "Wireframe/MergeInverseHostilityFlag.asm"               ; (0)
                include "Wireframe/ReadObjectTacticsGates.asm"                  ; (1)
                include "Combat/HandleObjectCollision.asm"                      ; (0)
                include "Combat/ReleaseMissileTargets.asm"                      ; (1)
                include "Combat/CreatePlayerWreckScene.asm"
                include "Combat/FirePlayerLaser.asm"
                include "Combat/SpawnDestroyedObjectContents.asm"
                include "Combat/BeginObjectMetadataPass.asm"
                include "Combat/InitializeSpawnedObjectLinks.asm"
                include "Combat/MarkRemovedAndReleaseTargets.asm"
                include "Combat/SetObjectEnergyAndDrawMissedLaser.asm"
                include "Combat/NextRandomByte.asm"
                include "Combat/ClearLaserDisplayState.asm"
                include "Combat/ProcessLaserAndEcm.asm"
                include "Objects/ActivateEnemyECM.asm"
                include "Objects/DispatchObjectAction.asm"
                include "Objects/SelectObjectAction.asm"
                include "Objects/InitializeObject.asm"
                include "Objects/SpawnFromObject.asm"
                include "Objects/FindFreeObjectSlot.asm"
                include "Objects/SpawnAtPlayer.asm"                             ; (0)
                include "Objects/InitializeAtPlayer.asm"                        ; (1)
                include "Objects/SpawnThargonWave.asm"
                include "Objects/SpawnMissile.asm"
                include "Objects/SpawnShipClass.asm"
                include "Objects/AlternateSpawnAxes.asm"
                include "Objects/RotateSpawnAxisComponent.asm"
                include "Objects/RandomizeSpawnDirection.asm"
                include "Objects/SpawnTwoAlloys.asm"                            ; (0)
                include "Objects/SpawnPlayerDebris.asm"                         ; (1)
                include "Objects/SpawnTwoShipAlloys.asm"
                include "Objects/SpawnCargo.asm"
                include "Objects/SpawnEscapePod.asm"
                include "Objects/SpawnShipCargoOrPod.asm"
                include "Objects/SpawnTwoMinerals.asm"                          ; (0)
                include "Objects/SpawnShipDebris.asm"                           ; (1)
                include "Objects/InitializeIntroModel.asm"
                include "Objects/GenerateSpaceTraffic.asm"
                include "Objects/ComputeFaceVisibility.asm"
                include "Objects/DotProduct16By8.asm"
                include "Motion/MultiplySignedWordByByte.asm"
                include "Motion/TransformNormalWithObjectCoordinate.asm"
                include "Data/SquareTables.asm"
                include "Resources/CockpitPixels.asm"
                include "Resources/SkippedSectors.asm"
                include "Data/MenuDispatchTable.asm"
                include "Interface/DispatchStatusAndChartKeys.asm"
                include "Interface/DispatchResetCommander.asm"
                include "Interface/DispatchClearView.asm"
                include "Interface/DispatchDescriptionToken.asm"
                include "Interface/DispatchFlightMessage.asm"
                include "Interface/DispatchJumpKey.asm"
                include "Interface/DispatchTextToken.asm"
                include "Interface/DispatchDiskAndCommanderState.asm"
                include "Missions/DispatchMissionEvents.asm"
                include "Missions/DispatchRatingAndMissionEnd.asm"
                include "Missions/DispatchEquipmentDamage.asm"
                include "Missions/ShowBoardingMessage.asm"
                include "Missions/OfferThirdMission.asm"
                include "Missions/CompleteThirdMission.asm"
                include "Missions/SpecialMessageAndScoopReward.asm"
                include "Missions/RatingBountyDamageAndNewCommander.asm"
                include "Economy/PrintBytePrice.asm"
                include "Economy/PrintByteInteger.asm"                          ; (0)
                include "Economy/PrintWordDecimal.asm"                          ; (1)
                include "Economy/FinishWordDecimal.asm"                         ; (0)
                include "Economy/PrintSplitCash.asm"                            ; (1)
                include "Economy/PrintDecimalPlace.asm"                         ; (0)
                include "Economy/PrintDigitOrLeadingZero.asm"                   ; (1)
                include "Economy/PrintNumberPadding.asm"
                include "Economy/CompareWordPreserveHL.asm"
                include "Economy/AddCashLow.asm"                                ; (0)
                include "Economy/AddCashThousands.asm"                          ; (1)
                include "Economy/SubtractCashThousands.asm"
                include "Economy/SubtractCashLow.asm"
                include "Text/PrintInlineToken.asm"                             ; (0)
                include "Text/PrintMainToken.asm"                               ; (1)
                include "Text/PrintDescriptionToken.asm"
                include "Text/PrintDescriptionByte.asm"
                include "Text/PrintDescriptionString.asm"
                include "Text/ApplyTextCase.asm"                                ; (0)
                include "Text/DrawCharacter8x8.asm"                             ; (1)
                include "Text/XorCharacterScanlines.asm"
                include "Text/SetPromptAttributes.asm"                          ; (0)
                include "Text/FillInnerAttributeRow.asm"                        ; (1)
                include "Text/DrawFullWidthRule.asm"                            ; (0)
                include "Text/FillBytes.asm"                                    ; (1)
                include "Text/ApplyAttributeRuns.asm"
                include "Text/PrintTwoLetterSyllable.asm"
                include "Text/CheckMineralLifeColony.asm"
                include "Text/InitializeSixTriples.asm"
                include "Text/NextDescriptionRandom.asm"
                include "Text/CheckObjectRandomGate.asm"
                include "Text/ClearViewAndFrame.asm"                            ; (0)
                include "Text/DrawViewFrame.asm"                                ; (1)
                include "Text/CheckSavedSystemRegion.asm"
                include "Text/CheckMissionRegion.asm"
                include "Text/HandleSpecialObjectMission.asm"
                include "Text/OfferRegionDependentMission.asm"
                include "Text/PrintRankWithMissionSuffix.asm"
                include "Text/InvalidateObjectLineCache.asm"
                include "Text/DrawProjectedSunAndTextDispatch.asm"
                include "Text/CapitalizeNextLetterAndTextCommands.asm"
                include "Text/EquipmentMenuLimit.asm"
                include "Text/BeginSystemLaunchState.asm"
                include "Text/SetDescriptionModeAndHelpers.asm"
                include "Disk/LoadDiskMenuOverlay.asm"
                include "Disk/BlackAttributesAndOverlayState.asm"
                include "Disk/TransferDiskSectors.asm"
                include "Disk/ConvertTrackForDrive.asm"                         ; (0)
                include "Disk/CallDosWithDriveParameter.asm"                    ; (1)
                include "Disk/CallDosInternal.asm"                              ; (2)
                include "Disk/ReactionOnPrivateStack.asm"
                include "Disk/DrawScreenStripsAndPrivateStack.asm"
                include "Travel/UpdateFlightMessages.asm"
                include "Travel/SelectQueuedFlightMessage.asm"                  ; (0)
                include "Travel/SetMessageCoordinatesAndRender.asm"             ; (1)
                include "Travel/UpdateAmbientFlightMessage.asm"
                include "Travel/ClearFlightEventsAndHandleJump.asm"
                include "Travel/TickJumpCountdown.asm"
                include "Travel/RotateTwoSeedBytesAdvance.asm"
                include "Travel/CommitJumpFuelAndMishap.asm"
                include "Travel/EnterTargetSystem.asm"
                include "Travel/BuildPlanetCoordinateByte.asm"
                include "Travel/BuildPlanetCoordinateMagnitude.asm"             ; (0)
                include "Travel/BuildStationGeometry.asm"                       ; (1)
                include "Travel/LaserTypeAndArrivalEvents.asm"
                include "Travel/GetSalePriceAndMissionFlags.asm"
                include "Travel/EmptyFuelWithWarning.asm"                       ; (0)
                include "Travel/SetFuelAndGauge.asm"                            ; (1)
                include "Galaxy/AdvanceGalaxySeed.asm"                          ; (0)
                include "Galaxy/RotateSeedPair.asm"                             ; (1)
                include "Galaxy/FindSystemByExactName.asm"
                include "Galaxy/SelectNearestSystemWithCursor.asm"
                include "Galaxy/FindNearestSystem.asm"
                include "Galaxy/AdvanceSystemSeed.asm"
                include "Galaxy/SquaredDistanceToTarget.asm"
                include "Galaxy/OnesComplementDifference.asm"
                include "Galaxy/DistanceMetricToFuel.asm"
                include "Galaxy/MultiplyBytes.asm"
                include "Galaxy/GenerateSystemName.asm"                         ; (0)
                include "Galaxy/AppendSystemNameSyllable.asm"                   ; (1)
                include "Math/NextRandom.asm"                                   ; (2)
                include "Data/LaunchCounter.asm"
                include "Galaxy/CopySystemNameToTarget.asm"
                include "Galaxy/DeriveSystemProperties.asm"
                include "Galaxy/PrintTargetDistance.asm"
                include "Galaxy/FinishDistanceLine.asm"
                include "Galaxy/LoadGalaxySeed.asm"
                include "Galaxy/SaveWorkingSystemSeed.asm"
                include "Galaxy/RestoreWorkingSystemSeed.asm"
                include "Trade/RefreshMarketRandom.asm"                         ; (0)
                include "Trade/GenerateMarket.asm"                              ; (1)
                include "Trade/OptionalBeep.asm"
                include "Trade/WaitForKeyCode.asm"
                include "Trade/ClearPressedKeyBits.asm"
                include "Trade/PrintMarketRow.asm"
                include "Trade/PrintMarketPriceAndStock.asm"
                include "Trade/PrintEmptyStockOrQuantity.asm"
                include "Trade/PrintNonemptyCargoRow.asm"
                include "Trade/PrintCargoQuantity.asm"
                include "Trade/PrintDescriptionColon.asm"
                include "Trade/PrintMainTokenColon.asm"
                include "Trade/PrintMainTokenSpace.asm"
                include "Trade/PrintTokenNewline.asm"                           ; (0)
                include "Trade/Newline.asm"                                     ; (1)
                include "Trade/IncrementTextRow.asm"                            ; (2)
                include "Trade/ResetTextColumn.asm"
                include "Trade/SetInlineTextColumn.asm"                         ; (0)
                include "Trade/SetTextColumn.asm"                               ; (1)
                include "Trade/SetTextRow.asm"
                include "Trade/ErasePreviousCharacter.asm"
                include "Trade/PrintDecoratedToken.asm"
                include "Trade/PrintScreenCaption.asm"
                include "Trade/PrintZeroTerminatedString.asm"
                include "Trade/PrintCommodityUnit.asm"
                include "Trade/PrintKilometreSuffix.asm"
                include "Trade/Wait20Interrupts.asm"
                include "Trade/Wait36Interrupts.asm"
                include "Trade/SaveTextPosition.asm"
                include "Trade/ClearPromptRows.asm"                             ; (0)
                include "Trade/ClearSecondPromptRow.asm"                        ; (1)
                include "Trade/FillCharacterRowInterior.asm"                    ; (2)
                include "Trade/RestoreTextPosition.asm"
                include "Charts/FindSystemNameDialog.asm"
                include "Charts/BeginTextInput.asm"
                include "Charts/TextInputLoop.asm"
                include "Charts/MapCursorTransformAndKeys.asm"
                include "Charts/XorMapCrosshair.asm"
                include "Charts/BuildHighBitRun.asm"
                include "Charts/BuildLowBitRun.asm"
                include "Charts/PixelAddressAndVerticalCrosshair.asm"
                include "Charts/NextScreenCharacterRowAndRefugees.asm"
                include "Trade/MissionRegionMetric.asm"
                include "Trade/ResetCloakingAndSeedFlightRandom.asm"
                include "Trade/BuyCargoLoop.asm"
                include "Trade/InputTradeQuantity.asm"
                include "Trade/ShowTradeSuccess.asm"
                include "Trade/TradeFeedback.asm"
                include "Trade/IndirectTradeCallbackAndBuy.asm"
                include "Trade/TradeErrorMessage.asm"
                include "Trade/RollbackFailedTrade.asm"                         ; (0)
                include "Trade/TradeBeepAndPause.asm"                           ; (1)
                include "Trade/SnapshotTrade.asm"
                include "Trade/RestoreTradeSnapshot.asm"
                include "Trade/PromptCargoQuantityAndRefugees.asm"
                include "Trade/PrepareTradeScreen.asm"
                include "Trade/TradeTitleAndSellLoop.asm"
                include "Trade/ResetTradeIterators.asm"
                include "Trade/OpenEquipmentShop.asm"
                include "Trade/ListEquipmentChoices.asm"
                include "Trade/PrintEquipmentPrice.asm"
                include "Trade/HandleEquipmentPurchase.asm"
                include "Trade/InstallPurchasedEquipment.asm"
                include "Trade/ChooseLaserDirection.asm"
                include "Trade/EquipmentPaymentFailed.asm"
                include "Trade/GetEquipmentPriceAddress.asm"
                include "Trade/GetEquipmentStateAddress.asm"                    ; (0)
                include "Trade/AddByteOffsetToHL.asm"                           ; (1)
                include "Trade/EquipmentAlreadyOwned.asm"
                include "Menus/MapCaptionAndGalaxyChart.asm"
                include "Menus/ClearCharacterRowsBackward.asm"
                include "Menus/PlotGalaxySystem.asm"
                include "Menus/ReturnZero.asm"
                include "Menus/Return255.asm"
                include "Menus/CheckMissionRegionBand.asm"
                include "Menus/RedirectDuplicateEquipment.asm"
                include "Menus/OpenLocalChart.asm"
                include "Menus/VisitLocalChartSystems.asm"
                include "Menus/LocalSystemPixelPosition.asm"
                include "Menus/DrawExplosionAndScanner.asm"
                include "Menus/ReadVisibleObjectByte.asm"
                include "Menus/PlaceLocalSystemLabel.asm"                       ; (0)
                include "Menus/PrintLabelOnUnusedRow.asm"                       ; (1)
                include "Menus/PrintSystemStatistics.asm"
                include "Menus/PrintTokenAndBlankLine.asm"
                include "Menus/BlankLineAndEconomyText.asm"
                include "Menus/ApplyMissionMarketRestrictions.asm"
                include "Menus/ChooseEncounterVariant.asm"
                include "Menus/PrintSystemRadius.asm"
                include "Menus/CompareSystemSeedToGalaxyBase.asm"
                include "Menus/OpenCommanderStatus.asm"
                include "Menus/PrintLegalStatus.asm"
                include "Menus/PrintCombatRankAndEquipment.asm"
                include "Menus/PrintInlineTokenIfNonzero.asm"                   ; (0)
                include "Menus/PrintEquipmentLine.asm"                          ; (1)
                include "Menus/NextEquipmentLine.asm"                           ; (2)
                include "Menus/PrintDirectionalLaser.asm"
                include "Menus/PrintStatusFieldAndCargoScreen.asm"
                include "Extensions/PrintCargoAndMessageBanks.asm"
                include "Extensions/DrawCircleAndProtectScratchStack.asm"
                include "Extensions/SetExtendedTextCursor.asm"
                include "Extensions/MarkObjectEventAndUpdateMetadata.asm"
                include "Extensions/StorePairedObjectDirections.asm"
                include "Extensions/GetViewAdjustedProjectedPoint.asm"
                include "Extensions/FindLiveTrackedObject.asm"
                include "Extensions/ResolveSpecialObjectCollision.asm"
                include "Extensions/SetSceneFlagAndResetMetadata.asm"           ; (0)
                include "Extensions/ResetObjectMetadata.asm"                    ; (1)
                include "Extensions/SetObjectAggressionFlag.asm"
                include "Extensions/SetAggressionThenContinue.asm"
                include "Extensions/ValidateTargetWithFlags.asm"                ; (0)
                include "Extensions/ValidatePackedObjectTarget.asm"             ; (1)
                include "Extensions/ChooseLinkedObjectTarget.asm"
                include "Extensions/ScheduleLinkedObjectLaser.asm"
                include "Extensions/AllocateVariantObjectSlot.asm"
                include "Extensions/OrSpriteByte.asm"
                include "Extensions/BuildSmallCircleProfile.asm"
                include "Extensions/DrawSmallSilhouetteAlternate.asm"
                include "Extensions/DrawSmallSilhouette.asm"
                include "Extensions/CompareObjectCoordinateDepth.asm"
                include "Input/FinishKeyboardRowAndSelectJoystick.asm"
                include "Input/MarkModelVisibilityMask.asm"
                include "Input/ResetDemoAndNormalizeControls.asm"
                include "Input/SetPressedKeyAssignment.asm"
                include "Input/CheckMissionSystem.asm"
                include "Input/ToggleSecondaryCoordinateObject.asm"
                include "Input/ScanKeyboardMatrix.asm"
                include "Input/IntegrateFlightControls.asm"
                include "Input/InterruptGateAndAcceleration.asm"
                include "Input/ClampAndStoreFlightSpeed.asm"
                include "Input/KeyboardControlInterrupt.asm"
                include "Input/EnableInterruptMode2.asm"
                include "Input/EnableInterruptMode1AndKeyboardMap.asm"
                ASSERT $ == #10000
                endmodule
                endif
