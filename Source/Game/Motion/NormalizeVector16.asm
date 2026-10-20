                module Motion
                module NormalizeVector16
; -----------------------------------------
; нормализация вектора и расчёт его приближённой длины
; исходный диапазон #9E73..#9E97
; In:
;   IX, адрес трёх знако-модульных слов
; Out:
;   DE, приближённая длина
;   IX, исходный адрес, вектор по нему нормализован
; Corrupt:
;   HL, BC, AF
; Note:
; Знак хранится в бите 15 каждого слова. Квадраты, их сумма и корень используют исходные приближения игры.
; Сумма ограничена 16 битами, отдельной обработки нулевого вектора нет.
; После получения длины каждое слово делится на неё и записывается обратно.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #9E73
                ; расчёт суммы квадратов трёх компонент
Entry:          PUSH IX
                CALL Game.Motion.SquareVectorComponent.Entry
                PUSH HL
                CALL Game.Motion.SquareVectorComponent.Entry
                PUSH HL
                CALL Game.Motion.SquareVectorComponent.Entry
                POP DE
                ADD HL, DE
                POP DE
                ADD HL, DE
                POP IX
                CALL Game.Math.SquareRoot
                ; расчёт длины и переход к нормализации компонент
                EX DE, HL
                PUSH IX
                CALL Game.Motion.DivideVectorComponent.Entry
                CALL Game.Motion.DivideVectorComponent.Entry
                CALL Game.Motion.DivideVectorComponent.Entry
                POP IX
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #9E98
                endmodule
                endmodule
