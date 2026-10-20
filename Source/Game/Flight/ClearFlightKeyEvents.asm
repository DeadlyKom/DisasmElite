                module Flight
                module ClearFlightKeyEvents
; -----------------------------------------
; Очистка пяти накопленных клавиатурных масок
; исходный диапазон #94FE..#9502
; In:
;   без параметров
; Out:
;   FC08..FC0C=0, далее общий 9503
; Corrupt:
;   HL, BC, AF
; Note:
;   Код символа FC0D и настройки FC0E сохраняются
; -----------------------------------------
                ASSERT $ == #94FE
                ; очистка пяти масок с сохранением символа и настроек
Entry:          LD B, #05
                LD HL, InputState.SystemKeys
                ASSERT $ == #9503
                endmodule
                endmodule
