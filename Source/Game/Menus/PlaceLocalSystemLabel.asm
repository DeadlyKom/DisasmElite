                module Menus
                module PlaceLocalSystemLabel
; -----------------------------------------
; Поиск свободной строки для имени планеты на местной карте
; исходный диапазон #ED78..#EDC4
; In:
;   Рабочее семя планеты и координаты текущего центра
; Out:
;   Имя выведено на свободной строке либо пропущено
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Генерация имени продвигает семя, позиция округляется к символьной сетке, пробует расчётную
;   строку, строку выше и строку ниже в границах 3..22, успешность отмечается CY от печати
;   строки
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #ED78
                ; длина имени и координаты планеты определяют предпочтительную строку подписи
Entry:          CALL Game.Menus.LocalSystemPixelPosition.Entry
                PUSH BC
                CALL Game.Galaxy.GenerateSystemName.Entry
                LD BC, #0009
                LD HL, GalaxyState.GeneratedName
                XOR A
                CPIR
                LD A, C
                XOR #07
                INC A
                LD (MapNameLength), A
                POP BC
                LD A, C
                RRA
                RRA
                RRA
                AND #1F
                INC A
                LD (TextColumn), A
                LD A, B
                SRL A
                SRL A
                SRL A
                JR NC, LabelRow                                                 ; переход, если бит округления вертикальной координаты сброшен, не увеличивать строку

                INC A
LabelRow:       NEG
                ADD A, #15
                LD (TextRow), A
                ; сначала пробуется исходная строка, затем верхняя и нижняя соседние
                CALL Game.Menus.PrintLabelOnUnusedRow.Entry
                RET C                                                           ; выход, если имя удалось вывести в исходной строке, завершить размещение

                LD HL, TextRow
                DEC (HL)
                LD A, (HL)
                CP #03
                JR C, TryLowerRow                                               ; переход, если строка выше 3, не пробовать её и перейти ниже исходной

                CALL Game.Menus.PrintLabelOnUnusedRow.Entry
                RET C                                                           ; выход, если имя удалось вывести в верхней соседней строке

TryLowerRow:    LD HL, TextRow
                INC (HL)
                INC (HL)
                LD A, (HL)
                CP #17
                RET NC                                                          ; выход, если нижняя попытка достигла строки 23, места для имени нет
                ; проверка исходного конца фрагмента
                ASSERT $ == #EDC5
                endmodule
                endmodule
