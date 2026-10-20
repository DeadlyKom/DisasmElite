                module Flight
                module MarkMissionViewInitialized
; -----------------------------------------
; Инициализация признака специального вида первой миссии
; исходный диапазон #726C..#7277
; In:
;   D081 состояние первой миссии
; Out:
;   при активности D0BA=1 и цвет L=2
; Corrupt:
;   HL, AF, прочие по 6FF8
; Note:
;   Нулевое состояние не изменяет ни флаг, ни цвет
; -----------------------------------------
                ASSERT $ == #726C
                ; пометка входа в окно первой миссии
Entry:          LD A, (State.Mission1)
                AND A
                RET Z                                                           ; выход, если первая миссия не активна

                LD A, #01
                LD (MissionNotice), A
                JR @Game.Flight.ApplyMissionViewColour.MissionColour
                ASSERT $ == #7278
                endmodule
                endmodule
