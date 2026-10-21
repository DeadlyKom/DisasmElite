                module Sound
                module PlayLaunchSound
; -----------------------------------------
; синхронный звук старта с проверкой настройки звука
; исходный диапазон #9527..#953C
; In:
;   InputState.Config - бит 7 разрешает звук
; Out:
;   завершение звука и возврат через общий цикл Game.Sound.PlayDestructionSound.PlayNoise
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   если звук запрещён, возврат выполняется до изменения проигрывателя
;   основной путь инициализирует Game.Sound.StartLaunchNoise.Entry и ждёт окончания всех пакетов
;   сохранённый вход Game.Sound.PlayLaunchSound.HyperSound повторяет проверку настройки и вызывает Game.Sound.StartLaunchNoise.HyperParams
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #9527
Entry:          LD A, (InputState.Config)
                BIT INPUT_SND_BIT, A
                RET Z                                                           ; выход, если бит 7 настройки звука сброшен

                CALL Game.Sound.StartLaunchNoise.Entry
                JR @Game.Sound.PlayDestructionSound.PlayNoise

; -----------------------------------------
; синхронный шум начала перехода после подготовки полётного состояния
; In:
;   бит 7 по InputState.Config, разрешение звука
; Out:
;   звук завершён, SoundState.Mode и FlightState.SoundRequests обнулены, прерывания включены
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   действующий вход, Game.Flight.DivideByteFractionForTunnel.FinishTunnel передаёт управление сюда через JP
;   Game.Sound.StartLaunchNoise.HyperParams задаёт параметры BC=#C0F0, DE=#C00C и запрещает прерывания
;   общий цикл Game.Sound.PlayDestructionSound.PlayNoise проигрывает шум до завершения
;   при запрете звука ранний выход сохраняет прежний режим прерываний
; -----------------------------------------
HyperSound:     ; синхронный шум начала перехода после подготовки полётного состояния
                ; проверка разрешения звука перед синхронным воспроизведением
                LD A, (InputState.Config)
                BIT INPUT_SND_BIT, A
                RET Z                                                           ; выход, если бит 7 настройки звука сброшен

                CALL Game.Sound.StartLaunchNoise.HyperParams
                JR @Game.Sound.PlayDestructionSound.PlayNoise

                ; проверка исходного конца фрагмента
                ASSERT $ == #953D
                endmodule
                endmodule
