                module Scanner
                module FillCockpitAttributePanel
; -----------------------------------------
; Заливка панели атрибутов размером пять на семь
; исходный диапазон #9995..#99A3
; In:
;   HL левый верх, DE добавка после пяти байтов, BC, C атрибут
; Out:
;   35 байт записаны, HL сдвинут на 7*(5+DE)
; Corrupt:
;   HL, BC, AF
; Note:
;   Штатный DE=27, поэтому экранный шаг составляет 32 байта, C сохраняется
;   CockpitBlink отдельный счётчик мигания аварийного индикатора
; -----------------------------------------
                ASSERT $ == #9995
                ; семь строк по пять атрибутов с шагом 5+DE
Entry:          LD B, #07
FillPanelRow:   PUSH BC
                LD B, #05
FillPanelByte:  LD (HL), C
                INC HL
                DJNZ FillPanelByte

                POP BC
                ADD HL, DE
                DJNZ FillPanelRow

                RET

                ; счётчик мигания, бит 1 выбирает красную фазу специального сигнала 63
BlinkCounter    DB #00                                                          ; счётчик мигания аварийного индикатора, бит 1 выбирает красную фазу
                ASSERT $ == #99A4
                endmodule
                endmodule
