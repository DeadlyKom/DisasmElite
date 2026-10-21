                module Sound
                module StepNoise
; -----------------------------------------
; воспроизведение одного пакета шумовых отсчётов из памяти
; исходный диапазон #95A6..#95CE
; In:
;   SoundState.Duration - E число пакетов, D задержка между отсчётами
;   SoundState.DataCursor - адрес следующего байта отсчёта
;   NoiseSamples - изменяемое число отсчётов в пакете
; Out:
;   SoundState.Duration/SoundState.DataCursor - обновлённое состояние звука
;   SoundState - 0 после завершения либо новый шумовой режим
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   каждый исходный байт маскируется #18 и передаётся в порт #FE
;   B получает D, цикл DJNZ задаёт задержку, значение D=0 означает 256 итераций
;   после пакета к D добавляется изменяемый операнд NoiseStep, E уменьшается
;   когда E достигает нуля, бит 7 режима выбирает завершение в Game.Sound.StepDataTone.FinishEffect либо инициализацию Game.Sound.StartExplosionNoise.Entry
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #95A6
Entry:          LD HL, (SoundState.DataCursor)
                LD DE, (SoundState.Duration)
PacketSize      EQU $ + 1                                                       ; изменяемый операнд LD C, число отсчётов шумового пакета
NextPacket:     LD C, #40
                ; чтение следующего шумового отсчёта, используются биты 3 и 4
NoiseSample:    LD A, (HL)
                AND #18
                OUT (#FE), A
                LD B, D
SampleDelay:    DJNZ SampleDelay

                INC HL
                DEC C
                JR NZ, NoiseSample                                              ; переход, если в пакете остались отсчёты

                ; расчёт нового периода пакета с изменяемым шагом NoiseStep
                LD A, D
PeriodStep      EQU $ + 1                                                       ; изменяемый операнд ADD A, шаг задержки шумового пакета
                ADD A, #00
                LD D, A
                ; обновление оставшейся длительности и адреса исходных отсчётов
                DEC E
                LD (SoundState.Duration), DE
                LD (SoundState.DataCursor), HL
                RET NZ                                                          ; выход, если число оставшихся шумовых пакетов не равно нулю

                ; проверка повторного запуска по старшему биту режима
                LD A, (SoundState.Mode)
                BIT SND_REPEAT_BIT, A
                JR Z, @Game.Sound.StepDataTone.FinishEffect                     ; переход, если бит 7 режима сброшен и требуется окончательное завершение, иначе далее Game.Sound.StartExplosionNoise.Entry без команды перехода

                ; проверка исходного конца фрагмента
                ASSERT $ == #95CF
                endmodule
                endmodule
