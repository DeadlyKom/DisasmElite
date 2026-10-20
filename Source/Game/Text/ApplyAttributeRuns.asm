                module Text
                module ApplyAttributeRuns
; -----------------------------------------
; Установка атрибутов по компактному списку строк
; исходный диапазон #D568..#D594
; In:
;   DE = таблица команд
; Out:
;   Выбранные участки атрибутов равны 5, байты 5822/5823 равны 7
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Начало 5841, старшие 5 бит команды задают длину заливки, младшие 3 бита число строк до
;   следующего участка, нулевой шаг заканчивает список, длина 0 передаётся DJNZ как 256
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D568
                ; чтение компактных атрибутных серий и переход по символьным строкам Spectrum
Entry:          LD HL, Memory.Attributes + 2 * 32 + 1
ReadRun:        LD A, (DE)
                INC DE
                PUSH AF
                AND #F8
                RRCA
                RRCA
                RRCA
                LD B, A
                PUSH HL
                LD A, #05
                CALL Game.Text.FillBytes.Entry
                POP HL
                POP AF
                AND #07
                JR Z, FinishRuns                                                ; переход, если младшие три бита команды задают нулевой шаг, завершить список

                LD B, A
AdvanceRow:     LD A, #20
                ADD A, L
                LD L, A
                JR NC, CountRows                                                ; переход, если прибавление ширины строки не переполнило L, H не изменяется

                INC H
CountRows:      DJNZ AdvanceRow

                JR ReadRun

FinishRuns:     LD HL, Memory.Attributes + 32 + 2
                LD A, #07
                LD (HL), A
                INC HL
                LD (HL), A
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #D595
                endmodule
                endmodule
