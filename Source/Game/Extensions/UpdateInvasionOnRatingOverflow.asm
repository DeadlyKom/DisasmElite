                module Extensions
                module UpdateInvasionOnRatingOverflow
; -----------------------------------------
; обработка старшего байта рейтинга и запуск вторжения
; исходный диапазон #5E78..#5EC4
; смысловое имя UpdateInvasionAfterRatingOverflow
; In: HL=State.RankState после переполнения младшего слова рейтинга в Game.Missions.RatingBountyDamageAndNewCommander.Entry
; Out: HL=FlightEvents + 6 * FFlightEvent + FFlightEvent.ColumnFlags, состояние вторжения и код военного допуска скорректированы
; Corrupt: HL, AF
; State.Invasion>=2 означает идущее вторжение, тогда чётный код State.RankState уменьшается до нечётного, сдерживая обычное повышение
; При State.Invasion=0/1 сначала сбрасывается бит 6 State.RankState, который принтер Game.Text.PrintRankWithMissionSuffix.Entry использует для подписи IN RESERVE
; Ненулевые Mission1=State.Mission1 либо Mission3=State.Mission3 запрещают запуск нового вторжения
; Для допуска требуется ненулевой AlienComputer=State.AlienComputer либо MineralLife=State.MineralLife, State.Invasion=0 и State.RankState>=#20
; Дополнительно исходный код требует State.RankState AND State.JumpFlags !=0, State.JumpFlags — старший байт счётчика переходов, отдельного именованного флага этот AND не выбирает
; При успехе State.RankState=State.Invasion=#81, маска State.MissionFlags AND #D0 очищает завершённые этапы 0..3 и занятый миссией трюм 5
; При отказе по оборудованию, рейтингу или пересечению битов устанавливается State.JumpFlags.7, сохраняя исходную связь со счётчиком переходов
; При State.Invasion=1 после установки State.JumpFlags.7 проверяется и при необходимости уменьшается именно State.JumpFlags, так как L уже равен 64
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #5E78
                ; миссия 7 INVASION, проверка условий начала вторжения
                ; описание в Docs/Manual.md, раздел mission-7-invasion
                ; проверка активного военного состояния перед переходами задания
Entry:          LD A, (State.Invasion)
                AND INV_ACTIVE_MASK
                JR NZ, ReduceIfEven                                             ; переход, если State.Invasion содержит активное состояние задания

                RES RANK_RSV_BIT, (HL)
                LD A, (State.Mission1)
                LD L, LOW State.Mission3
                OR (HL)
                JR NZ, ReturnInput                                              ; переход, если первая либо третья миссия активна, новое вторжение не запускается

                ; проверка двух условий допуска в полях пилота
                LD L, LOW State.AlienComputer
                LD A, (HL)
                INC HL
                OR (HL)
                JR Z, MarkJumpCount                                             ; переход, если AlienComputer и MineralLife отсутствуют, установить бит 7 старшего счётчика переходов

                LD A, (State.Invasion)
                AND A
                JR Z, CheckRating                                               ; переход, если State.Invasion равен нулю, проверить допуск нового задания

                LD L, LOW State.JumpFlags
                SET JUMP_MSN_BIT, (HL)
                JR ReduceIfEven

                ; проверка порога #20 и общих битов разрешения
CheckRating:    LD A, (State.RankState)
                CP RANK_ELITE_MIN
                JR C, MarkJumpCount                                             ; переход, если State.RankState меньше #20, установить флаг State.JumpFlags.7

                LD L, LOW State.JumpFlags
                AND (HL)
                JR Z, MarkJumpCount                                             ; переход, если общих битов State.RankState и State.JumpFlags нет, установить флаг State.JumpFlags.7

                ; перевод пилота и задания в начальное активное состояние #81
                LD L, LOW State.MissionFlags
                LD A, (HL)
                AND H                                                           ; H=#D0, маска MS_START_MASK сохраняет оборудование и пятую отметку
                LD (HL), A
                LD A, RANK_START_CODE
                LD (State.RankState), A
                LD (State.Invasion), A
                JR ReturnInput

MarkJumpCount:  LD L, LOW State.JumpFlags
                SET JUMP_MSN_BIT, (HL)
ReturnInput:    LD L, #C9
                RET

                ; проверка чётности всего RankState либо JumpFlags, по фактическому входу HL
ReduceIfEven:   BIT 0, (HL)
                JR NZ, ReturnInput                                              ; переход, если проверяемый байт нечётный, уменьшение не требуется

                DEC (HL)
                JR ReturnInput

                ; проверка исходного конца фрагмента
                ASSERT $ == #5EC5
                endmodule
                endmodule
