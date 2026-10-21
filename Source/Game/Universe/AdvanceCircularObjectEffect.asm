                module Universe
                module AdvanceCircularObjectEffect
; -----------------------------------------
; продвижение восьмифазного кругового эффекта объекта
; исходный диапазон #7EA9..#7EC7
; In:
;   IX, объект
;   память ObjectEffects.Current, метаданные
;   память CombatState.SpawnCounter, счётчик кадра
; Out:
;   BC, C содержит счётчик кадра
;   первая запись и энергия могут быть обнулены
; Corrupt:
;   HL, DE, AF
; Note:
; Эффект распознаётся по (первыйбайт AND F8)==A0. Младшие три бита увеличиваются.
; При переходе в следующую восьмёрку обнуляет запись и энергию, снимает ракетные цели.
; POP HL удаляет адрес возврата, завершение идёт прямо в Game.Combat.UpdateAllSpaceObjects.NextSlot, контракт привязан к циклу объектов.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #7EA9
                ; проверка типа и продвижение фазы кругового эффекта
Entry:          LD A, (CombatState.SpawnCounter)
                LD C, A
                LD HL, (ObjectEffects.Current)
                LD A, (HL)
                AND EffectRecord.TypeMask
                CP EffectRecord.CircleType
                RET NZ                                                          ; выход, если запись не относится к круговому эффекту A0

                INC (HL)
                LD A, (HL)
                AND EffectRecord.PhaseMask
                ; завершение эффекта с удалением объекта и выходом из текущей итерации
                RET NZ                                                          ; выход, если младшие три бита фазы ещё не обнулились

                LD (HL), A
                LD (IX+FSpaceObject.Energy), A
                POP HL
                PUSH BC
                CALL Game.Combat.ReleaseMissileTargets.Entry
                POP BC
                JP @Game.Combat.UpdateAllSpaceObjects.NextSlot

                ; проверка исходного конца фрагмента
                ASSERT $ == #7EC8
                endmodule
                endmodule
