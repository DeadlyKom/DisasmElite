                module Flight
                module ApplyCloakingViewColour
; -----------------------------------------
; Повторное применение цвета маскировки
; исходный диапазон #7265..#726B
; In:
;   CloakActive состояние маскировки
; Out:
;   ненулевое состояние выбирает L=15 через Game.Flight.ToggleCloakingDevice.CloakedColour
; Corrupt:
;   HL, AF, прочие по Game.Extensions.AttributeVectorAndEnergyBomb.Entry
; Note:
;   Использует общий хвост изменения атрибутов, собственных данных нет
; -----------------------------------------
                ASSERT $ == #7265
                ; проверка маскировки перед применением её цвета
                ; миссия 2 CLOAKING DEVICE, активная маскировка восстанавливает свой цвет полётного вида
                ; описание в Docs/Manual.md, раздел mission-2
Entry:          LD A, (CloakActive)
                AND A
                JR NZ, @Game.Flight.ToggleCloakingDevice.CloakedColour          ; переход, если маскировка включена, применить атрибут 0F

                RET

                ASSERT $ == #726C
                endmodule
                endmodule
