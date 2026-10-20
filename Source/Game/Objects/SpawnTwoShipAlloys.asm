                module Objects
                module SpawnTwoShipAlloys
; -----------------------------------------
; две попытки создать сплав у исходного объекта
; исходный диапазон #BAE8..#BAF1
; In:
;   IX - исходный объект
; Out:
;   IX сохранён, создано до двух объектов модели 3
; Corrupt:
;   HL, DE, BC, AF, IY
; Note:
;   если первая попытка вернула NZ, вторая не выполняется
;   вторая попытка использует общий хвост #BB55 через JR
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #BAE8
Entry:          LD A, #03
                CALL Game.Objects.SpawnShipDebris.Entry
                RET NZ                                                          ; выход, если первый обломок исходного объекта не создан

                LD A, #03
                JR Game.Objects.SpawnShipDebris.Entry
                ; проверка исходного конца фрагмента
                ASSERT $ == #BAF2
                endmodule
                endmodule
