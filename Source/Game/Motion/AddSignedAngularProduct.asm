                module Motion
                module AddSignedAngularProduct
; -----------------------------------------
; прибавление произведения угла и компоненты к знако-модульному байту
; исходный диапазон #A0FD..#A126
; In:
;   DE, D содержит изменяемую компоненту
;   BC, B содержит множимую компоненту, C коэффициент
;   AF, A содержит знак коэффициента
; Out:
;   AF, A содержит новую компоненту
; Corrupt:
;   HL, DE, BC
; Note:
; Game.Wireframe.MultiplyHighByteApprox.Entry вычисляет приближённый старший байт произведения по таблице квадратов.
; Модули удваиваются, переполнение суммы насыщается до #FF.
; Последний RRA возвращает семибитный модуль и знак.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #A0FD
                ; расчёт модуля произведения с сохранением знака
Entry:          PUSH DE
                XOR B
                SLA B
                RES 7, C
                LD E, A
                CALL Game.Wireframe.MultiplyHighByteApprox.Entry
                POP BC
                LD C, A
                LD A, E
                XOR B
                SLA B
                ; проверка знаков перед сложением
                RR E
                SLA C
                RLA
                LD A, B
                JR C, SubtractTerms                                             ; переход, если знаки исходной компоненты и произведения различаются

                ADD A, C
                JR NC, PackResult                                               ; переход, если сумма удвоенных модулей помещается в байт

                LD A, #FF
                JR PackResult

                ; расчёт разности модулей при разных знаках
SubtractTerms:  SUB C
                JR NC, PackResult                                               ; переход, если исходный модуль не меньше добавляемого и знак сохраняется

                NEG
                RL E
PackResult:     RL E
                RRA
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #A127
                endmodule
                endmodule
