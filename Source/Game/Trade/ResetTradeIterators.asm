                module Trade
                module ResetTradeIterators
; -----------------------------------------
; Начальные указатели обхода товаров
; исходный диапазон #E962..#E972
; In:
;   Нет параметров
; Out:
;   E1E0=D06A, E1E2=E1BB, E1DF=0
; Corrupt:
;   HL, AF
; Note:
;   Указатели стоят перед первыми элементами, обработчики строк сначала увеличивают их на 1 и 2
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E962
                ; указатели выставляются перед первым элементом, цикл предварительно увеличивает их
Entry:          LD HL, State.MarketRandom
                LD (MarketWork.CargoCursor), HL
                LD HL, BeforePrices
                LD (MarketWork.PriceCursor), HL
                XOR A
                LD (MarketWork.Commodity), A
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #E973
                endmodule
                endmodule
