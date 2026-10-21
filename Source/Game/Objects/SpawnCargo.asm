                module Objects
                module SpawnCargo
; -----------------------------------------
; выбор создания груза у игрока или исходного объекта
; исходный диапазон #BAF2..#BAF9
; In:
;   BC - C bit0 выбирает игрока
;   IX - исходный объект для другого пути
; Out:
;   результат выбранного общего обработчика
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
;   модель 4, у игрока переход в Game.Objects.SpawnPlayerDebris.SpawnDebris, у исходного объекта в Game.Objects.SpawnShipCargoOrPod.Entry
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #BAF2
Entry:          BIT 0, C
                LD A, #04
                JR Z, Game.Objects.SpawnShipCargoOrPod.Entry                    ; переход, если груз выбрасывает исходный объект

                JR @Game.Objects.SpawnPlayerDebris.SpawnDebris

                ; проверка исходного конца фрагмента
                ASSERT $ == #BAFA
                endmodule
                endmodule
