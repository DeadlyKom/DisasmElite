                module Circles
                module IntegerCircleCathetus
; -----------------------------------------
; целочисленный катет по радиусу и смещению
; исходный диапазон #8ACD..#8AF6
; смысловое имя IntegerCircleCathetus
; In: DE — D содержит радиус, AF — A содержит смещение и C входной заём
; Out: A=floor(sqrt((D²-A²-C) mod 65536)), Z=1, C=1, #8625 — подкоренное слово
; Corrupt: AF и #8625/#8626, HL/DE/BC сохраняются
; Square сохраняет перенос, поэтому первое SBC учитывает входной C, при C=0 получается обычный катет
; Затем восемь раз проверяется очередной бит корня, пробные ADD A,B не переполняются
; Пробный бит начинается с#80 и сдвигается до 1, слишком большой квадрат отменяет добавленный бит
; Перенос последнего SRL B завершает поиск после проверки младшего разряда
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #8ACD
                ; расчёт квадрата катета с сохранением входных регистров
Entry:          PUSH BC
                PUSH DE
                PUSH HL
                PUSH AF
                LD A, D
                CALL Game.Math.Square
                LD H, D
                LD L, E
                POP AF
                CALL Game.Math.Square
                SBC HL, DE
                LD B, #80
                XOR A
                LD (CircleState.Radicand), HL
                ; проверка очередного пробного бита целочисленного квадратного корня
TryRootBit:     LD HL, (CircleState.Radicand)
                ADD A, B
                CALL Game.Math.Square
                SBC HL, DE
                JR NC, NextRootBit                                              ; переход, если квадрат пробного корня не больше исходного значения, сохранить пробный бит

                SUB B
                ; переход к следующему младшему пробному биту
NextRootBit:    SRL B
                JR NC, TryRootBit                                               ; переход, если младший пробный бит ещё не обработан, перейти к следующему

                POP HL
                POP DE
                POP BC
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #8AF7
                endmodule
                endmodule
