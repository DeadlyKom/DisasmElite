                module Motion
                module ScaleAxisHighByte
; -----------------------------------------
; масштабирование старшего байта компоненты оси
; исходный диапазон #9F68..#9F81
; In:
;   BC, B содержит коэффициент коррекции
;   IX, адрес слова компоненты
; Out:
;   BC, B сохраняет коэффициент
;   IX, адрес следующего слова
; Corrupt:
;   HL, DE, AF
; Note:
; масштабируется только FSignWord.SignHigh текущего слова по IX, его знак восстанавливается через перенос
; RotationState и RotationState.Pitch после RET являются рабочими углами LR и DU.
; Начальные байты #94,#8C используются демонстрационным вращением.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #9F68
                ; расчёт нового модуля с сохранением исходного знака
Entry:          LD C, (IX + FSignWord.SignHigh)
                SLA C
                CALL Game.Wireframe.MultiplyBytesApprox.Entry
                SLA H
                SLA (IX + FSignWord.SignHigh)
                RR H
                LD (IX + FSignWord.SignHigh), H
                INC IX
                INC IX
                RET

                ; данные текущих углов вращения, этот хвост не исполняется
RotationData    FRotationState {
                    #94,                                                        ; FRotationState.Roll, угол крена
                    #8C                                                         ; FRotationState.Pitch, угол тангажа
                }
                ; проверка исходного конца фрагмента
                ASSERT $ == #9F82
                endmodule
                endmodule
