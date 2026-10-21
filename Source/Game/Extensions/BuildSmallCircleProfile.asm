                module Extensions
                module BuildSmallCircleProfile
; -----------------------------------------
; подготовка строчного профиля малого силуэта
; исходный диапазон #FB03..#FB30
; смысловое имя BuildSmallCircleProfile
; In: AF — A содержит радиус, AF' — A' выбирает таблицу профиля
; Out: ProjectedVerts содержит профиль, E — радиус, D=0, B=0
; Corrupt: HL, DE, BC, AF, AF'
; При A'=0 выбирается CircleProfile, иначе SmallProfile, адрес индексируется радиусом
; Младшие три бита задают число арифметических сдвигов маски, старшие пять — исходную маску
; После ступенчатого участка повторяется последняя маска E раз
; Первый байт окончательно заменяется старшими пятью битами таблицы SmallProfile
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #FB03
                ; выбор таблицы по альтернативному аккумулятору и радиусу
Entry:          LD E, A
                LD D, #00
                LD HL, CircleProfile
                EX AF, AF'
                AND A
                JR Z, ReadProfile                                               ; переход, если A' был нулевым, использовать стандартный профиль CircleProfile

                LD HL, SmallProfile
                ; расчёт числа сдвигов и начальной пятибитной маски
ReadProfile:    ADD HL, DE
                LD A, (HL)
                AND #07
                LD B, A
                LD A, (HL)
                AND #F8
                ; создание наклонного участка профиля арифметическим сдвигом
                LD HL, ProjectedVerts
SlopeRow:       LD (HL), A
                INC HL
                SRA A
                DJNZ SlopeRow

                ; создание повторяющегося участка длиной в радиус
                LD B, E
RepeatRow:      LD (HL), A
                INC HL
                DJNZ RepeatRow

                LD HL, SmallProfile
                ADD HL, DE
                LD A, (HL)
                AND #F8
                LD (ProjectedVerts), A
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #FB31
                endmodule
                endmodule
