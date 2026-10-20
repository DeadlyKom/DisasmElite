                include "EnterDemoInstaller.asm"
                include "PreservedMenuExit.asm"
                include "InstallDemoOverlay.asm"
                include "RestartPatch.asm"
                include "VirtualInputPatches.asm"
DemoPayload     EQU $                                                           ; начало переносимого кода в исходном оверлее #C8D6
