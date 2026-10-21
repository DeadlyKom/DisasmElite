                module Flight
                module SetViewAttributesWithCloaking
; -----------------------------------------
; Выбор атрибутов обзорного окна с учётом маскировки
; исходный диапазон #70B0..#70B9
; In:
;   HL, L содержит атрибут
; Out:
;   L ограничен цветом чернил, если CloakActive=0, далее общий вход Game.Flight.FillViewAttributesAndFlightState.Entry
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   При выключенной маскировке AND7 убирает PAPER/BRIGHT/FLASH, при включённой исходный L сохраняется
; -----------------------------------------
                ASSERT $ == #70B0
                ; проверка маскировки перед удалением цвета бумаги и яркости из атрибута
                ; миссии 1, 2, общий выбор атрибута учитывает маскировку и далее состояние первой миссии
                ; описание в Docs/Manual.md, раздел mission-1, mission-2
Entry:          LD A, (CloakActive)
                AND A
                JR NZ, Game.Flight.FillViewAttributesAndFlightState.Entry       ; переход, если маскировка включена, сохранить полный атрибут L

                LD A, L
                AND #07
                LD L, A                                                         ; далее Game.Flight.FillViewAttributesAndFlightState.Entry без команды перехода
                ASSERT $ == #70BA
                endmodule
                endmodule
