                module Trade
                module InstallPurchasedEquipment
; -----------------------------------------
; Выдача оборудования и выбор направления лазера
; исходный диапазон #EA3B..#EADF
; In:
;   AF, A = номер пункта E8AB
; Out:
;   Изменены ракеты, трюм, устройства либо открыт выбор 0..3
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   Пункт 2 ограничивает ракеты четырьмя, пункт 3 направлен в патч 6FFB, пункты 4 и 7..12 меняют
;   байты по D081+номер, пункты 5/6/13/14/15 выбирают тип лазера через DDEC и спрашивают
;   направление
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #EA3B
                ; отдельные случаи топлива, ракет и трюма предшествуют общему полю оборудования
Entry:          CP #02
                JR NZ, CheckCargoBay                                            ; переход, если номер покупки не равен 2, это не ракета

                LD HL, State.Missiles
                LD A, (HL)
                CP #04
                JP NC, Game.Trade.EquipmentAlreadyOwned.Entry                   ; переход, если уже имеется четыре ракеты, дополнительную покупать нельзя

                INC A
                LD (HL), A
                JR BuySuccess

CheckCargoBay:  CP #03
                JR NZ, CheckItemKind                                            ; переход, если номер покупки не равен 3, это не расширенный трюм

                LD HL, State.LargeCargo
                LD A, (HL)
                JP Game.Extensions.AttributeVectorAndEnergyBomb.ConfirmUpgrade

AddCargoSpace:  LD HL, State.FreeCargo
                LD A, (HL)
                ADD A, #0F
                LD (HL), A
                JR InstallItem

                ; общий предмет получает новый уровень, лазеры требуют выбора направления
CheckItemKind:  CP #04
                JR Z, CheckOwned                                                ; переход, если номер покупки равен 4, обработать ECM

                CP #07
                JR C, SelectLaser                                               ; переход, если номер покупки меньше 7, перейти к выдаче соответствующего лазера

                CP #0D
                JR NC, SelectLaser                                              ; переход, если номер покупки не меньше 13, обработать лазерный или специальный пункт

CheckOwned:     CALL Game.Trade.GetEquipmentStateAddress.Entry
                LD A, (HL)
                OR #80
                CALL Game.Menus.RedirectDuplicateEquipment.Entry
InstallItem:    CALL Game.Trade.GetEquipmentStateAddress.Entry
                DEC (HL)
BuySuccess:     CALL Game.Trade.ShowTradeSuccess.Entry
                JP @Game.Trade.PrintEquipmentPrice.SelectItem

                ; номер покупки переводится в тип устанавливаемого лазера
SelectLaser:    LD B, #01
                CP #05
                JR Z, LaserSelected                                             ; переход, если пункт равен 5, выбран первый тип лазера

                INC B
                CP #06
                JR Z, LaserSelected                                             ; переход, если пункт равен 6, выбран второй тип лазера

                INC B
                CP #0D
                JR Z, LaserSelected                                             ; переход, если пункт равен 13, выбран третий тип лазера

                INC B
LaserSelected:  NOP
                CALL Game.Travel.LaserTypeAndArrivalEvents.Entry
                PUSH BC
                CALL Game.Text.ClearViewAndFrame.Entry
                CALL Game.Text.SetPromptAttributes.Entry
                POP BC
                LD A, #04
                ADD A, B
                CALL Game.Trade.SetTextColumn.Entry
                LD A, #0E
                CALL Game.Trade.SetTextRow.Entry
                LD A, (TradeSnapshot.Selection)
                LD B, #68
                ADD A, B
                CALL Game.Text.PrintMainToken.Entry
                LD A, #10
                CALL Game.Trade.SetTextRow.Entry
                XOR A
                ; печать четырёх сторон корабля и их текущих лазеров
ListDirection:  LD (EquipmentWork.ItemIndex), A
                CALL Game.Trade.SetInlineTextColumn.Entry
                DB #0A                                                          ; аргумент вызываемой процедуры из потока команд
                LD A, (EquipmentWork.ItemIndex)
                ADD A, #30
                CALL Game.Trade.PrintMainTokenSpace.Entry
                LD A, (EquipmentWork.ItemIndex)
                ADD A, #60
                CALL Game.Trade.PrintTokenNewline.Entry
                LD A, (EquipmentWork.ItemIndex)
                INC A
                CP #04
                JR C, ListDirection                                             ; переход, если показано меньше четырёх направлений лазера, вывести следующее

                CALL Game.Trade.ClearPromptRows.Entry
                CALL Game.Text.PrintInlineToken.Entry
                DB #AF                                                          ; аргумент вызываемой процедуры из потока команд
                CALL Game.Text.PrintInlineToken.Entry
                DB #3F                                                          ; аргумент вызываемой процедуры из потока команд
                ; проверка исходного конца фрагмента
                ASSERT $ == #EAE0
                endmodule
                endmodule
