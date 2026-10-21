                module Menus
                module RedirectDuplicateEquipment
; -----------------------------------------
; Подмена возврата при специальном конфликте оборудования
; исходный диапазон #EC4B..#EC57
; In:
;   HL = байт устанавливаемого предмета в странице D0, AF, A = его текущее состояние с битом 7
; Out:
;   При совпадении A+1 с State.ShipUpgrade следующий RET ведёт в Game.Trade.EquipmentAlreadyOwned.PrintItemError
; Corrupt:
;   HL, AF
; Note:
;   HL сохраняется, EX(SP), HL меняет адрес возврата на стеке, поэтому вызывающая выдача
;   предмета прекращается через сообщение об уже установленном устройстве
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #EC4B
                ; сравнение уровня устройства с состоянием Mk4 до разрешения покупки
Entry:          PUSH HL
                LD L, #8E
                INC A
                CP (HL)
                POP HL
                RET NZ                                                          ; выход, если состояние оборудования плюс один отличается от состояния корабля Mk4, оставить возврат

                ; адрес возврата на стеке заменяется на Game.Trade.EquipmentAlreadyOwned.PrintItemError, вызывающий обработчик выдачи прерывается
                EX (SP), HL
                LD HL, Game.Trade.EquipmentAlreadyOwned.PrintItemError
                EX (SP), HL
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #EC58
                endmodule
                endmodule
