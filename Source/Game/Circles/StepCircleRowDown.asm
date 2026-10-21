                module Circles
                module StepCircleRowDown
; -----------------------------------------
; переход обоих краёв окружности на строку ниже
; исходный диапазон #8E08..#8E0C
; смысловое имя StepCircleRowDown
; In: HL — правый край, E — младший байт левого края
; Out: H увеличен, при H&7=0 продолжается Game.Circles.CrossCircleCharacterRowDown.Entry
; Corrupt: AF, H
; Нелокальное завершение на нижней границе выполняется общим Game.Circles.CrossCircleCharacterRowDown.FinishHalf
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #8E08
                ; расчёт следующей строки внутри восьмистрочной полосы
Entry:          INC H
                LD A, H
                AND #07
                RET NZ                                                          ; выход, если новая строка не пересекла восьмистрочный блок, иначе далее Game.Circles.CrossCircleCharacterRowDown.Entry без команды перехода

                ; проверка исходного конца фрагмента
                ASSERT $ == #8E0D
                endmodule
                endmodule
