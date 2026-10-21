                module Universe
                module DispatchLinkedObjectAction
; -----------------------------------------
; диспетчер действий с назначением цели новой ракете и обработкой лазерной связи
; исходный диапазон #7D4D..#7DA3
; In:
;   AF, A содержит действие
;   IX, источник либо созданный объект
;   память ObjectEffects.Current, метаданные источника
; Out:
;   AF, Z при успешном действии 2
;   FSpaceObject.Target, младшая ссылка источника для новой ракеты
; Corrupt:
;   HL, DE, BC, AF, AF', IY
; Note:
; Все действия кроме ровно 2 переходят в штатный диспетчер без расширения.
; При успешном действии 2 номер цели берётся из low4 поля+8 текущей записи.
; Отдельный вход Game.Universe.DispatchLinkedObjectAction.LaserHitLinks обслуживает попадание лазером, ищет запись по CombatState.CrosshairTarget.
; Проверяет её тип, объединяет bit2 с общим ObjectEffects.Flags и переносит low4 ссылки+8 в старшую тетраду.
; При определённом общем признаке возвращает состояние энергии станции Memory.Station + FSpaceObject.Energy.
; Отдельный сохранённый вход Game.Universe.DispatchLinkedObjectAction.LegacyFlag устанавливает бит 2 предыдущего байта записи.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #7D4D
                ; выбор штатного действия либо создания связанной ракеты
Entry:          CP #02
                JP NZ, Game.Objects.DispatchObjectAction.Entry                  ; переход, если действие отличается от 2 и расширенное назначение цели не требуется

                CALL Game.Objects.DispatchObjectAction.Entry
                RET NZ                                                          ; выход, если создание ракеты не удалось

                ; назначение новой ракете цели из метаданных источника
                LD IY, (ObjectEffects.Current)
                LD A, (IY+FEffectRecord10.Links)
                AND FX_LINK_MASK
                LD (IX+FSpaceObject.Target), A
                XOR A
                RET

                ; отдельный вход обработки связи при попадании лазером
LaserHitLinks:  LD HL, ObjectEffects.Records
                LD A, (CombatState.CrosshairTarget)
                SUB #0A
                CPL
                LD DE, #000A
FindTarget:     DEC A
                JR Z, CheckType                                                 ; переход, если достигнута запись цели лазерного попадания

                ADD HL, DE
                JR FindTarget

                ; проверка типа поражённой записи
CheckType:      BIT FX_GROUP_BIT, (HL)
                JR NZ, UpdateLink                                               ; переход, если тип цели имеет bit6 и допускает обработку связи

                LD A, (HL)
                OR FX_GROUP_KEEP
                INC A
                RET Z                                                           ; выход, если младшая группа типа равна 3 при сброшенном bit6 и связь не меняется

                ; обновление общих признаков и упакованной ссылки
UpdateLink:     LD A, (ObjectEffects.Flags)
                CALL Game.Wireframe.MergeInverseHostilityFlag.Entry
                LD (ObjectEffects.Flags), A
                LD E, #08
                ADD HL, DE
                EX AF, AF'
                LD A, (HL)
                AND FX_LINK_MASK
                RET Z                                                           ; выход, если младшая ссылка уже нулевая

                LD A, (HL)
                ADD A, A
                ADD A, A
                ADD A, A
                ADD A, A
                LD (HL), A
                EX AF, AF'
                AND 1 << FX_ALLOW_BIT
                RET Z                                                           ; выход, если общий признак bit2 сброшен и проверка станции не нужна

                ; возврат состояния станции для специальной связи
                LD HL, Memory.Station + FSpaceObject.Energy
                LD A, (HL)
                AND A
                RET

                ; сохранённые байты прежнего обработчика

; -----------------------------------------
; установка бита 2 в предыдущем байте записи
; In:
;   HL, адрес байта после изменяемого поля
; Out:
;   HL, уменьшен на один
;   бит 2 по новому HL установлен, флаги сохраняются
; Corrupt:
;   HL
; Note:
;   сохранённая процедура, прямые входящие переходы не найдены
;   конкретный владелец поля этим фрагментом не определяется, адрес задаёт вызывающий
; -----------------------------------------
LegacyFlag:     ; установка бита 2 в предыдущем байте записи
                DEC HL
                SET FX_ALLOW_BIT, (HL)
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #7DA4
                endmodule
                endmodule
