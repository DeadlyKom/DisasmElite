                module Screen
                module MatchTargetPlanet
; -----------------------------------------
; проверка совпадения перебираемой планеты с целевыми координатами
; In:
;   BC, B содержит координату X
;   AF, A содержит координату Y
;   стек, контекст поиска планеты
; Out:
;   при несовпадении устанавливается бит 0 L
;   при совпадении выполняется выход в Game.Galaxy.FindNearestSystem.MeasureNearest
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   координаты сравниваются с TargetX и TargetY
;   при совпадении расстояние NearestMetric обнуляется и вызывается Game.Galaxy.SaveWorkingSystemSeed.Entry
;   POP HL и POP BC снимают два уровня контекста поиска, это не обычный RET
;   при несовпадении Game.Galaxy.SquaredDistanceToTarget.Entry рассчитывает расстояние
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #8020
Entry:          PUSH AF
                ; проверка Y, затем X целевой планеты
                LD HL, TargetY
                XOR (HL)
                JR NZ, SetDistance                                              ; переход, если координата Y отличается

                DEC HL
                LD A, B
                XOR (HL)
                JR Z, SaveMatch                                                 ; переход, если обе координаты совпадают

SetDistance:    POP AF
                CALL Game.Galaxy.SquaredDistanceToTarget.Entry
                SET 0, L
                RET

                ; сохранение точного совпадения и снятие контекста поиска
SaveMatch:      LD HL, #0000
                LD (NearestMetric), HL
                CALL Game.Galaxy.SaveWorkingSystemSeed.Entry
                POP AF
                POP HL
                POP BC
                JP Game.Galaxy.FindNearestSystem.MeasureNearest

                ASSERT $ == #8042
                endmodule
                endmodule
