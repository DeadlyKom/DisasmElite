                module Universe
                module CheckSpecialSystemOrRandom
; -----------------------------------------
; особая инициализация станционного слота либо получение случайного байта
; исходный диапазон #7F64..#7F80
; In:
;   состояние системы для проверки Game.Input.CheckMissionSystem.Entry
; Out:
;   при NZ от Game.Input.CheckMissionSystem.Entry A содержит случайное значение
;   при Z от Game.Input.CheckMissionSystem.Entry настроены координаты станции и режим 4
; Corrupt:
;   HL, DE, BC, AF
; Note:
; Решение использует фактический Z от Game.Input.CheckMissionSystem.Entry, а не только совпадение координат.
; Полный путь Game.Input.CheckMissionSystem.Entry возвращает Z для Y=#5C,X=#03.
; Ранний выход при CY=0 также возвращает Z для Y=#FF, координата X тогда не проверяется.
; при Z обнуляет первые восемь байтов координат станции, задаёт её Z.SignHigh=1, Energy=#F0 и State.Mission3=4
; POP HL удаляет адрес возврата вызывающего помощника, RET выходит уровнем выше.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #7F64
                ; миссия 7+4, размещение особой станции по результату проверки системы
                ; описание в Docs/Manual.md, раздел mission-7-4
                ; проверка особой системы
Entry:          CALL Game.Input.CheckMissionSystem.Entry
                JP NZ, Game.Combat.NextRandomByte.Entry                         ; переход, если Game.Input.CheckMissionSystem.Entry вернула NZ, требуется обычный случайный байт

                ; создание специального положения станции
                LD HL, Memory.Station
                LD B, #08
ClearStation:   LD (HL), #00
                INC HL
                DJNZ ClearStation

                LD (HL), #01
                LD L, #6A
                LD (HL), #F0
                LD A, #04
                LD (State.Mission3), A
                POP HL
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #7F81
                endmodule
                endmodule
