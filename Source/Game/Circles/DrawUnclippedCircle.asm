                module Circles
                module DrawUnclippedCircle
; -----------------------------------------
; вывод двух половин круга без бокового отсечения
; исходный диапазон #87C8..#87D3
; смысловое имя DrawUnclippedCircle
; In: рабочие параметры круга #861A..#8621
; Out: верхняя и нижняя половины нарисованы
; Corrupt: HL, DE, BC, AF, HL', DE', BC', AF'
; Перед каждой половиной адреса и маски рассчитываются заново
; Вторая половина вызывается хвостовым JP и сама возвращается вызывающему
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #87C8
                ; вывод верхней и нижней половин с повторной подготовкой краёв
Entry:          CALL Game.Circles.PrepareUnclippedCircle.Entry
                CALL Game.Screen.UnclippedArcUp.Entry
                CALL Game.Circles.PrepareUnclippedCircle.Entry
                JP Game.Screen.UnclippedArcDown.Entry
                ; проверка исходного конца фрагмента
                ASSERT $ == #87D4
                endmodule
                endmodule
