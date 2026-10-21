                module Sound
                module UpdateSound
; -----------------------------------------
; выбор запроса звука и обработка одного пакета активного эффекта
; исходный диапазон #9579..#95A5
; In:
;   InputState.Config - бит 7 разрешения звука
;   SoundState.Mode - текущий режим, FlightState.SoundRequests - битовая маска запросов
; Out:
;   активный звук продолжен либо выбран младший установленный бит запроса
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   при нулевом режиме поиск RRA выбирает запрос с наименьшим номером
;   номер сохраняется в SoundRequest, адрес элемента таблицы равен Game.Sound.PlayDestructionSound.EffectJumps + номер*3
;   таблица состоит из восьми JP, передача выполняется через JP (HL)
;   режим 1 выбирает Game.Sound.StepPitchSweep.Entry, режим 2 выбирает Game.Sound.StepDataTone.Entry, остальные ненулевые режимы проваливаются в Game.Sound.StepNoise.Entry
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #9579
Entry:          LD A, (InputState.Config)
                BIT INPUT_SND_BIT, A
                RET Z                                                           ; выход, если бит 7 настройки звука сброшен

                LD A, (SoundState.Mode)
                AND A
                JR NZ, ResumeEffect                                             ; переход, если уже имеется активный режим проигрывателя

                ; проверка наличия хотя бы одного запроса
                LD A, (FlightState.SoundRequests)
                AND A
                RET Z                                                           ; выход, если маска звуковых запросов пуста

                ; поиск младшего установленного бита запроса через RRA
                LD B, #FF
FindRequest:    INC B
                RRA
                JR NC, FindRequest                                              ; переход, если очередной младший бит запроса равен нулю

                LD A, B
                LD (SoundRequest), A
                ; расчёт адреса трёхбайтового элемента таблицы переходов
                ADD A, A
                ADD A, B
                LD HL, Game.Sound.PlayDestructionSound.EffectJumps
                ADD A, L
                LD L, A
                JR NC, StartEffect                                              ; переход, если прибавление смещения таблицы не переполнило младший байт

                INC H
StartEffect:    JP (HL)

                ; проверка режима тона с изменяемым периодом
ResumeEffect:   DEC A
                JP Z, Game.Sound.StepPitchSweep.Entry                           ; переход, если активный режим равен 1

                ; проверка режима тона с периодом из данных
                DEC A
                JR Z, Game.Sound.StepDataTone.Entry                             ; переход, если активный режим равен 2, иначе далее Game.Sound.StepNoise.Entry без команды перехода

                ; проверка исходного конца фрагмента
                ASSERT $ == #95A6
                endmodule
                endmodule
