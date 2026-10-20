                module Flight
                module SetViewAttributesWithCloaking
; -----------------------------------------
; Выбор атрибутов обзорного окна с учётом маскировки
; исходный диапазон #70B0..#70B9
; In:
;   HL, L содержит атрибут
; Out:
;   L ограничен цветом чернил, если D041=0, далее общий вход 70BA
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   При выключенной маскировке AND7 убирает PAPER/BRIGHT/FLASH, при включённой исходный L сохраняется
; -----------------------------------------
                ASSERT $ == #70B0
                ; проверка маскировки перед удалением цвета бумаги и яркости из атрибута
Entry:          LD A, (CloakActive)
                AND A
                JR NZ, Game.Flight.FillViewAttributesAndFlightState.Entry       ; переход, если маскировка включена, сохранить полный атрибут L

                LD A, L
                AND #07
                LD L, A
                ASSERT $ == #70BA
                endmodule
                endmodule
