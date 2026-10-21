                module Travel
                module BuildPlanetCoordinateMagnitude
; -----------------------------------------
; Формирование величины из пары соседних байтов семени
; исходный диапазон #DD53..#DD5F
; In:
;   HL = первый из двух байтов, DE = прежняя позиция, BC = шаг
; Out:
;   HL+1, DE+BC, A=((старый[HL] OR новый[HL])&7)+C
; Corrupt:
;   HL, DE, AF
; Note:
;   запись результата выполняет вызывающий, после RET сохранено отдельное LD (nn), A в поле
;   FlightState.Planet + 2 * FCoordinate + FCoordinate.SignHigh с продолжением Game.Travel.BuildStationGeometry.Entry
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #DD53
                ; сбор величины координаты из соседних байтов с ограничением старших битов
Entry:          EX DE, HL
                ADD HL, BC
                EX DE, HL
                LD A, (HL)
                INC HL
                OR (HL)
                AND #07
                ADD A, C
                RET

                LD (FlightState.Planet + 2 * FCoordinate + FCoordinate.SignHigh), A ; далее Game.Travel.BuildStationGeometry.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #DD60
                endmodule
                endmodule
