                ifndef _LOADER_SAVE_STATE_
                define _LOADER_SAVE_STATE_
; -----------------------------------------
; сохранение позиции дисковых операций и переключение на системную область игры
; In:
;   слово позиции TR-DOS по адресу Loader.TRDOS_CUR
;   #5C00..#5FFF содержат действующую системную область
;   #CC00..#CFFF содержат соответствующую часть загруженного снимка
; Out:
;   слово Loader.TRDOS_CUR сохранено по адресу Loader.GAME_DISKPOS
;   HL = Loader.SNAP_MIDDLE, DE = Loader.SNAP_HIGH, BC = #0000, A = #00, флаг Z установлен
; Corrupt:
;   HL, DE, BC, AF, AF'
; -----------------------------------------
SaveState:      ; сохранение состояния дискового указателя до обмена областей
                LD HL, (TRDOS_CUR)
                LD (GAME_DISKPOS), HL
                CALL ExchangeState
                RET

                endif                                                           ; ~_LOADER_SAVE_STATE_
