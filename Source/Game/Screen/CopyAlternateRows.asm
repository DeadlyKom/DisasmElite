                module Screen
                module CopyAlternateRows
; -----------------------------------------
; копирование строк с шагом две строки Spectrum
; In:
;   HL, источник
;   DE, назначение
;   BC, B содержит число строк
; Out:
;   HL, DE, адреса после последней строки
;   BC, B равен нулю
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   LDIR переносит 32 байта, но начальные адреса восстанавливаются со стека
;   два вызова #7FE3 перемещают оба адреса на две строки
;   каждый вызов меняет роли указателей и дважды продвигает прежний DE
;   после второго вызова роли указателей восстанавливаются
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #7FCF
Entry:          PUSH BC
                PUSH HL
                PUSH DE
                ; копирование одной полной строки с сохранением исходных указателей
                LD BC, #0020
                LDIR
                POP DE
                POP HL
                POP BC
                ; пропуск соседней строки для чередующегося вывода
                CALL Game.Screen.SwapAndSkipRow.Entry
                CALL Game.Screen.SwapAndSkipRow.Entry
                DJNZ Game.Screen.CopyAlternateRows.Entry

                RET
                ASSERT $ == #7FE3
                endmodule
                endmodule
