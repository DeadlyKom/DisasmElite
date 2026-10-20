                module Flight
                module DispatchAppendDecimalDigit
; -----------------------------------------
; Вектор присоединения десятичной цифры
; исходный диапазон #712A..#712C
; In:
;   HL адрес десятичной величины, DE, D печатаемый символ, BC, B добавляемая цифра
; Out:
;   продолжение 7130
; Corrupt:
;   HL, BC, AF
; Note:
;   Обработчик используется вводом количества E776 для второй цифры
; -----------------------------------------
                ASSERT $ == #712A
                ; переход к общему накоплению десятичного количества
Entry:          JP @Game.Flight.DispatchDeviceAndAppendDigit.AppendDigit
                ASSERT $ == #712D
                endmodule
                endmodule
