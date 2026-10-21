                module Galaxy
                module DistanceMetricToFuel
; -----------------------------------------
; Преобразование квадрата расстояния в расход топлива
; исходный диапазон #DFF2..#E008
; In:
;   HL = квадрат метрики, AF, CY = переполнение метрики
; Out:
;   GalaxyState.Distance=4*старший байт результата корня, при нуле 0
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   При CY заменяет метрику FFFF, ненулевую передаёт Game.Combat.SquareRootVectorLength.Entry, берёт только H результата и умножает
;   на 4, точность определяется исходным приближённым корнем
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #DFF2
                ; метрика переводится в расход топлива через квадратный корень и масштабирование
Entry:          JR C, ClampDistance                                             ; переход, если входной перенос установлен, заменить переполненную метрику значением FFFF

                JR ConvertMetric

ClampDistance:  LD HL, #FFFF
ConvertMetric:  LD A, H
                OR L
                JR Z, StoreFuelCost                                             ; переход, если квадратичная метрика нулевая, вернуть нулевой расход топлива

                CALL Game.Combat.SquareRootVectorLength.Entry
                LD L, H
                LD H, #00
                ADD HL, HL
                ADD HL, HL
StoreFuelCost:  LD (GalaxyState.Distance), HL
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #E009
                endmodule
                endmodule
