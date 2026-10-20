                module Economy
                module PrintNumberPadding
; -----------------------------------------
; Выравнивание числового поля пробелами или нулями
; исходный диапазон #D37D..#D3CD
; In:
;   HL = значение, AF, CY = дробный формат, D0CE = ширина, D0CC = вид дополнения
; Out:
;   Перед числом напечатано необходимое дополнение
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Порогами 10, 100, 1000, 10000 определяет число позиций, денежный ноль требует также место
;   для 0 перед точкой, при D0CC=0 печатает нули иначе пробелы, ширина меньше числа не обрезает
;   число
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D37D
                ; определение числа десятичных позиций с учётом дробного режима
Entry:          LD B, #01
                JR NC, CountDigits                                              ; переход, если входное число не помечено дробным режимом, считать обычную ширину

                PUSH HL
                AND A
                LD DE, #000A
                SBC HL, DE
                POP HL
                JR C, TwoPositions                                              ; переход, если модуль числа меньше десяти, учесть одну значащую цифру

CountDigits:    AND A
                LD DE, #000A
                CALL Game.Economy.CompareWordPreserveHL.Entry
                JR C, CheckWidth                                                ; переход, если число меньше 10, оно содержит одну десятичную цифру

                LD DE, #0064
                CALL Game.Economy.CompareWordPreserveHL.Entry
                JR C, TwoPositions                                              ; переход, если число меньше 100, оно содержит две десятичные цифры

                LD DE, #03E8
                CALL Game.Economy.CompareWordPreserveHL.Entry
                JR C, ThreeDigits                                               ; переход, если число меньше 1000, оно содержит три десятичные цифры

                LD DE, #2710
                CALL Game.Economy.CompareWordPreserveHL.Entry
                JR C, FourDigits                                                ; переход, если число меньше 10000, оно содержит четыре десятичные цифры

                INC B
FourDigits:     INC B
ThreeDigits:    INC B
TwoPositions:   INC B
CheckWidth:     LD A, (NumberWidth)
                CP B
                RET Z                                                           ; выход, если заданная ширина уже равна числу печатаемых позиций

                RET C                                                           ; выход, если заданная ширина меньше числа печатаемых позиций

                ; добивка поля до заданной ширины выбранными пробелами или нулями
                SUB B
                LD B, A
PadPosition:    PUSH BC
                LD A, (ZeroSuppress)
                AND A
                JP Z, ZeroPadding                                               ; переход, если режим дополнения D0CC равен нулю, заполнять поле нулями вместо пробелов

                LD A, #20
                JP PrintPadding

ZeroPadding:    LD A, #30
PrintPadding:   CALL Game.Text.PrintMainToken.Entry
                POP BC
                DJNZ PadPosition

                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #D3CE
                endmodule
                endmodule
