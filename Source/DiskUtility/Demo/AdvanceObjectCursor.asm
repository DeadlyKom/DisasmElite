; -----------------------------------------
; Циклический переход по семи слотам после станции
; исходный диапазон #EB7D..#EB99
; In:
;   DiskUtility.Demo.ObjectCursor прежний адрес
; Out:
;   IY указывает следующий из семи слотов FSpaceObject, ObjectCursor обновлён
; Corrupt:
;   HL, DE, AF, IY
; Note:
;   При сложении 39 получается Memory.ModelIndex, тогда устанавливается Memory.Objects, начальный Memory.Station даёт первый Memory.Objects
; -----------------------------------------
                ; кольцевой обход семи структур FSpaceObject начиная с Memory.Objects
NextObject:     LD IY, (ObjectCursor)
                LD DE, FSpaceObject
                ADD IY, DE
                PUSH IY
                POP HL
                LD DE, Memory.ModelIndex
                AND A
                SBC HL, DE
                JR NZ, StoreCursor                                              ; переход, если следующий адрес не равен Memory.ModelIndex, сохранить его

                LD IY, Memory.Objects
                ; фиксация курсора для следующего вызова
StoreCursor:    LD (ObjectCursor), IY
                RET
