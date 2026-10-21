                module Extensions
                module StorePairedObjectDirections
; -----------------------------------------
; запись двух связанных троек направлений в метаданные объекта
; исходный диапазон #F92D..#F944
; смысловое имя StorePairedObjectDirections
; In: DE — две координаты, BC — C содержит общий байт, (ObjectEffects.Current) — адрес метаданных
; Out: +1..+3 получают C,D,E, +4..+6 получают C,D^1,E^1
; Corrupt: HL
; AF сохраняется, DE и BC сохраняются, байт флагов +0 остаётся прежним
; Инверсия младших битов формирует парную ориентацию для следующего расчёта
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #F92D
                ; создание пары троек в метаданных с противоположными младшими признаками
Entry:          PUSH AF
                LD HL, (ObjectEffects.Current)
                INC HL
                LD (HL), C
                INC HL
                LD (HL), D
                INC HL
                LD (HL), E
                INC HL
                LD (HL), C
                INC HL
                LD A, D
                XOR #01
                LD (HL), A
                INC HL
                LD A, E
                XOR #01
                LD (HL), A
                POP AF
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #F945
                endmodule
                endmodule
