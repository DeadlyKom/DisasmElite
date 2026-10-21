                module Motion
                module TransformNormalWithObjectCoordinate
; -----------------------------------------
; преобразование нормали с добавлением координаты объекта
; исходный диапазон #BDB4..#BDFF
; In:
;   IX, данные для RotateCrdN
;   IY, модель и контекст преобразования
;   стек, под адресом возврата лежит указатель трёхбайтовой координаты
; Out:
;   HL, преобразованная знако-модульная координата
;   AF, A содержит преобразованную компоненту нормали
;   стек, вложенный указатель продвинут на 3 байта
; Corrupt:
;   DE, BC
; Note:
; Внутренний помощник цикла Game.Objects.ComputeFaceVisibility.Entry, обычного CALL без дополнительного слова на стеке недостаточно.
; EX (SP),IX временно извлекает координату объекта из стека.
; Байт FaceState.Scale задаёт уменьшение нормали перед знаковым сложением с координатой.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #BDB4
                ; преобразование нормали и извлечение координаты из стека
Entry:          CALL Game.Wireframe.RotateCoordinateAndCacheProducts.Entry
                POP BC
                EX (SP), IX
                LD E, (IX + FCoordinate.Fraction)
                LD D, (IX + FCoordinate.Low)
                LD A, (IX + FCoordinate.SignHigh)
                INC IX
                INC IX
                INC IX
                EX (SP), IX
                PUSH BC
                LD C, A
                LD A, (FaceState.Scale)
                SLA L
                PUSH HL
                LD B, A
                INC B
ScaleNormal:    SRL L
                DJNZ ScaleNormal

                ; проверка знаков перед сложением
                RL L
                LD A, C
                XOR H
                SLA H
                RLA
                JR C, SubtractNormal                                            ; переход, если знаки координаты и добавляемой нормали различаются

                ADD HL, DE
                JR PackCoordinate

                ; расчёт разности модулей и знака
SubtractNormal: EX DE, HL
                AND A
                SBC HL, DE
                JR NC, PackCoordinate                                           ; переход, если модуль координаты не меньше модуля нормали

                ADD HL, DE
                EX DE, HL
                AND A
                SBC HL, DE
                LD A, C
                XOR #80
                LD C, A
                ; упаковка координаты и возврат компоненты нормали
PackCoordinate: SLA C
                RR H
                RR L
                POP DE
                LD A, E
                RL D
                RRA
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #BE00
                endmodule
                endmodule
