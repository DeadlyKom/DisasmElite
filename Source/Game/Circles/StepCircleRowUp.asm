                module Circles
                module StepCircleRowUp
; -----------------------------------------
; переход обоих краёв окружности на строку выше
; исходный диапазон #8DEE..#8DF2
; смысловое имя StepCircleRowUp
; In: HL — правый край, E — младший байт левого края
; Out: H уменьшен, при границе восьмистрочного блока продолжается Game.Circles.CrossCircleCharacterRowUp.Entry
; Corrupt: HL — H, AF
; Проверяется старое H&7, DEC H не меняет используемый аккумулятор
; Этот помощник допускает нелокальный выход через Game.Circles.CrossCircleCharacterRowDown.FinishHalf при пересечении экрана
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #8DEE
                ; расчёт предыдущей строки внутри восьмистрочной полосы
Entry:          LD A, H
                DEC H
                AND #07
                RET NZ                                                          ; выход, если старая строка не была первой в восьмистрочном блоке, иначе далее Game.Circles.CrossCircleCharacterRowUp.Entry без команды перехода

                ; проверка исходного конца фрагмента
                ASSERT $ == #8DF3
                endmodule
                endmodule
