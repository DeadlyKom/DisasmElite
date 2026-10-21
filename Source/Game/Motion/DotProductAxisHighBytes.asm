                module Motion
                module DotProductAxisHighBytes
; -----------------------------------------
; приближённое скалярное произведение по старшим байтам векторов
; исходный диапазон #A6AC..#A6DE
; In:
;   IX, первый вектор из трёх слов
;   IY, второй вектор из трёх слов
; Out:
;   AF, A содержит знако-модульный результат
; Corrupt:
;   HL, DE, BC
; Note:
; Используются только байты +1,+3,+5, указатели сохраняются.
; Три произведения суммируются с насыщением модуля до #FF, затем упаковываются в байт.
; После RET расположен рабочий проекционный радиус ProjectedRadius.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #A6AC
                ; расчёт произведений соответствующих компонент
Entry:          LD B, (IX + FAxis.X + FSignWord.SignHigh)
                LD A, (IY + FAxis.X + FSignWord.SignHigh)
                CALL Game.Motion.SignedByteProductPair.Entry
                PUSH HL
                LD B, (IX + FAxis.Y + FSignWord.SignHigh)
                LD A, (IY + FAxis.Y + FSignWord.SignHigh)
                CALL Game.Motion.SignedByteProductPair.Entry
                PUSH HL
                LD B, (IX + FAxis.Z + FSignWord.SignHigh)
                LD A, (IY + FAxis.Z + FSignWord.SignHigh)
                CALL Game.Motion.SignedByteProductPair.Entry
                POP DE
                CALL Game.Wireframe.AddSignedByteMagnitudes.Entry
                JR NC, AddThirdTerm                                             ; переход, если сумма первых двух произведений не переполнилась

                LD A, #FF
AddThirdTerm:   POP DE
                LD L, A
                CALL Game.Wireframe.AddSignedByteMagnitudes.Entry
                JR NC, PackProduct                                              ; переход, если итоговая сумма трёх произведений не переполнилась

                LD A, #FF
PackProduct:    RL H
                RRA
                RET

                ; данные проекционного радиуса, начальное значение 40
RadiusData      EQU $                                                           ; начало сохранённых рабочих данных, исходное размещение
.Radius         DB #28                                                          ; экранный радиус объекта после деления на глубину
                ; проверка исходного конца фрагмента
                ASSERT $ == #A6DF
                endmodule
                endmodule
