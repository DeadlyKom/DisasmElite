                module Galaxy
                module AppendSystemNameSyllable
; -----------------------------------------
; Добавление слога в создаваемое имя
; исходный диапазон #E03D..#E062
; In:
;   GalaxyState.WorkingSeed + FSystemSeed.Syllable = источник индекса, GalaxyState.NameCursor = выходной указатель
; Out:
;   В имя добавлено 0..2 символа, затем один шаг NextRandom
; Corrupt:
;   HL, DE, AF
; Note:
;   Индекс GalaxyState.WorkingSeed + FSystemSeed.Syllable AND31, нулевой индекс пропускает слог, таблица NameSyllables по 2 байта, второй символ 3F
;   означает отсутствие второй буквы, GalaxyState.NameCursor обновляется
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E03D
                ; индекс слога берётся из пяти младших битов семени, нулевой индекс пропускается
Entry:          LD HL, (GalaxyState.WorkingSeed + FSystemSeed.MixLow)
                LD A, H
                AND SEED_SYLL_MASK
                AND A
                JR Z, Game.Math.NextRandom                                      ; переход, если индекс слога нулевой, пропустить его и перейти к следующему семени

                LD HL, NameSyllables
                ADD A, A
                LD D, #00
                LD E, A
                ADD HL, DE
                LD A, (HL)
                INC HL
                PUSH HL
                LD HL, (GalaxyState.NameCursor)
                LD (HL), A
                INC HL
                EX DE, HL
                POP HL
                LD A, (HL)
                EX DE, HL
                CP #3F
                JR Z, StoreCursor                                               ; переход, если символ слога равен заполнителю ?, не включать его в имя

                LD (HL), A
                INC HL
StoreCursor:    LD (GalaxyState.NameCursor), HL                                 ; далее Game.Math.NextRandom без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #E063
                endmodule
                endmodule
