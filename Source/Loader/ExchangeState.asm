                ifndef _LOADER_EXCHANGE_STATE_
                define _LOADER_EXCHANGE_STATE_
; -----------------------------------------
; взаимный обмен 1024 байт между #5C00..#5FFF и #CC00..#CFFF
; In:
;   две области памяти исходного снимка и действующего BASIC/TR-DOS
; Out:
;   HL = Loader.SNAP_MIDDLE, DE = Loader.SNAP_HIGH, BC = #0000, A = #00, флаг Z установлен
; Corrupt:
;   HL, DE, BC, AF, AF'
; Note:
;   AF' временно удерживает байт первой области, пока A переносит второй
;   это обмен, поэтому повторный вызов восстанавливает исходное размещение
; -----------------------------------------
ExchangeState:  LD HL, SYS_BASE
                LD DE, SYS_COPY
                LD BC, SYS_SIZE
.Loop           ; обмен текущей парой байтов без дополнительного буфера
                LD A, (HL)
                EX AF, AF'
                LD A, (DE)
                LD (HL), A
                EX AF, AF'
                LD (DE), A
                INC HL
                INC DE
                DEC BC
                ; проверка завершения обмена всех 1024 байт
                LD A, B
                OR C
                JR NZ, .Loop                                                    ; переход, если остались необменённые байты

                RET

                endif                                                           ; ~_LOADER_EXCHANGE_STATE_
