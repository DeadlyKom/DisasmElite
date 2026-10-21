                module Flight
                module FillViewAttributesAndFlightState
; -----------------------------------------
; Заливка внутренних атрибутов окна и состояние полёта
; исходный диапазон #70BA..#7118
; In:
;   HL, L содержит атрибут
; Out:
;   15 строк по 30 атрибутов заполнены, рамочные столбцы сохранены
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   При State.Mission1!=0 используется L&3A, затем HALT синхронизирует запись
;   Каждая строка получает одну запись и LDDR29 байтов, итого 450 ячеек от Memory.Attributes + #0021 до Memory.Attributes + #01FE
;   за кодом лежат InvasionClock, приборы GaugeState, поля FlightState и координаты Sun/Planet
; -----------------------------------------
                ASSERT $ == #70BA
                ; проверка специального цвета первой миссии
                ; миссия 1, беженцы, первая миссия ограничивает атрибут вида маской перед заливкой
                ; описание в Docs/Manual.md, раздел mission-1
Entry:          LD A, (State.Mission1)
                AND A
                JR Z, SyncFill                                                  ; переход, если первая миссия не активна, сохранить исходный цвет

                LD A, L
                AND #3A
                LD L, A
                ; синхронизация с кадром перед заливкой внутреннего окна
SyncFill:       HALT
                LD A, L
                LD HL, Memory.Attributes + #01FE                                ; последний внутренний атрибут нижней строки обзорного окна
                LD B, #0F
                ; размножение атрибута в 30 ячеек строки, затем пропуск боковых столбцов рамки
FillRow:        LD (HL), A
                LD D, H
                LD E, L
                DEC DE
                PUSH BC
                LD BC, #001D
                LDDR
                DEC HL
                DEC HL
                DEC HL
                POP BC
                DJNZ FillRow

                RET

                ; 16-битный накопитель времени вторжения, обновляется Game.Combat.UpdateClockAndRotateDistantBodies.Entry добавкой NOT State.Invasion
InvasionClock   DW #0000                                                        ; хранение FlightState.InvasionClock
                ; сохранённое слово FFFC, прямых чтений и записей в разобранном коде не найдено
                DB #FC, #FF                                                     ; #70DE..#70DF
                ; отдельный стартовый вектор сохраняет стек и настраивает кабину
StartGame:      JP Game.Flight.PlaySweepingBeeperAndBootstrap.Bootstrap

                ; номер текущего вида,0..3 кабина,7/8 карты
View            DB #0B                                                          ; хранение FlightState.View
                ; знако-модульный крен из InputMotion.Roll + 1
Roll            DB #00                                                          ; хранение FlightState.Roll
                ; знако-модульный тангаж из InputMotion.Pitch + 1
Pitch           DB #00                                                          ; хранение FlightState.Pitch
                ; текущая скорость из InputMotion.Speed + 1
Speed           DB #0C                                                          ; хранение FlightState.Speed
                ; передний щит, сначала прежнее значение прибора, затем текущее
FrontShieldPrev EQU Gauges + FGaugeState.FrontShield.Previous                   ; сохранённое имя поля FGaugeState.FrontShield.Previous
FrontShieldNow  EQU Gauges + FGaugeState.FrontShield.Current                    ; сохранённое имя поля FGaugeState.FrontShield.Current
RearShieldPrev  EQU Gauges + FGaugeState.RearShield.Previous                    ; сохранённое имя поля FGaugeState.RearShield.Previous
RearShieldNow   EQU Gauges + FGaugeState.RearShield.Current                     ; сохранённое имя поля FGaugeState.RearShield.Current
FuelPrev        EQU Gauges + FGaugeState.Fuel.Previous                          ; сохранённое имя поля FGaugeState.Fuel.Previous
FuelNow         EQU Gauges + FGaugeState.Fuel.Current                           ; сохранённое имя поля FGaugeState.Fuel.Current
CabinHeatPrev   EQU Gauges + FGaugeState.CabinHeat.Previous                     ; сохранённое имя поля FGaugeState.CabinHeat.Previous
CabinHeatNow    EQU Gauges + FGaugeState.CabinHeat.Current                      ; сохранённое имя поля FGaugeState.CabinHeat.Current
LaserHeatPrev   EQU Gauges + FGaugeState.LaserHeat.Previous                     ; сохранённое имя поля FGaugeState.LaserHeat.Previous
LaserHeatNow    EQU Gauges + FGaugeState.LaserHeat.Current                      ; сохранённое имя поля FGaugeState.LaserHeat.Current
AltitudePrev    EQU Gauges + FGaugeState.Altitude.Previous                      ; сохранённое имя поля FGaugeState.Altitude.Previous
AltitudeNow     EQU Gauges + FGaugeState.Altitude.Current                       ; сохранённое имя поля FGaugeState.Altitude.Current
SpeedPrev       EQU Gauges + FGaugeState.Speed.Previous                         ; сохранённое имя поля FGaugeState.Speed.Previous
SpeedNow        EQU Gauges + FGaugeState.Speed.Current                          ; сохранённое имя поля FGaugeState.Speed.Current
Energy1Prev     EQU Gauges + FGaugeState.Energy1.Previous                       ; сохранённое имя поля FGaugeState.Energy1.Previous
Energy1Now      EQU Gauges + FGaugeState.Energy1.Current                        ; сохранённое имя поля FGaugeState.Energy1.Current
Energy2Prev     EQU Gauges + FGaugeState.Energy2.Previous                       ; сохранённое имя поля FGaugeState.Energy2.Previous
Energy2Now      EQU Gauges + FGaugeState.Energy2.Current                        ; сохранённое имя поля FGaugeState.Energy2.Current
Energy3Prev     EQU Gauges + FGaugeState.Energy3.Previous                       ; сохранённое имя поля FGaugeState.Energy3.Previous
Energy3Now      EQU Gauges + FGaugeState.Energy3.Current                        ; сохранённое имя поля FGaugeState.Energy3.Current
Energy4Prev     EQU Gauges + FGaugeState.Energy4.Previous                       ; сохранённое имя поля FGaugeState.Energy4.Previous
Energy4Now      EQU Gauges + FGaugeState.Energy4.Current                        ; сохранённое имя поля FGaugeState.Energy4.Current
RollPrev        EQU Gauges + FGaugeState.Roll.Previous                          ; сохранённое имя поля FGaugeState.Roll.Previous
RollNow         EQU Gauges + FGaugeState.Roll.Current                           ; сохранённое имя поля FGaugeState.Roll.Current
PitchPrev       EQU Gauges + FGaugeState.Pitch.Previous                         ; сохранённое имя поля FGaugeState.Pitch.Previous
PitchNow        EQU Gauges + FGaugeState.Pitch.Current                          ; сохранённое имя поля FGaugeState.Pitch.Current

Gauges          FGaugeState {                                                   ; явные исходные значения полей
                    {                                                           ; FGaugeState.FrontShield, передний щит
                        #00,                                                    ; FGauge.Previous, предыдущее значение индикатора
                        #00                                                     ; FGauge.Current, новое значение для сравнения и вывода
                    },
                    {                                                           ; FGaugeState.RearShield, задний щит
                        #00,                                                    ; FGauge.Previous, предыдущее значение индикатора
                        #00                                                     ; FGauge.Current, новое значение для сравнения и вывода
                    },
                    {                                                           ; FGaugeState.Fuel, полоса топлива, 2*fuel+floor(fuel/4)
                        #00,                                                    ; FGauge.Previous, предыдущее значение индикатора
                        #A0                                                     ; FGauge.Current, новое значение для сравнения и вывода
                    },
                    {                                                           ; FGaugeState.CabinHeat, нагрев кабины
                        #00,                                                    ; FGauge.Previous, предыдущее значение индикатора
                        #00                                                     ; FGauge.Current, новое значение для сравнения и вывода
                    },
                    {                                                           ; FGaugeState.LaserHeat, нагрев лазера
                        #00,                                                    ; FGauge.Previous, предыдущее значение индикатора
                        #00                                                     ; FGauge.Current, новое значение для сравнения и вывода
                    },
                    {                                                           ; FGaugeState.Altitude, высота над планетой
                        #00,                                                    ; FGauge.Previous, предыдущее значение индикатора
                        #A0                                                     ; FGauge.Current, новое значение для сравнения и вывода
                    },
                    {                                                           ; FGaugeState.Speed, полоса скорости, 5*speed+5
                        #00,                                                    ; FGauge.Previous, предыдущее значение индикатора
                        #41                                                     ; FGauge.Current, новое значение для сравнения и вывода
                    },
                    {                                                           ; FGaugeState.Energy1, нижний банк энергии
                        #FF,                                                    ; FGauge.Previous, предыдущее значение индикатора
                        #00                                                     ; FGauge.Current, новое значение для сравнения и вывода
                    },
                    {                                                           ; FGaugeState.Energy2, второй банк энергии
                        #00,                                                    ; FGauge.Previous, предыдущее значение индикатора
                        #00                                                     ; FGauge.Current, новое значение для сравнения и вывода
                    },
                    {                                                           ; FGaugeState.Energy3, третий банк энергии
                        #00,                                                    ; FGauge.Previous, предыдущее значение индикатора
                        #A0                                                     ; FGauge.Current, новое значение для сравнения и вывода
                    },
                    {                                                           ; FGaugeState.Energy4, верхний банк энергии
                        #00,                                                    ; FGauge.Previous, предыдущее значение индикатора
                        #A0                                                     ; FGauge.Current, новое значение для сравнения и вывода
                    },
                    {                                                           ; FGaugeState.Roll, позиция крена относительно центра 21
                        #00,                                                    ; FGauge.Previous, предыдущее значение индикатора
                        #15                                                     ; FGauge.Current, новое значение для сравнения и вывода
                    },
                    {                                                           ; FGaugeState.Pitch, позиция тангажа относительно центра 21
                        #00,                                                    ; FGauge.Previous, предыдущее значение индикатора
                        #15                                                     ; FGauge.Current, новое значение для сравнения и вывода
                    }
                }
                ; два сохранённых нулевых байта после тринадцати пар приборов
                DB #00, #00                                                     ; #7101..#7102
                ; особое пространство, ненулевое значение запрещает обычные светила и стыковку
SpaceMode       DB #00                                                          ; хранение FlightState.SpaceMode
                ; состояние полёта и цвет опасности,0 станция,4 норма,6 зона станции,2 опасность,63 мигание
FlightStatus    DB #00                                                          ; хранение FlightState.FlightStatus
                ; копия случайного параметра рынка State.MarketRandom для текущего выхода, Game.Trade.ResetCloakingAndSeedFlightRandom.Entry переносит её в FlightState.RandomByte
RandomByte      DB #37                                                          ; хранение FlightState.RandomByte
                ; сохранённый байт 4A перед координатами, Game.Travel.BuildPlanetCoordinateByte.Entry начинает запись только с FlightState.Sun + FCoordinate.SignHigh
                DB #4A                                                          ; #7106..#7106
                ; три знако-модульные трёхбайтовые координаты солнца, X/Y/Z
Sun             FSpacePosition {                                                ; явные исходные значения полей
                    {                                                           ; FSpacePosition.X
                        #27,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #08,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #01                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpacePosition.Y
                        #2A,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #4D,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #8F                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpacePosition.Z
                        #F2,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #88,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #05                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    }
                }
                ; три знако-модульные трёхбайтовые координаты планеты, X/Y/Z
Planet          FSpacePosition {                                                ; явные исходные значения полей
                    {                                                           ; FSpacePosition.X
                        #00,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #00,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #00                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpacePosition.Y
                        #00,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #00,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #00                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpacePosition.Z
                        #00,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #80,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #01                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    }
                }
                ASSERT $ == #7119
                endmodule
                endmodule
