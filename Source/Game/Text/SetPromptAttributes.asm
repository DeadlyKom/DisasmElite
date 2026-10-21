                module Text
                module SetPromptAttributes
; -----------------------------------------
; Установка зелёных атрибутов строки приглашения
; исходный диапазон #D54F..#D553
; In:
;   Нет параметров
; Out:
;   Тридцать байт от Memory.Attributes + #02A1 равны 5
; Corrupt:
;   HL, BC, AF
; Note:
;   Общий хвост Game.Text.FillInnerAttributeRow.Entry продвигает HL на 32 после заполнения 30 байт
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D54F
                ; выбор зелёного атрибута для внутренних 30 ячеек строки приглашения
Entry:          LD HL, Memory.Attributes + 21 * 32 + 1
                LD A, #05                                                       ; далее Game.Text.FillInnerAttributeRow.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #D554
                endmodule
                endmodule
