                module Flight
                module ToggleCloakingDevice
; -----------------------------------------
; Переключение маскировки клавишей Y
; исходный диапазон #7222..#725B
; In:
;   InputState bit7, State.MissionFlags bit6 наличие устройства,GaugeState + FGaugeState.Energy3.Current энергия
; Out:
;   CloakActive изменён, при включении требуется энергия>=40 и снимается конфликт со стыковкой
; Corrupt:
;   HL, AF, прочие по Game.Extensions.AttributeVectorAndEnergyBomb.Entry
; Note:
;   Счётчик CloakDivider опрашивает нажатие через раз, RES7 очищает старый бит и HALT позволяет прерыванию его
;   обновить
;   Уменьшение CloakActive с 1 до 0 выключает устройство, при исходном 0 промежуточное FF остаётся при
;   недостатке энергии, это фактический порядок оригинала
; -----------------------------------------
                ASSERT $ == #7222
                ; делитель частоты проверки, старая клавиша снимается до HALT
                ; миссия 2 CLOAKING DEVICE, наличие CLOAKING DEVICE разрешает переключение маскировки клавишей Y
                ; описание в Docs/Manual.md, раздел mission-2
Entry:          LD HL, CloakDivider
                DEC (HL)
                LD HL, InputState.SystemKeys
                RES SYS_Y_BIT, (HL)
                RET NZ                                                          ; выход, если очередь проверки маскировки ещё не наступила

                LD A, #02
                LD (CloakDivider), A
                HALT
                ; проверка нового нажатия после HALT и наличия маскировки
                BIT SYS_Y_BIT, (HL)
                RET Z                                                           ; выход, если за время HALT клавиша маскировки не появилась

                LD HL, State.MissionFlags
                BIT MS_CLOAK_BIT, (HL)
                RET Z                                                           ; выход, если устройство маскировки отсутствует

                ; переключение состояния, переход 1→0 выключает устройство
                LD HL, CloakActive
                DEC (HL)
                JR Z, NormalColour                                              ; переход, если маскировка была включена, выбрать обычный атрибут 7

                ; проверка энергии, при отказе после 0→FF остаётся CloakActive=FF
                LD A, (GaugeState + FGaugeState.Energy3.Current)
                CP #28
                RET C                                                           ; выход, если третий банк энергии меньше 40, включение прекращается

                ; включение маскировки снимает враждебность станции и признак атаки
                LD A, #01
                LD (HL), A
                LD HL, Memory.Station + FSpaceObject.Hostility
                RES 2, (HL)
                XOR A
                LD (CombatState.Danger), A
                ; атрибут маскировки имеет значение 0F
CloakedColour:  LD L, #0F
                JR ApplyColour

                ; обычный атрибут после выключения имеет значение 07
NormalColour:   LD L, #07
ApplyColour:    JP Game.Extensions.AttributeVectorAndEnergyBomb.Entry

                ASSERT $ == #725C
                endmodule
                endmodule
