                module Sound
                module StepDataTone
; -----------------------------------------
; воспроизведение пакета тона с периодом из байтов памяти
; исходный диапазон #95E7..#9623
; In:
;   SoundState.DataCursor - адрес данных периода
;   SoundState.Duration - D число оставшихся пакетов
;   ToneShift/ToneShift + 1 - изменяемая первая операция преобразования отсчёта
; Out:
;   состояние звука обновлено, завершённый запрос удалён из FlightState.SoundRequests
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   пакет содержит 100 периодов, INC L сохраняет старший байт адреса данных
;   исходные две SRL A делят отсчёт на четыре, первый сдвиг может заменяться ADD A,n
;   значения #30 и 0 поочерёдно поступают в порт #FE с одинаковыми задержками
;   общий хвост Game.Sound.StepDataTone.FinishPacket уменьшает D, Game.Sound.StepDataTone.FinishEffect обнуляет режим и XOR снимает бит запроса по индексу SoundRequest
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #95E7
Entry:          LD HL, (SoundState.DataCursor)
                LD DE, (SoundState.Duration)
NextPacket:     LD C, #64
                ; чтение данных периода с циклическим изменением младшего байта адреса
ReadPeriod:     LD A, (HL)
                INC L
                ; преобразование периода, эта пара байтов заменяется установщиками эффекта
SampleShift     EQU $                                                           ; изменяемая двухбайтовая команда преобразования отсчёта тона
                SRL A
                SRL A
                LD E, A
                LD B, A
                ; формирование первой половины звукового периода
                LD A, #30
                OUT (#FE), A
HighDelay:      DJNZ HighDelay

                ; формирование второй половины звукового периода
                LD B, E
                XOR A
                OUT (#FE), A
LowDelay:       DJNZ LowDelay

                DEC C
                JR NZ, ReadPeriod                                               ; переход, если ещё не воспроизведены все 100 периодов пакета

                ; обновление оставшегося числа пакетов
FinishPacket:   DEC D
                LD (SoundState.Duration), DE
                LD (SoundState.DataCursor), HL
                RET NZ                                                          ; выход, если число оставшихся пакетов не равно нулю

                ; завершение активного эффекта
FinishEffect:   XOR A
                LD (SoundState.Mode), A
                ; расчёт маски завершённого запроса из номера SoundRequest
                LD A, (SoundRequest)
                INC A
                LD B, A
                LD A, #80
RequestMask:    RLCA
                DJNZ RequestMask

                ; удаление завершённого запроса из битовой маски звуков
                LD HL, FlightState.SoundRequests
                XOR (HL)
                LD (HL), A
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #9624
                endmodule
                endmodule
