; -----------------------------------------
; Подсчёт ракет с целью игрока
; исходный диапазон #EC6A..#EC91
; In:
;   7 слотов 606F..6159
; Out:
;   A число 0..7, Z при отсутствии
; Corrupt:
;   DE, BC, AF, IY сохраняется
; Note:
;   Требуются полный байт Flags2=1, цель Target=0 и кешированный бит 7=1
; -----------------------------------------
                ; обход семи объектов в поиске ракет, направленных на игрока
CountMissiles:  PUSH IY
                LD IY, Memory.Station
                LD DE, FSpaceObject
                LD BC, #0700
                ; сочетание Flags2=1 и код цели 0 проверяются до метаданных
CheckMissile:   ADD IY, DE
                LD A, (IY + FSpaceObject.Flags2)
                DEC A
                JR NZ, NextMissile                                              ; переход, если полный байт Flags2 не равен 1, пропустить слот

                LD A, (IY + FSpaceObject.Target)
                AND A
                JR NZ, NextMissile                                              ; переход, если цель ракеты не игрок 0, пропустить слот

                CALL ReadSlotFlags
                RLCA
                JR NC, NextMissile                                              ; переход, если бит 7 классификатора сброшен, не учитывать ракету

                INC C
NextMissile:    DJNZ CheckMissile

                LD A, C
                POP IY
                AND A
                RET
