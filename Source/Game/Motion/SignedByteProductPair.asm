                module Motion
                module SignedByteProductPair
; -----------------------------------------
; приближённое произведение двух знако-модульных байтов
; исходный диапазон #A69D..#A6AB
; In:
;   BC, B содержит первый множитель
;   AF, A содержит второй множитель
; Out:
;   HL, H содержит знак, L модуль произведения
; Corrupt:
;   DE, BC, AF
; Note:
; Модули удваиваются перед табличным умножением Game.Wireframe.MultiplyHighByteApprox.Entry.
; Знак в H инвертирован XOR #80 согласно внутреннему формату сумматора Game.Wireframe.AddSignedByteMagnitudes.Entry.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #A69D
                ; расчёт знака и модуля произведения для скалярного сумматора
Entry:          LD C, A
                XOR B
                XOR #80
                SLA B
                SLA C
                PUSH AF
                CALL Game.Wireframe.MultiplyHighByteApprox.Entry
                POP HL
                LD L, A
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #A6AC
                endmodule
                endmodule
