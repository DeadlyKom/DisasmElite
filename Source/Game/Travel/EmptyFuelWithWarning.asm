                module Travel
                module EmptyFuelWithWarning
; -----------------------------------------
; Обнуление топлива с постановкой предупреждения
; исходный диапазон #DE97..#DEA1
; In:
;   State.Fuel = текущий запас
; Out:
;   При ненулевом запасе бит 7 FlightEvents + 9 * FFlightEvent + FFlightEvent.ColumnFlags установлен и топливо обнулено
; Corrupt:
;   HL, BC, AF
; Note:
;   Уже пустой бак возвращается без изменений, иначе продолжение через Game.Travel.SetFuelAndGauge.Entry синхронизирует
;   прибор
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #DE97
                ; потеря ненулевого топлива создаёт отдельное предупреждение перед обнулением
Entry:          LD A, (State.Fuel)
                AND A
                RET Z                                                           ; выход, если топливо уже равно нулю, предупреждение не требуется

                LD HL, FlightEvents + 9 * FFlightEvent
                SET EVENT_WAIT_BIT, (HL)
                XOR A                                                           ; далее Game.Travel.SetFuelAndGauge.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #DEA2
                endmodule
                endmodule
