                module Travel
                module GetSalePriceAndMissionFlags
; -----------------------------------------
; Чтение цены продажи с переключаемой специальной надбавкой
; исходный диапазон #DE67..#DE96
; In:
;   HL = адрес цены для Game.Travel.GetSalePriceAndMissionFlags.Entry
; Out:
;   HL увеличен на 1
;   DE = цена из памяти при RET в Game.Travel.GetSalePriceAndMissionFlags.MineralGate либо 10000 при NOP
; Corrupt:
;   HL, DE
; Note:
;   Game.Travel.GetSalePriceAndMissionFlags.MineralGate является самомодифицируемым NOP/RET, Game.Extensions.HandleSpecialMessageToken.Entry записывает RET для обычного товара и NOP при
;   специальном результате Game.Text.CheckMineralLifeColony.Entry для минералов, только NOP допускает замену цены на 10000, Game.Travel.GetSalePriceAndMissionFlags.GrantMission
;   отдельно обрабатывает биты миссий с выходом Game.Travel.LaserTypeAndArrivalEvents.FinishArrival
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #DE67
                ; обычная цена читается из двух байтов, NOP в Game.Travel.GetSalePriceAndMissionFlags.MineralGate включает цену MINERAL LIFE
                ; миссия 4 MINERAL LIFE, изменяемый MineralGate разрешает специальную цену живых минералов
                ; описание в Docs/Manual.md, раздел mission-4
Entry:          LD E, (HL)
                INC HL
                LD D, (HL)
MineralGate:    NOP
                LD DE, #2710
                RET

                ; миссии 1..3, выбор очередного события по маске состояния пилота
                ; описание в Docs/Manual.md, раздел mission-dispatch
                ; дополнительный вход выдачи первой, второй и третьей миссий по битовой маске
GrantMission:   AND (HL)
                RRCA
                JR C, SecondMission                                             ; переход, если младший бит маски выполненных миссий установлен, первая уже учтена

                SET MS_MARK1_BIT, (HL)
                LD A, #01
                LD (State.Mission1), A
                LD L, #02
                CALL Game.Extensions.AttributeVectorAndEnergyBomb.Entry
                CALL Game.Travel.EmptyFuelWithWarning.Entry
                JR @Game.Travel.LaserTypeAndArrivalEvents.FinishArrival

SecondMission:  RRCA
                JR C, ThirdMission                                              ; переход, если следующий бит выполненных миссий установлен, вторая уже учтена

                SET MS_MARK2_BIT, (HL)
                JR @Game.Travel.LaserTypeAndArrivalEvents.FinishArrival

ThirdMission:   RRCA
                JR C, @Game.Travel.LaserTypeAndArrivalEvents.RandomPolice       ; переход, если третий бит выполненных миссий установлен, третья уже учтена

                SET MS_MARK3_BIT, (HL)
                LD A, #01
                LD (State.Mission3), A
                JR @Game.Travel.LaserTypeAndArrivalEvents.FinishArrival

                ; проверка исходного конца фрагмента
                ASSERT $ == #DE97
                endmodule
                endmodule
