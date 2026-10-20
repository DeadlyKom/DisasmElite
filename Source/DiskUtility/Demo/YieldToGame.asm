; -----------------------------------------
; Уступка кадра с сохранением состояния корутины
; исходный диапазон #E730..#E768
; In:
;   SP демо, E6DC стек игры
; Out:
;   шесть пар сохранены в демо, возврат на стек игры
; Corrupt:
;   HL, AF для обработки клавиш, SP, остальные сохраняются в стеке
; Note:
;   Аппаратная Z по FEFE.1 перенаправляет следующий ResumeDemo в ManualControl
;   Аппаратная V по FEFE.4 сбрасывает стек EF00 и выбирает FollowStation/ApproachBody по знаку Z планеты 7118
;   Обычный путь сохраняет AF,BC,DE,HL,IX,IY, затем E6DE=SP и SP=(E6DC), RET возвращается в FrameHook
; -----------------------------------------
                ; сохранение AF и прямое чтение физического ряда CAPS SHIFT,Z,X,C,V
YieldToGame:    PUSH AF
                LD A, #FE
                IN A, (#FE)
                BIT 1, A
                JR NZ, CheckResetKey                                            ; переход, если физическая Z не нажата, проверить V

                ; нажатие Z перенаправляет следующий возврат корутины в ручной цикл
                POP AF
                PUSH AF
                LD HL, ManualControl
                LD (ResumeJump+1), HL
                JR SaveCoroutine

                ; проверка V для полного сброса текущего сценария
CheckResetKey:  BIT 4, A
                JR NZ, SaveCoroutine                                            ; переход, если физическая V не нажата, сохранить текущую корутину

                ; отмена текущего стека и повторный выбор сценария по знаку Z планеты
                LD SP, StackTop
                LD A, #01
                LD (LaunchPending), A
                LD A, (FlightState.Planet + FSpaceObject.Z.SignHigh)
                RLCA
                JP NC, FollowStation                                            ; переход, если Z планеты неотрицательна, перезапустить сопровождение станции

                JP ApproachBody

                ; сохранение остальных пяти пар и фиксация текущего стека демо
SaveCoroutine:  PUSH BC
                PUSH DE
                PUSH HL
                PUSH IX
                PUSH IY
                LD (DemoStack), SP
                ; возврат игрового SP и выход в прерванный кадровый обработчик
                LD SP, (SavedStacks)
                RET
