                module Trade
                module MissionRegionMetric
; -----------------------------------------
; Метрика специальной области миссии
; исходный диапазон #E6C6..#E6ED
; In:
;   BC, B = X, AF, A = Y
; Out:
;   HL = метрика относительно X=92 и Y=0
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Использует асимметричный Game.Galaxy.OnesComplementDifference.Entry, квадрат X и половину разности Y, Game.Trade.MissionRegionMetric.BoardRefugees отдельно запрашивает Y,
;   очищает 18 байт груза и ставит бит 5 State.MissionFlags для занятого миссией трюма
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E6C6
                ; квадрат отклонения от X=92 дополняется общим расчётом вертикальной метрики относительно Y=0
                ; миссия 7 INVASION, метрика координат используется общей проверкой фронта
                ; описание в Docs/Manual.md, раздел mission-7-invasion
Entry:          PUSH AF
                LD A, #5C
                CALL Game.Galaxy.OnesComplementDifference.Entry
                LD D, A
                CALL Game.Galaxy.MultiplyBytes.Entry
                POP BC
                PUSH HL
                XOR A
                JP @Game.Galaxy.SquaredDistanceToTarget.AddYDistance

                ; миссии 1 и 7+1, приём беженцев, для 7+3 тот же трюм принимает десант
                ; описание в Docs/Manual.md, раздел mission-1, mission-7-1 и mission-7-3
                ; ответ Y на перевозку беженцев, очистка 17 слотов и свободного тоннажа
BoardRefugees:  CALL Game.Trade.WaitForKeyCode.Entry
                CP #59
                JR NZ, ReturnCargo                                              ; переход, если ответ отличается от Y, не занимать трюм беженцами

                XOR A
                LD HL, State.Cargo
                LD B, #12
ClearCargo:     LD (HL), A
                INC HL
                DJNZ ClearCargo

                LD L, #B0
                SET MS_CARGO_BIT, (HL)
ReturnCargo:    JP @Game.Menus.PrintStatusFieldAndCargoScreen.CargoScreen

                ; проверка исходного конца фрагмента
                ASSERT $ == #E6EE
                endmodule
                endmodule
