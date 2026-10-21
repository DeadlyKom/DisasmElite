                module Motion
                module SquareVectorComponent
; -----------------------------------------
; приближённый квадрат одной знако-модульной компоненты
; исходный диапазон #9E98..#9ECE
; In:
;   IX, адрес компоненты
; Out:
;   HL, старшие 16 бит приближённого квадрата
;   IX, адрес следующего слова
; Corrupt:
;   DE, BC, AF
; Note:
; Складываются квадраты отдельных байтов и удвоенное перекрёстное произведение.
; Таблицы Game.Data.SquareTables.Entry/Game.Data.SquareTables.Entry + #0100 содержат младшие и старшие байты квадратов.
; Game.Wireframe.MultiplyBytesApprox.Entry теряет min(B,C), если множители разной чётности, поэтому квадрат также приближённый.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #9E98
                ; чтение модуля и сохранение указателя компоненты
Entry:          LD B, (IX + FSignWord.SignHigh)
                LD C, (IX + FSignWord.Low)
                RES 7, B
                PUSH IX
                LD IX, #0000
                CALL Game.Wireframe.MultiplyBytesApprox.Entry
                XOR A
                ; расчёт перекрёстного произведения двух байтов
                LD D, A
                ADD HL, HL
                RL D
                LD E, H
                ADD IX, DE
                LD H, L
                LD L, A
                ; добавление табличных квадратов старшего и младшего байтов
                PUSH HL
                LD H, #BE
                LD L, B
                LD E, (HL)
                INC H
                LD D, (HL)
                DEC H
                ADD IX, DE
                LD L, C
                LD E, (HL)
                INC H
                LD D, (HL)
                POP HL
                ADD HL, DE
                JR NC, RestoreVector                                            ; переход, если младшие части не создают перенос в старшую половину квадрата

                INC IX
RestoreVector:  EX (SP), IX
                POP HL
                INC IX
                INC IX
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #9ECF
                endmodule
                endmodule
