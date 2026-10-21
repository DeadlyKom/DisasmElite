                module Screen
                module FillRowsDown
; -----------------------------------------
; выбор заполнения или пропуска строк при движении вниз
; In:
;   BC, B содержит число строк
;   AF, A содержит начальную координату Y
;   байт CircleState.OutlineOnly, режим контура
; Out:
;   отрисованы или пропущены строки до нижней границы
;   DE, B и A сохраняются, C получает исходный A
; Corrupt:
;   HL, BC, AF
; Note:
;   нулевой режим вызывает заполнение Game.Circles.PrepareBothClippedMasksAndFillRows.PatchDownward, ненулевой перемещение без заливки Game.Circles.SkipRowsDownAndDrawCircleContours.Entry
;   A сохраняется через C, адрес возврата остаётся у выбранного обработчика
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #86C4
                ; проверка необходимости заливать строки
Entry:          LD C, A
                LD A, (CircleState.OutlineOnly)
                AND A
                LD A, C
                JP NZ, Game.Circles.SkipRowsDownAndDrawCircleContours.Entry     ; переход, если рисуется только контур

                JP Game.Circles.PrepareBothClippedMasksAndFillRows.PatchDownward

                ASSERT $ == #86D0
                endmodule
                endmodule
