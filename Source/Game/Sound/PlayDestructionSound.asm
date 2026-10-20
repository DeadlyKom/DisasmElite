                module Sound
                module PlayDestructionSound
; -----------------------------------------
; синхронное воспроизведение шума разрушения и таблица эффектов
; исходный диапазон #9548..#9578
; In:
;   #FC0E - бит 7 разрешения звука
; Out:
;   #9522=0, #7128=0, прерывания разрешены
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   вызов #95CF и цикл #9551 воспроизводят шум до нулевого режима
;   общий цикл также используется звуками старта и гиперперехода
;   таблица #9561 содержит адреса #9678,#9674,#9692,#965E,#9641,#9648,#9657,#9657
;   режим прерываний вызывающего кода не сохраняется, нормальный выход выполняет EI
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #9548
Entry:          LD A, (InputState.Config)
                BIT INPUT_SND_BIT, A
                RET Z                                                           ; выход, если бит 7 настройки звука сброшен

                CALL Game.Sound.StartExplosionNoise.Entry
                ; проверка завершения синхронного звука
PlayNoise:      LD A, (SoundState.Mode)
                AND A
                JR Z, EndSound                                                  ; переход, если режим проигрывателя равен нулю

                CALL Game.Sound.StepNoise.Entry
                JR PlayNoise

EndSound:       LD (FlightState.SoundRequests), A
                EI
                RET

; -----------------------------------------
; исполняемая таблица восьми звуковых запросов
; In:
;   HL, адрес элемента выбирается диспетчером #9579
; Out:
;   переход к установщику соответствующего эффекта
; Corrupt:
;   по контракту выбранного установщика
; Note:
;   диспетчер вычисляет #9561 + 3*номер младшего установленного бита #7128
;   каждый элемент является JP, адрес вызывающего сохраняется без нового CALL
; -----------------------------------------
EffectJumps:    ; исполняемая таблица восьми звуковых запросов
                JP Game.Sound.StepPitchSweep.SlowNoise

                JP Game.Sound.StepPitchSweep.FastNoise

                JP Game.Sound.StepPitchSweep.ChainedNoise

                JP Game.Sound.StepPitchSweep.ShiftedTone

                JP Game.Sound.StepPitchSweep.FallingTone

                JP Game.Sound.StepPitchSweep.LongTone

                JP Game.Sound.StepPitchSweep.AddedTone

                JP Game.Sound.StepPitchSweep.AddedTone
                ; проверка исходного конца фрагмента
                ASSERT $ == #9579
                endmodule
                endmodule
