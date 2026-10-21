                module Trade
                module WaitForKeyCode
; -----------------------------------------
; Ожидание кода клавиши после паузы
; исходный диапазон #E1F7..#E204
; In:
;   Прерывания включены, InputState.LastKey обновляет обработчик клавиатуры
; Out:
;   A = код, отличный от FF
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Пауза Game.Trade.Wait20Interrupts.Entry длится 20 HALT, затем очищает четыре байта клавиш и опрашивает InputState.LastKey
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
