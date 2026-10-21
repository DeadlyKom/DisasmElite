                module Galaxy
                module GenerateSystemName
; -----------------------------------------
; Генерация имени планеты из трёх или четырёх слогов
; исходный диапазон #E01C..#E03C
; In:
;   GalaxyState.WorkingSeed = семя
; Out:
;   GalaxyState.GeneratedName содержит до 8 букв, первые 8 байт предварительно очищены, девятый байт не меняется,
;   семя продвинуто 4 раза
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Очищает 8 байт, бит 6 младшего байта первого слова выбирает 3 или 4 слога, при 3 слогах
;   четвёртый шаг генератора всё равно выполняется
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E01C
                ; очистка восьми байтов имени и выбор трёх или четырёх печатаемых слогов
Entry:          LD HL, GalaxyState.GeneratedName
                LD (GalaxyState.NameCursor), HL
                LD B, #08
ClearName:      LD (HL), #00
                INC HL
                DJNZ ClearName

                LD HL, (GalaxyState.WorkingSeed)
                LD A, L
                AND 1 << SEED_LONG_BIT
                AND A
                PUSH AF
                CALL Game.Galaxy.AppendSystemNameSyllable.Entry
                CALL Game.Galaxy.AppendSystemNameSyllable.Entry
                CALL Game.Galaxy.AppendSystemNameSyllable.Entry
                POP AF
                JR Z, Game.Math.NextRandom                                      ; переход, если бит выбора длины имени сброшен, перейти к последнему шагу семени без печати слога, иначе далее Game.Galaxy.AppendSystemNameSyllable.Entry без команды перехода

                ; проверка исходного конца фрагмента
                ASSERT $ == #E03D
                endmodule
                endmodule
