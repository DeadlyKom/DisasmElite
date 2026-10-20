                module Universe
                module DrawSunAndPlanet
; -----------------------------------------
; проекция и вывод солнца и планеты
; исходный диапазон #7584..#75BF
; In:
;   память 7107/7110, две трёхбайтовые координатные тройки
; Out:
;   графический буфер обновлён
;   7120 задаёт режим наложения объектов
; Corrupt:
;   HL, DE, BC, AF
; Note:
; Каждые девять байтов копируются в общую рабочую тройку 757A.
; D7B9 вычисляет проекцию и дополнительные параметры, солнечный радиус корректирует 75C0.
; Первое светило рисуется 86D0, при радиусе от 40 ставится 7120=1 для XOR-режима объектов.
; Второе светило выводится хвостовым переходом 86DE.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #7584
                ; подготовка координат первого светила и сброс режима наложения
Entry:          XOR A
                LD (FlightState.XorObjects), A
                LD HL, FlightState.Sun
                LD DE, Game.Flight.MainGameLoop.BodyX
                LD BC, #0009
                LDIR
                CALL Game.Text.DrawProjectedSunAndTextDispatch.Entry
                PUSH AF
                CALL Game.Universe.ExpandNovaRadius.Entry
                POP AF
                AND A
                JR Z, DrawPlanet                                                ; переход, если первое светило не имеет видимой проекции

                CALL Game.Screen.DrawFilledCircle.Entry
                LD A, (CircleState.Radius)
                CP #28
                JR C, DrawPlanet                                                ; переход, если радиус первого светила меньше 40

                LD A, #01
                LD (FlightState.XorObjects), A
                ; подготовка и проекция второго светила
DrawPlanet:     LD HL, FlightState.Planet
                LD DE, Game.Flight.MainGameLoop.BodyX
                LD BC, #0009
                LDIR
                CALL Game.Text.DrawProjectedSunAndTextDispatch.Entry
                AND A
                RET Z                                                           ; выход, если второе светило не имеет видимой проекции

                JP Game.Screen.DrawCircleOutline.Entry
                ; проверка исходного конца фрагмента
                ASSERT $ == #75C0
                endmodule
                endmodule
