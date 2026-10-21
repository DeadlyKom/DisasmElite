                module Trade
                module GetEquipmentPriceAddress
; -----------------------------------------
; Адрес трёхбайтной цены оборудования
; исходный диапазон #EB2F..#EB37
; In:
;   AF, A = номер меню 1..15
; Out:
;   HL = адрес цены, DE = смещение
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Для пунктов 1..14 адрес равен EquipmentTable.Base+3*(A-1), для индекса >=14 помощник Game.Screen.CargoTripleOffset.Entry выбирает
;   отдельную цену по LegacyPrice с нулевым смещением
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #EB2F
                ; цена занимает три байта, адрес определяется умножением индекса на три
Entry:          DEC A
                LD HL, EquipmentTable.Base
                CALL Game.Screen.CargoTripleOffset.Entry
                JR Game.Trade.AddByteOffsetToHL.Entry

                ; проверка исходного конца фрагмента
                ASSERT $ == #EB38
                endmodule
                endmodule
