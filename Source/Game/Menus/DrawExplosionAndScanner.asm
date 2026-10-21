                module Menus
                module DrawExplosionAndScanner
; -----------------------------------------
; Общий вызов взрыва, копирования экрана и сканера
; исходный диапазон #ED60..#ED68
; In:
;   Регистры по контракту Game.Circles.DrawPendingObjectExplosions.Entry
; Out:
;   Изображение взрыва и сканера обновлено
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
;   Последний вызов выполнен JP Game.Scanner.DrawScannerObjects.Entry, сохраняющим исходный адрес возврата
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #ED60
                ; общий путь обновления взрыва, изображения полёта и маркеров сканера
Entry:          CALL Game.Circles.DrawPendingObjectExplosions.Entry
                CALL Game.Screen.CopyFlightView.Entry
                JP Game.Scanner.DrawScannerObjects.Entry

                ; проверка исходного конца фрагмента
                ASSERT $ == #ED69
                endmodule
                endmodule
