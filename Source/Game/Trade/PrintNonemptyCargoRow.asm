                module Trade
                module PrintNonemptyCargoRow
; -----------------------------------------
; Печать непустого слота трюма
; исходный диапазон #E268..#E27E
; In:
;   MarketWork.CargoCursor = предыдущий слот, MarketWork = индекс товара
; Out:
;   Указатель увеличен, CY=1 при пустом слоте
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Имя выводится через Game.Extensions.HandleSpecialMessageToken.Entry, который также меняет Game.Travel.GetSalePriceAndMissionFlags.MineralGate и Game.Extensions.AttributeVectorAndEnergyBomb.ColonyGate для специального товара, далее
;   количество и единица через Game.Trade.PrintCargoQuantity.Entry
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E268
                ; пустые грузовые слоты возвращают перенос и не занимают строку инвентаря
Entry:          LD HL, (MarketWork.CargoCursor)
                INC HL
                LD (MarketWork.CargoCursor), HL
                LD A, (HL)
                AND A
                JR Z, @Game.Trade.PrintCargoQuantity.EmptyCargo                 ; переход, если количество груза в текущем слоте нулевое, пропустить строку

                LD A, (MarketWork.Commodity)
                ADD A, #D0
                CALL Game.Extensions.HandleSpecialMessageToken.Entry
                CALL Game.Trade.SetInlineTextColumn.Entry
                DB #0D                                                          ; аргумент вызываемой процедуры из потока команд
                ; проверка исходного конца фрагмента
                ASSERT $ == #E27F
                endmodule
                endmodule
