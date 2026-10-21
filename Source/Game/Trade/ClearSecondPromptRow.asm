                module Trade
                module ClearSecondPromptRow
; -----------------------------------------
; Очистка второй строки приглашения
; исходный диапазон #E37A..#E37C
; In:
;   AF, A = заполнитель
; Out:
;   Восемь строк по 30 байт от Memory.Screen + #10C1 заполнены A
; Corrupt:
;   HL, BC
; Note:
;   Продолжается в Game.Trade.FillCharacterRowInterior.Entry без собственного RET
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E37A
                ; вход очистки только второй строки приглашения
Entry:          LD HL, Memory.Screen + #10C1                                    ; первое внутреннее знакоместо второй строки ввода, далее Game.Trade.FillCharacterRowInterior.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #E37D
                endmodule
                endmodule
