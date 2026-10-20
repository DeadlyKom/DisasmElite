                ifndef _LOADER_INCLUDE_
                define _LOADER_INCLUDE_

                module Loader
                include "Constants.inc"

; -----------------------------------------
; файл ELITE3.B, 385 байт без секторного дополнения
; строка BASIC 0 содержит REM, переносимый загрузчик и его подпрограммы
; строка BASIC 10 вычисляет PROG + 5 и передаёт его команде RANDOMIZE USR
; абсолютный адрес размещения BASIC не зафиксирован кодом загрузчика
; -----------------------------------------
FileBegin:      DB #00, #00                                                     ; номер строки BASIC 0
                ; расчёт исходной длины строки с машинным кодом
                DW BasicLine - FileBegin - 4
                DB #EA                                                          ; токен REM
                include "Bootstrap.asm"

                ; восстановление исходных адресов переносимого блока
                disp CODE_BASE
FileName:       DB "ELITE3  C"                                                  ; имя и тип искомого файла TR-DOS
                include "Load.asm"
                include "Restart.asm"
                include "ExchangeState.asm"
                include "MutateMemory.asm"
                include "SaveState.asm"
                ; проверка точного конца переносимого блока
                assert $ = CODE_BASE + CODE_SIZE
                ent

                include "Basic.asm"
FileEnd:        EQU $
                ; проверка точной длины исходного файла
                assert FileEnd - FileBegin = #0181
                endmodule

                endif ; ~_LOADER_INCLUDE_
