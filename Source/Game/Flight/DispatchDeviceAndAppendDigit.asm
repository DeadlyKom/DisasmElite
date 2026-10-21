                module Flight
                module DispatchDeviceAndAppendDigit
; -----------------------------------------
; Вектор атрибутов приборов и ввод второй цифры
; исходный диапазон #712D..#713B
; In:
;   для Game.Flight.DispatchDeviceAndAppendDigit.Entry состояние приборов, для Game.Flight.DispatchDeviceAndAppendDigit.AppendDigit HL=количество, B=цифра, D=символ
; Out:
;   Game.Flight.DispatchDeviceAndAppendDigit.AppendDigit записывает 10*(HL)+B по модулю 256 и печатает D
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Game.Flight.DispatchDeviceAndAppendDigit.AppendDigit строит 10*n как 8*n+2*n, затем прибавляет очередную цифру
; -----------------------------------------
                ASSERT $ == #712D
                ; основной вход настраивает цвета приборов
Entry:          JP Game.Scanner.SetCockpitDeviceAttributes.Entry

                ; отдельный вход рассчитывает 10*старое+B по модулю 256
AppendDigit:    LD A, (HL)
                ADD A, A
                LD C, A
                ADD A, A
                ADD A, A
                ADD A, C
                ADD A, B
                LD (HL), A
                ; вывод принятой цифры, её экранный код передан в D
                LD A, D
                JP Game.Interface.DispatchTextToken.Entry

                ASSERT $ == #713C
                endmodule
                endmodule
