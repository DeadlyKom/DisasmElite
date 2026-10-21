                module Trade
                module ErasePreviousCharacter
; -----------------------------------------
; Удаление предыдущего символа ввода
; исходный диапазон #E2D5..#E2F7
; In:
;   TextPosition = колонка после введённого символа
; Out:
;   Предыдущая ячейка затёрта пробелом, X уменьшен на 1
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Сохраняет операцию Game.Text.XorCharacterScanlines.XorOpcode, временно меняет XOR на NOP и печатает пробел, затем восстанавливает
;   операцию, после RET сохранены двенадцать рабочих байтов
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E2D5
                ; возврат курсора к прошлой позиции и перезапись ячейки пробелом при временном NOP
Entry:          LD HL, TextColumn
                DEC (HL)
                PUSH HL
                LD HL, Game.Text.XorCharacterScanlines.XorOpcode
                PUSH HL
                LD A, (HL)
                PUSH AF
                LD (HL), #00
                CALL Game.Text.PrintInlineToken.Entry
                DB #20                                                          ; аргумент вызываемой процедуры из потока команд
                POP AF
                POP HL
                LD (HL), A
                POP HL
                DEC (HL)
                RET

                ; сохранённые двенадцать нулевых байтов после удаления символа
                DB #00, #00, #00, #00, #00, #00, #00, #00                       ; #E2EC..#E2F3
                DB #00, #00, #00, #00                                           ; #E2F4..#E2F7
                ; проверка исходного конца фрагмента
                ASSERT $ == #E2F8
                endmodule
                endmodule
