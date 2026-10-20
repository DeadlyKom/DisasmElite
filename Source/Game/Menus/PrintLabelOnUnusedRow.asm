                module Menus
                module PrintLabelOnUnusedRow
; -----------------------------------------
; Печать имени только на ещё не занятой строке
; исходный диапазон #EDC5..#EE3B
; In:
;   D046 = строка, D045 = X, DEDB = имя
; Out:
;   A90A+Y помечено FF, CY=1 после успешной печати
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   При ненулевом признаке строки возвращается без вывода, EDDE отдельный экран информации
;   планеты печатает расстояние, экономику, правительство, технологию, население и продолжает
;   EE3C
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #EDC5
                ; занятость строки проверяется в таблице перед печатью имени и пометкой этой строки
Entry:          LD A, (TextRow)
                LD HL, ProjectedVerts + 16
                CALL Game.Trade.AddByteOffsetToHL.Entry
                LD A, (HL)
                AND A
                RET NZ                                                          ; выход, если выбранная строка уже занята именем другой системы, отказаться от печати

                LD A, #FF
                LD (HL), A
                LD A, #01
                LD (WordStart), A
                LD HL, GalaxyState.GeneratedName
                JP Game.Trade.PrintZeroTerminatedString.Entry

                ; экран сведений о выбранной системе, экономика, правительство и население
ShowSystem:     CALL Game.Galaxy.SelectNearestSystemWithCursor.Entry
                CALL Game.Trade.TradeTitleAndSellLoop.Entry
                LD DE, CaptionFormat
                CALL Game.Text.ApplyAttributeRuns.Entry
                LD A, #A3
                CALL Game.Trade.PrintScreenCaption.Entry
                LD A, #03
                CALL Game.Trade.SetTextRow.Entry
                CALL Game.Galaxy.PrintTargetDistance.Entry
                CALL Game.Trade.Newline.Entry
                CALL Game.Menus.BlankLineAndEconomyText.EconomyText
                LD A, #A2
                CALL Game.Trade.PrintMainTokenColon.Entry
                LD A, #B1
                LD B, A
                LD A, (GalaxyState.Government)
                ADD A, B
                CALL Game.Menus.PrintTokenAndBlankLine.Entry
                LD A, #C4
                CALL Game.Trade.PrintMainTokenColon.Entry
                LD A, #03
                LD (NumberWidth), A
                LD A, (GalaxyState.Technology)
                INC A
                CALL Game.Economy.PrintByteInteger.Entry
                CALL Game.Menus.BlankLineAndEconomyText.Entry
                LD A, #D7
                CALL Game.Trade.PrintDescriptionColon.Entry
                LD A, (GalaxyState.Population)
                CALL Game.Economy.PrintBytePrice.Entry
                LD A, #C6
                CALL Game.Menus.PrintTokenAndBlankLine.Entry
                CALL Game.Text.PrintInlineToken.Entry
                DB #28                                                          ; параметр предыдущего вызова, не исполняется как инструкция
                CALL @Game.Menus.BlankLineAndEconomyText.Population
                CALL Game.Text.PrintInlineToken.Entry
                DB #53                                                          ; параметр предыдущего вызова, не исполняется как инструкция
                ; проверка исходного конца фрагмента
                ASSERT $ == #EE3C
                endmodule
                endmodule
