                module Objects
                module DotProduct16By8
; -----------------------------------------
; масштабированное скалярное произведение 16-битного и 8-битного векторов
; исходный диапазон #BD5F..#BD94
; In:
;   IX - три знаковых восьмибитных компоненты
;   IY - три знаковых 16-битных компоненты
; Out:
;   HL - половина суммы трёх произведений в формате знак и модуль
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   каждая пара перемножается через #BD95, промежуточные результаты сохраняются в стеке
;   первое AddSigned делит сумму пополам, ADC HL,HL возвращает масштаб и отброшенный бит
;   последнее AddSigned делит итоговую сумму пополам, знак берётся из преобладающего модуля
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #BD5F
                ; расчёт первого произведения компонент векторов
Entry:          LD E, (IY+FAxis.X+FSignWord.SignHigh)
                LD C, (IY+FAxis.X+FSignWord.Low)
                LD A, (IX+FVector3.X)
                CALL Game.Motion.MultiplySignedWordByByte.Entry
                PUSH HL
                ; расчёт второго произведения компонент векторов
                LD E, (IY+FAxis.Y+FSignWord.SignHigh)
                LD C, (IY+FAxis.Y+FSignWord.Low)
                LD A, (IX+FVector3.Y)
                CALL Game.Motion.MultiplySignedWordByByte.Entry
                PUSH HL
                ; расчёт третьего произведения компонент векторов
                LD E, (IY+FAxis.Z+FSignWord.SignHigh)
                LD C, (IY+FAxis.Z+FSignWord.Low)
                LD A, (IX+FVector3.Z)
                CALL Game.Motion.MultiplySignedWordByByte.Entry
                ; суммирование знаковых результатов с восстановлением масштаба и знака
                POP DE
                CALL Game.Math.AddSigned
                ADC HL, HL
                BIT 7, B
                JR Z, AddLastAxis                                               ; переход, если после первого сложения знак в B не установлен

                SET 7, H
AddLastAxis:    POP DE
                JP Game.Math.AddSigned
                ; проверка исходного конца фрагмента
                ASSERT $ == #BD95
                endmodule
                endmodule
