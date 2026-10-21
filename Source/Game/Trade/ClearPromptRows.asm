                module Trade
                module ClearPromptRows
; -----------------------------------------
; Очистка двух строк ввода
; исходный диапазон #E36B..#E379
; In:
;   Нет параметров
; Out:
;   Строки 21 и 22 очищены внутри рамки, X=0, Y=21
; Corrupt:
;   HL, BC, AF
; Note:
;   Заливает нулём по 30 байт в восьми пиксельных строках от Memory.Screen + #10A1 и Memory.Screen + #10C1, первая инструкция ClearInputGate
;   временно изменяется дисковым оверлеем
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E36B
                ; очистка обеих строк запроса перед началом ввода количества
Entry:          LD A, #15
                CALL Game.Trade.SetTextRow.Entry
                CALL Game.Trade.ResetTextColumn.Entry
                XOR A
                LD HL, Memory.Screen + #10A1                                    ; первое внутреннее знакоместо первой строки ввода
                CALL Game.Trade.FillCharacterRowInterior.Entry                  ; далее Game.Trade.ClearSecondPromptRow.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #E37A
                endmodule
                endmodule
