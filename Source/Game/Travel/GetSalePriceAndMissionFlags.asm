                module Travel
                module GetSalePriceAndMissionFlags
; -----------------------------------------
; Чтение цены продажи с переключаемой специальной надбавкой
; исходный диапазон #DE67..#DE96
; In:
;   HL = адрес цены для DE67
; Out:
;   DE = цена из памяти при RET в DE6A либо 10000 при NOP, HL увеличен на 1
; Corrupt:
;   HL, DE
; Note:
;   DE6A является самомодифицируемым NOP/RET, 5E1A записывает RET для обычного товара и NOP при
;   специальном результате D5B4 для минералов, только NOP допускает замену цены на 10000, DE6F
;   отдельно обрабатывает биты миссий с выходом DE4C
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #DE67
                ; обычная цена читается из двух байтов, NOP в DE6A включает цену MINERAL LIFE
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
