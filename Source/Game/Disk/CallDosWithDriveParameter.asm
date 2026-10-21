                module Disk
                module CallDosWithDriveParameter
; -----------------------------------------
; Подстановка параметра устройства перед внутренним вызовом TR-DOS
; исходный диапазон #DA17..#DA19
; In:
;   IX = адрес процедуры ROM TR-DOS
; Out:
;   A загружен из DiskParameter, затем переход через Game.Disk.CallDosInternal.Entry
; Corrupt:
;   AF и регистры вызываемой ROM-процедуры
; Note:
;   Это общий хвост для подготовки параметра устройства
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #DA17
                ; передача параметра текущего дисковода через внутренний шлюз TR-DOS
Entry:          LD A, (DiskParameter)                                           ; далее Game.Disk.CallDosInternal.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #DA1A
                endmodule
                endmodule
