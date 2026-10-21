; -----------------------------------------
; Вывод сферы сканера и наложение маркеров
; исходный диапазон #E6B4..#E6BC
; In:
;   состояние основного игрового рендера
; Out:
;   выполнены Game.Circles.DrawPendingObjectExplosions.Entry, копирование Game.Screen.CopyFlightView.Entry и маркеры Game.Scanner.DrawScannerObjects.Entry
; Corrupt:
;   HL, DE, BC, AF, IX, альтернативные регистры по Game.Circles.DrawPendingObjectExplosions.Entry
; Note:
;   Этот вызов заменяет Game.Flight.MainGameLoop.DrawIndicators, переход Game.Scanner.DrawScannerObjects.Entry сохраняет исходный адрес возврата
; -----------------------------------------
                ; подложка сферы рисуется до копирования буфера, маркеры накладываются после него
DrawViewHook:   CALL @Game.Circles.DrawPendingObjectExplosions.Entry
                CALL @Game.Screen.CopyFlightView.Entry
                JP @Game.Scanner.DrawScannerObjects.Entry
