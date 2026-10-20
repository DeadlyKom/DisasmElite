                module Objects
                module SpawnShipClass
; -----------------------------------------
; выбор модели запускаемого корабля по параметру класса
; исходный диапазон #B9E7..#BA26
; In:
;   BC - C код класса 1-5
;   IX - родитель
; Out:
;   IX - новый корабль при успехе, IY - родитель, NZ при неудаче
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
;   классы дают модели 8,9/10,18,15,16/17 соответственно
;   если IX родителя +26 bit2 сброшен, ориентация дочернего корабля изменяется #BA27
;   враждебность IX+21 bit2 наследуется от родителя
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #B9E7
Entry:          LD A, #08
                DEC C
                JR Z, SpawnChild                                                ; переход, если класс равен 1

                CALL Game.Combat.NextRandomByte.Entry
                AND #01
                ADD A, #09
                DEC C
                JR Z, SpawnChild                                                ; переход, если класс равен 2

                LD A, #12
                DEC C
                JR Z, SpawnChild                                                ; переход, если класс равен 3

                LD A, #0F
                DEC C
                JR Z, SpawnChild                                                ; переход, если класс равен 4

                DEC C
                RET NZ                                                          ; выход, если класс не равен 5 и не входит в обработанные варианты

                CALL Game.Combat.NextRandomByte.Entry
                BIT 0, A
                LD A, #10
                JR Z, SpawnChild                                                ; переход, если случайный младший бит равен 0 и выбрана модель 16

                LD A, #11
SpawnChild:     PUSH IX
                CALL Game.Objects.SpawnFromObject.Entry
                POP IY
                RET NZ                                                          ; выход, если дочерний корабль не создан

                BIT OBJ_SPECIAL_BIT, (IY+FSpaceObject.Flags2)
                CALL Z, Game.Objects.AlternateSpawnAxes.Entry                   ; вызов процедуры, если у родителя сброшен специальный бит 2 поля 26
                BIT OBJ_HOSTILE_BIT, (IY+FSpaceObject.Hostility)
                RET Z                                                           ; выход, если родитель не враждебен

                SET OBJ_HOSTILE_BIT, (IX+FSpaceObject.Hostility)
                XOR A
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #BA27
                endmodule
                endmodule
