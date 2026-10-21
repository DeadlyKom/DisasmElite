                module Combat
                module ClearLaserDisplayState
; -----------------------------------------
; сброс двух полей отображения лазера после гибели
; исходный диапазон #B7AC..#B7B3
; In:
;   нет
; Out:
;   память MarketTable.FirearmPrice/MarketTable.FirearmEconomy обнулена
; Corrupt:
;   AF
; Note:
; Общий ранний выход ProcessLaserAndEcm при ненулевом признаке гибели FlightState.PlayerDead.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #B7AC
                ; обнуление двух рабочих полей отображения лазера
Entry:          XOR A
                LD (MarketTable.FirearmPrice), A
                LD (MarketTable.FirearmEconomy), A
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #B7B4
                endmodule
                endmodule
