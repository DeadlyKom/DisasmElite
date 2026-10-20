                module Galaxy
                module SquaredDistanceToTarget
; -----------------------------------------
; Квадратичная метрика от заданной точки до выбранной
; исходный диапазон #DFCE..#DFE9
; In:
;   BC, B = исходный X, AF, A = исходный Y, D0BB/D0BC = цель
; Out:
;   HL=dx*dx+floor(dy/2)^2
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   DFEA даёт модуль разности с исходной асимметрией отрицательного направления, затем два
;   беззнаковых умножения и сложение, входной Y сохраняется через PUSH AF/POP BC
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #DFCE
                ; квадрат горизонтальной разности складывается с квадратом половины вертикальной
Entry:          PUSH AF
                LD A, (TargetX)
                CALL Game.Galaxy.OnesComplementDifference.Entry
                LD D, A
                CALL Game.Galaxy.MultiplyBytes.Entry
                POP BC
                PUSH HL
                LD A, (TargetY)
AddYDistance:   CALL Game.Galaxy.OnesComplementDifference.Entry
                SRL A
                LD D, A
                CALL Game.Galaxy.MultiplyBytes.Entry
                POP DE
                ADD HL, DE
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #DFEA
                endmodule
                endmodule
