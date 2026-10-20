                module Extensions
                module UpdateInvasionOnRatingOverflow
; -----------------------------------------
; обработка старшего байта рейтинга и запуск вторжения
; исходный диапазон #5E78..#5EC4
; смысловое имя UpdateInvasionAfterRatingOverflow
; In: HL=#D062 после переполнения младшего слова рейтинга в #D1C7
; Out: HL=#D0C9, состояние вторжения и код военного допуска скорректированы
; Corrupt: HL, AF
; #D08F>=2 означает идущее вторжение, тогда чётный код D062 уменьшается до нечётного, сдерживая обычное повышение
; При D08F=0/1 сначала сбрасывается бит 6 D062, который принтер D755 использует для подписи IN RESERVE
; Ненулевые Mission1=D081 либо Mission3=D0AF запрещают запуск нового вторжения
; Для допуска требуется ненулевой AlienComputer=D086 либо MineralLife=D087, D08F=0 и D062>=#20
; Дополнительно исходный код требует D062 AND D064 !=0, D064 — старший байт счётчика переходов, отдельного именованного флага этот AND не выбирает
; При успехе D062=D08F=#81, маска D0B0 AND #D0 очищает завершённые этапы 0..3 и занятый миссией трюм 5
; При отказе по оборудованию, рейтингу или пересечению битов устанавливается D064.7, сохраняя исходную связь со счётчиком переходов
; При D08F=1 после установки D064.7 проверяется и при необходимости уменьшается именно D064, так как L уже равен 64
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #5E78
                ; миссия 7 INVASION, проверка условий начала вторжения
                ; описание в Docs/Manual.md, раздел mission-7-invasion
                ; проверка активного военного состояния перед переходами задания
Entry:          LD A, (State.Invasion)
                AND INV_ACTIVE_MASK
                JR NZ, ReduceIfEven                                             ; переход, если #D08F содержит активное состояние задания

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
                JR Z, CheckRating                                               ; переход, если #D08F равен нулю, проверить допуск нового задания

                LD L, LOW State.JumpFlags
                SET JUMP_MSN_BIT, (HL)
                JR ReduceIfEven

                ; проверка порога #20 и общих битов разрешения
CheckRating:    LD A, (State.RankState)
                CP RANK_ELITE_MIN
                JR C, MarkJumpCount                                             ; переход, если #D062 меньше #20, установить флаг #D064.7

                LD L, LOW State.JumpFlags
                AND (HL)
                JR Z, MarkJumpCount                                             ; переход, если общих битов #D062 и #D064 нет, установить флаг #D064.7

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
