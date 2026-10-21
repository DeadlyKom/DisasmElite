                module Objects
                module SpawnShipCargoOrPod
; -----------------------------------------
; создание капсулы или контейнера с сохранением указателя родителя
; исходный диапазон #BB2F..#BB4C
; In:
;   AF - A модель
;   IX - родитель
; Out:
;   IX восстановлен, Z при успехе либо NZ при отсутствии слота
; Corrupt:
;   HL, DE, BC, AF, IY
; Note:
;   обмен IX с вершиной стека временно выбирает новый слот и сохраняет родителя
;   у дочернего объекта сбрасывается OBJ_ACTIVE_BIT в FSpaceObject.Flags, FSpaceObject.Flags2=#0A и FSpaceObject.Roll=#80
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #BB2F
                ; создание дочернего объекта с временным сохранением указателя родителя на стеке
Entry:          PUSH IX
                CALL Game.Objects.SpawnFromObject.Entry
                EX (SP), IX
                POP HL
                RET NZ                                                          ; выход, если создание капсулы или груза не удалось

                PUSH HL
                EX (SP), IX
                RES OBJ_ACTIVE_BIT, (IX+FSpaceObject.Flags)
                LD A, #0A
                LD (IX+FSpaceObject.Flags2), A
                LD A, #80
                LD (IX+FSpaceObject.Roll), A
                XOR A
                POP IX
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #BB4D
                endmodule
                endmodule
