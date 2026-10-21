                module Flight
                module MarkMissionViewInitialized
; -----------------------------------------
; Инициализация признака специального вида первой миссии
; исходный диапазон #726C..#7277
; In:
;   State.Mission1 состояние первой миссии
; Out:
;   при активности MissionNotice=1 и цвет L=2
; Corrupt:
;   HL, AF, прочие по Game.Extensions.AttributeVectorAndEnergyBomb.Entry
; Note:
;   Нулевое состояние не изменяет ни флаг, ни цвет
; -----------------------------------------
                ASSERT $ == #726C
                ; пометка входа в окно первой миссии
                ; миссия 1, беженцы, после вылета отмечается уже показанное предупреждение первой миссии
                ; описание в Docs/Manual.md, раздел mission-1
Entry:          LD A, (State.Mission1)
                AND A
                RET Z                                                           ; выход, если первая миссия не активна

                LD A, #01
                LD (MissionNotice), A
                JR @Game.Flight.ApplyMissionViewColour.MissionColour

                ASSERT $ == #7278
                endmodule
                endmodule
