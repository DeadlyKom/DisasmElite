                module Text
                module DrawViewFrame
; -----------------------------------------
; Рисование верхней, боковых и нижней границ окна
; исходный диапазон #D646..#D674
; In:
;   Нет параметров
; Out:
;   Рамка выведена, TextPosition=0, TextRow=2, A=0
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   верхняя линия начинается Memory.Screen + #0020, IX указывает на экранную строку, крайние биты ставятся в столбцах LeftColumn и RightColumn, нижняя
;   линия Memory.Screen + #17E0, после RET сохранены два отдельных байта
; -----------------------------------------
                ; смещения описывают исходные данные, память не выделяется
LeftColumn:     EQU 0                                                           ; левый байт текущей 32-байтовой строки растра
RightColumn:    EQU 31                                                          ; правый байт той же строки растра

                ; проверка исходного начала фрагмента
                ASSERT $ == #D646
                ; верхняя и нижняя горизонтали и боковые пиксели образуют рамку обзорного окна
Entry:          LD HL, Memory.Screen + #0020
                PUSH HL
                CALL Game.Text.DrawFullWidthRule.Entry
                POP HL
DrawSides:      PUSH HL
                POP IX
                SET 7, (IX+LeftColumn)
                SET 0, (IX+RightColumn)
                INC H
                LD A, H
                AND #07
                CALL Z, Game.Screen.NextCharacterRow.Entry                      ; вызов, если пересечена граница восьми строк растра, перейти к следующей символьной строке
                LD A, H
                CP #58
                JR NZ, DrawSides                                                ; переход, если старшая часть адреса ещё не достигла 58, продолжить боковую рамку

                LD HL, Memory.Screen + #17E0
                CALL Game.Text.DrawFullWidthRule.Entry
                XOR A
                LD HL, #0200
                LD (TextColumn), HL
                RET

                ; остаточные байты D0,C9 после рамки, линейное исполнение завершено RET
                DB #D0, #C9                                                     ; #D673..#D674
                ; проверка исходного конца фрагмента
                ASSERT $ == #D675
                endmodule
                endmodule
