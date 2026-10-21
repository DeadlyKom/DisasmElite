                module Extensions
                module FillBackwardAndCountDemo
; -----------------------------------------
; обратное заполнение буфера и учёт завершений демонстрации
; исходный диапазон #5E36..#5E77
; смысловое имя FillBackwardAndCountDemo
; In: HL — старшая часть конца буфера, D — младшая часть, A — половина длины
; Out: HL восстанавливается уже с L=D, A=(CircleState.DirectionDown), Z соответствует этому байту
; Corrupt: HL, AF, DE и BC сохраняются при ненулевой длине
; Заполняются 2*A байтов назад от HL-1 значением (CircleFillWord)
; Независимый вход Game.Extensions.FillBackwardAndCountDemo.CountDemo обнуляет флаг LaunchPending и увеличивает слово LaunchCount, если флаг был ненулевым
; затем выполняется хвостовой переход к Game.Screen.DispatchMenu.Entry, после него сохранены два восьмибайтовых знака
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #5E36
                ; расчёт конца и удвоенной длины обратного заполнения
Entry:          LD L, D
                ADD A, A
                JR Z, ReturnState                                               ; переход, если удвоенная длина равна нулю, заполнение не требуется

                ; сохранение рабочих регистров перед размножением одного байта
                PUSH BC
                PUSH DE
                PUSH HL
                LD C, A
                LD B, #00
                LD A, (CircleFillWord)
                DEC HL
                LD (HL), A
                DEC C
                JR Z, RestoreRegs                                               ; переход, если единственный байт уже записан, восстановить регистры

                LD D, H
                LD E, L
                DEC DE
                LDDR
RestoreRegs:    POP HL
                POP DE
                POP BC
                ; проверка состояния результата в CircleState.DirectionDown после восстановления регистров
ReturnState:    LD A, (CircleState.DirectionDown)
                AND A
                RET

                ; проверка и сброс признака завершения демонстрационного такта
CountDemo:      LD HL, LaunchPending
                INC (HL)
                DEC (HL)
                LD (HL), #00
                JR Z, ShowMenu                                                  ; переход, если флаг демонстрации был нулевым, не увеличивать счётчик

                ; увеличение 16-битного счётчика завершений
                LD HL, (LaunchCount)
                INC HL
                LD (LaunchCount), HL
ShowMenu:       JP Game.Screen.DispatchMenu.Entry

                ; два дополнительных знака по восемь строк
                DB #00, #7E, #42, #06, #08, #00, #08, #00                       ; данные #5E68..#5E6F
                DB #00, #00, #00, #00, #00, #00, #00, #FF                       ; данные #5E70..#5E77
                ; проверка исходного конца фрагмента
                ASSERT $ == #5E78
                endmodule
                endmodule
