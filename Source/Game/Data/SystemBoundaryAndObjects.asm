                module Data
                module SystemBoundaryAndObjects
; -----------------------------------------
; продолжение выхода за дальнюю границу координаты Z, начало по Game.Extensions.OfferUpgradeAndCorrectPosition.CorrectCentre
; In:
;   HL, адрес X или Y текущей системы, выбранный предшествующей ветвью
;   AF, перенос от удвоения старшей компоненты направления
; Out:
;   обновлены координаты системы, положение солнца, планеты и станции
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   обычный объект завершается отдельной ветвью Game.Data.SystemBoundaryAndObjects.ClampZ с Z_high = #DF
;   планета при переполнении инициирует смену координат текущей системы
;   INC/DEC не меняют входной перенос от ADD A,A по Game.Extensions.OfferUpgradeAndCorrectPosition.DoubleDominant
; -----------------------------------------
                ; проверка исходной границы продолжения
                ASSERT $ == #6000
                ; изменение выбранной координаты системы на +1 или -1
Continue:       INC (HL)
                JR C, @Game.Data.SystemBoundaryAndObjects.FindPlanet            ; переход, если исходное направление требует приращения

                DEC (HL)
                DEC (HL)
                ; поиск планеты в новой точке карты
FindPlanet:     LD HL, (State.SystemSeed + FSystemSeed.X)
                LD A, (State.SystemSeed + FSystemSeed.Y)
                LD H, A
                LD (TargetX), HL
                CALL Game.Galaxy.FindNearestSystem.Entry
                LD HL, (NearestMetric)
                LD A, H
                OR L
                LD (FlightState.SpaceMode), A
                JR NZ, @Game.Data.SystemBoundaryAndObjects.PlaceBodies          ; переход, если точка не совпадает с планетой, остаётся свободное пространство

                ; временная замена окончания гиперперехода на RET
                LD HL, ArrivalGate
                LD (HL), #C9
                PUSH HL
                CALL Game.Travel.EnterTargetSystem.Entry
                POP HL
                LD (HL), #28                                                    ; восстановление исходного кода JR Z
                ; завершение миссионной обработки и размещение небесных тел
                ; миссия 7+4, секретная база, размещение небесных тел вызывает особую проверку станционного слота
                ; описание в Docs/Manual.md, раздел mission-7-4
PlaceBodies:    CALL Game.Universe.CheckSpecialSystemOrRandom.Entry
                LD A, #48
                LD DE, #0003
                LD HL, FlightState.Sun + FCoordinate.SignHigh
                CALL Game.Screen.WriteStridedTriple.Entry
                ; расчёт положения планеты, после первого вызова L равен #12
                SUB L
                CALL Game.Screen.WriteStridedTriple.Entry
                LD HL, Memory.Station + FSpaceObject.X + FCoordinate.SignHigh
                CALL Game.Screen.WriteStridedTriple.Entry
                JP Game.Menus.ApplyMissionMarketRestrictions.Entry

                ; ограничение дальнего обычного объекта отрицательной координатой Z
ClampZ:         LD (IX+FCoordinate+FCoordinate+FCoordinate.SignHigh), #DF
                RET

                ASSERT $ == #6048
                endmodule
                module ObjectPool
; -----------------------------------------
; восемь исходных слотов по 39 байтов, структура FSpaceObject
; первый слот принадлежит станции, следующие шесть общим объектам
; последний слот по Memory.Missile выделен ракете игрока
; исходный первый слот содержит сохранённое состояние снимка
; штатные процедуры инициализации устанавливают действующие координаты и ориентацию
; нулевая Energy по смещению #22 обозначает свободный слот
; -----------------------------------------
                ; исходное содержимое слота Station
Station         FSpaceObject {                                                  ; явные исходные значения полей
                    {                                                           ; FSpaceObject.X, +00..02, положение относительно игрока по X
                        #20,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #2A,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #2A                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpaceObject.Y, +03..05, положение относительно игрока по Y
                        #2A,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #2D,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #2D                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpaceObject.Z, +06..08, положение относительно игрока по Z
                        #2D,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #22,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #0D                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpaceObject.AxisX, +09..0E, первая ось ориентации
                        #EC80,                                                  ; FAxis.X, компонента X
                        #3033,                                                  ; FAxis.Y, компонента Y
                        #3030                                                   ; FAxis.Z, компонента Z
                    },
                    {                                                           ; FSpaceObject.AxisY, +0F..14, вторая ось ориентации
                        #000E,                                                  ; FAxis.X, компонента X
                        #B800,                                                  ; FAxis.Y, компонента Y
                        #000B                                                   ; FAxis.Z, компонента Z
                    },
                    {                                                           ; FSpaceObject.AxisZ, +15..1A, третья ось ориентации
                        #800D,                                                  ; FAxis.X, компонента X
                        #0000,                                                  ; FAxis.Y, компонента Y
                        #5B22                                                   ; FAxis.Z, компонента Z
                    },
                    #00,                                                        ; FSpaceObject.Speed, +1B, текущая скорость
                    #00,                                                        ; FSpaceObject.Acceleration, +1C, ускорение, при взрыве координата X
                    #80,                                                        ; FSpaceObject.Roll, +1D, вращение вправо и влево, при взрыве координата Y
                    #70,                                                        ; FSpaceObject.Pitch, +1E, вращение вверх и вниз, при взрыве признаки X и Y
                    #00,                                                        ; FSpaceObject.Payload, +1F, радиус взрыва, ущерб ракеты или груз по состоянию объекта
                    #C0,                                                        ; FSpaceObject.Flags, +20, состояние корабля и остаток запускаемых объектов
                    #00,                                                        ; FSpaceObject.Hostility, +21, бит 2 задаёт враждебность
                    #F0,                                                        ; FSpaceObject.Energy, +22, энергия, нуль означает свободный слот, #FF защищает от обычного лазера
                    Blueprint.Coriolis,                                         ; FSpaceObject.Blueprint, +23..24, адрес описания модели
                    #7F,                                                        ; FSpaceObject.Target, +25, цель ракеты либо оборудование обычного корабля
                    #0C                                                         ; FSpaceObject.Flags2, +26, дополнительные признаки объекта
                }
                ; исходное содержимое слота Ship1
Ship1           FSpaceObject {                                                  ; явные исходные значения полей
                    {                                                           ; FSpaceObject.X, +00..02, положение относительно игрока по X
                        #00,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #00,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #00                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpaceObject.Y, +03..05, положение относительно игрока по Y
                        #00,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #00,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #00                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpaceObject.Z, +06..08, положение относительно игрока по Z
                        #00,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #00,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #00                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpaceObject.AxisX, +09..0E, первая ось ориентации
                        #0000,                                                  ; FAxis.X, компонента X
                        #0000,                                                  ; FAxis.Y, компонента Y
                        #0000                                                   ; FAxis.Z, компонента Z
                    },
                    {                                                           ; FSpaceObject.AxisY, +0F..14, вторая ось ориентации
                        #0000,                                                  ; FAxis.X, компонента X
                        #0000,                                                  ; FAxis.Y, компонента Y
                        #0000                                                   ; FAxis.Z, компонента Z
                    },
                    {                                                           ; FSpaceObject.AxisZ, +15..1A, третья ось ориентации
                        #0000,                                                  ; FAxis.X, компонента X
                        #0000,                                                  ; FAxis.Y, компонента Y
                        #0000                                                   ; FAxis.Z, компонента Z
                    },
                    #00,                                                        ; FSpaceObject.Speed, +1B, текущая скорость
                    #00,                                                        ; FSpaceObject.Acceleration, +1C, ускорение, при взрыве координата X
                    #00,                                                        ; FSpaceObject.Roll, +1D, вращение вправо и влево, при взрыве координата Y
                    #00,                                                        ; FSpaceObject.Pitch, +1E, вращение вверх и вниз, при взрыве признаки X и Y
                    #00,                                                        ; FSpaceObject.Payload, +1F, радиус взрыва, ущерб ракеты или груз по состоянию объекта
                    #00,                                                        ; FSpaceObject.Flags, +20, состояние корабля и остаток запускаемых объектов
                    #00,                                                        ; FSpaceObject.Hostility, +21, бит 2 задаёт враждебность
                    #00,                                                        ; FSpaceObject.Energy, +22, энергия, нуль означает свободный слот, #FF защищает от обычного лазера
                    #0000,                                                      ; FSpaceObject.Blueprint, +23..24, адрес описания модели
                    #00,                                                        ; FSpaceObject.Target, +25, цель ракеты либо оборудование обычного корабля
                    #00                                                         ; FSpaceObject.Flags2, +26, дополнительные признаки объекта
                }
                ; исходное содержимое слота Ship2
Ship2           FSpaceObject {                                                  ; явные исходные значения полей
                    {                                                           ; FSpaceObject.X, +00..02, положение относительно игрока по X
                        #00,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #00,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #00                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpaceObject.Y, +03..05, положение относительно игрока по Y
                        #00,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #00,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #00                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpaceObject.Z, +06..08, положение относительно игрока по Z
                        #00,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #00,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #00                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpaceObject.AxisX, +09..0E, первая ось ориентации
                        #0000,                                                  ; FAxis.X, компонента X
                        #0000,                                                  ; FAxis.Y, компонента Y
                        #0000                                                   ; FAxis.Z, компонента Z
                    },
                    {                                                           ; FSpaceObject.AxisY, +0F..14, вторая ось ориентации
                        #0000,                                                  ; FAxis.X, компонента X
                        #0000,                                                  ; FAxis.Y, компонента Y
                        #0000                                                   ; FAxis.Z, компонента Z
                    },
                    {                                                           ; FSpaceObject.AxisZ, +15..1A, третья ось ориентации
                        #0000,                                                  ; FAxis.X, компонента X
                        #0000,                                                  ; FAxis.Y, компонента Y
                        #0000                                                   ; FAxis.Z, компонента Z
                    },
                    #00,                                                        ; FSpaceObject.Speed, +1B, текущая скорость
                    #00,                                                        ; FSpaceObject.Acceleration, +1C, ускорение, при взрыве координата X
                    #00,                                                        ; FSpaceObject.Roll, +1D, вращение вправо и влево, при взрыве координата Y
                    #00,                                                        ; FSpaceObject.Pitch, +1E, вращение вверх и вниз, при взрыве признаки X и Y
                    #00,                                                        ; FSpaceObject.Payload, +1F, радиус взрыва, ущерб ракеты или груз по состоянию объекта
                    #00,                                                        ; FSpaceObject.Flags, +20, состояние корабля и остаток запускаемых объектов
                    #00,                                                        ; FSpaceObject.Hostility, +21, бит 2 задаёт враждебность
                    #00,                                                        ; FSpaceObject.Energy, +22, энергия, нуль означает свободный слот, #FF защищает от обычного лазера
                    #0000,                                                      ; FSpaceObject.Blueprint, +23..24, адрес описания модели
                    #00,                                                        ; FSpaceObject.Target, +25, цель ракеты либо оборудование обычного корабля
                    #00                                                         ; FSpaceObject.Flags2, +26, дополнительные признаки объекта
                }
                ; исходное содержимое слота Ship3
Ship3           FSpaceObject {                                                  ; явные исходные значения полей
                    {                                                           ; FSpaceObject.X, +00..02, положение относительно игрока по X
                        #00,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #00,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #00                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpaceObject.Y, +03..05, положение относительно игрока по Y
                        #00,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #00,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #00                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpaceObject.Z, +06..08, положение относительно игрока по Z
                        #00,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #00,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #00                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpaceObject.AxisX, +09..0E, первая ось ориентации
                        #0000,                                                  ; FAxis.X, компонента X
                        #0000,                                                  ; FAxis.Y, компонента Y
                        #0000                                                   ; FAxis.Z, компонента Z
                    },
                    {                                                           ; FSpaceObject.AxisY, +0F..14, вторая ось ориентации
                        #0000,                                                  ; FAxis.X, компонента X
                        #0000,                                                  ; FAxis.Y, компонента Y
                        #0000                                                   ; FAxis.Z, компонента Z
                    },
                    {                                                           ; FSpaceObject.AxisZ, +15..1A, третья ось ориентации
                        #0000,                                                  ; FAxis.X, компонента X
                        #0000,                                                  ; FAxis.Y, компонента Y
                        #0000                                                   ; FAxis.Z, компонента Z
                    },
                    #00,                                                        ; FSpaceObject.Speed, +1B, текущая скорость
                    #00,                                                        ; FSpaceObject.Acceleration, +1C, ускорение, при взрыве координата X
                    #00,                                                        ; FSpaceObject.Roll, +1D, вращение вправо и влево, при взрыве координата Y
                    #00,                                                        ; FSpaceObject.Pitch, +1E, вращение вверх и вниз, при взрыве признаки X и Y
                    #00,                                                        ; FSpaceObject.Payload, +1F, радиус взрыва, ущерб ракеты или груз по состоянию объекта
                    #00,                                                        ; FSpaceObject.Flags, +20, состояние корабля и остаток запускаемых объектов
                    #00,                                                        ; FSpaceObject.Hostility, +21, бит 2 задаёт враждебность
                    #00,                                                        ; FSpaceObject.Energy, +22, энергия, нуль означает свободный слот, #FF защищает от обычного лазера
                    #0000,                                                      ; FSpaceObject.Blueprint, +23..24, адрес описания модели
                    #00,                                                        ; FSpaceObject.Target, +25, цель ракеты либо оборудование обычного корабля
                    #00                                                         ; FSpaceObject.Flags2, +26, дополнительные признаки объекта
                }
                ; исходное содержимое слота Ship4
Ship4           FSpaceObject {                                                  ; явные исходные значения полей
                    {                                                           ; FSpaceObject.X, +00..02, положение относительно игрока по X
                        #00,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #00,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #00                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpaceObject.Y, +03..05, положение относительно игрока по Y
                        #00,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #00,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #00                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpaceObject.Z, +06..08, положение относительно игрока по Z
                        #00,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #00,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #00                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpaceObject.AxisX, +09..0E, первая ось ориентации
                        #0000,                                                  ; FAxis.X, компонента X
                        #0000,                                                  ; FAxis.Y, компонента Y
                        #0000                                                   ; FAxis.Z, компонента Z
                    },
                    {                                                           ; FSpaceObject.AxisY, +0F..14, вторая ось ориентации
                        #0000,                                                  ; FAxis.X, компонента X
                        #0000,                                                  ; FAxis.Y, компонента Y
                        #0000                                                   ; FAxis.Z, компонента Z
                    },
                    {                                                           ; FSpaceObject.AxisZ, +15..1A, третья ось ориентации
                        #0000,                                                  ; FAxis.X, компонента X
                        #0000,                                                  ; FAxis.Y, компонента Y
                        #0000                                                   ; FAxis.Z, компонента Z
                    },
                    #00,                                                        ; FSpaceObject.Speed, +1B, текущая скорость
                    #00,                                                        ; FSpaceObject.Acceleration, +1C, ускорение, при взрыве координата X
                    #00,                                                        ; FSpaceObject.Roll, +1D, вращение вправо и влево, при взрыве координата Y
                    #00,                                                        ; FSpaceObject.Pitch, +1E, вращение вверх и вниз, при взрыве признаки X и Y
                    #00,                                                        ; FSpaceObject.Payload, +1F, радиус взрыва, ущерб ракеты или груз по состоянию объекта
                    #00,                                                        ; FSpaceObject.Flags, +20, состояние корабля и остаток запускаемых объектов
                    #00,                                                        ; FSpaceObject.Hostility, +21, бит 2 задаёт враждебность
                    #00,                                                        ; FSpaceObject.Energy, +22, энергия, нуль означает свободный слот, #FF защищает от обычного лазера
                    #0000,                                                      ; FSpaceObject.Blueprint, +23..24, адрес описания модели
                    #00,                                                        ; FSpaceObject.Target, +25, цель ракеты либо оборудование обычного корабля
                    #00                                                         ; FSpaceObject.Flags2, +26, дополнительные признаки объекта
                }
                ; исходное содержимое слота Ship5
Ship5           FSpaceObject {                                                  ; явные исходные значения полей
                    {                                                           ; FSpaceObject.X, +00..02, положение относительно игрока по X
                        #00,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #00,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #00                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpaceObject.Y, +03..05, положение относительно игрока по Y
                        #00,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #00,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #00                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpaceObject.Z, +06..08, положение относительно игрока по Z
                        #00,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #00,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #00                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpaceObject.AxisX, +09..0E, первая ось ориентации
                        #0000,                                                  ; FAxis.X, компонента X
                        #0000,                                                  ; FAxis.Y, компонента Y
                        #0000                                                   ; FAxis.Z, компонента Z
                    },
                    {                                                           ; FSpaceObject.AxisY, +0F..14, вторая ось ориентации
                        #0000,                                                  ; FAxis.X, компонента X
                        #0000,                                                  ; FAxis.Y, компонента Y
                        #0000                                                   ; FAxis.Z, компонента Z
                    },
                    {                                                           ; FSpaceObject.AxisZ, +15..1A, третья ось ориентации
                        #0000,                                                  ; FAxis.X, компонента X
                        #0000,                                                  ; FAxis.Y, компонента Y
                        #0000                                                   ; FAxis.Z, компонента Z
                    },
                    #00,                                                        ; FSpaceObject.Speed, +1B, текущая скорость
                    #00,                                                        ; FSpaceObject.Acceleration, +1C, ускорение, при взрыве координата X
                    #00,                                                        ; FSpaceObject.Roll, +1D, вращение вправо и влево, при взрыве координата Y
                    #00,                                                        ; FSpaceObject.Pitch, +1E, вращение вверх и вниз, при взрыве признаки X и Y
                    #00,                                                        ; FSpaceObject.Payload, +1F, радиус взрыва, ущерб ракеты или груз по состоянию объекта
                    #00,                                                        ; FSpaceObject.Flags, +20, состояние корабля и остаток запускаемых объектов
                    #00,                                                        ; FSpaceObject.Hostility, +21, бит 2 задаёт враждебность
                    #00,                                                        ; FSpaceObject.Energy, +22, энергия, нуль означает свободный слот, #FF защищает от обычного лазера
                    #0000,                                                      ; FSpaceObject.Blueprint, +23..24, адрес описания модели
                    #00,                                                        ; FSpaceObject.Target, +25, цель ракеты либо оборудование обычного корабля
                    #00                                                         ; FSpaceObject.Flags2, +26, дополнительные признаки объекта
                }
                ; исходное содержимое слота Ship6
Ship6           FSpaceObject {                                                  ; явные исходные значения полей
                    {                                                           ; FSpaceObject.X, +00..02, положение относительно игрока по X
                        #00,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #00,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #00                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpaceObject.Y, +03..05, положение относительно игрока по Y
                        #00,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #00,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #00                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpaceObject.Z, +06..08, положение относительно игрока по Z
                        #00,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #00,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #00                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpaceObject.AxisX, +09..0E, первая ось ориентации
                        #0000,                                                  ; FAxis.X, компонента X
                        #0000,                                                  ; FAxis.Y, компонента Y
                        #0000                                                   ; FAxis.Z, компонента Z
                    },
                    {                                                           ; FSpaceObject.AxisY, +0F..14, вторая ось ориентации
                        #0000,                                                  ; FAxis.X, компонента X
                        #0000,                                                  ; FAxis.Y, компонента Y
                        #0000                                                   ; FAxis.Z, компонента Z
                    },
                    {                                                           ; FSpaceObject.AxisZ, +15..1A, третья ось ориентации
                        #0000,                                                  ; FAxis.X, компонента X
                        #0000,                                                  ; FAxis.Y, компонента Y
                        #0000                                                   ; FAxis.Z, компонента Z
                    },
                    #00,                                                        ; FSpaceObject.Speed, +1B, текущая скорость
                    #00,                                                        ; FSpaceObject.Acceleration, +1C, ускорение, при взрыве координата X
                    #00,                                                        ; FSpaceObject.Roll, +1D, вращение вправо и влево, при взрыве координата Y
                    #00,                                                        ; FSpaceObject.Pitch, +1E, вращение вверх и вниз, при взрыве признаки X и Y
                    #00,                                                        ; FSpaceObject.Payload, +1F, радиус взрыва, ущерб ракеты или груз по состоянию объекта
                    #00,                                                        ; FSpaceObject.Flags, +20, состояние корабля и остаток запускаемых объектов
                    #00,                                                        ; FSpaceObject.Hostility, +21, бит 2 задаёт враждебность
                    #00,                                                        ; FSpaceObject.Energy, +22, энергия, нуль означает свободный слот, #FF защищает от обычного лазера
                    #0000,                                                      ; FSpaceObject.Blueprint, +23..24, адрес описания модели
                    #00,                                                        ; FSpaceObject.Target, +25, цель ракеты либо оборудование обычного корабля
                    #00                                                         ; FSpaceObject.Flags2, +26, дополнительные признаки объекта
                }
                ; исходное содержимое слота Missile
Missile         FSpaceObject {                                                  ; явные исходные значения полей
                    {                                                           ; FSpaceObject.X, +00..02, положение относительно игрока по X
                        #00,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #00,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #00                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpaceObject.Y, +03..05, положение относительно игрока по Y
                        #00,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #00,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #00                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpaceObject.Z, +06..08, положение относительно игрока по Z
                        #00,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #00,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #00                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpaceObject.AxisX, +09..0E, первая ось ориентации
                        #0000,                                                  ; FAxis.X, компонента X
                        #0000,                                                  ; FAxis.Y, компонента Y
                        #0000                                                   ; FAxis.Z, компонента Z
                    },
                    {                                                           ; FSpaceObject.AxisY, +0F..14, вторая ось ориентации
                        #0000,                                                  ; FAxis.X, компонента X
                        #0000,                                                  ; FAxis.Y, компонента Y
                        #0000                                                   ; FAxis.Z, компонента Z
                    },
                    {                                                           ; FSpaceObject.AxisZ, +15..1A, третья ось ориентации
                        #0000,                                                  ; FAxis.X, компонента X
                        #0000,                                                  ; FAxis.Y, компонента Y
                        #0000                                                   ; FAxis.Z, компонента Z
                    },
                    #00,                                                        ; FSpaceObject.Speed, +1B, текущая скорость
                    #00,                                                        ; FSpaceObject.Acceleration, +1C, ускорение, при взрыве координата X
                    #00,                                                        ; FSpaceObject.Roll, +1D, вращение вправо и влево, при взрыве координата Y
                    #00,                                                        ; FSpaceObject.Pitch, +1E, вращение вверх и вниз, при взрыве признаки X и Y
                    #00,                                                        ; FSpaceObject.Payload, +1F, радиус взрыва, ущерб ракеты или груз по состоянию объекта
                    #00,                                                        ; FSpaceObject.Flags, +20, состояние корабля и остаток запускаемых объектов
                    #00,                                                        ; FSpaceObject.Hostility, +21, бит 2 задаёт враждебность
                    #00,                                                        ; FSpaceObject.Energy, +22, энергия, нуль означает свободный слот, #FF защищает от обычного лазера
                    #0000,                                                      ; FSpaceObject.Blueprint, +23..24, адрес описания модели
                    #00,                                                        ; FSpaceObject.Target, +25, цель ракеты либо оборудование обычного корабля
                    #00                                                         ; FSpaceObject.Flags2, +26, дополнительные признаки объекта
                }
                ASSERT $ == #6180
                endmodule
                module ModelIndex
; -----------------------------------------
; 23 четырёхбайтные записи индекса моделей и нулевой терминатор
; байт 0 задаёт исходные свойства объекта, слово 1 адрес описания модели
; байт 3 содержит класс, используемый при выборе случайного объекта
; Game.Universe.InitializeExtendedObjectMetadata.NextBlueprint ищет запись по адресу модели и читает её первый байт как набор свойств
; первый байт этой версии не является неиспользуемым кодом JP из старого Elite
; заголовки моделей перечислены в каталоге Game.Data.ModelIndex.Entry
; -----------------------------------------
Entry           FModelIndex {                                                   ; запись 0, FModelIndex
                    #80,                                                        ; FModelIndex.Flags, +00, свойства модели для Game.Universe.InitializeExtendedObjectMetadata.NextBlueprint
                    Blueprint.Coriolis,                                         ; FModelIndex.Address, +01..02, абсолютный адрес FModel, потребитель Game.Objects.InitializeObject.Entry
                    #00                                                         ; FModelIndex.Class, +03, класс модели для выбора случайного объекта
                }

                FModelIndex {                                                   ; запись 1, FModelIndex
                    #84,                                                        ; FModelIndex.Flags, +00, свойства модели для Game.Universe.InitializeExtendedObjectMetadata.NextBlueprint
                    Blueprint.Missile,                                          ; FModelIndex.Address, +01..02, абсолютный адрес FModel, потребитель Game.Objects.InitializeObject.Entry
                    #00                                                         ; FModelIndex.Class, +03, класс модели для выбора случайного объекта
                }

                FModelIndex {                                                   ; запись 2, FModelIndex
                    #B0,                                                        ; FModelIndex.Flags, +00, свойства модели для Game.Universe.InitializeExtendedObjectMetadata.NextBlueprint
                    Blueprint.EscapePod,                                        ; FModelIndex.Address, +01..02, абсолютный адрес FModel, потребитель Game.Objects.InitializeObject.Entry
                    #01                                                         ; FModelIndex.Class, +03, класс модели для выбора случайного объекта
                }

                FModelIndex {                                                   ; запись 3, FModelIndex
                    #93,                                                        ; FModelIndex.Flags, +00, свойства модели для Game.Universe.InitializeExtendedObjectMetadata.NextBlueprint
                    Blueprint.Alloys,                                           ; FModelIndex.Address, +01..02, абсолютный адрес FModel, потребитель Game.Objects.InitializeObject.Entry
                    #01                                                         ; FModelIndex.Class, +03, класс модели для выбора случайного объекта
                }

                FModelIndex {                                                   ; запись 4, FModelIndex
                    #93,                                                        ; FModelIndex.Flags, +00, свойства модели для Game.Universe.InitializeExtendedObjectMetadata.NextBlueprint
                    Blueprint.Cargo,                                            ; FModelIndex.Address, +01..02, абсолютный адрес FModel, потребитель Game.Objects.InitializeObject.Entry
                    #01                                                         ; FModelIndex.Class, +03, класс модели для выбора случайного объекта
                }

                FModelIndex {                                                   ; запись 5, FModelIndex
                    #93,                                                        ; FModelIndex.Flags, +00, свойства модели для Game.Universe.InitializeExtendedObjectMetadata.NextBlueprint
                    Blueprint.Minerals,                                         ; FModelIndex.Address, +01..02, абсолютный адрес FModel, потребитель Game.Objects.InitializeObject.Entry
                    #01                                                         ; FModelIndex.Class, +03, класс модели для выбора случайного объекта
                }

                FModelIndex {                                                   ; запись 6, FModelIndex
                    #87,                                                        ; FModelIndex.Flags, +00, свойства модели для Game.Universe.InitializeExtendedObjectMetadata.NextBlueprint
                    Blueprint.Asteroid,                                         ; FModelIndex.Address, +01..02, абсолютный адрес FModel, потребитель Game.Objects.InitializeObject.Entry
                    #02                                                         ; FModelIndex.Class, +03, класс модели для выбора случайного объекта
                }

                FModelIndex {                                                   ; запись 7, FModelIndex
                    #D0,                                                        ; FModelIndex.Flags, +00, свойства модели для Game.Universe.InitializeExtendedObjectMetadata.NextBlueprint
                    Blueprint.AsteroidArmed,                                    ; FModelIndex.Address, +01..02, абсолютный адрес FModel, потребитель Game.Objects.InitializeObject.Entry
                    #02                                                         ; FModelIndex.Class, +03, класс модели для выбора случайного объекта
                }

                FModelIndex {                                                   ; запись 8, FModelIndex
                    #C0,                                                        ; FModelIndex.Flags, +00, свойства модели для Game.Universe.InitializeExtendedObjectMetadata.NextBlueprint
                    Blueprint.Viper,                                            ; FModelIndex.Address, +01..02, абсолютный адрес FModel, потребитель Game.Objects.InitializeObject.Entry
                    #02                                                         ; FModelIndex.Class, +03, класс модели для выбора случайного объекта
                }

                FModelIndex {                                                   ; запись 9, FModelIndex
                    #F0,                                                        ; FModelIndex.Flags, +00, свойства модели для Game.Universe.InitializeExtendedObjectMetadata.NextBlueprint
                    Blueprint.CobraTrader,                                      ; FModelIndex.Address, +01..02, абсолютный адрес FModel, потребитель Game.Objects.InitializeObject.Entry
                    #02                                                         ; FModelIndex.Class, +03, класс модели для выбора случайного объекта
                }

                FModelIndex {                                                   ; запись 10, FModelIndex
                    #F0,                                                        ; FModelIndex.Flags, +00, свойства модели для Game.Universe.InitializeExtendedObjectMetadata.NextBlueprint
                    Blueprint.PythonTrader,                                     ; FModelIndex.Address, +01..02, абсолютный адрес FModel, потребитель Game.Objects.InitializeObject.Entry
                    #02                                                         ; FModelIndex.Class, +03, класс модели для выбора случайного объекта
                }

                FModelIndex {                                                   ; запись 11, FModelIndex
                    #F0,                                                        ; FModelIndex.Flags, +00, свойства модели для Game.Universe.InitializeExtendedObjectMetadata.NextBlueprint
                    Blueprint.PythonPirate,                                     ; FModelIndex.Address, +01..02, абсолютный адрес FModel, потребитель Game.Objects.InitializeObject.Entry
                    #03                                                         ; FModelIndex.Class, +03, класс модели для выбора случайного объекта
                }

                FModelIndex {                                                   ; запись 12, FModelIndex
                    #F0,                                                        ; FModelIndex.Flags, +00, свойства модели для Game.Universe.InitializeExtendedObjectMetadata.NextBlueprint
                    Blueprint.CobraPirate,                                      ; FModelIndex.Address, +01..02, абсолютный адрес FModel, потребитель Game.Objects.InitializeObject.Entry
                    #03                                                         ; FModelIndex.Class, +03, класс модели для выбора случайного объекта
                }

                FModelIndex {                                                   ; запись 13, FModelIndex
                    #FC,                                                        ; FModelIndex.Flags, +00, свойства модели для Game.Universe.InitializeExtendedObjectMetadata.NextBlueprint
                    Blueprint.Asp,                                              ; FModelIndex.Address, +01..02, абсолютный адрес FModel, потребитель Game.Objects.InitializeObject.Entry
                    #04                                                         ; FModelIndex.Class, +03, класс модели для выбора случайного объекта
                }

                FModelIndex {                                                   ; запись 14, FModelIndex
                    #F0,                                                        ; FModelIndex.Flags, +00, свойства модели для Game.Universe.InitializeExtendedObjectMetadata.NextBlueprint
                    Blueprint.FerDeLance,                                       ; FModelIndex.Address, +01..02, абсолютный адрес FModel, потребитель Game.Objects.InitializeObject.Entry
                    #03                                                         ; FModelIndex.Class, +03, класс модели для выбора случайного объекта
                }

                FModelIndex {                                                   ; запись 15, FModelIndex
                    #FF,                                                        ; FModelIndex.Flags, +00, свойства модели для Game.Universe.InitializeExtendedObjectMetadata.NextBlueprint
                    Blueprint.Thargoid,                                         ; FModelIndex.Address, +01..02, абсолютный адрес FModel, потребитель Game.Objects.InitializeObject.Entry
                    #03                                                         ; FModelIndex.Class, +03, класс модели для выбора случайного объекта
                }

                FModelIndex {                                                   ; запись 16, FModelIndex
                    #C4,                                                        ; FModelIndex.Flags, +00, свойства модели для Game.Universe.InitializeExtendedObjectMetadata.NextBlueprint
                    Blueprint.Sidewinder,                                       ; FModelIndex.Address, +01..02, абсолютный адрес FModel, потребитель Game.Objects.InitializeObject.Entry
                    #04                                                         ; FModelIndex.Class, +03, класс модели для выбора случайного объекта
                }

                FModelIndex {                                                   ; запись 17, FModelIndex
                    #D4,                                                        ; FModelIndex.Flags, +00, свойства модели для Game.Universe.InitializeExtendedObjectMetadata.NextBlueprint
                    Blueprint.Adder,                                            ; FModelIndex.Address, +01..02, абсолютный адрес FModel, потребитель Game.Objects.InitializeObject.Entry
                    #04                                                         ; FModelIndex.Class, +03, класс модели для выбора случайного объекта
                }

                FModelIndex {                                                   ; запись 18, FModelIndex
                    #C7,                                                        ; FModelIndex.Flags, +00, свойства модели для Game.Universe.InitializeExtendedObjectMetadata.NextBlueprint
                    Blueprint.Tharglet,                                         ; FModelIndex.Address, +01..02, абсолютный адрес FModel, потребитель Game.Objects.InitializeObject.Entry
                    #04                                                         ; FModelIndex.Class, +03, класс модели для выбора случайного объекта
                }

                FModelIndex {                                                   ; запись 19, FModelIndex
                    #FF,                                                        ; FModelIndex.Flags, +00, свойства модели для Game.Universe.InitializeExtendedObjectMetadata.NextBlueprint
                    Blueprint.Thargoid6,                                        ; FModelIndex.Address, +01..02, абсолютный адрес FModel, потребитель Game.Objects.InitializeObject.Entry
                    #03                                                         ; FModelIndex.Class, +03, класс модели для выбора случайного объекта
                }

                FModelIndex {                                                   ; запись 20, FModelIndex
                    #D0,                                                        ; FModelIndex.Flags, +00, свойства модели для Game.Universe.InitializeExtendedObjectMetadata.NextBlueprint
                    Blueprint.Fighter1,                                         ; FModelIndex.Address, +01..02, абсолютный адрес FModel, потребитель Game.Objects.InitializeObject.Entry
                    #02                                                         ; FModelIndex.Class, +03, класс модели для выбора случайного объекта
                }

                FModelIndex {                                                   ; запись 21, FModelIndex
                    #D4,                                                        ; FModelIndex.Flags, +00, свойства модели для Game.Universe.InitializeExtendedObjectMetadata.NextBlueprint
                    Blueprint.Fighter2,                                         ; FModelIndex.Address, +01..02, абсолютный адрес FModel, потребитель Game.Objects.InitializeObject.Entry
                    #04                                                         ; FModelIndex.Class, +03, класс модели для выбора случайного объекта
                }

                FModelIndex {                                                   ; запись 22, FModelIndex
                    #D4,                                                        ; FModelIndex.Flags, +00, свойства модели для Game.Universe.InitializeExtendedObjectMetadata.NextBlueprint
                    Blueprint.Krait,                                            ; FModelIndex.Address, +01..02, абсолютный адрес FModel, потребитель Game.Objects.InitializeObject.Entry
                    #04                                                         ; FModelIndex.Class, +03, класс модели для выбора случайного объекта
                }
Terminator:     DB #00                                                          ; конец поиска по адресу модели
                ASSERT $ == #61DD
                endmodule
                endmodule
