                module Extensions
                module OfferUpgradeAndCorrectPosition
; -----------------------------------------
; предложение улучшения корабля и коррекция координат второго объекта
; исходный диапазон #5FA1..#5FFF
; смысловое имя OfferShipUpgradeAndCorrectCoordinates
; In: IX — объект для дополнительного входа Game.Extensions.OfferUpgradeAndCorrectPosition.CorrectCentre, состояние пилота в State
; Out: подтверждение Y устанавливает State.ShipUpgrade=#FD и уменьшает State.CashHigh + 1
; Corrupt: HL, DE, BC, AF, флаги и память вызываемых экранных процедур
; Предложение доступно при State.CashHigh + 1!=0, Flags2 второго слота Memory.Objects + FSpaceObject.Flags2=#0C и неустановленном State.ShipUpgrade
; Встроенный токен #F4 после CALL Game.Text.PrintInlineToken.Entry является аргументом принтера
; Вход Game.Extensions.OfferUpgradeAndCorrectPosition.CorrectCentre обслуживает IX с младшим байтом #10 и совпадающим знаком оси
; Он снимает адрес возврата и выбирает координату State.SystemSeed + FSystemSeed.Y либо State.SystemSeed + FSystemSeed.X по DistantBodies.Second.Z + FCoordinate.SignHigh/DistantBodies.First.Z + FCoordinate.SignHigh
; последняя ADD A, A передаёт поток в Game.Data.SystemBoundaryAndObjects.Continue
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #5FA1
                ; миссия 6 Cobra Mk4, проверка предложения покупки за 256000 кредитов
                ; описание в Docs/Manual.md, раздел mission-6
                ; обновление текста и третьего задания перед предложением улучшения
                ; миссии 3, 6, 7 INVASION, после посадки сначала обрабатываются задания, затем предложение Cobra Mk4
                ; описание в Docs/Manual.md, раздел mission-3, mission-6, mission-7-invasion
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
                RET NZ                                                          ; выход, если улучшение State.ShipUpgrade уже установлено

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
                JR NZ, Game.Data.SystemBoundaryAndObjects.ClampZ                ; переход, если младший байт IX отличается от #10, продолжить с Game.Data.SystemBoundaryAndObjects.ClampZ

                LD A, (FlightState.Planet + 2 * FCoordinate + FCoordinate.SignHigh)
                XOR (IX+FCoordinate+FCoordinate+FCoordinate.SignHigh)
                RLCA
                JR C, Game.Data.SystemBoundaryAndObjects.ClampZ                 ; переход, если знаки Z планеты в FlightState.Planet + FSpacePosition.Z.SignHigh и текущего тела в IX + FSpacePosition.Z.SignHigh различаются, продолжить с Game.Data.SystemBoundaryAndObjects.ClampZ

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
                JR NC, DoubleDominant                                           ; переход, если удвоенная DistantBodies.First.Z + FCoordinate.SignHigh не меньше удвоенной DistantBodies.Second.Z + FCoordinate.SignHigh, оставить координату State.SystemSeed + FSystemSeed.Y

                LD L, #99
                LD A, B
DoubleDominant: ADD A, A                                                        ; далее Game.Data.SystemBoundaryAndObjects.Continue без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #6000
                endmodule
                endmodule
