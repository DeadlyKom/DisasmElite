                module Input
                module SetPressedKeyAssignment
; -----------------------------------------
; преобразование позиции нажатой клавиши в символ и игровую команду
; исходный диапазон #FCBA..#FCE9
; смысловое имя SetPressedKeyAssignment
; In: DE — D задаёт обратный номер ряда 8..1, E задаёт остаток клавиш 5..1
; Out: InputState.LastKey получает код символа, один байт в InputState.SystemKeys..InputState.NumberKeys дополнен маской
; Corrupt: HL
; DE, BC и AF сохраняются, включая перенос сканируемого бита
; Индекс равен (5-E)*8+D-1, он выбирает символ из KeyCharacters и пару из KeyAssignments
; Первый байт пары — смещение от InputState, второй — маска OR
; Пара с нулевой маской оставляет команду прежней, но код символа всё равно обновляется
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #FCBA
                ; сохранение сканируемого ряда и вычисление индекса (5-E)*8+D-1
Entry:          PUSH BC
                PUSH AF
                LD A, #05
                SUB E
                SLA A
                SLA A
                SLA A
                ADD A, D
                DEC A
                LD B, A
                SLA B
                LD HL, KeyCharacters
                ADD A, L
                JR NC, StoreKeyCode                                             ; переход, если индекс символа не перенёс адрес через границу страницы

                INC H
StoreKeyCode:   LD L, A
                LD A, (HL)
                LD (InputState.LastKey), A
                ; получение пары смещение/маска назначения клавиши
                LD HL, KeyAssignments
                LD A, L
                ADD A, B
                LD L, A
                LD A, (HL)
                ; обновление соответствующего байта команд через OR
                INC HL
                LD B, (HL)
                LD HL, InputState.SystemKeys
                ADD A, L
                LD L, A
                LD A, (HL)
                OR B
                LD (HL), A
                POP AF
                POP BC
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #FCEA
                endmodule
                endmodule
