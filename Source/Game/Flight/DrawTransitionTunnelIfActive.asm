                module Flight
                module DrawTransitionTunnelIfActive
; -----------------------------------------
; Обновление сообщения и активного тоннеля перехода
; исходный диапазон #928C..#9295
; In:
;   JumpMode признак тоннеля
; Out:
;   при активности продолжение Game.Flight.AnimateTransitionTunnel.SelectFrameEnd, иначе возврат
; Corrupt:
;   HL, DE, BC, AF, IX, IY по рисованию
; Note:
;   Сначала Game.Interface.DispatchFlightMessage.Entry обслуживает полётные сообщения, тот же тоннель используется запуском, стыковкой и
;   гиперпереходом
; -----------------------------------------
                ASSERT $ == #928C
                ; обработка пространства и проверка активности туннеля
Entry:          CALL Game.Interface.DispatchFlightMessage.Entry
                LD A, (JumpMode)
                AND A
                RET Z                                                           ; выход, если туннель перехода не активен

                JR @Game.Flight.AnimateTransitionTunnel.SelectFrameEnd

                ASSERT $ == #9296
                endmodule
                endmodule
