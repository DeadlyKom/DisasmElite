                module Objects
                module SpawnTwoAlloys
; -----------------------------------------
; создание двух обломков сплава от игрока или исходного объекта
; исходный диапазон #BA94..#BA9B
; In:
;   BC - C bit0 выбирает источник
;   IX - родитель для C bit0=0
; Out:
;   создано до двух объектов, NZ при исчерпании слотов
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
;   путь игрока после успешного CALL Game.Objects.SpawnPlayerDebris.Entry проваливается в Game.Objects.SpawnPlayerDebris.Entry второй раз
;   путь объекта переходит в Game.Objects.SpawnTwoShipAlloys.Entry, который также делает две попытки
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #BA94
Entry:          BIT 0, C
                JR Z, Game.Objects.SpawnTwoShipAlloys.Entry                     ; переход, если бит 0 C сброшен и источник является игровым объектом

                CALL Game.Objects.SpawnPlayerDebris.Entry
                RET NZ                                                          ; выход, если первый обломок игрока не удалось создать, иначе далее Game.Objects.SpawnPlayerDebris.Entry без команды перехода

                ; проверка исходного конца фрагмента
                ASSERT $ == #BA9C
                endmodule
                endmodule
