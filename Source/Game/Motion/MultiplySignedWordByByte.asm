                module Motion
                module MultiplySignedWordByByte
; -----------------------------------------
; приближённое произведение знако-модульного слова на байт
; исходный диапазон #BD95..#BDB3
; In:
;   DE, E содержит старший байт первого множителя
;   BC, C содержит младший байт первого множителя
;   AF, A содержит второй множитель
; Out:
;   HL, знако-модульный результат в масштабе базиса
; Corrupt:
;   DE, BC, AF
; Note:
; Сначала вычисляется старший вклад младшего байта, затем произведение старшего байта.
; Game.Wireframe.MultiplyHighByteApprox.Entry и Game.Wireframe.MultiplyBytesApprox.Entry используют четверть-квадраты с усечением, сохраняется исходная погрешность.
; Последние вращения упаковывают знак в бит 15.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #BD95
                ; расчёт знака и старшего вклада младшей части
Entry:          LD B, A
                SLA B
                AND #80
                XOR E
                LD E, A
                CALL Game.Wireframe.MultiplyHighByteApprox.Entry
                LD D, E
                LD E, A
                LD C, D
                RES 7, C
                PUSH DE
                CALL Game.Wireframe.MultiplyBytesApprox.Entry
                POP DE
                LD A, D
                LD D, #00
                ADD HL, DE
                ADD HL, HL
                RLA
                RR H
                RR L
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #BDB4
                endmodule
                endmodule
