; -----------------------------------------
; Циклический переход по семи слотам после станции
; исходный диапазон #EB7D..#EB99
; In:
;   EB9A прежний адрес
; Out:
;   IY следующий 606F..6159, EB9A обновлён
; Corrupt:
;   HL, DE, AF, IY
; Note:
;   При сложении 39 получается 6180, тогда устанавливается 606F, начальный 6048 даёт первый 606F
; -----------------------------------------
                ; переход по структурам 39 байтов с кольцом 606F..6159
NextObject:     LD IY, (ObjectCursor)
                LD DE, FSpaceObject
                ADD IY, DE
                PUSH IY
                POP HL
                LD DE, Memory.ModelIndex
                AND A
                SBC HL, DE
                JR NZ, StoreCursor                                              ; переход, если следующий адрес не равен 6180, сохранить его

                LD IY, Memory.Objects
                ; фиксация курсора для следующего вызова
StoreCursor:    LD (ObjectCursor), IY
                RET
