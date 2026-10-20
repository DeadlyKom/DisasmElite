                module Flight
                module DrawTransitionTunnelIfActive
; -----------------------------------------
; Обновление сообщения и активного тоннеля перехода
; исходный диапазон #928C..#9295
; In:
;   D03F признак тоннеля
; Out:
;   при активности продолжение 92D6, иначе возврат
; Corrupt:
;   HL, DE, BC, AF, IX, IY по рисованию
; Note:
;   Сначала D03C обслуживает полётные сообщения, тот же тоннель используется запуском, стыковкой и
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
