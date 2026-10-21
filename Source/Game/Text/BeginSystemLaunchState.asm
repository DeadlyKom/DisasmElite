                module Text
                module BeginSystemLaunchState
; -----------------------------------------
; Установка маркера прибытия и возврат указателя семени
; исходный диапазон #D8DD..#D8E4
; In:
;   Нет параметров
; Out:
;   LaunchPending=E0, HL=GalaxyState
; Corrupt:
;   HL
; Note:
;   Байт LaunchPending используется пути запуска/стыковки Game.Flight.LaunchOrDockShip.Entry→Game.Extensions.FillBackwardAndCountDemo.CountDemo, процедура не сохраняет и не
;   восстанавливает генератор случайных чисел
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D8DD
                ; LaunchPending получает маркер однократного увеличения счётчика запуска, HL указывает на целевое семя
Entry:          LD HL, LaunchPending
                LD (HL), H
                LD HL, GalaxyState.TargetSeed
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #D8E5
                endmodule
                endmodule
