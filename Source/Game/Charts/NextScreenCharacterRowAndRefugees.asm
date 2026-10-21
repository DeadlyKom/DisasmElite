                module Charts
                module NextScreenCharacterRowAndRefugees
; -----------------------------------------
; Переход между восьмистрочными блоками экрана
; исходный диапазон #E6A3..#E6C5
; In:
;   HL = адрес после INC H на границе 8 строк
; Out:
;   L увеличен на 32, H уменьшен на 8 если переноса L нет
; Corrupt:
;   HL, AF
; Note:
;   OfferRefugees отдельно начинает проверку приёма беженцев по MS_CARGO_BIT в State.MissionFlags и специальному условию
;   Game.Input.ToggleSecondaryCoordinateObject.CheckPilot, это не продолжение после RET
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E6A3
                ; переход между блоками восьми растровых строк корректирует L и старшую часть адреса
Entry:          LD A, L
                ADD A, #20
                LD L, A
                RET C                                                           ; выход, если L+32 переполнилось, уменьшать H на 8 не требуется

                LD A, H
                SUB #08
                LD H, A
                RET

                ; сохранённый нулевой байт после перехода экранной строки
                DB #00                                                          ; #E6AD..#E6AD
                ; миссии 1 и 7+1, предложение перевозки при свободном миссионном трюме
                ; описание в Docs/Manual.md, раздел mission-1 и mission-7-1
                ; проверка предложения перевозки беженцев через специальный допуск Game.Input.ToggleSecondaryCoordinateObject.CheckPilot
OfferRefugees:  LD A, (State.MissionFlags)
                BIT MS_CARGO_BIT, A
                JR NZ, @Game.Trade.ResetCloakingAndSeedFlightRandom.BusyCargo   ; переход, если бит 5 флагов миссии установлен, трюм уже занят беженцами или десантом

                LD DE, #5B17                                                    ; D=#5B токен предложения беженцев, E=#17 атрибут
                LD HL, #0201
                CALL @Game.Input.ToggleSecondaryCoordinateObject.CheckPilot
                NOP
                JR NC, @Game.Trade.ResetCloakingAndSeedFlightRandom.OpenBuy     ; переход, если специальный допуск не выдан, открыть обычное меню покупки

                CALL Game.Missions.SpecialMessageAndScoopReward.Entry
                JR Game.Trade.MissionRegionMetric.BoardRefugees

                ; проверка исходного конца фрагмента
                ASSERT $ == #E6C6
                endmodule
                endmodule
