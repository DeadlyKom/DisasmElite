                module Resources
; -----------------------------------------
; буфер 256 атрибутов нижней трети экрана, восемь строк по 32 ячейки
; PrnCockpit по Game.Screen.RestoreCockpit.Entry копирует буфер в видеопамять Memory.Attributes + #0200
; SaveCockpitInBuffer по Game.Screen.SaveCockpit.Entry сохраняет текущие атрибуты обратно сюда
; поэтому это одновременно исходный ресурс и изменяемый буфер кабины
; при выводе сканера Game.Scanner.SaveScannerBackground.Entry использует Memory.CockpitAttrs для 624 байтов чистого фона
; Game.Scanner.RestoreScannerBackground.Entry возвращает этот фон в экран перед новым выводом маркеров
; бит 7 задаёт FLASH, бит 6 BRIGHT, биты 5..3 PAPER, биты 2..0 INK
; -----------------------------------------
                ; проверка исходного размещения ресурса
                ASSERT $ == #5B00
CockpitAttrs:   INCBIN "CockpitAttributes.bin"
                ; проверка размера ресурса и следующего адреса
                ASSERT $ == #5C00
                endmodule
