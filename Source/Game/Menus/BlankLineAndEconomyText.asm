                module Menus
                module BlankLineAndEconomyText
; -----------------------------------------
; Два перевода строки и обработчики описания экономики
; исходный диапазон #EEA2..#EEDA
; In:
;   Нет параметров для EEA2
; Out:
;   Курсор переведён на две строки
; Corrupt:
;   AF
; Note:
;   EEA8 отдельно печатает класс экономики по DEF8, значение 4 имеет особое название, EECE
;   выбирает токен BC/F7 по старшему биту DEBE для типа населения
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #EEA2
                ; двукратное увеличение строки отделяет абзацы информации о планете
Entry:          CALL Game.Trade.Newline.Entry
SecondNewline:  JP Game.Trade.Newline.Entry

                ; печать типа экономики и вида населения
EconomyText:    LD A, #70
                CALL Game.Trade.PrintDescriptionColon.Entry
                LD A, (GalaxyState.Economy)
                CP #04
                JR Z, PoorEconomy                                               ; переход, если экономика равна 4, использовать отдельный токен её названия

                JR C, EconomyToken                                              ; переход, если экономика меньше 4, индекс категории уже подходит для таблицы

                SUB #05
EconomyToken:   ADD A, #AA
                CALL Game.Text.PrintMainToken.Entry
EconomyClass:   LD A, (GalaxyState.Economy)
                SRL A
                SRL A
                ADD A, #A8
                JR Game.Menus.PrintTokenAndBlankLine.Entry

PoorEconomy:    CALL Game.Text.PrintInlineToken.Entry
                DB #AD                                                          ; параметр предыдущего вызова, не исполняется как инструкция
                JR EconomyClass

Population:     LD A, (GalaxyState.TargetSeed + FSystemSeed.MixLow)
                RLCA
                LD A, #BC
                JR NC, PrintRace                                                ; переход, если старший бит семени населения сброшен, использовать токен BC

                LD A, #F7
PrintRace:      JP Game.Text.PrintMainToken.Entry
                ; проверка исходного конца фрагмента
                ASSERT $ == #EEDB
                endmodule
                endmodule
