                module Screen
                module DrawCircleOutline
; -----------------------------------------
; рисование контура окружности с быстрым путём для малого радиуса
; In:
;   поля CircleState.OffsetY, OffsetX, Flags и Radius
; Out:
;   контур в буфере либо ранний выход
; Corrupt:
;   HL, DE, BC, AF, HL', DE', BC', AF'
; Note:
;   Game.Extensions.DrawSmallSilhouette.Entry выбирает контурный профиль малого силуэта
;   при радиусе от 9 выполнение проваливается в Game.Screen.DrawLargeOutline.Entry
;   прерывания отключает вызывающий путь, сам этот вход отдельной DI не содержит
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #86DE
                ; проверка готового профиля малого контура
Entry:          CALL Game.Extensions.DrawSmallSilhouette.Entry
                CP #09
                RET C                                                           ; выход, если малый силуэт уже обработан, иначе далее Game.Screen.DrawLargeOutline.Entry без команды перехода

                ASSERT $ == #86E4
                endmodule
                endmodule
