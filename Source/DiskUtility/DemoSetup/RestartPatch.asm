; -----------------------------------------
; Шаблон восстановления демо после гибели
; исходный диапазон #C8C4..#C8C9
; In:
;   A передаётся состоянием игрового выхода
; Out:
;   после переноса OverlayTrack записывает LaunchPending=A и идёт Game.Flight.ShowTitleAndSelectControls.WaitRelease
; Corrupt:
;   регистры не меняются до перехода Game.Flight.ShowTitleAndSelectControls.WaitRelease
; Note:
;   InstallDemo копирует шесть байтов RestartPatch в OverlayTrack
;   штатный путь гибели передаёт A=0, запись LaunchPending обнуляет маркер перезапуска
; -----------------------------------------
RestartPatch    DB #32, #7A, #E0, #C3, #9E, #73                                 ; данные #C8C4..#C8C9
