                module Input
                module ClampAndStoreFlightSpeed
; -----------------------------------------
; ограничение скорости и общий выход управления
; исходный диапазон #FF0E..#FF24
; смысловое имя ClampAndStoreFlightSpeed
; In: HL — рассчитанная скорость, DE — шаг, C-флаг — заём при торможении
; Out: InputMotion.Speed обновлён, InputState.FlightKeys=0, A=0 и Z=1
; Corrupt: HL, AF
; Вход Game.Input.ClampAndStoreFlightSpeed.Entry обнуляет скорость при заёме, иначе сразу сохраняет
; Вход Game.Input.ClampAndStoreFlightSpeed.SpeedLimit отменяет шаг увеличения при достижении бита 5 старшего байта
; Сброс InputState.FlightKeys завершает обработку однотактных команд скорости и направлений
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #FF0E
                ; проверка заёма после уменьшения скорости
Entry:          JR NC, StoreSpeed                                               ; переход, если уменьшение скорости не вызвало заём, сохранить результат

                LD HL, #0000
                JP StoreSpeed

                ; проверка верхнего предела после увеличения скорости
SpeedLimit:     BIT 5, H
                JR Z, StoreSpeed                                                ; переход, если предел скорости по H.5 не достигнут, сохранить увеличение

                ; отмена последнего шага при достижении верхнего предела
                AND A
                SBC HL, DE
                ; сохранение скорости и очистка обработанных команд
StoreSpeed:     LD (InputMotion.Speed), HL
                XOR A
                LD (InputState.FlightKeys), A
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #FF25
                endmodule
                endmodule
