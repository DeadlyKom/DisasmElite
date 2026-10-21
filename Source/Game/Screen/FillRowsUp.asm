                module Screen
                module FillRowsUp
; -----------------------------------------
; выбор заполнения или пропуска строк при движении вверх
; In:
;   BC, B содержит число строк
;   AF, A содержит начальную координату Y
;   байт CircleState.OutlineOnly, режим контура
; Out:
;   отрисованы или пропущены строки до верхней границы
;   DE, B и A сохраняются, C получает исходный A
; Corrupt:
;   HL, BC, AF
; Note:
;   A сохраняется через C на время проверки режима
;   нулевой режим вызывает заполнение Game.Circles.PrepareBothClippedMasksAndFillRows.PatchUpward, ненулевой перемещение без заливки Game.Circles.SkipViewportRowsUp.Entry
;   это хвостовой переход, выбранный обработчик возвращается непосредственному вызывающему
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #86B8
                ; проверка необходимости заливать строки
Entry:          LD C, A
                LD A, (CircleState.OutlineOnly)
                AND A
                LD A, C
                JP NZ, Game.Circles.SkipViewportRowsUp.Entry                    ; переход, если рисуется только контур

                JP Game.Circles.PrepareBothClippedMasksAndFillRows.PatchUpward

                ASSERT $ == #86C4
                endmodule
                endmodule
