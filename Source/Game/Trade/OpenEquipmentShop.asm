                module Trade
                module OpenEquipmentShop
; -----------------------------------------
; Заголовок меню покупки оборудования
; исходный диапазон #E973..#E986
; In:
;   Нет параметров
; Out:
;   Исполнение продолжается перечнем E987
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   Печатает управляющие коды 6 и 8, токены CF и B9 после общей подготовки
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E973
                ; подготовка экрана оборудования с заголовком и списком допустимых покупок
Entry:          CALL Game.Trade.PrepareTradeScreen.Entry
                CALL Game.Text.PrintInlineToken.Entry
                DB #06                                                          ; аргумент вызываемой процедуры из потока команд
                LD A, #CF
                CALL Game.Trade.PrintMainTokenSpace.Entry
                CALL Game.Text.PrintInlineToken.Entry
                DB #B9                                                          ; аргумент вызываемой процедуры из потока команд
                CALL Game.Text.PrintInlineToken.Entry
                DB #08                                                          ; аргумент вызываемой процедуры из потока команд
                ; проверка исходного конца фрагмента
                ASSERT $ == #E987
                endmodule
                endmodule
