                module Screen
                module CompassShape
; -----------------------------------------
; переход к выбору изображения указателя компаса
; In:
;   байты FlightState.SpaceMode и InputPhase задают режим компаса
; Out:
;   HL, адрес изображения Game.Extensions.PrintEquipmentAndSelectIcon.ModeIcons, Game.Extensions.PrintEquipmentAndSelectIcon.ModeIcons + 8 или Game.Extensions.PrintEquipmentAndSelectIcon.ModeIcons + 16
;   DE, #0008
; Corrupt:
;   HL, DE, AF
; Note:
;   это хвостовой переход, дополнительный адрес возврата не создаётся
;   в обычной системе FlightState.SpaceMode=0 выбирается Game.Extensions.PrintEquipmentAndSelectIcon.ModeIcons
;   иначе бит 0 по InputPhase выбирает Game.Extensions.PrintEquipmentAndSelectIcon.ModeIcons + 8 или Game.Extensions.PrintEquipmentAndSelectIcon.ModeIcons + 16, в InputViewSkip записывается #02
;   вызывается рисованием компаса Game.Screen.VectorLength.DrawCompass перед выбором передней или задней формы
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #8442
Entry:          JP Game.Extensions.PrintEquipmentAndSelectIcon.SelectIcon

                ASSERT $ == #8445
                endmodule
                endmodule
