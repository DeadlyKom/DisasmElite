                module Screen
                module SaveCockpit
; -----------------------------------------
; сохранение приборной панели перед информационным экраном
; In:
;   экран Memory.Screen + #1000 и атрибуты Memory.Attributes + #0200 содержат кабину
; Out:
;   буферы Memory.Frame и Memory.CockpitAttrs обновлены
;   AF, A сохраняется
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   вызов Game.Scanner.RestoreScannerBackground.Entry синхронизирует изображение сканера перед копированием
;   LDIR переносит 2048 пиксельных байтов и 256 атрибутов
;   при полёте Memory.Frame снова используется как буфер кадра после восстановления кабины
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #817E
Entry:          PUSH AF
                CALL Game.Scanner.RestoreScannerBackground.Entry
                POP AF
                ; сохранение пиксельного изображения кабины
                LD DE, Memory.Frame                                             ; копия 2048 байтов пикселей кабины
                LD HL, Memory.Screen + #1000                                    ; строка 128, начало пиксельного изображения кабины
                LD BC, #0800
                LDIR
                ; сохранение её восьми строк атрибутов
                LD DE, Memory.CockpitAttrs                                      ; копия 256 атрибутов кабины
                LD HL, Memory.Attributes + 16 * 32                              ; восемь строк атрибутов кабины начиная с 16
                LD BC, #0100
                LDIR
                RET

                ASSERT $ == #819A
                endmodule
                endmodule
