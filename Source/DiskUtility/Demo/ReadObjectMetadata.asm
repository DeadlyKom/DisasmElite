; -----------------------------------------
; Снимок метаданных и выбор флага конкретного объекта
; исходный диапазон #EBE9..#EC21
; In:
;   IY точный адрес одного из 8 слотов 6048..6159
; Out:
;   HL, DE, BC и IY сохраняются, A классификатор слота из EBE1..EBE8
; Corrupt:
;   AF
; Note:
;   Если IsGameHalted даёт Z, восемь флагов копируются из B457 с шагом 10
;   Индекс получается вычитаниями 39 из IY-6021, неправильный невыровненный адрес может зациклить
;   поиск
;   Без HALT используется предыдущий снимок, это защищает от промежуточного состояния игрового
;   обновления
; -----------------------------------------
                ; сохранение рабочих регистров перед обновлением снимка метаданных
ReadSlotFlags:  PUSH BC
                PUSH DE
                PUSH HL
                PUSH IY
                ; обновление снимка допускается только при остановке игрового потока на HALT
                CALL IsGameHalted
                JR NZ, SelectFlagSlot                                           ; переход, если прерывание застало другую команду, использовать предыдущий снимок метаданных

                ; копирование восьми классификаторов с шагом 10 в плотный кеш
                LD HL, ObjectEffects.Records
                LD DE, SlotFlagCache
                LD B, #08
CacheSlotFlags: LD A, (HL)
                LD (DE), A
                INC DE
                PUSH BC
                LD BC, FEffectRecord10
                ADD HL, BC
                POP BC
                DJNZ CacheSlotFlags

                ; индекс слота рассчитывается повторным вычитанием 39 из IY-6021
SelectFlagSlot: LD HL, SlotFlagCache-1
                LD DE, FSpaceObject - Memory.Station
                AND A
                ADD IY, DE
AdvanceFlag:    INC HL
                LD DE, -FSpaceObject
                ADD IY, DE
                LD A, IYH
                OR IYL
                JR NZ, AdvanceFlag                                              ; переход, если вычитания 39 ещё не довели адрес до нуля, перейти к следующему байту кеша

                ; чтение выбранного байта и восстановление указателя объекта
                LD A, (HL)
                POP IY
                POP HL
                POP DE
                POP BC
                RET
