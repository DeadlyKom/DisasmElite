                module Trade
                module PrintMainTokenSpace
; -----------------------------------------
; Основной токен с пробелом
; исходный диапазон #E29E..#E2A5
; In:
;   AF, A = токен
; Out:
;   Текст и пробел выведены
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Game.Trade.PrintMainTokenSpace.PrintSuffix является общим хвостом печати завершающего символа
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E29E
                ; к основному токену дописывается пробел, курсор сохраняется в глобальном состоянии
Entry:          CALL Game.Text.PrintMainToken.Entry
                LD A, #20
PrintSuffix:    JP Game.Text.PrintMainToken.Entry

                ; проверка исходного конца фрагмента
                ASSERT $ == #E2A6
                endmodule
                endmodule
