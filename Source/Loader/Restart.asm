                ifndef _LOADER_RESTART_
                define _LOADER_RESTART_
; -----------------------------------------
; сохранённая точка перенаправления Loader.Restart к обработчику игры Loader.GAME_RESTART
; In:
;   состояние игры, ожидаемое исходным обработчиком
; Out:
;   переход к Loader.GAME_RESTART, где устанавливается SP = Loader.START_STACK и выполняется JP Game.Flight.MainGameLoop.DrawObjects
; Corrupt:
;   непосредственный JP регистры не изменяет
; Note:
;   из процедуры Load этот переход не выполняется
; -----------------------------------------
Restart:        JP GAME_RESTART

                endif                                                           ; ~_LOADER_RESTART_
