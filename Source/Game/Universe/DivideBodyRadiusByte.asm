                module Universe
                module DivideBodyRadiusByte
; -----------------------------------------
; подготовка деления восьмибитного радиуса
; исходный диапазон #783B..#783C
; In:
;   BC, B содержит делитель
;   AF, A содержит числитель
; Out:
;   DE, D содержит дробное частное
; Corrupt:
;   AF
; Note:
; Устанавливает E=0 и продолжается в Game.Universe.DivideBodyProjectionFraction.Entry, входящий числитель должен быть меньше делителя.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #783B
                ; обнуление младших разрядов перед дробным делением
Entry:          LD E, #00                                                       ; далее Game.Universe.DivideBodyProjectionFraction.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #783D
                endmodule
                endmodule
