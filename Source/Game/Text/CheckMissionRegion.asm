                module Text
                module CheckMissionRegion
; -----------------------------------------
; Геометрическая проверка области миссии со встроенным порогом
; исходный диапазон #D67A..#D6A9
; In:
;   State.SystemSeed + FSystemSeed.Y/State.SystemSeed + FSystemSeed.X = координаты, State.Galaxy = галактика, State.Invasion = состояние, байт после CALL = порог
; Out:
;   Флаги сравнения метрик, HL = разность на полном пути
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Работает только в галактике 0 и при State.Invasion>=2, читает байт через EX(SP), HL и сдвигает адрес
;   возврата на 1, два вызова Game.Trade.MissionRegionMetric.Entry сравнивают специальные метрики относительно Y=92, ранние
;   возвраты до чтения байта его не поглощают
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D67A
                ; миссия 7 INVASION, проверка принадлежности системы области вторжения
                ; описание в Docs/Manual.md, раздел mission-7-invasion
                ; фронт вторжения существует только в первой галактике при Invasion не меньше 2
Entry:          LD HL, State.SystemSeed + FSystemSeed.Y
CheckGalaxy:    LD A, (State.Galaxy)
                AND A
                RET NZ                                                          ; выход, если индекс галактики ненулевой, фронта вторжения здесь нет

                LD A, (State.Invasion)
                CP INV_ACTIVE_MIN
                CCF
                RET NC                                                          ; выход, если состояние вторжения равно 0 или 1, активная геометрия фронта отсутствует

                ADD A, A
                EX (SP), HL
                ; встроенный порог после CALL прибавляется к удвоенному состоянию с насыщением до 255
                LD B, #5C
                ADD A, (HL)
                JR NC, ConsumeLimit                                             ; переход, если прибавление встроенного порога к удвоенному состоянию не переполнилось

                SBC A, A
ConsumeLimit:   INC HL
                EX (SP), HL
                PUSH HL
                ; сравнение квадрата радиуса фронта и метрики положения системы относительно Y=92,X=0
                CALL Game.Trade.MissionRegionMetric.Entry
                JR C, RadiusOverflow                                            ; переход, если расчёт граничной метрики переполнился, восстановить HL и вернуть перенос

                EX (SP), HL
                LD B, (HL)
                INC HL
                INC HL
                LD A, (HL)
                CALL Game.Trade.MissionRegionMetric.Entry
                POP DE
                CCF
                RET NC                                                          ; выход, если метрика текущей системы переполнена, вернуть результат без вычитания

                AND A
                SBC HL, DE
                RET

RadiusOverflow: POP HL
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #D6AA
                endmodule
                endmodule
