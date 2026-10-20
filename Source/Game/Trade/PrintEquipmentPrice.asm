                module Trade
                module PrintEquipmentPrice
; -----------------------------------------
; Цена оборудования и продолжение списка
; исходный диапазон #E9BF..#E9E5
; In:
;   EB60 = адрес цены, EB5F = номер строки
; Out:
;   Указатель цены увеличен на 3, переход к следующей строке либо вводу
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Первый байт задаёт тысячи кредитов, следующие два десятые, число печатает D334, в конце
;   списка вызывается 6EE8 и печатается 7F
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E9BF
                ; трёхбайтовая цена делится на тысячи и остаток в десятых кредита
Entry:          LD HL, (EquipmentWork.PriceCursor)
                LD A, (HL)
                INC HL
                LD E, (HL)
                INC HL
                LD D, (HL)
                INC HL
                LD (EquipmentWork.PriceCursor), HL
                LD H, #00
                LD L, A
                CALL Game.Economy.PrintSplitCash.Entry
                CALL Game.Trade.Newline.Entry
                LD A, (EquipmentWork.ItemLimit)
                LD B, A
                LD A, (EquipmentWork.ItemIndex)
                INC A
                CP B
                JR NZ, @Game.Trade.ListEquipmentChoices.ListNextItem            ; переход, если номер следующего пункта не достиг предела, печатать следующую цену

SelectItem:     CALL Game.Extensions.PrintEquipmentAndSelectIcon.Entry
                CALL Game.Text.PrintInlineToken.Entry
                DB #7F                                                          ; аргумент вызываемой процедуры из потока команд
                ; проверка исходного конца фрагмента
                ASSERT $ == #E9E6
                endmodule
                endmodule
