                include "Constants.inc"
                include "EnterDiskMenu.asm"
                include "MenuMessages.asm"
                include "PreservedSectorReader.asm"
                include "SelectTrackAndSide.asm"
                include "WriteWorkBuffer.asm"                                   ; (0) жёсткий порядок, последовательное исполнение
                include "WriteSector.asm"                                       ; (1) жёсткий порядок, последовательное исполнение
                include "ReadWorkBuffer.asm"                                    ; (0) жёсткий порядок, последовательное исполнение
                include "ReadSector.asm"                                        ; (1) жёсткий порядок, последовательное исполнение
                include "TransferSector.asm"                                    ; (2) жёсткий порядок, последовательное исполнение
                include "VerifyProtectionTiming.asm"
                include "MeasureTrackMarker.asm"
                include "TransformProtectionMark.asm"
                include "UpdateProtectionMark.asm"
                include "VerifyProtectionMark.asm"
                include "CheckMenuAbort.asm"
                include "WriteFdcStream.asm"
                include "ClearWorkBuffer.asm"
                include "BuildCommanderCatalog.asm"                             ; (0) жёсткий порядок, последовательное исполнение
                include "DispatchMenuCommand.asm"                               ; (1) жёсткий порядок, последовательное исполнение
                include "SelectPreviousSave.asm"
                include "SelectNextSave.asm"                                    ; (0) жёсткий порядок, последовательное исполнение
                include "DrawCommanderNames.asm"                                ; (1) жёсткий порядок, последовательное исполнение
                include "PrintMenuCharacter.asm"                                ; (2) жёсткий порядок, последовательное исполнение
                include "ComputeNamePosition.asm"
                include "GetSelectedSave.asm"                                   ; (0) жёсткий порядок, последовательное исполнение
                include "GetSaveRecord.asm"                                     ; (1) жёсткий порядок, последовательное исполнение
                include "HighlightSelectedSave.asm"
                include "WaitMenuKey.asm"
                include "MenuBeep.asm"
                include "LoadCommander.asm"
                include "EditSaveName.asm"
                include "CopyCommanderName.asm"                                 ; (0) жёсткий порядок, последовательное исполнение
                include "SaveNamedCommander.asm"                                ; (1) жёсткий порядок, последовательное исполнение
                include "AllocateSaveRecord.asm"
                include "ShowDiskFullError.asm"
                include "FormatTrack.asm"
                include "BuildTrackStream.asm"                                  ; (0) жёсткий порядок, последовательное исполнение
                include "EmitRepeatedByte.asm"                                  ; (1) жёсткий порядок, последовательное исполнение
                include "EmitSectorPattern.asm"
                include "SectorFormatPattern.asm"
                include "PreservedSectorOrder.asm"
                include "FormatDecimalNumber.asm"                               ; (0) жёсткий порядок, последовательное исполнение
                include "FormatDecimalDigit.asm"                                ; (1) жёсткий порядок, последовательное исполнение
                include "CopyServiceMessages.asm"
                include "ShowCopyServiceMenu.asm"
                include "CopyServicePointers.asm"
                include "ConfirmAndPrepareCopy.asm"
                include "PreservedMenuTail.asm"
