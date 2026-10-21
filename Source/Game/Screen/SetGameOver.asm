                module Screen
                module SetGameOver
; -----------------------------------------
; установка признака гибели игрока
; In:
;   не требуются
; Out:
;   байт FlightState.PlayerDead равен 1
;   AF, A равен 1
; Corrupt:
;   AF
; Note:
;   анимация гибели и возврат к началу выполняются главным циклом, а не этим входом
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #82D1
Entry:          LD A, #01
                LD (FlightState.PlayerDead), A
                RET

                ASSERT $ == #82D7
                endmodule
                endmodule
