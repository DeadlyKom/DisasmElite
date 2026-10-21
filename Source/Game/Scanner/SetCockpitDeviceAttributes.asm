                module Scanner
                module SetCockpitDeviceAttributes
; -----------------------------------------
; Цвета двух панелей приборов по наличию спасательной капсулы
; исходный диапазон #9974..#9994
; In:
;   номер вида FlightState.View, наличие капсулы State.EscapePod
; Out:
;   по 35 атрибутов левой и правой панелей обновлены
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Виды 0..3 используют Memory.Attributes + #0223, прочие Memory.Attributes + #0323, второе поле смещено на 21 столбец
;   Без капсулы атрибут 17, с капсулой 1F, каждый прямоугольник 5×7
;   После первой панели хвостом вызывается Game.Scanner.FillCockpitAttributePanel.Entry для второй
; -----------------------------------------
                ASSERT $ == #9974
                ; выбор атрибутов на экране либо в его копии
Entry:          LD HL, Memory.Attributes + 17 * 32 + 3                          ; левая панель приборов, строка 17, столбец 3
                LD A, (FlightState.View)
                CP #04
                JR C, SelectColor                                               ; переход, если открыт один из четырёх видов кабины, писать атрибуты на экран

                INC H
                ; проверка капсулы для выбора цвета панелей
SelectColor:    LD C, #17
                LD A, (State.EscapePod)
                AND A
                JR Z, FillPanels                                                ; переход, если спасательная капсула отсутствует, оставить атрибут 17

                LD C, #1F
                ; заливка левой панели и смещение на 21 столбец к правой
FillPanels:     LD DE, #001B
                PUSH HL
                CALL Game.Scanner.FillCockpitAttributePanel.Entry
                POP HL
                LD A, L
                ADD A, #15
                LD L, A                                                         ; далее Game.Scanner.FillCockpitAttributePanel.Entry без команды перехода
                ASSERT $ == #9995
                endmodule
                endmodule
