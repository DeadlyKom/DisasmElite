                module Menus
                module PrintSystemStatistics
; -----------------------------------------
; Вывод производительности, радиуса и описания планеты
; исходный диапазон #EE3C..#EE9C
; In:
;   поля GalaxyState.Economy, Government, Technology, Population и Productivity и GalaxyState.TargetSeed = характеристики
; Out:
;   Показана статистика, подготовлены семена описания GalaxyState.TextSeed/GalaxyState.TextSeed + 2
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Производительность печатается целым шириной 5, радиус вычисляет Game.Menus.PrintSystemRadius.Entry, при активной миссии и
;   совпадении семени с State.GalaxySeed печатается 57, обычный путь вызывает Game.Extensions.PrintPlanetInvasionStatus.Entry и возвращает A=5,
;   два байта после последнего JP сохранены буквально
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #EE3C
                ; производительность, радиус и описание выводятся из рассчитанных свойств цели
                ; миссии 3, 7 INVASION, ненулевое общее состояние и совпадение семени разрешают особое описание системы
                ; описание в Docs/Manual.md, раздел mission-3, mission-7-invasion
Entry:          LD A, #29
                CALL Game.Menus.PrintTokenAndBlankLine.Entry
                LD A, #6F
                CALL Game.Trade.PrintDescriptionColon.Entry
                LD HL, (GalaxyState.Productivity)
                LD A, #05
                LD (NumberWidth), A
                AND A
                CALL Game.Economy.PrintWordDecimal.Entry
                CALL Game.Text.PrintInlineToken.Entry
                DB #20                                                          ; аргумент вызываемой процедуры из потока команд
                CALL Game.Text.PrintInlineToken.Entry
                DB #4D                                                          ; аргумент вызываемой процедуры из потока команд
                LD A, #E2
                CALL Game.Trade.PrintDecoratedToken.Entry
                CALL Game.Menus.BlankLineAndEconomyText.Entry
                LD A, #FA
                CALL Game.Trade.PrintMainTokenColon.Entry
                CALL Game.Menus.PrintSystemRadius.Entry
                CALL Game.Text.PrintInlineToken.Entry
                DB #20                                                          ; аргумент вызываемой процедуры из потока команд
                ; для специальной миссии проверяется совпадение семени до подмены обычного описания
                LD A, #11
                LD (MarketWork.Commodity), A
                CALL Game.Trade.PrintCommodityUnit.Entry
                CALL Game.Menus.BlankLineAndEconomyText.Entry
                LD A, (State.Mission3)
                AND A
                JR Z, Description                                               ; переход, если специальная миссия не активна, печатать обычное описание планеты

                LD HL, GalaxyState.TargetSeed
                CALL Game.Menus.CompareSystemSeedToGalaxyBase.Entry
                JR C, Description                                               ; переход, если семя выбранной планеты отличается от базового, специальное описание не применяется

                LD A, #57
                JP Game.Text.PrintDescriptionToken.Entry

Description:    CALL Game.Extensions.PrintPlanetInvasionStatus.Entry
                LD (GalaxyState.TextSeed), HL
                LD HL, (GalaxyState.TargetSeed + FSystemSeed.MixLow)
                LD (GalaxyState.TextSeed + 2), HL
                LD A, #05
                RET

                ; остаточное слово Game.Text.PrintDescriptionToken.Entry после завершения описания системы
                DB #5F, #D4                                                     ; #EE9B..#EE9C
                ; проверка исходного конца фрагмента
                ASSERT $ == #EE9D
                endmodule
                endmodule
