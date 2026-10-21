                module Sound
                module PlayDestructionSound
; -----------------------------------------
; синхронное воспроизведение шума разрушения и таблица эффектов
; исходный диапазон #9548..#9578
; In:
;   InputState.Config - бит 7 разрешения звука
; Out:
;   SoundState.Mode=0, FlightState.SoundRequests=0, прерывания разрешены
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   вызов Game.Sound.StartExplosionNoise.Entry и цикл Game.Sound.PlayDestructionSound.PlayNoise воспроизводят шум до нулевого режима
;   общий цикл также используется звуками старта и гиперперехода
;   таблица Game.Sound.PlayDestructionSound.EffectJumps содержит адреса Game.Sound.StepPitchSweep.SlowNoise,Game.Sound.StepPitchSweep.FastNoise,Game.Sound.StepPitchSweep.ChainedNoise,Game.Sound.StepPitchSweep.ShiftedTone,Game.Sound.StepPitchSweep.FallingTone,Game.Sound.StepPitchSweep.LongTone,Game.Sound.StepPitchSweep.AddedTone,Game.Sound.StepPitchSweep.AddedTone
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
;   HL, адрес элемента выбирается диспетчером Game.Sound.UpdateSound.Entry
; Out:
;   переход к установщику соответствующего эффекта
; Corrupt:
;   по контракту выбранного установщика
; Note:
;   диспетчер вычисляет Game.Sound.PlayDestructionSound.EffectJumps + 3*номер младшего установленного бита FlightState.SoundRequests
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
