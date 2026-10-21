                ifndef _DISK_UTILITY_INCLUDE_
                define _DISK_UTILITY_INCLUDE_

                module DiskUtility
ResetRom:       EQU #0000                                                       ; вход холодного перезапуска ПЗУ Spectrum
DosGateway:     EQU #3D2F                                                       ; адрес включения ПЗУ TR-DOS через исполняемый переход
FileBegin:      EQU $

; первый оверлей читается процедурой Game.Disk.LoadDiskMenuOverlay.Entry в исходную область #C800
                disp #C800
                module Menu
                include "Menu/Include.inc"
; проверка границы первых восьми секторов
                assert $ = #D000
                endmodule
                ent

                include "Robot.asm"

; второй оверлей читается процедурой Game.Disk.BlackAttributesAndOverlayState.LoadDemo в ту же область #C800
                disp #C800
                module DemoSetup
                include "DemoSetup/Include.inc"
; проверка начала переносимого кода демонстрации
                assert $ = #C8D6
                endmodule
                ent

; продолжение файла выполняется после исходного переноса в DiskUtility.Demo.FrameHook
; LDIR переносит #0852 байта, включая #0128 байт основной игры за оверлеем
; эти дополнительные байты принадлежат ELITE3.C и не добавляются в cl.C
                disp #E6AE
                module Demo
                include "Demo/Include.inc"
; проверка конца данных, реально присутствующих в cl.C
                assert $ = #EDD8
                endmodule
                ent
FileEnd:        EQU $
; проверка сохранения всех 17 исходных секторов файла
                assert FileEnd - FileBegin = #1100
                endmodule

                endif                                                           ; ~_DISK_UTILITY_INCLUDE_
