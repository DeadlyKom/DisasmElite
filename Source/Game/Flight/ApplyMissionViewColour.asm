                module Flight
                module ApplyMissionViewColour
; -----------------------------------------
; Выбор цвета обзорного окна для первой миссии
; исходный диапазон #725C..#7264
; In:
;   D081 состояние первой миссии
; Out:
;   при ненулевом состоянии продолжение 7259 с L=2
; Corrupt:
;   HL, AF, прочие по 6FF8
; Note:
;   Нулевое состояние возвращается без изменения атрибутов
; -----------------------------------------
                ASSERT $ == #725C
                ; проверка первой миссии перед применением её цвета
Entry:          LD A, (State.Mission1)
                AND A
MissionColour:  LD L, #02
                JR NZ, @Game.Flight.ToggleCloakingDevice.ApplyColour            ; переход, если первая миссия активна, применить атрибут 2

                RET
                ASSERT $ == #7265
                endmodule
                endmodule
