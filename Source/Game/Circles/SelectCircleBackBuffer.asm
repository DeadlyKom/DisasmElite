                module Circles
                module SelectCircleBackBuffer
; -----------------------------------------
; переключение построителя окружности на экранный буфер
; исходный диапазон #8F74..#8F87
; смысловое имя SelectCircleBackBuffer
; In: нет
; Out: подготовлены границы #C0..#CF, HL=#FCCB, A=#D0, далее выполняется#8F88
; Corrupt: HL, AF
; #FCCB даёт байты CB FC, то есть SET7,H, в трёх местах вычисления адреса
; Меняются также операнды самого патчера, чтобы его последующие записи использовали новые пределы
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #8F74
                ; подготовка режима экранного буфера после эффекта взрыва
Entry:          LD A, #C0
                LD (CircleRaster.FillTop), A
                LD A, #CF
                LD (CircleRaster.TargetBottom), A
                LD A, #BF
                LD (CircleRaster.TargetTop), A
                LD HL, #FCCB
                LD A, #D0
                ; проверка исходного конца фрагмента
                ASSERT $ == #8F88
                endmodule
                endmodule
