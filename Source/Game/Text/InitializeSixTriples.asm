                module Text
                module InitializeSixTriples
; -----------------------------------------
; Инициализация шести трёхбайтовых записей
; исходный диапазон #D5CB..#D5E0
; In:
;   738E..7393 = шесть старших байтов
; Out:
;   8ABA..8ACB = шесть записей 00, 00, байт
; Corrupt:
;   AF, HL', DE', BC'
; Note:
;   EXX сохраняет обычные HL/DE/BC, рабочий набор альтернативных регистров перезаписывается
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D5CB
                ; обнуление и настройка шести записей по три байта
Entry:          EXX
                LD BC, #0600
                LD DE, DistantSigns
                LD HL, DistantBodies.First.X
InitTriple:     LD A, (DE)
                INC DE
                LD (HL), C
                INC HL
                LD (HL), C
                INC HL
                LD (HL), A
                INC HL
                DJNZ InitTriple

                EXX
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #D5E1
                endmodule
                endmodule
