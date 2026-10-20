                module Wireframe
                module CorrectYAxisComponent
; -----------------------------------------
; коррекция одной компоненты Y для ортогональности к X
; исходный диапазон #AE8A..#AECB
; In:
;   DE, E содержит знако-модульную взаимную проекцию осей
;   IX, слово компоненты X
;   IY, слово компоненты Y
; Out:
;   DE, E сохраняет коэффициент
;   IX, следующая компонента X
;   IY, следующая компонента Y
; Corrupt:
;   HL, BC, AF
; Note:
; Меняются только старшие байты Y, младшая точность базиса сохраняется.
; Произведение коэффициента и X прибавляется по знакам с насыщением переполнения.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #AE8A
                ; расчёт величины и знака корректирующего произведения
Entry:          LD C, (IX + FSignWord.SignHigh)
                LD B, E
                SLA B
                SLA C
                CALL Game.Wireframe.MultiplyHighByteApprox.Entry
                LD C, A
                LD A, E
                XOR (IX + FSignWord.SignHigh)
                RLA
                RR C
                LD B, (IY + FSignWord.SignHigh)
                ; проверка знаков и расчёт новой компоненты Y
                LD A, B
                XOR C
                SLA C
                RL H
                SLA B
                RL H
                RLA
                LD A, B
                JR C, SubtractTerm                                              ; переход, если знаки компоненты Y и корректирующего произведения различаются

                ADD A, C
                JR NC, PackComponent                                            ; переход, если сумма модулей не переполнилась

                LD A, #FF
                JP PackComponent

SubtractTerm:   SUB C
                JR NC, PackComponent                                            ; переход, если модуль Y не меньше корректирующего произведения

                NEG
                RR H
                ; упаковка результата и переход к следующим компонентам
PackComponent:  RR H
                RRA
                LD (IY + FSignWord.SignHigh), A
                INC IX
                INC IX
                INC IY
                INC IY
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #AECC
                endmodule
                endmodule
