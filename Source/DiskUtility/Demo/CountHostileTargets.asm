; -----------------------------------------
; Подсчёт враждебных боевых целей
; исходный диапазон #EC22..#EC4D
; In:
;   семь слотов FSpaceObject начиная с Memory.Objects
; Out:
;   DE, BC, IY сохраняются, A число 0..7, Z при отсутствии
; Corrupt:
;   AF
; Note:
;   Для зачёта нужны AllowAttack с C=1, FX_GROUP_BIT и OBJ_HOSTILE_BIT в FSpaceObject.Hostility
; -----------------------------------------
                ; обход семи слотов после станции с сохранением регистров вызывающего
CountHostiles:  PUSH IY
                PUSH BC
                PUSH DE
                LD IY, Memory.Station
                LD DE, FSpaceObject
                LD BC, #0700
                ; совмещение допуска цели, группового режима TypeFlags и признака враждебности
CountHostile:   ADD IY, DE
                CALL AllowAttack
                JR NC, NextHostile                                              ; переход, если объект не является допустимой боевой целью, не учитывать его

                CALL ReadSlotFlags
                BIT FX_GROUP_BIT, A
                JR Z, NextHostile                                               ; переход, если FX_GROUP_BIT кешированного TypeFlags сброшен, не учитывать объект

                BIT OBJ_HOSTILE_BIT, (IY + FSpaceObject.Hostility)
                JR Z, NextHostile                                               ; переход, если OBJ_HOSTILE_BIT поля FSpaceObject.Hostility сброшен, не учитывать объект

                INC C
NextHostile:    DJNZ CountHostile

                LD A, C
                AND A
                POP DE
                POP BC
                POP IY
                RET
