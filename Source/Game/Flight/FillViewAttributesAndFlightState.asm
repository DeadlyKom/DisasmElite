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
;   При D081!=0 используется L&3A, затем HALT синхронизирует запись
;   Каждая строка получает одну запись и LDDR29 байтов, итого 450 ячеек от 5821 до 59FE
;   70DC..7118 содержат поля полёта и двух светил,70E0 отдельный JP7366
; -----------------------------------------
                ASSERT $ == #70BA
                ; проверка специального цвета первой миссии
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
                ; 16-битный накопитель времени вторжения, обновляется 9B41 добавкой NOT D08F
InvasionClock   DW #0000                                                        ; хранение FlightState.InvasionClock
                ; сохранённое слово FFFC, прямых чтений и записей в разобранном коде не найдено
                DB #FC, #FF                                                     ; #70DE..#70DF
                ; отдельный стартовый вектор сохраняет стек и настраивает кабину
StartGame:      JP Game.Flight.PlaySweepingBeeperAndBootstrap.Bootstrap
                ; номер текущего вида,0..3 кабина,7/8 карты
View            DB #0B                                                          ; хранение FlightState.View
                ; знако-модульный крен из FF09
Roll            DB #00                                                          ; хранение FlightState.Roll
                ; знако-модульный тангаж из FF0B
Pitch           DB #00                                                          ; хранение FlightState.Pitch
                ; текущая скорость из FF0D
Speed           DB #0C                                                          ; хранение FlightState.Speed
                ; передний щит, сначала прежнее значение прибора, затем текущее
FrontShieldPrev DB #00                                                          ; хранение GaugeState + FGaugeState.FrontShield.Previous
FrontShieldNow  DB #00                                                          ; хранение GaugeState + FGaugeState.FrontShield.Current
                ; задний щит, прежнее и текущее значения
RearShieldPrev  DB #00                                                          ; хранение GaugeState + FGaugeState.RearShield.Previous
RearShieldNow   DB #00                                                          ; хранение GaugeState + FGaugeState.RearShield.Current
                ; полоса топлива, прежняя и текущая, DEA2 вычисляет 2*fuel+floor(fuel/4)
FuelPrev        DB #00                                                          ; хранение GaugeState + FGaugeState.Fuel.Previous
FuelNow         DB #A0                                                          ; хранение GaugeState + FGaugeState.Fuel.Current
                ; нагрев кабины, прежнее и текущее значения, обновляется 8B3F
CabinHeatPrev   DB #00                                                          ; хранение GaugeState + FGaugeState.CabinHeat.Previous
CabinHeatNow    DB #00                                                          ; хранение GaugeState + FGaugeState.CabinHeat.Current
                ; нагрев лазера, прежнее и текущее значения, изменяется при выстреле
LaserHeatPrev   DB #00                                                          ; хранение GaugeState + FGaugeState.LaserHeat.Previous
LaserHeatNow    DB #00                                                          ; хранение GaugeState + FGaugeState.LaserHeat.Current
                ; высота над планетой, прежнее и текущее значения
AltitudePrev    DB #00                                                          ; хранение GaugeState + FGaugeState.Altitude.Previous
AltitudeNow     DB #A0                                                          ; хранение GaugeState + FGaugeState.Altitude.Current
                ; полоса скорости, прежнее и текущее значения 5*скорость+5
SpeedPrev       DB #00                                                          ; хранение GaugeState + FGaugeState.Speed.Previous
SpeedNow        DB #41                                                          ; хранение GaugeState + FGaugeState.Speed.Current
                ; первый банк энергии, прежнее и текущее значения
Energy1Prev     DB #FF                                                          ; хранение GaugeState + FGaugeState.Energy1.Previous
Energy1Now      DB #00                                                          ; хранение GaugeState + FGaugeState.Energy1.Current
                ; второй банк энергии, прежнее и текущее значения
Energy2Prev     DB #00                                                          ; хранение GaugeState + FGaugeState.Energy2.Previous
Energy2Now      DB #00                                                          ; хранение GaugeState + FGaugeState.Energy2.Current
                ; третий банк энергии, прежнее и текущее значения
Energy3Prev     DB #00                                                          ; хранение GaugeState + FGaugeState.Energy3.Previous
Energy3Now      DB #A0                                                          ; хранение GaugeState + FGaugeState.Energy3.Current
                ; четвёртый банк энергии, прежнее и текущее значения
Energy4Prev     DB #00                                                          ; хранение GaugeState + FGaugeState.Energy4.Previous
Energy4Now      DB #A0                                                          ; хранение GaugeState + FGaugeState.Energy4.Current
                ; индикатор крена, прежняя и текущая позиция относительно 21
RollPrev        DB #00                                                          ; хранение GaugeState + FGaugeState.Roll.Previous
RollNow         DB #15                                                          ; хранение GaugeState + FGaugeState.Roll.Current
                ; индикатор тангажа, прежняя и текущая позиция относительно 21
PitchPrev       DB #00                                                          ; хранение GaugeState + FGaugeState.Pitch.Previous
PitchNow        DB #15                                                          ; хранение GaugeState + FGaugeState.Pitch.Current
                ; два сохранённых нулевых байта после тринадцати пар приборов
                DB #00, #00                                                     ; #7101..#7102
                ; особое пространство, ненулевое значение запрещает обычные светила и стыковку
SpaceMode       DB #00                                                          ; хранение FlightState.SpaceMode
                ; состояние полёта и цвет опасности,0 станция,4 норма,6 зона станции,2 опасность,63 мигание
FlightStatus    DB #00                                                          ; хранение FlightState.FlightStatus
                ; копия случайного параметра рынка D06A для текущего выхода, E6EE переносит её в 7105
RandomByte      DB #37                                                          ; хранение FlightState.RandomByte
                ; сохранённый байт 4A перед координатами, DD48 начинает запись только с 7109
                DB #4A                                                          ; #7106..#7106
                ; три знако-модульные трёхбайтовые координаты солнца, X/Y/Z
Sun             DB #27, #08, #01, #2A, #4D, #8F, #F2, #88                       ; хранение FlightState.Sun
                DB #05                                                          ; #710F..#710F
                ; три знако-модульные трёхбайтовые координаты планеты, X/Y/Z
Planet          DB #00, #00, #00, #00, #00, #00, #00, #80                       ; хранение FlightState.Planet
                DB #01                                                          ; #7118..#7118
                ASSERT $ == #7119
                endmodule
                endmodule
