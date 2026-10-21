                module Wireframe
                module RotateCoordinateAndCacheProducts
; -----------------------------------------
; вычисление одной компоненты повёрнутого вектора и кэширование произведений
; исходный диапазон #AC01..#AC68
; In:
;   IX, три байта модулей координат
;   IY, строка матрицы из трёх слов
;   память VertexFlags.Current, признаки знаков координат
; Out:
;   HL, знако-модульная сумма
;   IY, следующая строка матрицы, прибавлено 6
;   память IY вх + FMatrix3, три слова кэшированных произведений
; Corrupt:
;   DE, BC, AF
; Note:
; Матрица хранит значимые старшие байты в нечётных позициях строки.
; Каждое произведение получает знак из XOR признака координаты и элемента матрицы.
; Кэш позволяет обработать симметричную вершину без повторных умножений.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #AC01
                ; расчёт первого произведения и его знака
Entry:          LD B, (IX + FVector3.X)
                LD C, (IY + FAxis.X + FSignWord.SignHigh)
                RES 7, C
                CALL Game.Wireframe.MultiplyHighByteApprox.Entry
                LD L, A
                LD A, (VertexFlags.Current)
                XOR (IY + FAxis.X + FSignWord.SignHigh)
                AND #80
                LD H, A
                LD (IY + FMatrix3 + FAxis.X + FSignWord.Low), L
                LD (IY + FMatrix3 + FAxis.X + FSignWord.SignHigh), H
                EX DE, HL
                LD B, (IX + FVector3.Y)
                LD C, (IY + FAxis.Y + FSignWord.SignHigh)
                RES 7, C
                PUSH DE
                CALL Game.Wireframe.MultiplyHighByteApprox.Entry
                POP DE
                LD L, A
                LD A, (VertexFlags.Current)
                RLA
                XOR (IY + FAxis.Y + FSignWord.SignHigh)
                AND #80
                LD H, A
                LD (IY + FMatrix3 + FAxis.Y + FSignWord.Low), L
                LD (IY + FMatrix3 + FAxis.Y + FSignWord.SignHigh), H
                CALL Game.Wireframe.AddSignedByteMagnitudes.Entry
                LD L, A
                EX DE, HL
                LD B, (IX + FVector3.Z)
                LD C, (IY + FAxis.Z + FSignWord.SignHigh)
                RES 7, C
                PUSH DE
                CALL Game.Wireframe.MultiplyHighByteApprox.Entry
                POP DE
                LD L, A
                LD A, (VertexFlags.Current)
                RLA
                RLA
                XOR (IY + FAxis.Z + FSignWord.SignHigh)
                AND #80
                LD H, A
                LD (IY + FMatrix3 + FAxis.Z + FSignWord.Low), L
                LD (IY + FMatrix3 + FAxis.Z + FSignWord.SignHigh), H
                CALL Game.Wireframe.AddSignedByteMagnitudes.Entry
                LD L, A
                LD DE, #0006
                ADD IY, DE
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #AC69
                endmodule
                endmodule
