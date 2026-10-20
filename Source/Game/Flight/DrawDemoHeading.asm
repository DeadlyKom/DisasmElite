                module Flight
                module DrawDemoHeading
; -----------------------------------------
; Печать общего заголовка демонстрации
; исходный диапазон #7447..#7460
; In:
;   D0D5 адрес инструкции загрузки экранной базы
; Out:
;   основной токен 1D выведен по X=5,Y=1, экранная база восстановлена
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   7459 общий хвост выключения bit7 по указателю D0D5+2, применяется также входами 7430 и 7426
; -----------------------------------------
                ASSERT $ == #7447
                ; основной токен 1D по X=5,Y=1 печатается в буфер вида
Entry:          LD HL, #0105
                LD (TextColumn), HL
                LD A, #1D
                LD HL, (TextBasePatch)
                INC HL
                INC HL
                SET 7, (HL)
                CALL Game.Interface.DispatchTextToken.Entry
                ; общий хвост возвращает печать в экран 4000
RestoreScreen:  LD HL, (TextBasePatch)
                INC HL
                INC HL
                RES 7, (HL)
                RET
                ASSERT $ == #7461
                endmodule
                endmodule
