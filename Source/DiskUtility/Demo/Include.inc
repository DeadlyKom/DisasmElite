                include "Constants.inc"
                include "ResumeDemoBeforeKeyboard.asm"
                include "DrawDemoFlightView.asm"
                include "AddByteOffset.asm"
                include "CheckInvasionBand.asm"
                include "PrintFormattingToken.asm"
                include "RestoreFlightState.asm"
                include "CoroutineStackPointers.asm"
                include "CoroutineDispatch.asm"
                include "StartDemoCoroutine.asm"
                include "ResumeDemoCoroutine.asm"
                include "CoroutineResumePoint.asm"
                include "YieldWithSteeringBrake.asm"                            ; (0) жёсткий порядок, последовательное исполнение
                include "YieldToGame.asm"                                       ; (1) жёсткий порядок, последовательное исполнение
                include "CompareCoordinateSum.asm"
                include "CompareWords.asm"
                include "InitializeDemoScenario.asm"                            ; (0) жёсткий порядок, последовательное исполнение
                include "ApproachCelestialBody.asm"                             ; (1) жёсткий порядок, последовательное исполнение
                include "FollowStation.asm"
                include "CheckDemoRestart.asm"
                include "ReservedDemoBytes.asm"
                include "BeepAndWait.asm"
                include "ChooseCelestialTarget.asm"                             ; (0) жёсткий порядок, последовательное исполнение
                include "AimAtNearBody.asm"                                     ; (1) жёсткий порядок, последовательное исполнение
                include "ChooseObjectAimPrecision.asm"                          ; (0) жёсткий порядок, последовательное исполнение
                include "SteerTowardTarget.asm"                                 ; (1) жёсткий порядок, последовательное исполнение
                include "ChooseRollFromSign.asm"
                include "ApplyRollKeys.asm"
                include "RollWindowCounter.asm"
                include "CollectNearbyTarget.asm"
                include "PreservedSteeringEntry.asm"
                include "ApplyPitchKeys.asm"
                include "PitchWindowCounter.asm"
                include "ApplyDefenceKeys.asm"
                include "BrakeForDistantTarget.asm"                             ; (0) жёсткий порядок, последовательное исполнение
                include "ApplyBrakeKey.asm"                                     ; (1) жёсткий порядок, последовательное исполнение
                include "ApplyAccelerationKey.asm"
                include "ReverseCourse.asm"
                include "ManualKeyboardMode.asm"
                include "ReadPhysicalKeyboard.asm"
                include "BombDelayCounter.asm"
                include "ChooseDemoAction.asm"
                include "ActionTimer.asm"
                include "AttackSelectedTarget.asm"
                include "CollectFloatingCargo.asm"
                include "AdvanceObjectCursor.asm"
                include "ObjectCursor.asm"
                include "FindAttackTarget.asm"
                include "CheckAttackTarget.asm"
                include "RejectCargoTarget.asm"
                include "ObjectMetadataCache.asm"
                include "ReadObjectMetadata.asm"
                include "CountHostileTargets.asm"
                include "CountCollectableMetadata.asm"
                include "CountPlayerSeekingMissiles.asm"
                include "ClearMainKeyboardRows.asm"
                include "CheckInterruptedHalt.asm"
                include "PauseWithDemoMark.asm"                                 ; (0) жёсткий порядок, последовательное исполнение
                include "DrawDemoMarkXor.asm"                                   ; (1) жёсткий порядок, последовательное исполнение
                include "DemoMarkShapeMasks.asm"
                include "DemoMarkCellMap.asm"
                include "DemoMarkCellShapes.asm"
                include "DemoMarkTail.asm"
