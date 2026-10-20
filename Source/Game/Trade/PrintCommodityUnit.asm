                module Trade
                module PrintCommodityUnit
; -----------------------------------------
; Печать единицы измерения товара
; исходный диапазон #E31E..#E346
; In:
;   E1DF = индекс товара
; Out:
;   Напечатаны T, KG, G либо KM
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   0..12 и 16 измеряются тоннами, 13..14 килограммами, 15 граммами, значения >=17 километрами,
;   E34C отдельно возвращает CY для товаров, занимающих тоннаж
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E31E
                ; единица товара определяется индексом, 0..12 и 16 тонны, 13..14 килограммы, 15 граммы
Entry:          LD A, #00
                LD (WordStart), A
                LD A, (MarketWork.Commodity)
                CP #0D
                JR C, Tonnes                                                    ; переход, если товар имеет индекс меньше 13, использовать тонны

                CP #0F
                JR C, Kilograms                                                 ; переход, если индекс товара равен 13 или 14, использовать килограммы

                JR Z, Grams                                                     ; переход, если индекс товара равен 15, использовать граммы

                CP #11
                JR C, Tonnes                                                    ; переход, если индекс товара равен 16, использовать тонны для ALIEN ITEMS

                JR Kilometres

Tonnes:         LD A, #54
                JR @Game.Trade.PrintKilometreSuffix.PrintSuffix

Kilograms:      LD A, #4B
                CALL Game.Text.PrintMainToken.Entry
Grams:          LD A, #47
                JR @Game.Trade.PrintKilometreSuffix.PrintSuffix

Kilometres:     CALL Game.Text.PrintInlineToken.Entry
                DB #4B                                                          ; аргумент вызываемой процедуры из потока команд
                ; проверка исходного конца фрагмента
                ASSERT $ == #E347
                endmodule
                endmodule
