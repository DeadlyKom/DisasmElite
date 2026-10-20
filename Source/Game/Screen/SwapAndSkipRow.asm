                module Screen
                module SwapAndSkipRow
; -----------------------------------------
; обмен указателей и пропуск одной строки у прежнего DE
; In:
;   HL, DE, два адреса в формате видеопамяти
; Out:
;   HL, next(next(DE_in))
;   DE, HL_in
; Corrupt:
;   HL, DE, AF
; Note:
;   после CALL #7FE7 выполнение повторно входит в #7FE7 через проваливание
;   оба прохода меняют прежний DE, прежний HL остаётся в DE
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #7FE3
Entry:          EX DE, HL
NextRowCall     CALL Game.Screen.NextScanline.Entry                             ; CALL либо JP, один или два перехода к следующей строке
                ASSERT $ == #7FE7
                endmodule
                endmodule
