                module Flight
                module ClearFlightKeyEvents
; -----------------------------------------
; Очистка пяти накопленных клавиатурных масок
; исходный диапазон #94FE..#9502
; In:
;   без параметров
; Out:
;   InputState.SystemKeys..InputState.ChartKeys=0, далее общий Game.Flight.ClearBytes.Entry
; Corrupt:
;   HL, BC, AF
; Note:
;   Код символа InputState.LastKey и настройки InputState.Config сохраняются
; -----------------------------------------
                ASSERT $ == #94FE
                ; очистка пяти масок с сохранением символа и настроек
Entry:          LD B, #05
                LD HL, InputState.SystemKeys                                    ; далее Game.Flight.ClearBytes.Entry без команды перехода
                ASSERT $ == #9503
                endmodule
                endmodule
