                ifndef _ELITE_BOOT_INCLUDE_
                define _ELITE_BOOT_INCLUDE_
                module Boot
; -----------------------------------------
; начальный BASIC-файл диска
; строка 1 вызывает диспетчер TR-DOS через RANDOMIZE USR 15619
; часть после REM интерпретируется TR-DOS как RUN "ELITE3HL"
; номер автозапуска 1 записывается упаковщиком за пределами этих 32 байт
; -----------------------------------------
Begin:          DB #00, #01
                DW End - Begin - 4
                DB #F9, #C0, "15619"
                DB #0E, #00, #00, #03, #3D, #00
                DB ":", #EA, ":", #F7, #22, "ELITE3HL", #22, #0D
End:            EQU $
                ; проверка размера исходной строки BASIC
                ASSERT End - Begin = 32
                endmodule
                endif
