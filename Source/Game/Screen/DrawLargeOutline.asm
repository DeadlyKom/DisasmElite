                module Screen
                module DrawLargeOutline
; -----------------------------------------
; установка контурного режима и общий выход построителя окружности
; In:
;   поля CircleState.OffsetY, OffsetX, Flags и Radius
; Out:
;   контур нарисован, прерывания включены
; Corrupt:
;   HL, DE, BC, AF, HL', DE', BC', AF'
; Note:
;   вход Game.Screen.DrawLargeOutline.Entry записывает 1 в режим CircleState.OutlineOnly и вызывает Game.Circles.DispatchClippedCircle.Entry
;   вход Game.Screen.DrawLargeOutline.DrawAndEnable используется также заполненным кругом с уже установленным нулевым режимом
;   EI выполняется безусловно, прежнее состояние IFF не восстанавливается
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #86E4
                ; установка режима контура без заливки
Entry:          LD A, #01
                LD (CircleState.OutlineOnly), A
                ; построение окружности с общим выходом и включением прерываний
DrawAndEnable:  CALL Game.Circles.DispatchClippedCircle.Entry
                EI
                RET

                ASSERT $ == #86EE
                endmodule
                endmodule
