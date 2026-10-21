                module Screen
                module CopySixtyRows
; -----------------------------------------
; подготовка копирования 60 строк через одну
; In:
;   HL, источник
;   DE, экранный адрес
; Out:
;   перенос 60 строк по 32 байта
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   этот вход задаёт только счётчик B и продолжается в Game.Screen.CopyAlternateRows.Entry
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #7FCD
Entry:          LD B, #3C                                                       ; далее Game.Screen.CopyAlternateRows.Entry без команды перехода
                ASSERT $ == #7FCF
                endmodule
                endmodule
