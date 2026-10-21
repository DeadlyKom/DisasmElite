                module Trade
                module TradeBeepAndPause
; -----------------------------------------
; Сигнал и пауза с кодом повторного ввода
; исходный диапазон #E832..#E83B
; In:
;   Прерывания включены
; Out:
;   A=1, CY=1
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Опциональный звук, 36 HALT, затем явный код 1 для торгового диалога
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E832
                ; после сигнала и паузы возвращается A=1 с переносом для повторного ввода
Entry:          CALL Game.Trade.OptionalBeep.Entry
                CALL Game.Trade.Wait36Interrupts.Entry
                LD A, #01
                SCF
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #E83C
                endmodule
                endmodule
