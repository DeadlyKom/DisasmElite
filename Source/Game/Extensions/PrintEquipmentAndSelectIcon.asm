                module Extensions
                module PrintEquipmentAndSelectIcon
; -----------------------------------------
; дополнительная строка оборудования и выбор значка режима
; исходный диапазон #6EE8..#6F40
; смысловое имя PrintExtendedEquipmentAndSelectIcon
; In: #D09C — уровень оборудования, для #6F29 состояния #7103 и #FD03
; Out: печать уровня +1 и цены 33, либо HL — один из трёх 8-байтовых значков
; Corrupt: HL, DE, BC, AF по контракту числового принтера
; На стек помещается адрес #E36B, поэтому ранний RET продолжает общий экран оборудования
; Вызовы #D421/#E2BC используют встроенные байты текста и X-координаты
; Вход #6F29 при специальном режиме пишет #02 в операнд #FD0A и выбирает второй/третий значок
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #6EE8
                ; создание общего продолжения экрана на стеке
Entry:          LD HL, ClearInputGate
                PUSH HL
                CALL Game.Text.PrintInlineToken.Entry
                DB #20                                                          ; данные #6EEF..#6EEF
                ; проверка уровня дополнительного оборудования
                LD A, (State.Technology)
                CP #0E
                RET C                                                           ; выход, если уровень #D09C меньше 14, продолжить общий экран по #E36B

                ; печать уровня, названия и фиксированной цены
                INC A
                CALL Game.Economy.PrintByteInteger.Entry
                CALL Game.Trade.SetInlineTextColumn.Entry
                DB #04                                                          ; данные #6EFD..#6EFD
                CALL Game.Text.PrintInlineToken.Entry
                DB #F6                                                          ; данные #6F01..#6F01
                CALL Game.Trade.SetInlineTextColumn.Entry
                DB #16                                                          ; данные #6F05..#6F05
                LD HL, #0021
                LD D, H
                LD E, H
                CALL Game.Economy.PrintSplitCash.Entry
                JP Game.Trade.Newline.Entry
                ; три восьмибайтовых значка, выбираемые входом #6F29
ModeIcons       DB #18, #3C, #3C, #18, #3C, #24, #24, #3C                       ; первый из трёх восьмибайтовых значков режима
                DB #09, #1A, #2C, #48, #0E, #10, #08, #70                       ; данные #6F19..#6F20
                DB #41, #82, #B4, #58, #0E, #1C, #20, #1C                       ; данные #6F21..#6F28
                ; выбор одного из трёх значков по специальному режиму
SelectIcon:     LD DE, #0008
                LD HL, ModeIcons
                LD A, (FlightState.SpaceMode)
                AND A
                RET Z                                                           ; выход, если игрок находится в обычной системе, вернуть первый значок

                ; включение чередования двух наборов координат через смещение JR Z
                LD A, #02
                LD (InputViewSkip), A
                LD A, (InputPhase)
                ADD HL, DE
                RRCA
                RET NC                                                          ; выход, если младший бит #FD03 сброшен, вернуть второй значок

                ADD HL, DE
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #6F41
                endmodule
                endmodule
