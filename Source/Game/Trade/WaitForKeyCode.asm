                module Trade
                module WaitForKeyCode
; -----------------------------------------
; Ожидание кода клавиши после паузы
; исходный диапазон #E1F7..#E204
; In:
;   Прерывания включены, FC0D обновляет обработчик клавиатуры
; Out:
;   A = код, отличный от FF
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Пауза E35A длится 20 HALT, затем очищает четыре байта клавиш и опрашивает FC0D
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E1F7
                ; пауза и сброс старых клавиш предшествуют ожиданию нового кода от обработчика ввода
Entry:          CALL Game.Trade.Wait20Interrupts.Entry
                CALL Game.Trade.ClearPressedKeyBits.Entry
AwaitKey:       LD A, (InputState.LastKey)
                CP #FF
                JR Z, AwaitKey                                                  ; переход, если код клавиши равен FF, продолжить ожидание нажатия

                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #E205
                endmodule
                endmodule
