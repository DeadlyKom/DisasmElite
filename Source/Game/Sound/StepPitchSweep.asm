                module Sound
                module StepPitchSweep
; -----------------------------------------
; воспроизведение 15 периодов тона с изменяемой частотой
; исходный диапазон #9624..#969A
; In:
;   SoundState.Duration - D число пакетов, E текущая задержка
;   PitchStep - изменяемый член формулы нового периода
; Out:
;   E := 2*E + операнд PitchStep по модулю 256
;   SoundState.Duration и SoundState.DataCursor обновлены общим хвостом, D уменьшен
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   период представлен двумя равными задержками DJNZ между #30 и 0 в порту #FE
;   входы Game.Sound.StepPitchSweep.FallingTone/Game.Sound.StepPitchSweep.LongTone задают слагаемые #FD/#D3 и длительности 2/8
;   Game.Sound.StepPitchSweep.AddedTone/Game.Sound.StepPitchSweep.ShiftedTone настраивают табличный тон и заменяют первую операцию ToneShift
;   Game.Sound.StepPitchSweep.FastNoise/Game.Sound.StepPitchSweep.SlowNoise/Game.Sound.StepPitchSweep.ChainedNoise задают шумовые варианты, Game.Sound.StepPitchSweep.SetNoisePatch является общим установщиком
;   все установщики таблицы Game.Sound.PlayDestructionSound.EffectJumps раскрыты ниже, общие хвосты сохраняют исходные адреса
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #9624
Entry:          LD DE, (SoundState.Duration)
                ; расчёт следующей задержки, удвоение E и прибавление изменяемого операнда
NextPeriod:     LD A, E
                ADD A, A
PeriodStep      EQU $ + 1                                                       ; изменяемый операнд ADD A, шаг периода скользящего тона
                ADD A, #05
                LD E, A
                LD C, #0F
                ; создание очередного из 15 периодов пакета
BeeperPeriod:   LD A, #30
                LD B, E
                OUT (#FE), A
HighDelay:      DJNZ HighDelay

                XOR A
                LD B, E
                OUT (#FE), A
LowDelay:       DJNZ LowDelay

                DEC C
                JR NZ, BeeperPeriod                                             ; переход, если остались периоды текущего пакета

                JR @Game.Sound.StepDataTone.FinishPacket

; -----------------------------------------
; запуск короткого тона с рекурсивно изменяемым периодом
; In:
;   не требуются
; Out:
;   SoundState.Mode=1, слагаемое PitchStep=#FD, DE=#0200 перед первым пакетом
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   действующий вход элемента 4 таблицы Game.Sound.PlayDestructionSound.EffectJumps
;   период E обновляется как 2*E-3 по модулю 256, всего два пакета по 15 периодов
; -----------------------------------------
FallingTone:    ; запуск короткого тона с рекурсивно изменяемым периодом
                LD A, #FD
                LD DE, #0200
                JR StartSweep

; -----------------------------------------
; запуск восьми пакетов тона с быстрым изменением периода
; In:
;   не требуются
; Out:
;   SoundState.Mode=1, слагаемое PitchStep=#D3, DE=#0800 перед первым пакетом
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   действующий вход элемента 5 таблицы Game.Sound.PlayDestructionSound.EffectJumps
;   период обновляется как 2*E-45 по модулю 256
; -----------------------------------------
LongTone:       ; запуск восьми пакетов тона с быстрым изменением периода
                LD A, #D3
                LD DE, #0800
                ; установка слагаемого формулы периода и запуск первого пакета
StartSweep:     LD (PitchStep), A
                LD A, #01
                LD (SoundState.Mode), A
                JR NextPeriod

; -----------------------------------------
; запуск тона по отсчётам памяти с прибавлением к каждому отсчёту
; In:
;   не требуются
; Out:
;   SoundState.Mode=2, чтение начинается с #1A1A, один пакет из 100 периодов
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   действующий вход элементов 6 и 7 таблицы Game.Sound.PlayDestructionSound.EffectJumps
;   слово #10C6 заменяет первую SRL A по ToneShift командой ADD A,#10
;   вторая SRL A сохраняется, задержка равна ((отсчёт+16) mod 256)/2
; -----------------------------------------
AddedTone:      ; запуск тона по отсчётам памяти с прибавлением к каждому отсчёту
                LD A, #1A
                LD HL, #10C6
                JR StartDataTone

; -----------------------------------------
; запуск тона по четверти каждого отсчёта памяти
; In:
;   не требуются
; Out:
;   SoundState.Mode=2, чтение начинается с #031A, один пакет из 100 периодов
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   действующий вход элемента 3 таблицы Game.Sound.PlayDestructionSound.EffectJumps
;   слово #3FCB восстанавливает SRL A по ToneShift, затем выполняется ещё одна SRL A
; -----------------------------------------
ShiftedTone:    ; запуск тона по четверти каждого отсчёта памяти
                LD A, #03
                LD HL, #3FCB
                ; установка преобразования отсчёта и адреса звуковых данных
StartDataTone:  LD DE, #0100
                LD (ToneShift), HL
                LD H, A
                LD L, #1A
                LD A, #02
                LD (SoundState.Mode), A
                JP @Game.Sound.StepDataTone.NextPacket

; -----------------------------------------
; запуск шума с уменьшением задержки на 28 после пакета
; In:
;   не требуются
; Out:
;   SoundState.Mode=3, шаг задержки #E4, начало чтения NoiseRomData
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   действующий вход элемента 1 таблицы Game.Sound.PlayDestructionSound.EffectJumps
;   DE=#4008 задаёт восемь пакетов, начальная задержка D=64, в пакете 64 отсчёта
; -----------------------------------------
FastNoise:      ; запуск шума с уменьшением задержки на 28 после пакета
                LD C, #E4
                JR StartNoise

; -----------------------------------------
; запуск шума с уменьшением задержки на 2 после пакета
; In:
;   не требуются
; Out:
;   SoundState.Mode=3, шаг задержки #FE, начало чтения NoiseRomData
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   действующий вход элемента 0 таблицы Game.Sound.PlayDestructionSound.EffectJumps
;   общий установщик Game.Sound.StepPitchSweep.SetNoisePatch записывает параметры непосредственно в код шумового проигрывателя
; -----------------------------------------
SlowNoise:      ; запуск шума с уменьшением задержки на 2 после пакета
                LD C, #FE
                ; установка восьми пакетов шума, каждый пакет содержит 64 отсчёта
StartNoise:     LD A, #03
                LD (SoundState.Mode), A
NoiseLength:    LD B, #40
                LD DE, #4008                                                    ; D=64 задержка шумового пакета, E=8 число пакетов
                ; обновление параметров самомодифицируемого шумового проигрывателя
SetNoisePatch:  LD HL, NoiseRomData
                LD A, C
                LD (NoiseStep), A
                LD A, B
                LD (NoiseSamples), A
                JP @Game.Sound.StepNoise.NextPacket

; -----------------------------------------
; запуск шума с последующим переходом к шуму разрушения
; In:
;   не требуются
; Out:
;   SoundState.Mode=#83, шаг задержки +2, DE=#4008 перед первым пакетом
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   действующий вход элемента 2 таблицы Game.Sound.PlayDestructionSound.EffectJumps
;   бит 7 режима направляет окончание первого шума в Game.Sound.StartExplosionNoise.Entry вместо завершения Game.Sound.StepDataTone.FinishEffect
; -----------------------------------------
ChainedNoise:   ; запуск шума с последующим переходом к шуму разрушения
                LD A, #83
                LD (SoundState.Mode), A
                LD C, #02
                JR NoiseLength

                ; проверка исходного конца фрагмента
                ASSERT $ == #969B
                endmodule
                endmodule
