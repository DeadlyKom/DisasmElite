                module Flight
                module AnimateTransitionTunnel
; -----------------------------------------
; Анимация тоннеля гиперперехода и стыковки
; исходный диапазон #9296..#9380
; In:
;   ViewKeyLock активное завершение перехода,TunnelRings число колец,HyperDepths/DockDepths счётчики глубины
; Out:
;   кадр тоннеля и счётчики изменены, общий Game.Flight.AnimateTransitionTunnel.SetSpeed устанавливает скорость 7
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
;   Для каждого кольца счётчик уменьшается, радиус вычисляется как 256/счётчик, значения меньше 4 не
;   рисуются
;   Операнд TunnelDepths выбирает таблицу 16 гиперколец или 8 стыковочных колец,TunnelLeft хранит остаток цикла
;   TunnelPhase выбирает ShowFrame либо FadeTunnel, TunnelLimit хранит порог затухания, TunnelFinish выбирает завершение гиперперехода, EndLaunch либо EndDocking
;   хвост FadeTunnel обнуляет ViewKeyLock и JumpMode и вычитает 190 из 16 HyperDepths, EndDocking снимает ViewKeyLock, EndDockTunnel снимает JumpMode и
;   вычитает 192 из 8 глубин
;   самомодификация является частью автомата фаз, хвосты FadeTunnel и EndDocking разобраны как
;   исполняемые обработчики
; -----------------------------------------
                ASSERT $ == #9296
                ; начало перехода, обслуживание минералов и очистка кораблей
Entry:          LD A, (ViewKeyLock)
                AND A
                RET Z                                                           ; выход, если новый этап перехода не запрошен

                CALL Game.Extensions.UpdateSpecialCargoStatus.Entry
                CALL Game.Flight.ClearNearbyShipSlots.Entry
                ; проверка особого пространства, в нём удаляется также станция
                LD A, (FlightState.SpaceMode)
                AND A
                JR Z, InitHyperRings                                            ; переход, если особый режим пространства выключен, сохранить станцию

                LD IX, Memory.Station
                XOR A
                LD (IX+FSpaceObject.Energy), A
                INC A
                CALL Game.Combat.DispatchObjectAction.Entry
                ; очистка экрана и подготовка шестнадцати глубин гипертуннеля
InitHyperRings: CALL Game.Screen.ClearFlightBuffer.Entry
                CALL Game.Screen.CopyFlightView.Entry
                LD A, #42
                LD (TunnelFrames), A
                CALL Game.Sound.PlayHyperjumpSound.Entry
                LD HL, HyperDepths
                ; подмена таблицы, числа колец, порога и завершающей ветви
                LD (TunnelDepths), HL
                LD A, #10
                LD (TunnelRings), A
                LD A, #01
                LD (TunnelLimit), A
                LD A, #15
                LD (TunnelFinish), A
                ; выбор завершения кадра через изменяемое смещение TunnelPhase
SelectFrameEnd: LD A, (ViewKeyLock)
                AND A
                JR NZ, MainFrameEnd                                             ; переход, если активен основной этап туннеля, выбрать вывод кадра

                LD A, #1E
                LD (TunnelPhase), A
                JR InitCircle

MainFrameEnd:   LD A, #05
                LD (TunnelPhase), A
                ; нулевой центр окружностей и признаки всех четвертей 0F
InitCircle:     LD A, CIRC_FLAGS_MASK
                LD (CircleState.Flags), A
                LD HL, #0000
                LD (CircleState.OffsetY), HL
                ; счётчик оставшихся колец берётся из конфигурации
                LD A, (TunnelRings)
                LD (TunnelLeft), A
                ; SMC, HL выбирает таблицу из 16 либо 8 глубин
DepthTable      EQU $ + 1                                                       ; адрес текущей таблицы глубин в операнде LD HL
SelectDepths:   LD HL, HyperDepths
                ; приближение кольца на единицу, радиус равен целой части 256/глубина
AdvanceRing:    LD A, (HL)
                DEC A
                LD (HL), A
                INC HL
                LD B, A
                LD A, #01
                CALL Game.Flight.DivideByteFractionForTunnel.Entry
                LD A, C
                ; проверка минимального видимого радиуса перед рисованием
                CP #04
                JR C, CountRing                                                 ; переход, если радиус кольца меньше 4, пропустить рисование

                LD (CircleState.Radius), A
                PUSH HL
                CALL Game.Screen.DrawLargeOutline.Entry
                POP HL
                ; проверка конца набора колец, переход со смещением TunnelPhase ведёт на Game.Flight.AnimateTransitionTunnel.ShowFrame либо Game.Flight.AnimateTransitionTunnel.FadeTunnel
CountRing:      LD A, (TunnelLeft)
                DEC A
PhaseJump       EQU $ + 1                                                       ; смещение JR Z, выбор этапа изменения туннеля
                JR Z, ShowFrame                                                 ; переход, если все кольца кадра обработаны, выполнить выбранный этап анимации

                LD (TunnelLeft), A
                JR AdvanceRing

                ; вывод кадра и уменьшение времени основного этапа
ShowFrame:      CALL Game.Screen.CopyFlightView.Entry
                LD A, (TunnelFrames)
                DEC A
                ; SMC, порог равен 1 для гипертуннеля либо 48 для стыковки
DepthLimit      EQU $ + 1                                                       ; изменяемая глубина завершения в операнде CP
                CP #30
                LD (TunnelFrames), A
                ; SMC, выбор завершения гиперперехода, стыковки или старта
FinishJump      EQU $ + 1                                                       ; смещение JR C, выбор завершения старта либо гипертуннеля
                JR C, EndLaunch                                                 ; переход, если счётчик кадров ниже подставленного порога, завершить текущий этап

                LD A, (TunnelRings)
                LD (TunnelLeft), A
                CALL Game.Screen.ClearFlightBuffer.Entry
                JR SelectDepths

                ; остаточная фаза уменьшает время до сброса флага и глубин
FadeTunnel:     LD A, (TunnelFrames)
                DEC A
                LD (TunnelFrames), A
                JR Z, EndDockTunnel                                             ; переход, если последний этап туннеля завершён, сбросить флаг и глубины колец

                RET

                ; завершение гиперперехода снимает оба флага и восстанавливает 16 глубин вычитанием BE
                XOR A
                LD (ViewKeyLock), A
                LD (JumpMode), A
                LD A, #10
                LD B, A
                LD HL, HyperDepths
RestoreHyper:   LD A, (HL)
                SUB #BE
                LD (HL), A
                INC HL
                DJNZ RestoreHyper

                CALL Game.Screen.ClearFlightBuffer.Entry
                CALL Game.Screen.CopyFlightView.Entry
                JP Game.Flight.DivideByteFractionForTunnel.FinishTunnel

                ; завершение старта снимает ViewKeyLock и задаёт скорость 7
EndLaunch:      XOR A
                LD (ViewKeyLock), A
                JR SetSpeed

                ; завершение посадки снимает только ViewKeyLock
EndDocking:     XOR A
                LD (ViewKeyLock), A
                RET

                ; окончание остаточной фазы снимает JumpMode и восстанавливает 8 глубин вычитанием C0
EndDockTunnel:  XOR A
                LD (JumpMode), A
                LD A, #08
                LD B, A
                LD HL, DockDepths
RestoreDock:    LD A, (HL)
                SUB #C0
                LD (HL), A
                INC HL
                DJNZ RestoreDock

                RET

                ; скорость после выхода из туннеля равна 7
SetSpeed:       LD A, #07
                LD (FlightState.Speed), A
                RET

                ASSERT $ == #9381
                endmodule
                endmodule
