                module Wireframe
                module OrthogonalizeObjectYAxis
; -----------------------------------------
; приближённое восстановление перпендикулярности осей X и Y
; исходный диапазон #AE69..#AE89
; In:
;   IX, объект
; Out:
;   IX, исходный объект
;   IY, исходное значение
;   старшие байты оси Y скорректированы
; Corrupt:
;   HL, DE, BC, AF
; Note:
; Скалярное произведение осей задаёт общую величину коррекции.
; Три вызова AE8A удаляют из Y составляющую вдоль X.
; В отличие от неточного заголовка справочной версии, оба индексных регистра восстанавливаются.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #AE69
                ; поиск осей X/Y и расчёт их взаимной проекции
Entry:          PUSH IX
                PUSH IX
                EX (SP), IY
                LD DE, #0009
                ADD IX, DE
                LD E, #0F
                ADD IY, DE
                CALL Game.Motion.DotProductAxisHighBytes.Entry
                LD E, A
                ; обновление трёх компонент оси Y
                CALL Game.Wireframe.CorrectYAxisComponent.Entry
                CALL Game.Wireframe.CorrectYAxisComponent.Entry
                CALL Game.Wireframe.CorrectYAxisComponent.Entry
                POP IY
                POP IX
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #AE8A
                endmodule
                endmodule
