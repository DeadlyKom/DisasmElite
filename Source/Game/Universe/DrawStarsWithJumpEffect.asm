                module Universe
                module DrawStarsWithJumpEffect
; -----------------------------------------
; вывод звёзд с дополнительными проходами при ускоренном перемещении
; исходный диапазон #7898..#78B0
; In:
;   память 7EDD, признак ускоренного шага
; Out:
;   звёзды выведены, скорость 70E6 может быть заменена
; Corrupt:
;   HL, DE, BC, AF, HL', DE', BC', AF'
; Note:
; При 7EDD=1 сначала вызывается F9A8, затем звёзды выводятся со скоростью 30 и 16.
; После второго CALL управление последовательно попадает в 78B1 и выполняет ещё один проход.
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
                CALL Game.Universe.UpdateAndDrawStarField.Entry
                ; проверка исходного конца фрагмента
                ASSERT $ == #78B1
                endmodule
                endmodule
