; -----------------------------------------
; Подсчёт враждебных боевых целей
; исходный диапазон #EC22..#EC4D
; In:
;   7 слотов 606F..6159
; Out:
;   DE, BC, IY сохраняются, A число 0..7, Z при отсутствии
; Corrupt:
;   AF
; Note:
;   Для зачёта нужны AllowAttack,C=1, кешированный бит 6 и враждебность IY21.2
; -----------------------------------------
                ; обход семи слотов после станции с сохранением регистров вызывающего
CountHostiles:  PUSH IY
                PUSH BC
                PUSH DE
                LD IY, Memory.Station
                LD DE, FSpaceObject
                LD BC, #0700
                ; совмещение допуска цели, класса 6 и признака враждебности
CountHostile:   ADD IY, DE
                CALL AllowAttack
                JR NC, NextHostile                                              ; переход, если объект не является допустимой боевой целью, не учитывать его

                CALL ReadSlotFlags
                BIT 6, A
                JR Z, NextHostile                                               ; переход, если бит 6 классификатора сброшен, не учитывать объект

                BIT OBJ_HOSTILE_BIT, (IY + FSpaceObject.Hostility)
                JR Z, NextHostile                                               ; переход, если бит 2 враждебности сброшен, не учитывать объект

                INC C
NextHostile:    DJNZ CountHostile

                LD A, C
                AND A
                POP DE
                POP BC
                POP IY
                RET
