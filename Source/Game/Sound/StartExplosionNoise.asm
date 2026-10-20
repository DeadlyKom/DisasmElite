                module Sound
                module StartExplosionNoise
; -----------------------------------------
; инициализация заключительного шума разрушения
; исходный диапазон #95CF..#95E6
; In:
;   нет
; Out:
;   HL=#0127, DE=#4002, AF - A=#A0
;   #9522=3, #95AE=#A0, параметры сохранены в #9523/#9525
; Corrupt:
;   HL, DE, AF
; Note:
;   два пакета по 160 отсчётов, исходный период задержки D=64
;   процедура сама не воспроизводит звук и не отключает прерывания
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #95CF
Entry:          LD A, #03
                LD (SoundState.Mode), A
                ; обновление непосредственного числа отсчётов в StepNoise
                LD A, #A0
                LD (NoiseSamples), A
                LD HL, NoiseRomData
                LD DE, #4002                                                    ; D=64 задержка шумового пакета, E=2 число пакетов
                LD (SoundState.Duration), DE
                LD (SoundState.DataCursor), HL
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #95E7
                endmodule
                endmodule
