; -----------------------------------------
; Подсчёт объектов по признакам собираемого груза
; исходный диапазон #EC4E..#EC69
; In:
;   восемь флагов ObjectEffects.Records+10*n
; Out:
;   HL, DE, BC сохраняются, A число 0..8, Z при отсутствии
; Corrupt:
;   AF
; Note:
;   Используется живой массив метаданных без кеширования, критерий битов 7=1, 6=0, 4=1
; -----------------------------------------
                ; прямой обход восьми живых классификаторов, без обновления кеша
CountCargo:     PUSH BC
                PUSH HL
                PUSH DE
                LD HL, ObjectEffects.Records
                LD DE, #000A
                LD BC, #0800
                ; подсчёт комбинации 7=1,6=0,4=1 через CheckCargoFlag
CountCargoFlag: LD A, (HL)
                CALL CheckCargoFlag
                JR C, NextCargoFlag                                             ; переход, если комбинация битов не соответствует 7=1,6=0,4=1, не учитывать запись

                INC C
NextCargoFlag:  ADD HL, DE
                DJNZ CountCargoFlag

                LD A, C
                POP DE
                POP HL
                POP BC
                AND A
                RET
