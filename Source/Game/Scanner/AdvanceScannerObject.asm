                module Scanner
                module AdvanceScannerObject
; -----------------------------------------
; Общий переход к следующему объекту сканера
; исходный диапазон #96D6..#96D8
; In:
;   IX текущий объект, ScannerState.ObjectIndex число оставшихся слотов
; Out:
;   продолжение общего цикла Game.Scanner.DrawScannerObjects.NextObject
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   Вход используется всеми ранними отбраковками Game.Scanner.DrawScannerObjects.Entry, собственный адрес возврата не создаётся
; -----------------------------------------
                ASSERT $ == #96D6
                ; ранний отказ использует общий переход к следующему объекту
Entry:          JP Game.Scanner.DrawScannerObjects.NextObject

                ASSERT $ == #96D9
                endmodule
                endmodule
