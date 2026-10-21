                module Trade
                module RefreshMarketRandom
; -----------------------------------------
; Обновление случайного параметра рынка
; исходный диапазон #E142..#E147
; In:
;   Генератор Game.Wireframe.GetSystemVariationByte.Entry
; Out:
;   State.MarketRandom = новый случайный байт, затем сформирован рынок
; Corrupt:
;   HL, DE, BC, AF, HL', DE', BC'
; Note:
;   Вход без RET продолжается в Game.Trade.GenerateMarket.Entry, сохранение командира удерживает State.MarketRandom для воспроизводимого
;   рынка
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E142
                ; обновление случайного байта рынка перед полной генерацией цен и запасов
Entry:          CALL Game.Wireframe.GetSystemVariationByte.Entry
                LD (State.MarketRandom), A                                      ; далее Game.Trade.GenerateMarket.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #E148
                endmodule
                endmodule
