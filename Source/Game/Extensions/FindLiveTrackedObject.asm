                module Extensions
                module FindLiveTrackedObject
; -----------------------------------------
; поиск живого объекта по идентификатору захвата
; исходный диапазон #F95A..#F97D
; смысловое имя FindLiveTrackedObject
; In: (ObjectIndex) — искомый идентификатор
; Out: при успехе IX — слот, Z=1 и C=1, при отказе C=0
; Corrupt: DE, BC — только B, AF, IX
; Проверяются семь 39-байтовых слотов от Memory.Missile назад до Memory.Objects
; Требуются OBJ_MISSILE_BIT в FSpaceObject.Flags2, ненулевая FSpaceObject.Energy и совпадение FSpaceObject.Target с ObjectIndex
; После полного отказа IX=Memory.Station, A по-прежнему содержит искомый идентификатор
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #F95A
                ; поиск идентификатора среди семи живых слотов, начиная с последнего
Entry:          LD IX, Memory.Missile
                LD A, (ObjectIndex)
                LD B, #07
                ; проверка флага ракеты, энергии и идентификатора очередного слота
CheckSlot:      BIT OBJ_MISSILE_BIT, (IX+FSpaceObject.Flags2)
                JR Z, PreviousSlot                                              ; переход, если флаг управляемой ракеты сброшен, проверить предыдущий слот

                LD D, (IX+FSpaceObject.Energy)
                INC D
                DEC D
                JR Z, PreviousSlot                                              ; переход, если энергия слота равна нулю, проверить предыдущий слот

                CP (IX+FSpaceObject.Target)
                SCF
                RET Z                                                           ; выход, если идентификатор совпадает, найден живой объект

                ; расчёт адреса предыдущего слота с шагом минус 39
PreviousSlot:   LD DE, #FFD9
                ADD IX, DE
                DJNZ CheckSlot

                AND A
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #F97E
                endmodule
                endmodule
