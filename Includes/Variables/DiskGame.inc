                ifndef _VARIABLES_DISK_
                define _VARIABLES_DISK_

OverlayTrack    EQU Game.Disk.BlackAttributesAndOverlayState.OverlayTrack       ; сектор и дорожка дискового оверлея cl.C
DemoTrack       EQU Game.Disk.BlackAttributesAndOverlayState.DemoTrack          ; сектор и дорожка файла демонстрации
DriveFlags      EQU Game.Disk.BlackAttributesAndOverlayState.DriveFlags         ; параметр диска, бит 1 включает пересчёт дорожки и стороны
DiskParameter   EQU Game.Disk.BlackAttributesAndOverlayState.DiskParameter      ; параметр внутреннего вызова TR-DOS
DiskSavedIX     EQU Game.Disk.TransferDiskSectors.SavedIX                       ; сохранённый IX в операнде LD IX после TR-DOS
ReactionStack   EQU Game.Disk.ReactionOnPrivateStack.SavedSP                    ; сохранённый SP в операнде восстановления стека
ScreenStack     EQU Game.Disk.DrawScreenStripsAndPrivateStack.SavedSP           ; сохранённый SP в операнде восстановления стека после вывода
SaveSelection   EQU Game.Disk.DrawScreenStripsAndPrivateStack.SaveSelection     ; индекс выбранного командира в дисковом меню
SavePageStart   EQU Game.Disk.DrawScreenStripsAndPrivateStack.SavePageStart     ; индекс первого командира отображаемой страницы
TimingFailures  EQU Game.Data.LaunchCounter.TimingFailures                      ; число отказов временной проверки маркера дорожки
MarkFailures    EQU Game.Data.LaunchCounter.MarkFailures                        ; число отказов VerifyMark, порог отказа равен 8
ProtectPassed   EQU Game.Data.LaunchCounter.ProtectPassed                       ; результат проверки дисковой защиты, #FF допуск, 0 отказ
ClearInputGate  EQU Game.Trade.ClearPromptRows.Entry                            ; изменяемая первая команда очистки строк ввода

DosReadSector   EQU #2F1B                                                       ; внутренний вход TR-DOS для чтения сектора
DosWriteSector  EQU #2D73                                                       ; внутренний вход TR-DOS для записи сектора
DosDriveInit    EQU #1FF3                                                       ; вход подготовки устройства, вызывается с A=DiskParameter
DosPrepareIO    EQU #2FC1                                                       ; вход подготовки перед циклом передачи секторов
DosBaseSide     EQU #2F0A                                                       ; вход перед выбором стороны и позиционированием дорожки
DosAltSide      EQU #2F17                                                       ; дополнительный вход для нечётной логической дорожки
DosSeekTrack    EQU #2F50                                                       ; вход позиционирования, A содержит физический номер дорожки
DosInlineCall   EQU #20B8                                                       ; внутренний вход с C,D из потока после CALL и B=1
DosReadTrack    EQU #3FE5                                                       ; внутренний вход приёма дорожки, C=#7F, DE=0

                endif                                                           ; ~_VARIABLES_DISK_
