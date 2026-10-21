                module Combat
                module FinishObjectFrame
; -----------------------------------------
; завершение объектного кадра и сброс опасности пустой сцены
; исходный диапазон #9E66..#9E72
; In:
;   память CombatState.ShipsPresent, наличие обычного корабля
; Out:
;   обновлены расширенные эффекты и признак CombatState.Danger
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
; Game.Universe.UpdateExtendedObjectEffects.Entry вызывается с A=0, снимая массовый запрос уничтожения.
; Опасность сбрасывается лишь при отсутствии обычных кораблей.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #9E66
                ; обновление расширенных эффектов и проверка оставшихся кораблей
Entry:          XOR A
                CALL Game.Universe.UpdateExtendedObjectEffects.Entry
                LD A, (CombatState.ShipsPresent)
                AND A
                RET NZ                                                          ; выход, если в сцене остался обычный корабль и признак опасности сохраняется

                LD (CombatState.Danger), A
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #9E73
                endmodule
                endmodule
