                module Extensions
                module OfferUpgradeAndCorrectPosition
; -----------------------------------------
; предложение улучшения корабля и коррекция координат второго объекта
; исходный диапазон #5FA1..#5FFF
; смысловое имя OfferShipUpgradeAndCorrectCoordinates
; In: IX — объект для дополнительного входа #5FD5, состояние пилота в #D054
; Out: подтверждение Y устанавливает #D08E=#FD и уменьшает #D067
; Corrupt: HL, DE, BC, AF, флаги и память вызываемых экранных процедур
; Предложение доступно при #D067!=0, Flags2 второго слота #6095=#0C и неустановленном #D08E
; Встроенный токен #F4 после CALL #D421 является аргументом принтера
; Вход #5FD5 обслуживает IX с младшим байтом #10 и совпадающим знаком оси
; Он снимает адрес возврата и выбирает координату #D097 либо #D099 по #8ACB/#8AC2
; Последняя ADD A,A продолжается в следующем файле с адреса #6000
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #5FA1
                ; миссия 6 Cobra Mk4, проверка предложения покупки за 256000 кредитов
                ; описание в Docs/Manual.md, раздел mission-6
                ; обновление текста и третьего задания перед предложением улучшения
Entry:          CALL Game.Text.OfferRegionDependentMission.Entry
                CALL Game.Flight.DispatchThirdMissionStage.Entry
                ; проверка денег, дополнительных флагов корабля и отсутствия уже установленного улучшения
                LD A, (State.CashHigh + 1)
                AND A
                RET Z                                                           ; выход, если старший байт CashHigh равен нулю, денег для улучшения недостаточно

                LD A, (Memory.Objects + FSpaceObject.Flags2)
                XOR OBJ_STATION_FL
                RET NZ                                                          ; выход, если Flags2 второго слота отличается от #0C

                LD A, (State.ShipUpgrade)
                AND A
                RET NZ                                                          ; выход, если улучшение #D08E уже установлено

                ; вывод предложения и ожидание подтверждения клавишей Y
                CALL Game.Text.ClearViewAndFrame.Entry
                LD A, #5C
                CALL Game.Text.PrintDescriptionToken.Entry
                CALL Game.Text.PrintInlineToken.Entry
                DB #F4                                                          ; данные #5FC2..#5FC2
                CALL Game.Trade.WaitForKeyCode.Entry
                CP #59
                RET NZ                                                          ; выход, если ответ отличается от Y

                CALL Game.Trade.OptionalBeep.Entry
                ; запись улучшения и вычитание 256000 кредитов через старший байт CashHigh
                LD HL, State.ShipUpgrade
                LD (HL), #FD
                LD L, #67
                DEC (HL)
                RET

                ; дополнительный вход проверки второго координатного объекта
CorrectCentre:  LD A, IXL
                CP #10
                JR NZ, Game.Data.SystemBoundaryAndObjects.ClampZ                ; переход, если младший байт IX отличается от #10, продолжить с #6043

                LD A, (FlightState.Planet + 2 * FCoordinate + FCoordinate.SignHigh)
                XOR (IX+FCoordinate+FCoordinate+FCoordinate.SignHigh)
                RLCA
                JR C, Game.Data.SystemBoundaryAndObjects.ClampZ                 ; переход, если знаки #7118 и IX+08 различаются, продолжить с #6043

                ; удаление внутреннего возврата и выбор преобладающей координаты
                POP HL
                LD HL, State.SystemSeed + FSystemSeed.Y
                LD A, (DistantBodies.Second.Z + FCoordinate.SignHigh)
                LD B, A
                ADD A, A
                LD D, A
                CP #0C
                CALL NC, Game.Text.InitializeSixTriples.Entry                   ; вызов, если удвоенная координата не меньше 12, восстановить шесть начальных троек
                LD A, (DistantBodies.First.Z + FCoordinate.SignHigh)
                LD C, A
                ADD A, A
                CP D
                LD A, C
                JR NC, DoubleDominant                                           ; переход, если удвоенная #8AC2 не меньше удвоенной #8ACB, оставить координату #D097

                LD L, #99
                LD A, B
DoubleDominant: ADD A, A
                ; проверка исходного конца фрагмента
                ASSERT $ == #6000
                endmodule
                endmodule
