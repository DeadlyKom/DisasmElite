                module Sound
                module PlayHyperjumpSound
; -----------------------------------------
; синхронный звук гиперперехода
; исходный диапазон #953D..#9547
; In:
;   InputState.Config - бит 7 разрешения звука
; Out:
;   возврат после завершения эффекта через Game.Sound.PlayDestructionSound.PlayNoise
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   вход SFX_Play задаёт шумовые параметры BC=#C010, DE=#100A
;   общий завершающий путь обнуляет запросы FlightState.SoundRequests и выполняет EI
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #953D
Entry:          LD A, (InputState.Config)
                BIT INPUT_SND_BIT, A
                RET Z                                                           ; выход, если бит 7 настройки звука сброшен

                CALL Game.Sound.StartHyperjumpNoise.Entry
                JR @Game.Sound.PlayDestructionSound.PlayNoise

                ; проверка исходного конца фрагмента
                ASSERT $ == #9548
                endmodule
                endmodule
