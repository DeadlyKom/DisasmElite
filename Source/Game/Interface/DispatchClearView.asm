                module Interface
                module DispatchClearView
; -----------------------------------------
; Вектор очистки обзорного окна
; исходный диапазон #D036..#D038
; In:
;   Нет параметров
; Out:
;   Переход в D61D
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   Использует общий вход очистки и рамки
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D036
Entry:          JP Game.Text.ClearViewAndFrame.Entry
                ; проверка исходного конца фрагмента
                ASSERT $ == #D039
                endmodule
                endmodule
