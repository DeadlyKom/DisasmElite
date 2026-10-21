                module Extensions
                module PrintPlanetInvasionStatus
; -----------------------------------------
; замена описания планеты на статус оккупации либо сопротивления
; исходный диапазон #6ED4..#6EE7
; смысловое имя PrintPlanetInvasionStatus
; In: сохранённое семя выбранной планеты GalaxyState.SavedSeed, состояние вторжения State.Invasion, вызов из Game.Menus.PrintSystemStatistics.Description
; Out: вне зоны возвращается HL=(GalaxyState.TargetSeed + FSystemSeed.GovBits), внутри печатается OCCUPIED либо RESISTING
; Corrupt: HL, DE, BC, AF
; Первый Game.Text.CheckSavedSystemRegion.Entry сравнивает планету с внешней границей вторжения, встроенный порог #3C расширяет удвоенный радиус
; При C=0 сохраняется обычное описание планеты, при C=1 повторная проверка использует порог 0
; Второй C=1 выбирает сообщение #56 IS OCCUPIED BY THARGONS, C=0 выбирает #57 IS RESISTING A THARGON INVASION
; токены #56/#57 находятся в MessageTable.Description, раскрываются PrintDescriptionByte и PrintDescriptionToken через TextSyllables
; Game.Text.CheckSavedSystemRegion.Entry поглощает байт порога только при активном вторжении в галактике 0, иначе #3C выполняется как INC A без изменения C
; POP HL удаляет возврат к записи GalaxyState.TextSeed внутри Game.Menus.PrintSystemStatistics.Description, хвостовой JP возвращает сразу внешнему экрану
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #6ED4
                ; проверка удалённости задания с поглощаемым байтом после CALL
                ; миссия 7 INVASION, геометрия выбранной системы определяет подписи OCCUPIED и RESISTING
                ; описание в Docs/Manual.md, раздел mission-7-invasion
Entry:          CALL Game.Text.CheckSavedSystemRegion.Entry
                INC A
                LD HL, (GalaxyState.TargetSeed + FSystemSeed.GovBits)
                RET NC                                                          ; выход, если первое сравнение задания не требует альтернативного сообщения

                ; повторное сравнение и выбор одного из двух альтернативных сообщений
                CALL Game.Text.CheckSavedSystemRegion.Entry
                NOP
                LD A, #57
                SBC A, #00
                POP HL
                JP Game.Text.PrintDescriptionToken.Entry

                ; проверка исходного конца фрагмента
                ASSERT $ == #6EE8
                endmodule
                endmodule
