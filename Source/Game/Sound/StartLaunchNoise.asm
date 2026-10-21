                module Sound
                module StartLaunchNoise
; -----------------------------------------
; инициализация шума старта и общий параметризованный вход
; исходный диапазон #969B..#96B6
; In:
;   для входа Game.Sound.StartLaunchNoise.Entry регистровых параметров нет
;   для входа Game.Sound.StartLaunchNoise.DisableIrq DE и BC уже содержат параметры эффекта
; Out:
;   передача управления первому пакету шумового проигрывателя
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   вход Game.Sound.StartLaunchNoise.Entry задаёт 80 отсчётов в пакете, шаг задержки +2,
;   начальную задержку 64 и 32 пакета, при запрещённых прерываниях
;   общий Game.Sound.StepPitchSweep.SetNoisePatch записывает C в шаг периода NoiseStep, B в длину пакета NoiseSamples
;   отдельный вход HyperParams задаёт BC=#C0F0, DE=#C00C
;   вход Game.Sound.StartLaunchNoise.DisableIrq использует переданные BC/DE и также устанавливает режим 3
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #969B
Entry:          LD A, #03
                LD (SoundState.Mode), A
                DI
                LD BC, #5002
                LD DE, #4020                                                    ; D=64 задержка шумового пакета, E=32 число пакетов
                JR @Game.Sound.StepPitchSweep.SetNoisePatch

; -----------------------------------------
; настройка длинного шума перехода
; In:
;   не требуются
; Out:
;   DE=#C00C, BC=#C0F0, далее общий вход Game.Sound.StartLaunchNoise.DisableIrq
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Game.Sound.PlayLaunchSound.HyperSound вызывает этот вход перед синхронным ожиданием
;   C=#F0 уменьшает задержку на 16, B=#C0 задаёт 192 отсчёта
;   D=#C0 задаёт начальную задержку, E=12 число пакетов
;   Game.Sound.StartLaunchNoise.DisableIrq запрещает прерывания, устанавливает режим 3 и переходит в Game.Sound.StepPitchSweep.SetNoisePatch
; -----------------------------------------
HyperParams:    ; настройка длинного шума перехода
                LD BC, #C0F0
                LD DE, #C00C                                                    ; D=192 задержка шумового пакета, E=12 число пакетов
DisableIrq:     DI
                LD A, #03
                LD (SoundState.Mode), A
                JR @Game.Sound.StepPitchSweep.SetNoisePatch

                ; проверка исходного конца фрагмента
                ASSERT $ == #96B7
                endmodule
                endmodule
