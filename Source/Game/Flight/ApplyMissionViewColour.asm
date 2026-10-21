                module Flight
                module ApplyMissionViewColour
; -----------------------------------------
; Выбор цвета обзорного окна для первой миссии
; исходный диапазон #725C..#7264
; In:
;   State.Mission1 состояние первой миссии
; Out:
;   при ненулевом состоянии продолжение Game.Flight.ToggleCloakingDevice.ApplyColour с L=2
; Corrupt:
;   HL, AF, прочие по Game.Extensions.AttributeVectorAndEnergyBomb.Entry
; Note:
;   Нулевое состояние возвращается без изменения атрибутов
; -----------------------------------------
                ASSERT $ == #725C
                ; проверка первой миссии перед применением её цвета
                ; миссия 1, беженцы, активная первая миссия выбирает особую окраску вида
                ; описание в Docs/Manual.md, раздел mission-1
Entry:          LD A, (State.Mission1)
                AND A
MissionColour:  LD L, #02
                JR NZ, @Game.Flight.ToggleCloakingDevice.ApplyColour            ; переход, если первая миссия активна, применить атрибут 2

                RET

                ASSERT $ == #7265
                endmodule
                endmodule
