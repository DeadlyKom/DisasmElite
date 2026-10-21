                module Trade
                module ResetCloakingAndSeedFlightRandom
; -----------------------------------------
; Состояние маскировки и полётный случайный параметр
; исходный диапазон #E6EE..#E710
; In:
;   AF, A = новое CloakActive
; Out:
;   CloakActive=A, FlightState.RandomByte=State.MarketRandom
; Corrupt:
;   AF
; Note:
;   два байта BuyAttributes являются сохранёнными байтами, Game.Trade.ResetCloakingAndSeedFlightRandom.PrepareBuy исправляет нулевую цену, Game.Trade.ResetCloakingAndSeedFlightRandom.OpenBuy начинает меню
;   покупки, очищает экран и задаёт X=16
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E6EE
                ; сохранение состояния маскировки и перенос случайного параметра рынка в полётный генератор
                ; миссия 2 CLOAKING DEVICE, подготовка полёта записывает переданное состояние маскировки
                ; описание в Docs/Manual.md, раздел mission-2
Entry:          LD (CloakActive), A
; основной путь Entry читает State.MarketRandom командой LD A, (nn)
; OfferRefugees переходит в BusyCargo внутрь операнда LD A, (nn), байты исполняются как LD L, D и RET NC
; диспетчер Game.Screen.DispatchMenu.Entry вызывает покупку с C=0, занятый миссией трюм немедленно возвращается
                ; миссии 1, 7+1, 7+3, перекрывающийся вход прекращает предложение покупки при занятом миссионном трюме
                ; описание в Docs/Manual.md, раздел mission-1, mission-7-1, mission-7-3
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
