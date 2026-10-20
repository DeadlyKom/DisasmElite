                module Trade
                module ResetCloakingAndSeedFlightRandom
; -----------------------------------------
; Состояние маскировки и полётный случайный параметр
; исходный диапазон #E6EE..#E710
; In:
;   AF, A = новое D041
; Out:
;   D041=A, 7105=D06A
; Corrupt:
;   AF
; Note:
;   E6F8/E6F9 являются сохранёнными байтами, E6FA исправляет нулевую цену, E707 начинает меню
;   покупки, очищает экран и задаёт X=16
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E6EE
                ; сохранение состояния маскировки и перенос случайного параметра рынка в полётный генератор
Entry:          LD (CloakActive), A
; основной вход #E6F1, LD A,(#D06A)
; альтернативный вход #E6F2 из #E6B3, LD L,D, затем RET NC по #E6F3
; диспетчер #813E вызывает покупку с C=0, занятый миссией трюм немедленно возвращается
BusyCargo:      EQU $+1                                                         ; LD L,D и RET NC внутри операнда чтения, отказ занятому трюму
                LD A, (State.MarketRandom)
                LD (FlightState.RandomByte), A
                RET
                ; сохранённые байты F1,F0 перед обработчиком исправления цены
BuyAttributes   DB #F1, #F0                                                     ; двухбайтовая последовательность настройки атрибутов экрана покупки
                ; исправление нулевой специальной цены и начало экрана покупки
PrepareBuy:     LD HL, MarketPrices + 2 * FGoods.Firearms + 1
                LD A, (HL)
                AND A
                RET NZ                                                          ; выход, если старший байт специальной цены ненулевой, исправление не требуется

                LD (HL), #02
                DEC HL
                LD A, #C0
                LD (HL), A
                RET

OpenBuy:        CALL PrepareBuy
                CALL Game.Text.ClearViewAndFrame.Entry
                CALL Game.Trade.SetInlineTextColumn.Entry
                DB #10                                                          ; параметр предыдущего вызова, не исполняется как инструкция
                ; проверка исходного конца фрагмента
                ASSERT $ == #E711
                endmodule
                endmodule
