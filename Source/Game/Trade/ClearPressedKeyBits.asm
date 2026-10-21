                module Trade
                module ClearPressedKeyBits
; -----------------------------------------
; Очистка четырёх байтов нажатий
; исходный диапазон #E205..#E211
; In:
;   Нет параметров
; Out:
;   InputState.SystemKeys..InputState.DeviceKeys=0, HL=InputState.ChartKeys, B=0, прерывания включены
; Corrupt:
;   HL, BC
; Note:
;   DI/EI защищают запись, прежнее состояние IFF не сохраняется, A и флаги сохраняются
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E205
                ; очистка четырёх байтов масок клавиш предотвращает повтор прежнего действия
Entry:          DI
                LD HL, InputState.SystemKeys
                LD B, #04
ClearKeyByte:   LD (HL), #00
                INC HL
                DJNZ ClearKeyByte

                EI
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #E212
                endmodule
                endmodule
