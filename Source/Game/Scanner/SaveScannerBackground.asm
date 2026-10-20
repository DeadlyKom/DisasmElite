                module Scanner
                module SaveScannerBackground
; -----------------------------------------
; Сохранение чистого фона сканера в линейный буфер
; исходный диапазон #98A2..#98CC
; In:
;   экран 5049, буфер 5B00, 96C4 наличие старых маркеров
; Out:
;   624 байта фона скопированы в 5B00..5D6F
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Сначала 98CD восстанавливает прошлый фон, затем меняются семь байтов команд общего цикла
;   Для сохранения 9912/9939=EX DE,HL, 9915/991A=PUSH HL, 9935=POP HL, 9936=INC H, 9940=NOP
;   Переход 990C использует тот же LDIR, что восстановление 98CD
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
