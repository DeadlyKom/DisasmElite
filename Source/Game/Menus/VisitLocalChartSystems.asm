                module Menus
                module VisitLocalChartSystems
; -----------------------------------------
; Перебор 256 систем с отсечением по местному прямоугольнику
; исходный диапазон #ECD2..#ECFC
; In:
;   HL = адрес обработчика видимой планеты
; Out:
;   Для каждой видимой системы вызван обработчик, семя проходит весь цикл
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Адрес HL записывается в операнд CALL LocalMapVisit, обработчик обязан сам продвинуть семя на
;   следующую планету, для невидимой системы это делает Game.Galaxy.AdvanceSystemSeed.Entry, границы CP задаёт Game.Menus.OpenLocalChart.Entry
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #ECD2
                ; обход семян применяет изменяемые границы X/Y до вызова выбранного обработчика
Entry:          LD (LocalMapVisit), HL
                CALL Game.Galaxy.LoadGalaxySeed.Entry
                LD B, #00
CheckSystem:    PUSH BC
                LD A, (GalaxyState.WorkingSeed + FSystemSeed.X)
LeftLimit       EQU $ + 1                                                       ; изменяемая включённая левая граница X в CP
                CP #01
                JR C, AdvanceSeed                                               ; переход, если X планеты меньше изменяемой левой границы, пропустить систему

RightLimit      EQU $ + 1                                                       ; изменяемая исключённая правая граница X в CP
                CP #27
                JR NC, AdvanceSeed                                              ; переход, если X планеты не меньше изменяемой правой границы, пропустить систему

                LD A, (GalaxyState.WorkingSeed + FSystemSeed.Y)
TopLimit        EQU $ + 1                                                       ; изменяемая включённая верхняя граница Y в CP
                CP #8B
                JR C, AdvanceSeed                                               ; переход, если Y планеты меньше изменяемой верхней границы, пропустить систему

BottomLimit     EQU $ + 1                                                       ; изменяемая исключённая нижняя граница Y в CP
                CP #CF
                JR NC, AdvanceSeed                                              ; переход, если Y планеты не меньше изменяемой нижней границы, пропустить систему

SystemHandler   EQU $ + 1                                                       ; адрес обработчика видимой системы в операнде CALL
                CALL Game.Menus.PlaceLocalSystemLabel.Entry
                JR NextSystem

AdvanceSeed:    CALL Game.Galaxy.AdvanceSystemSeed.Entry
NextSystem:     POP BC
                DJNZ CheckSystem

                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #ECFD
                endmodule
                endmodule
