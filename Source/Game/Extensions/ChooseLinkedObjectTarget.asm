                module Extensions
                module ChooseLinkedObjectTarget
; -----------------------------------------
; выбор цели по связям и флагам метаданных объекта
; исходный диапазон #FA0D..#FA83
; смысловое имя ChooseLinkedObjectTarget
; In: IX — объект, AF — A содержит запасной номер, (#B452) — метаданные
; Out: BC — выбранная цель и производный индекс, Z/флаги зависят от ветви
; Corrupt: HL, DE, BC, AF, AF'
; При бит 0 IX+26 используется собственный IX+25 без поиска
; Иначе проверяются младшая и старшая тетрады +8, затем резервная тетрада +9
; Ссылки проверяются #F9E7/#F9E8 по энергии и состоянию +20 живого объекта
; Если разрешён поиск, просматриваются семь записей с шагом 10 от #B461
; Резервная станция с номером 8 допускается по энергии #606A и случайному биту
; При выборе в +9 сохраняется старший бит и записывается номер цели
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #FA0D
                ; проверка флага управляемой ракеты и активности объекта перед поиском связей
Entry:          LD C, A
                LD B, (IX+FSpaceObject.Target)
                BIT OBJ_MISSILE_BIT, (IX+FSpaceObject.Flags2)
                JR NZ, ReturnTarget                                             ; переход, если у объекта установлен флаг управляемой ракеты, вернуть собственный номер

                LD A, (IX+FSpaceObject.Flags)
                AND A
                RET Z                                                           ; выход, если байт активности IX+20 нулевой

                ; получение флагов и трёх упакованных ссылок метаданных
                LD HL, (ObjectEffects.Current)
                LD A, (HL)
                LD DE, #0007
                ADD HL, DE
                LD E, A
                BIT FX_SEARCH_TICK, (HL)
                INC HL
                LD A, (HL)
                RET Z                                                           ; выход, если бит 0 метаданных +7 сброшен, вернуть сохранённую связь без поиска

                ; проверка первой тетрады основной ссылки
                CALL Game.Extensions.ValidateTargetWithFlags.Entry
                RET NZ                                                          ; выход, если первая ссылка указывает на живой объект

                ; проверка второй тетрады основной ссылки
                LD A, (HL)
                RRCA
                RRCA
                RRCA
                RRCA
                CALL Game.Extensions.ValidateTargetWithFlags.Entry
                RET NZ                                                          ; выход, если вторая ссылка указывает на живой объект

                ; проверка резервной ссылки и очистка недействительного номера
                INC HL
                LD A, (HL)
                AND FX_LINK_MASK
                JR Z, CheckSearch                                               ; переход, если резервная ссылка нулевая, перейти к поиску

                CALL Game.Extensions.ValidatePackedObjectTarget.Entry
                JR Z, ClearReserve                                              ; переход, если резервная ссылка недействительна, обнулить её

                DEC HL
                DEC HL
                BIT FX_SEARCH_TICK, (HL)
                RET

ClearReserve:   LD (HL), A
                ; проверка разрешающих флагов для нового поиска
CheckSearch:    BIT FX_SEARCH_BIT, E
                RET Z                                                           ; выход, если бит 4 флагов метаданных сброшен, поиск запрещён

                BIT FX_GROUP_BIT, E
                RET Z                                                           ; выход, если бит 6 флагов метаданных сброшен, поиск запрещён

                ; поиск записи с признаком #90 по семи десятибайтовым структурам
                PUSH HL
                LD HL, ObjectEffects.Records + FEffectRecord10
                LD B, #07
FindLinked:     LD A, (HL)
                AND FX_KIND_MASK
                CP FX_RESERVE_KIND
                JR Z, FoundLinked                                               ; переход, если старшая тетрада записи равна 9, выбрать её номер

                PUSH DE
                LD E, #0A
                ADD HL, DE
                POP DE
                DJNZ FindLinked

                ; проверка разрешения резервной станции и её энергии
                POP HL
                BIT FX_ALLOW_BIT, E
                JR NZ, NoTarget                                                 ; переход, если бит 2 исходных флагов установлен, станцию не выбирать

                BIT FX_NOSTAT_BIT, (HL)
                JR NZ, NoTarget                                                 ; переход, если бит 7 резервной ссылки установлен, станцию не выбирать

                LD A, (Memory.Station + FSpaceObject.Energy)
                AND A
                LD B, #08
                JR Z, NoTarget                                                  ; переход, если энергия станции равна нулю, станцию не выбирать

                ; случайный выбор станции с вероятностью одного установленного бита
                CALL Game.Combat.NextRandomByte.Entry
                AND B
                JR NZ, StoreTarget                                              ; переход, если случайный бит 3 установлен, выбрать станцию с номером 8

NoTarget:       XOR A
                RET

FoundLinked:    POP HL
                ; сохранение найденного номера с прежним старшим битом
StoreTarget:    LD A, (HL)
                AND FX_NOSTAT_MASK
                OR B
                LD (HL), A
ReturnTarget:   LD C, B
                INC B
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #FA84
                endmodule
                endmodule
