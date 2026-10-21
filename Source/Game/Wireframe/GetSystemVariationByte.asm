                module Wireframe
                module GetSystemVariationByte
; -----------------------------------------
; смешивание координаты системы и полётного параметра
; исходный диапазон #ABAF..#ABBF
; In:
;   память FlightState.RandomByte и State.SystemSeed + FSystemSeed.Y, координата системы и полётный параметр
; Out:
;   HL, адрес FlightState.RandomByte
;   AF, A содержит восьмибитную сумму
; Corrupt:
;   нет дополнительных регистров
; Note:
; State.SystemSeed + FSystemSeed.Y содержит координату системы, FlightState.RandomByte изменяемый полётный параметр.
; После RET сохранена копия короткой последовательности байтов, текущий вход её не исполняет.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #ABAF
                ; расчёт восьмибитной суммы параметров эффекта
Entry:          LD HL, FlightState.RandomByte
                LD A, (State.SystemSeed + 1)
                ADD A, (HL)
                RET

                ; сохранённые байты повторной короткой процедуры

; -----------------------------------------
; сохранённый пустой вход
; In:
;   любые регистры
; Out:
;   все регистры и флаги сохраняются
; Corrupt:
;   нет
; Note:
;   прямые входящие переходы на Game.Wireframe.GetSystemVariationByte.EmptyReturn не найдены
; -----------------------------------------
EmptyReturn:    ; сохранённый пустой вход
                RET

; -----------------------------------------
; сумма координаты Y системы и параметра движения
; In:
;   байт State.SystemSeed + FSystemSeed.Y, координата Y системы
;   байт FlightState.RandomByte, параметр цикла движения
; Out:
;   HL, FlightState.RandomByte
;   AF, A содержит сумму по модулю 256, CY при переполнении
; Corrupt:
;   HL, AF
; Note:
;   сохранённая процедура, прямые входящие переходы не найдены
;   повторяет вычисление основного входа Game.Wireframe.GetSystemVariationByte.Entry без изменения данных
; -----------------------------------------
LegacyVariation:; сумма координаты Y системы и параметра движения
                LD HL, FlightState.RandomByte
                LD A, (State.SystemSeed + 1)
                ADD A, (HL)
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #ABC0
                endmodule
                endmodule
