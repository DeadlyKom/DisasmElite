                module Trade
                module GenerateMarket
; -----------------------------------------
; Расчёт цен и запасов 17 товаров
; исходный диапазон #E148..#E1E7
; In:
;   MarketTable.Base = записи по 4 байта, GalaxyState.Economy = экономика, State.MarketRandom = случайный параметр
; Out:
;   MarketPrices содержит 17 цен, State.MarketStock содержит 17 количеств по полям FGoods
; Corrupt:
;   HL, DE, BC, AF, HL', DE', BC'
; Note:
;   Game.Combat.CalculateFuelPurchasePrice.Entry рассчитывает цену топлива EquipmentTable.FuelPrice и возвращает HL=State.MarketStock, запись содержит базовую цену, знак
;   и коэффициент экономики, базовый запас и случайную маску, запас ограничивается 6 битами
;   после отсечения отрицательного, цена масштабируется на 4, последний товар получает запас 0,
;   MarketWork содержит индекс товара, указатели груза, цены и остатка, а также сохранённую позицию печати
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E148
                ; два набора регистров отделяют чтение записей товара от записи цен и остатков
Entry:          CALL Game.Combat.CalculateFuelPurchasePrice.Entry
                LD DE, MarketPrices
                EXX
                LD HL, MarketTable.Base
                LD B, #11
                ; чтение базовой цены и знакового коэффициента, произведение экономики вычисляется сложением
NextCommodity:  PUSH BC
                LD E, (HL)
                INC HL
                LD A, (HL)
                LD D, A
                PUSH DE
                AND #1F
                JR Z, StockAmount                                               ; переход, если коэффициент экономики в пяти младших битах равен нулю, произведение уже нулевое

                LD B, A
                LD A, (GalaxyState.Economy)
                LD C, A
                XOR A
EconomyProduct: ADD A, C
                DJNZ EconomyProduct

                ; остаток товара строится из базового запаса, случайной маски и экономической поправки
StockAmount:    LD E, A
                INC HL
                LD B, (HL)
                INC HL
                LD C, (HL)
                INC HL
                LD A, (State.MarketRandom)
                AND C
                ADD A, B
                LD B, A
                LD A, E
                BIT 7, D
                JR NZ, ApplyStock                                               ; переход, если коэффициент экономики товара отрицательный, использовать отрицательную поправку

                INC A
                NEG
ApplyStock:     ADD A, B
                BIT 7, A
                JR Z, ClampStock                                                ; переход, если рассчитанный остаток не имеет знакового бита, не обнулять его

                XOR A
                ; шести битный остаток сохраняется на стеке до переключения в набор выходных указателей
ClampStock:     AND #3F
                LD B, E
                POP DE
                ; цена получает ту же случайную маску, затем экономическую поправку с учётом знака
                PUSH AF
                LD A, (State.MarketRandom)
                AND C
                ADD A, E
                LD E, #00
                RL E
                LD C, A
                LD A, B
                BIT 7, D
                JR Z, PositivePrice                                             ; переход, если коэффициент товара положительный, прибавить поправку к базовой цене

                LD D, A
                LD A, C
                SUB D
                JR ScalePrice

PositivePrice:  ADD A, C
                JR NC, ScalePrice                                               ; переход, если сложение компонентов цены не переполнило байт, старшая часть не нужна

                INC E
                ; цена масштабируется в четыре раза с переносами в старший байт
ScalePrice:     LD B, E
                ADD A, A
                RL B
                ADD A, A
                RL B
                LD C, A
                PUSH BC
                EXX
                ; готовая цена и количество передаются в выходные таблицы через EXX
                POP BC
                LD A, C
                LD (DE), A
                INC DE
                LD A, B
                LD (DE), A
                INC DE
                POP AF
StoreStock      EQU $                                                           ; изменяемая команда LD (HL),A, NOP сохраняет остатки рынка нового командира
                LD (HL), A
                INC HL
                EXX
                POP BC
                DJNZ NextCommodity

                ; ALIEN ITEMS не продаются станцией, последний остаток принудительно обнуляется
                LD HL, State.MarketStock + FGoods.AlienItems
                LD (HL), B
                RET

                ; нулевое слово перед таблицей цен, начальное значение указателя обхода
BeforePrices    DB #00, #00                                                     ; нулевое слово перед ценами, обход сначала увеличивает указатель на 2
                ; 17 двухбайтовых цен в десятых кредита, заполняются генератором рынка
MarketPrices    DB #24, #00, #3C, #00, #C8, #00, #3C, #00                       ; семнадцать двухбайтовых рыночных цен
                DB #E8, #00, #B0, #03, #F0, #05, #80, #03                       ; #E1C5..#E1CC
                DB #4C, #02, #4C, #01, #F4, #02, #0C, #02                       ; #E1CD..#E1D4
                DB #6C, #00, #70, #01, #84, #02, #A0, #00                       ; #E1D5..#E1DC
                DB #00, #02                                                     ; #E1DD..#E1DE
                ; рабочие указатели выбранного товара и печатная позиция рынка
MarketData      FMarketWork {
                    #00,                                                        ; FMarketWork.Commodity, номер текущего товара, 0..16
                    #0000,                                                      ; FMarketWork.CargoCursor, адрес количества выбранного товара в трюме
                    #0000,                                                      ; FMarketWork.PriceCursor, адрес двухбайтовой цены выбранного товара
                    #0000,                                                      ; FMarketWork.StockCursor, адрес остатка выбранного товара на станции
                    #0000                                                       ; FMarketWork.TextPosition, сохранённые столбец и строка печати
                }
                ASSERT $ - MarketData == FMarketWork

                ; прежние имена указывают на поля экземпляра MarketData
Commodity       EQU MarketData.Commodity                                        ; поле FMarketWork.Commodity
CargoCursor     EQU MarketData.CargoCursor                                      ; поле FMarketWork.CargoCursor
PriceCursor     EQU MarketData.PriceCursor                                      ; поле FMarketWork.PriceCursor
StockCursor     EQU MarketData.StockCursor                                      ; поле FMarketWork.StockCursor
TextPosition    EQU MarketData.TextPosition                                     ; поле FMarketWork.TextPosition
                ; проверка исходного конца фрагмента
                ASSERT $ == #E1E8
                endmodule
                endmodule
