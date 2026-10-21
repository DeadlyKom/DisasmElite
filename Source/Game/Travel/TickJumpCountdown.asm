                module Travel
                module TickJumpCountdown
; -----------------------------------------
; Уменьшение и отображение отсчёта гиперперехода
; исходный диапазон #DC29..#DC82
; In:
;   JumpCountdown = отсчёт в половинах отображаемой единицы
; Out:
;   Печатается прежнее значение>>1 либо начинается переход
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Нулевой отсчёт ничего не делает, при достижении 0 очищает очередь, JumpMode=2 очищает активные
;   миссии и запускает галактическое преобразование, затем выбирает систему и входит Game.Travel.EnterTargetSystem.Entry
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #DC29
                ; уменьшение активного счётчика и печать оставшегося времени гиперперехода
Entry:          LD HL, JumpCountdown
                LD A, (HL)
                AND A
                RET Z                                                           ; выход, если отсчёт гиперперехода не активен

                DEC (HL)
                JR Z, CommitJump                                                ; переход, если счётчик после уменьшения обнулился, выполнить переход

                LD B, A
                LD A, #02
                LD (NumberWidth), A
                LD HL, #0101
                LD (TextColumn), HL
                LD A, B
                SRL A
                JP Game.Economy.PrintByteInteger.Entry

                ; после завершения отсчёта разделяются обычный и галактический переходы
CommitJump:     CALL Game.Travel.ClearFlightEventsAndHandleJump.Entry
                LD A, (JumpMode)
                SUB #02
                JR NZ, Game.Travel.CommitJumpFuelAndMishap.Entry                ; переход, если режим перехода не равен 2, выполнять обычный гиперпереход

                ; миссии 1, 3, общий переход очищает активные старые миссии и предупреждение
                ; описание в Docs/Manual.md, раздел mission-1, mission-3
ClearMissions:  XOR A
                LD (State.Mission3), A
                LD A, (State.Mission1)
                AND A
                JR Z, UseGalDrive                                               ; переход, если первая миссия не активна, не выполнять её отдельный хвост

                XOR A
                LD (State.Mission1), A
                LD (MissionNotice), A
UseGalDrive:    CALL Game.Extensions.ConsumeGalacticDriveCharge.Entry
                LD HL, State.Galaxy
                PUSH BC
                PUSH DE
                PUSH AF
                CALL Game.Universe.SelectGalaxyOnJump.Entry
                POP AF
                POP DE
                POP BC
                LD A, (State.Galaxy)
                LD (EquipmentTable.FuelPrice), A
                AND #07
                LD (State.Galaxy), A
                NOP
                XOR A
                LD (State.LegalStatus), A
                CALL Game.Galaxy.SelectNearestSystemWithCursor.Entry
                JR Game.Travel.EnterTargetSystem.Entry

                ; проверка исходного конца фрагмента
                ASSERT $ == #DC83
                endmodule
                endmodule
