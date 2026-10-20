                module Combat
                module UpdateClockAndRotateDistantBodies
; -----------------------------------------
; обновление накопителя времени и отдельное вращение далёких тел
; исходный диапазон #9B41..#9B82
; In:
;   память 70DC/70DD, счётчик
;   память D08F, темп и состояние
; Out:
;   счётчик и состояние обновлены
;   при входе 9B68 повёрнуты объект, планета и солнце
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
; Счётчик увеличивается на ~D08F, переполнение старшего байта регулирует D08F к крайним значениям.
; При отрицательной кодировке переполнение сообщает состояние через D0C7/D0C8.
; 9B68 отдельный вход, сначала вращает объект IX, затем координаты 8ABA и 8AC3.
; Для двух далёких тел временно патчит A1AD на RET, отключая перенос по скорости, затем возвращает LD A,(nn).
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #9B41
                ; миссия 7 INVASION, накопление времени и изменение состояния фронта
                ; описание в Docs/Manual.md, раздел mission-7-invasion
                ; расчёт приращения счётчика и проверка переполнения
Entry:          LD HL, FlightState.InvasionClock
                LD A, (State.Invasion)
                CPL
                ADD A, (HL)
                LD (HL), A
                RET NC                                                          ; выход, если младший счётчик не переполнился

                INC HL
                ; коррекция темпа после переполнения старшего байта
                INC (HL)
                RET NZ                                                          ; выход, если старший счётчик не переполнился

                LD HL, State.Invasion
                LD A, (HL)
                CP INV_ACTIVE_MIN
                RET C                                                           ; выход, если код темпа меньше 2 и уменьшать его не нужно

                RLCA
                JR C, TickNegative                                              ; переход, если старший бит кода темпа установлен

                DEC (HL)
                RET

TickNegative:   INC (HL)
                JR Z, WrapClock                                                 ; переход, если отрицательная кодировка достигла нуля и должна перейти к 7F

                LD L, #C7
                LD (HL), #82
                INC HL
                LD (HL), #F0
                RET

WrapClock:      LD (HL), INV_RETREAT_MAX
                RET

                ; отдельный вход вращения объекта и двух далёких тел
RotateBodies:   CALL Game.Combat.ApplyPlayerMotion.Entry
                LD IX, DistantBodies.First.X
                LD HL, MotionRaster.TranslateGate
                LD (HL), #C9
                PUSH HL
                CALL Game.Combat.ApplyPlayerMotion.Entry
                LD IX, DistantBodies.Second.X
                CALL Game.Combat.ApplyPlayerMotion.Entry
                POP HL
                LD (HL), #3A
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #9B83
                endmodule
                endmodule
