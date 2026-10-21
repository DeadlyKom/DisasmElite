                module Galaxy
                module AdvanceGalaxySeed
; -----------------------------------------
; Выбор следующей из восьми галактик
; исходный диапазон #DF03..#DF19
; In:
;   State.Galaxy = индекс, State.GalaxySeed = исходное семя
; Out:
;   Индекс=(индекс+1)&7, каждый байт семени циклически сдвинут влево
; Corrupt:
;   HL, DE, AF
; Note:
;   Три вызова/хвоста Game.Galaxy.RotateSeedPair.Entry обрабатывают три слова, независимый RLC каждого байта сохраняет его
;   старший бит в младшем
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #DF03
                ; переход к следующей галактике и циклический сдвиг её шести байтов семени
Entry:          LD HL, State.Galaxy
                LD A, (HL)
                INC A
                AND #07
                LD (HL), A
                LD HL, State.GalaxySeed
                CALL Game.Galaxy.RotateSeedPair.Entry
                LD HL, State.GalaxySeed + FSystemSeed.GovBits
                CALL Game.Galaxy.RotateSeedPair.Entry
                LD HL, State.GalaxySeed + FSystemSeed.MixLow                    ; далее Game.Galaxy.RotateSeedPair.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #DF1A
                endmodule
                endmodule
