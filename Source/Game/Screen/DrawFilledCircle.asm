                module Screen
                module DrawFilledCircle
; -----------------------------------------
; рисование заполненного круга с быстрым путём для малого радиуса
; In:
;   поля CircleState.OffsetY, OffsetX, Flags и Radius
; Out:
;   изображение круга в буфере либо ранний выход
; Corrupt:
;   HL, DE, BC, AF, HL', DE', BC', AF'
; Note:
;   Game.Extensions.DrawSmallSilhouetteAlternate.Entry выбирает заполненный профиль малого силуэта
;   при радиусе от 9 возвращает A=радиус и запускается общий алгоритм
;   меньший круг уже нарисован или отброшен быстрым путём, повторное рисование не требуется
;   большой круг рисуется с запрещёнными прерываниями, общий хвост Game.Screen.DrawLargeOutline.Entry включает EI
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #86D0
                ; проверка возможности нарисовать малый круг готовым профилем
Entry:          CALL Game.Extensions.DrawSmallSilhouetteAlternate.Entry
                CP #09
                RET C                                                           ; выход, если быстрый путь завершил обработку радиуса меньше 9

                ; подготовка режима заливки большого круга
                DI
                XOR A
                LD (CircleState.OutlineOnly), A
                JP Game.Screen.DrawLargeOutline.DrawAndEnable

                ASSERT $ == #86DE
                endmodule
                endmodule
