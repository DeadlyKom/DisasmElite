                module Economy
                module AddCashLow
; -----------------------------------------
; Прибавление суммы в десятых кредита
; исходный диапазон #D3D3..#D3E6
; In:
;   DE = сумма, State.CashLow = младшая группа, State.CashHigh = тысячи
; Out:
;   Денежный счёт увеличен
; Corrupt:
;   HL, DE, AF
; Note:
;   После сложения вычитает 10000 и при отсутствии заёма переносит единицу в State.CashHigh через Game.Economy.AddCashThousands.Entry,
;   нормализация выполняется один раз, для штатного контракта DE<10000
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D3D3
                ; сложение младшей группы денег и перенос единицы при достижении 10000
Entry:          LD HL, (State.CashLow)
                ADD HL, DE
                LD (State.CashLow), HL
                AND A
                LD DE, #2710
                SBC HL, DE
                RET C                                                           ; выход, если младшая группа денег меньше 10000, перенос в старшую группу не нужен

                LD (State.CashLow), HL
                LD DE, #0001                                                    ; далее Game.Economy.AddCashThousands.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #D3E7
                endmodule
                endmodule
