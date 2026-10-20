                module Travel
                module BuildStationGeometry
; -----------------------------------------
; Размещение станции относительно новой планеты
; исходный диапазон #DD60..#DDEB
; In:
;   BC, C = биты выбора стороны, 7110..7118 = координаты планеты
; Out:
;   6048..6050 координаты станции, 6051..6062 её ориентация
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Копирует 9 байт координат, выбирает одну из осей по битам C, сдвигает модуль относительно
;   планеты, очищает 18 байт матрицы и ставит направляющие 7F/FF, часть маршрутов переходит в
;   DE22 для событий миссии
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #DD60
                ; размещение станции относительно планеты, её ось и знак задаются битами семени
Entry:          PUSH BC
                LD BC, #0009
                LD HL, FlightState.Planet
                LD DE, Memory.Station
                LDIR
                POP BC
                LD A, (FlightState.Planet + 2 * FCoordinate + FCoordinate.SignHigh)
                LD HL, Memory.Station + FSpaceObject.Z + FCoordinate.Low
                SRL C
                JR C, RotateAxis                                                ; переход, если младший бит C установлен, выбрать другую координатную ось станции

                LD A, (FlightState.Planet + FCoordinate.SignHigh)
                LD HL, Memory.Station + FSpaceObject.X + FCoordinate.Low
RotateAxis:     SET 7, (HL)
                LD B, A
                AND #7F
                SRL C
                JR C, PositiveBias                                              ; переход, если бит выбора стороны установлен, увеличить модуль координаты станции

                CP #01
                JR NZ, NegativeBias                                             ; переход, если старшая компонента не равна 1, уменьшить модуль без смены знака

                LD D, A
                LD A, B
                XOR #80
                LD B, A
                LD A, D
                JR LowerComponent

NegativeBias:   DEC A
LowerComponent: DEC A
                JR PackComponent

PositiveBias:   INC A
PackComponent:  SLA A
                SLA B
                RR A
                INC HL
                LD (HL), A
                XOR A
                LD HL, Memory.Station + FSpaceObject.AxisX
                LD B, #12
ClearAxes:      LD (HL), A
                INC HL
                DJNZ ClearAxes

                LD HL, FlightState.Planet + 2 * FCoordinate + FCoordinate.Low
                LD A, (Memory.Station + FSpaceObject.Z + FCoordinate.Low)
                CP (HL)
                LD A, #7F
                LD (Memory.Station + FSpaceObject.AxisY + FAxis.Y + FSignWord.SignHigh), A
                JR NZ, VerticalAxis                                             ; переход, если сравниваемые координатные байты различаются, выбрать альтернативное размещение

                LD BC, Memory.Station + FSpaceObject.AxisZ + FAxis.Z + FSignWord.SignHigh
                LD DE, Memory.Station + FSpaceObject.AxisX + FSignWord.SignHigh
                LD (BC), A
                LD (DE), A
                LD HL, FlightState.Planet + FCoordinate.SignHigh
                LD A, (Memory.Station + FSpaceObject.X + FCoordinate.SignHigh)
                CP (HL)
                LD A, #FF
                JR C, StoreSideAxis                                             ; переход, если старшая компонента X станции меньше компоненты планеты, инвертировать вторую ось

                LD (DE), A
                JR FinishGeometry

StoreSideAxis:  LD (BC), A
                JR FinishGeometry

VerticalAxis:   LD BC, Memory.Station + FSpaceObject.AxisZ + FSignWord.SignHigh
                LD DE, Memory.Station + FSpaceObject.AxisX + FAxis.Z + FSignWord.SignHigh
                LD HL, FlightState.Planet + 2 * FCoordinate + FCoordinate.SignHigh
                LD A, (Memory.Station + FSpaceObject.Z + FCoordinate.SignHigh)
                CP (HL)
                JR C, AxisPositive                                              ; переход, если старшая компонента Z станции меньше компоненты планеты, выбрать положительные оси

                LD A, #FF
                JR StoreAxes

MissionStage:   LD A, #05
                JR @Game.Travel.LaserTypeAndArrivalEvents.StoreMission

AxisPositive:   LD A, #7F
StoreAxes:      LD (BC), A
                LD (DE), A
FinishGeometry: RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #DDEC
                endmodule
                endmodule
