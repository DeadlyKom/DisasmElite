                module Universe
                module DrawStarsWithJumpEffect
; -----------------------------------------
; вывод звёзд с дополнительными проходами при ускоренном перемещении
; исходный диапазон #7898..#78B0
; In:
;   память FastTravel, признак ускоренного шага
; Out:
;   звёзды выведены, скорость FlightState.Speed может быть заменена
; Corrupt:
;   HL, DE, BC, AF, HL', DE', BC', AF'
; Note:
; При FastTravel=1 сначала вызывается Game.Extensions.SetSceneFlagAndResetMetadata.Entry, затем звёзды выводятся со скоростью 30 и 16.
; После второго CALL управление последовательно попадает в Game.Universe.UpdateAndDrawStarField.Entry и выполняет ещё один проход.
; При другом состоянии сразу переходит в единственный обычный проход.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #7898
                ; проверка ускоренного звёздного эффекта
Entry:          LD A, (FastTravel)
                DEC A
                JR NZ, Game.Universe.UpdateAndDrawStarField.Entry               ; переход, если признак ускоренного шага отличается от 1 и достаточно одного прохода

                CALL Game.Extensions.SetSceneFlagAndResetMetadata.Entry
                LD A, #1E
                LD (FlightState.Speed), A
                CALL Game.Universe.UpdateAndDrawStarField.Entry
                LD A, #10
                LD (FlightState.Speed), A
                CALL Game.Universe.UpdateAndDrawStarField.Entry                 ; далее Game.Universe.UpdateAndDrawStarField.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #78B1
                endmodule
                endmodule
