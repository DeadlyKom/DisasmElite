                module Universe
                module FindInteractingObject
; -----------------------------------------
; поиск цели для расширенного взаимодействия объекта
; исходный диапазон #7C13..#7C5F
; In:
;   HL, расширенная запись источника
;   IX, источник
;   IY, расширенная запись источника
; Out:
;   HL, исходный указатель
;   AF, перенос при выполненном взаимодействии
; Corrupt:
;   DE, BC, IY
; Note:
; Сначала ракета с младшим адресом модели 6A проверяет собственный IX+25.
; Затем проверяются младшая и старшая ссылки поля+8.
; Если связанные цели не дали результата, последовательно проверяются семь слотов после станции.
; Первое успешное взаимодействие завершает поиск с установленным переносом.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #7C13
                ; поиск приоритетной собственной цели специальной ракеты
Entry:          LD C, (IY+FEffectRecord10.TypeFlags)
                LD B, (IY+FEffectRecord10.Links)
                PUSH HL
                LD A, (IX+FSpaceObject.Blueprint)
                CP #6A
                JR NZ, CheckLinks                                               ; переход, если модель не имеет младшего адреса 6A

                BIT OBJ_MISSILE_BIT, (IX+FSpaceObject.Flags2)
                JR Z, CheckLinks                                                ; переход, если объект не является ракетой

                LD A, (IX+FSpaceObject.Target)
                CALL Game.Universe.CheckLinkedObjectInteraction.Entry
                JR C, RestoreFlags                                              ; переход, если собственная цель ракеты дала взаимодействие

                ; проверка двух упакованных ссылок
CheckLinks:     LD A, B
                CALL Game.Universe.CheckLinkedObjectInteraction.Entry
                JR C, RestoreFlags                                              ; переход, если младшая ссылка дала взаимодействие

                LD A, B
                RRCA
                RRCA
                RRCA
                RRCA
                CALL Game.Universe.CheckLinkedObjectInteraction.Entry
                JR C, RestoreFlags                                              ; переход, если старшая ссылка дала взаимодействие

                ; последовательный поиск по семи слотам
                LD HL, Memory.Objects
                LD IY, ObjectEffects.Records + FEffectRecord10
                LD A, #07
SearchSlot:     PUSH AF
                CALL Game.Universe.TryObjectInteraction.Entry
                JR C, FoundSlot                                                 ; переход, если очередной объект общего поиска дал взаимодействие

                LD DE, FSpaceObject
                ADD HL, DE
                LD E, #0A
                ADD IY, DE
                POP AF
                DEC A
                JR NZ, SearchSlot                                               ; переход, если остались непроверенные слоты общего поиска

RestoreFlags:   POP HL
                RET

                ; успешное завершение поиска с восстановлением стека
FoundSlot:      POP AF
                POP HL
                SCF
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #7C60
                endmodule
                endmodule
