                module Objects
                module SelectObjectAction
; -----------------------------------------
; диспетчер создания объектов по младшей тетраде команды
; исходный диапазон #B86A..#B897
; In:
;   BC - C уже содержит исходный код A >> 1
;   AF - исходная команда
;   IX - исходный объект
; Out:
;   результат выбранной процедуры или возврат для кода 3 и кодов выше 9
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
;   три SRL C завершают выделение старшей тетрады в C
;   коды 0-9 выбирают случайный корабль, волну таргонов, ракету, пустой код, корабль, сплавы, груз, капсулу, минералы, заставку
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #B86A
Entry:          SRL C
                SRL C
                SRL C
                AND #0F
                JP Z, Game.Objects.GenerateSpaceTraffic.Entry                   ; переход, если код действия равен 0

                DEC A
                JP Z, Game.Objects.SpawnThargonWave.Entry                       ; переход, если код действия равен 1

                DEC A
                JP Z, Game.Objects.SpawnMissile.Entry                           ; переход, если код действия равен 2

                DEC A
                RET Z                                                           ; выход, если код действия равен 3 и не имеет обработчика

                DEC A
                JP Z, Game.Objects.SpawnShipClass.Entry                         ; переход, если код действия равен 4

                DEC A
                JP Z, Game.Objects.SpawnTwoAlloys.Entry                         ; переход, если код действия равен 5

                DEC A
                JP Z, Game.Objects.SpawnCargo.Entry                             ; переход, если код действия равен 6

                DEC A
                JP Z, Game.Objects.SpawnEscapePod.Entry                         ; переход, если код действия равен 7

                DEC A
                JP Z, Game.Objects.SpawnTwoMinerals.Entry                       ; переход, если код действия равен 8

                DEC A
                JP Z, Game.Objects.InitializeIntroModel.Entry                   ; переход, если код действия равен 9

                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #B898
                endmodule
                endmodule
