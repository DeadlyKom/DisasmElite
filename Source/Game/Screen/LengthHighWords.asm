                module Screen
                module LengthHighWords
; -----------------------------------------
; длина вектора по старшим словам знаковых координат
; In:
;   IX, адрес среднего байта первой координаты
; Out:
;   HL, приближённая длина в исходном масштабе
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   после чтения трёх слов удаляет их знаковые биты
;   основное нормирование и квадратный корень выполняются общим входом Game.Screen.VectorLength.Normalize
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #8315
Entry:          CALL Game.Screen.LoadVectorWords.Entry
                RES 7, H
                RES 7, D
                RES 7, B
                LD A, #01
                JR Game.Screen.VectorLength.Normalize

                ASSERT $ == #8322
                endmodule
                endmodule
