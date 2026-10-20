                module Trade
                module ListEquipmentChoices
; -----------------------------------------
; Перечень оборудования по технологии мира
; исходный диапазон #E987..#E9BE
; In:
;   D09C = технология, 705F = таблица цен по три байта
; Out:
;   EB5E = предел, EB5F = индекс строки, EB60 = указатель цены
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Предел равен технологии+3, при значении >=12 заменяется на 14, строка печатает номер с 1,
;   токен 69+индекс и цену, особый пункт 15 добавляет 6EE8
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E987
                ; максимальный пункт списка зависит от технологии системы и специальных разрешений
Entry:          CALL Game.Menus.BlankLineAndEconomyText.Entry
                LD HL, EquipmentTable.Base
                LD (EquipmentWork.PriceCursor), HL
                LD A, (State.Technology)
                ADD A, #03
                CP #0C
                JR C, SetItemLimit                                              ; переход, если технологический уровень плюс 3 меньше 12, не ограничивать список значением 12

                LD A, #0E
SetItemLimit:   LD (EquipmentWork.ItemLimit), A
                XOR A
ListNextItem:   LD (EquipmentWork.ItemIndex), A
                LD A, #03
                LD (NumberWidth), A
                LD A, (EquipmentWork.ItemIndex)
                INC A
                CALL Game.Economy.PrintByteInteger.Entry
                CALL Game.Trade.SetInlineTextColumn.Entry
                DB #04                                                          ; аргумент вызываемой процедуры из потока команд
                LD B, #69
                LD A, (EquipmentWork.ItemIndex)
                ADD A, B
                CALL Game.Text.PrintMainToken.Entry
                CALL Game.Trade.SetInlineTextColumn.Entry
                DB #16                                                          ; аргумент вызываемой процедуры из потока команд
                ; проверка исходного конца фрагмента
                ASSERT $ == #E9BF
                endmodule
                endmodule
