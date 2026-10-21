                module Scanner
                module SaveScannerBackground
; -----------------------------------------
; Сохранение чистого фона сканера в линейный буфер
; исходный диапазон #98A2..#98CC
; In:
;   экран Memory.Screen + #1049, буфер Memory.CockpitAttrs, ScannerState.Redraw наличие старых маркеров
; Out:
;   624 байта фона скопированы в Memory.CockpitAttrs
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Сначала Game.Scanner.RestoreScannerBackground.Entry восстанавливает прошлый фон, затем меняются семь байтов команд общего цикла
;   Для сохранения ScannerCopy/ScannerCopy.SelectScreen=EX DE,HL, ScannerCopy.SaveCharRow/ScannerCopy.SavePixelRow=PUSH HL, ScannerCopy.RestoreRow=POP HL, ScannerCopy.AdvanceRow=INC H, ScannerCopy.SelectTarget=NOP
;   Переход Game.Scanner.RestoreScannerBackground.CopyBackground использует тот же LDIR, что восстановление Game.Scanner.RestoreScannerBackground.Entry
; -----------------------------------------
                ASSERT $ == #98A2
                ; удаление старых маркеров перед новым снимком фона
Entry:          CALL Game.Scanner.RestoreScannerBackground.Entry
                ; подмена команд общего копировщика для направления экран→буфер
                LD BC, #0005
                LD A, #EB
                LD HL, ScannerCopy.SelectSource
                LD (HL), A
                LD A, #E5
                LD HL, ScannerCopy.SaveCharRow
                LD (HL), A
                ADD HL, BC
                LD (HL), A
                LD A, #E1
                LD HL, ScannerCopy.RestoreRow
                LD (HL), A
                INC HL
                LD A, #24
                LD (HL), A
                ; NOP сохраняет расположение линейного указателя назначения
                XOR A
                LD HL, ScannerCopy.SelectTarget
                LD (HL), A
                LD A, #EB
                LD HL, ScannerCopy.SelectScreen
                LD (HL), A
                JR Game.Scanner.RestoreScannerBackground.CopyBackground

                ASSERT $ == #98CD
                endmodule
                endmodule
