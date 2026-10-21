                module Objects
                module SpawnTwoMinerals
; -----------------------------------------
; создание двух минералов у исходного объекта
; исходный диапазон #BB4D..#BB54
; In:
;   IX - исходный объект
; Out:
;   IX восстановлен, создано до двух объектов модели 5
; Corrupt:
;   HL, DE, BC, AF, IY
; Note:
;   первый вызов Game.Objects.SpawnShipDebris.Entry, затем при успехе проваливание в ту же процедуру со вторым A=5
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #BB4D
Entry:          LD A, #05
                CALL Game.Objects.SpawnShipDebris.Entry
                RET NZ                                                          ; выход, если первый минерал не создан

                LD A, #05                                                       ; далее Game.Objects.SpawnShipDebris.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #BB55
                endmodule
                endmodule
