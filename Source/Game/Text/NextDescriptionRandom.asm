                module Text
                module NextDescriptionRandom
; -----------------------------------------
; Детерминированный генератор вариантов описания планеты
; исходный диапазон #D5E1..#D60A
; In:
;   DECC/DECE = два слова состояния
; Out:
;   DECC = сумма, DECE = преобразованное старое первое слово, A = старший байт суммы
; Corrupt:
;   HL, DE, AF
; Note:
;   SLA применяется только к L первого слова, сумма второго слова с полученной парой учитывает
;   вынесенный бит 7 L через ADC, D5F5 отдельный обработчик товара 0 или 10, который при
;   выполнении условия EC40 ставит бит 1 D0B0
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D5E1
                ; обновление отдельного генератора описания, не изменяющего семя галактики
Entry:          LD HL, (GalaxyState.TextSeed)
                SLA L
                EX DE, HL
                LD HL, (GalaxyState.TextSeed + 2)
                ADC HL, DE
                LD A, H
                LD (GalaxyState.TextSeed), HL
                EX DE, HL
                LD (GalaxyState.TextSeed + 2), HL
                RET

                ; миссия 7+2, проверка военной поставки продовольствия либо оружия
                ; описание в Docs/Manual.md, раздел mission-7-2
                ; проверка продажи товара 0 или 10 в особой области, установка бита награды
CheckWarSupply: PUSH AF
                CP #0A
                JR Z, CheckSupply                                               ; переход, если продаваемый товар имеет индекс 10, проверить военную поставку оружия

                AND A
                JR NZ, ReturnGoods                                              ; переход, если индекс товара не равен 0 и ранее не был 10, поставка не учитывается

CheckSupply:    PUSH BC
InvasionCall    EQU $ + 1                                                       ; операнд CALL, установщик демо перенаправляет проверку
                CALL Game.Menus.CheckMissionRegionBand.Entry
                POP BC
                JR NC, ReturnGoods                                              ; переход, если система вне полосы сопротивления, не выдавать отметку за поставку

                LD HL, State.MissionFlags
                SET MS_MARK2_BIT, (HL)
ReturnGoods:    POP AF
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #D60B
                endmodule
                endmodule
