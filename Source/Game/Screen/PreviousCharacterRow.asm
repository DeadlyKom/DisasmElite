                module Screen
                module PreviousCharacterRow
; -----------------------------------------
; коррекция адреса после перехода вверх через границу знакоместа
; In:
;   HL, адрес после DEC H на границе знакоместа
; Out:
;   HL, адрес предыдущей строки знакомест
; Corrupt:
;   HL, AF
; Note:
;   из L вычитается #20, при отсутствии займа к H прибавляется 8
;   Game.Screen.PreviousCharacterRow.RestorePanel является отдельным входом восстановления компаса и сканера
;   подготовка перед CopySpriteRow задаёт 24 строки спрайта по три последовательных байта
;   после RET CopySpriteRow сохранены десять байтов данных
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #844F
                ; расчёт переноса в предыдущую строку знакомест
Entry:          LD A, L
                SUB #20
                LD L, A
                RET C                                                           ; выход, если заём L уже выполнил переход между третями

                LD A, H
                ADD A, #08
                LD H, A
                RET

                ; восстановление фона компаса и изображения сканера
RestorePanel:   CALL Game.Screen.RestoreCompassBackground.Entry
                JP Game.Scanner.SaveScannerBackground.Entry

                ; копирование 24 строк спрайта, по три последовательных байта
                LD BC, #18FF
CopySpriteRow:  LDI
                LDI
                LDI
                DEC E
                DEC E
                DEC E
                EX DE, HL
                INC H
                LD A, H
                AND #07
                CALL Z, Game.Screen.NextCharacterRow.Entry                      ; вызов, если следующая строка спрайта пересекла границу знакоместа
                EX DE, HL
                DJNZ CopySpriteRow

                RET

                DB #00, #00, #3C, #00, #24, #00, #24, #00                       ; исходные байты #8477..#847E
                DB #3C, #00                                                     ; исходные байты #847F..#8480
                ASSERT $ == #8481
                endmodule
                endmodule
