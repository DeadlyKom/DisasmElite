                module Wireframe
                module MultiplyClippingDistance
; -----------------------------------------
; умножение расстояния до границы на коэффициент 8.8
; исходный диапазон #B286..#B29E
; In:
;   HL, неотрицательный коэффициент в формате 8.8
;   AF, A содержит расстояние, входной перенос сброшен
; Out:
;   DE, исходное значение
;   AF, A содержит старший байт произведения либо #FF при переполнении
; Corrupt:
;   HL
; Note:
; Двоичное умножение суммирует выбранные сдвинутые части HL в DE.
; OverflowSkip содержит CP #7A, его второй байт является LD A,D при входе ProductHigh.
; Переполнение идёт через CP и сохраняет A=#FF, обычное завершение входит на LD A,D.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #B286
                ; расчёт произведения коэффициента и расстояния до границы
Entry:          PUSH DE
                LD DE, #0000
                JR MultiplyBit

CheckBits:      AND A
                JR Z, ProductHigh                                               ; переход, если оставшиеся биты расстояния равны нулю

MultiplyBit:    RRA
                JR NC, ShiftProduct                                             ; переход, если текущий бит расстояния равен нулю

                EX DE, HL
                ADD HL, DE
                JR C, Saturate                                                  ; переход, если накопленная сумма произведения переполнилась

                EX DE, HL
ShiftProduct:   ADD HL, HL
                JR CheckBits

                ; насыщение до #FF, CP поглощает байт обычного входа ProductHigh и сохраняет A
Saturate:       SBC A, A
OverflowSkip:   CP #7A
ProductHigh     EQU OverflowSkip + 1                                            ; вход LD A,D во второй байт инструкции CP
                POP DE
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #B29F
                endmodule
                endmodule
