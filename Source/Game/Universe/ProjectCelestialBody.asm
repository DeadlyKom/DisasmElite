                module Universe
                module ProjectCelestialBody
; -----------------------------------------
; перспективная проекция светила для четырёх направлений обзора
; исходный диапазон #75E1..#7798
; In:
;   память 757A..7582, трёхбайтовые X/Y/Z со знаком
;   память 70E3, направление вида
; Out:
;   AF, A=1 при допустимой проекции, A=0 при отказе
;   861A/861B, модули экранных координат
;   861C, знаки и признаки положения
;   861D, экранный радиус
; Corrupt:
;   HL, DE, BC, HL', DE', BC'
; Note:
; Виды 0/1 используют положительную/отрицательную Z, виды 2/3 отрицательную/положительную X.
; Горизонтальная ось выбирается X либо Z, вертикальная всегда Y. Закамерное светило отвергается.
; 77A0 нормализует и делит каждую боковую координату на глубину, дополнительные признаки копятся в B'.
; Радиус вычисляется из масштаба A000 и глубины, очень близкое светило получает FF.
; Глубина выше предельного A000 отвергается. Младший и старший диапазоны используют разные подготовительные сдвиги.
; Знаковые биты рабочей глубины очищаются на месте, исходная тройка вызывающего кода уже скопирована.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #75E1
                ; подготовка дополнительных признаков и выбор направления камеры
Entry:          EXX
                LD BC, #0003
                EXX
                LD A, (FlightState.View)
                AND A
                JP NZ, RearView                                                 ; переход, если выбран не передний вид

                ; проверка полупространства переднего вида
                LD A, (Game.Flight.MainGameLoop.BodyZ+FCoordinate.SignHigh)
                BIT 7, A
                JP NZ, @Game.Universe.DivideCelestialAxis.RejectBody            ; переход, если при переднем виде светило находится сзади

                AND #7F
                LD (Game.Flight.MainGameLoop.BodyZ+FCoordinate.SignHigh), A
                ; расчёт горизонтальной проекции по X/Z
                LD HL, (Game.Flight.MainGameLoop.BodyZ+FCoordinate.Low)
                EX DE, HL
                LD HL, (Game.Flight.MainGameLoop.BodyX+FCoordinate.Low)
                LD A, (Game.Flight.MainGameLoop.BodyZ)
                LD B, A
                LD A, (Game.Flight.MainGameLoop.BodyX)
                LD C, A
                LD A, H
                BIT 7, A
                JR NZ, DivideFrontX                                             ; переход, если горизонтальная координата отрицательна и положительный знак не ставится

                EXX
                SET CIRC_RIGHT_BIT, B
                EXX
DivideFrontX:   AND #7F
                LD H, A
                CALL Game.Universe.DivideCelestialAxis.Entry
                LD A, D
                LD (CircleState.OffsetX), A
                ; расчёт вертикальной проекции по Y/Z
                LD HL, (Game.Flight.MainGameLoop.BodyZ+FCoordinate.Low)
                EX DE, HL
                LD HL, (Game.Flight.MainGameLoop.BodyY+FCoordinate.Low)
                LD A, (Game.Flight.MainGameLoop.BodyZ)
                LD B, A
                LD A, (Game.Flight.MainGameLoop.BodyY)
                LD C, A
                LD A, H
                BIT 7, A
                JR NZ, DivideFrontY                                             ; переход, если вертикальная координата отрицательна и положительный знак не ставится

                EXX
                SET CIRC_UP_BIT, B
                EXX
DivideFrontY:   AND #7F
                LD H, A
                CALL Game.Universe.DivideCelestialAxis.Entry
                LD A, D
                LD (CircleState.OffsetY), A
                ; сохранение признаков и расчёт радиуса по глубине
                EXX
                LD A, B
                EXX
                LD (CircleState.Flags), A
                LD A, (Game.Flight.MainGameLoop.BodyZ+FCoordinate.SignHigh)
                AND A
                JR NZ, RadiusFromZ                                              ; переход, если старший байт глубины ненулевой и нужен общий расчёт радиуса

                LD HL, #A000                                                    ; числовой масштаб радиуса при делении на координату, не указатель
                LD DE, (Game.Flight.MainGameLoop.BodyZ)
                SBC HL, DE
                JR C, RadiusFromZ                                               ; переход, если ближняя глубина превышает порог насыщения радиуса

                LD A, #FF
                JR CommitFront

                ; проверка предельной глубины и нормализация делителя радиуса
RadiusFromZ:    LD HL, #A000                                                    ; числовой масштаб радиуса при делении на координату, не указатель
                LD DE, (Game.Flight.MainGameLoop.BodyZ+FCoordinate.Low)
                AND A
                SBC HL, DE
                JP C, @Game.Universe.DivideCelestialAxis.RejectBody             ; переход, если светило дальше предельной глубины A000

                LD A, (Game.Flight.MainGameLoop.BodyZ+FCoordinate.SignHigh)
                AND A
                JR Z, ByteZRadius                                               ; переход, если старший байт глубины нулевой и достаточно короткого деления

                LD B, A
                LD A, (Game.Flight.MainGameLoop.BodyZ+FCoordinate.Low)
                LD C, A
                XOR A
                LD E, #A0
NormalizeZ:     SLA C
                RL B
                JR C, DivideZRadius                                             ; переход, если нормализация глубины дошла до старшего разряда

                SLA E
                RLA
                JR NormalizeZ

DivideZRadius:  SCF
                RR B
                CALL Game.Universe.DivideBodyProjectionFraction.Entry
                LD A, D
                JR CommitFront

                ; короткое деление радиуса при нулевом старшем байте глубины
ByteZRadius:    LD A, (Game.Flight.MainGameLoop.BodyZ+FCoordinate.Low)
                LD B, A
                LD A, #A0
                CALL Game.Universe.DivideBodyRadiusByte.Entry
                LD A, D
CommitFront:    JP StoreRadius

                ; отдельная ветвь заднего вида
RearView:       DEC A
                JR NZ, SideView                                                 ; переход, если выбран не задний вид

                LD A, (Game.Flight.MainGameLoop.BodyZ+FCoordinate.SignHigh)
                BIT 7, A
                JP Z, @Game.Universe.DivideCelestialAxis.RejectBody             ; переход, если при заднем виде светило находится впереди

                AND #7F
                LD (Game.Flight.MainGameLoop.BodyZ+FCoordinate.SignHigh), A
                LD HL, (Game.Flight.MainGameLoop.BodyZ+FCoordinate.Low)
                EX DE, HL
                LD HL, (Game.Flight.MainGameLoop.BodyX+FCoordinate.Low)
                LD A, (Game.Flight.MainGameLoop.BodyZ)
                LD B, A
                LD A, (Game.Flight.MainGameLoop.BodyX)
                LD C, A
                LD A, H
                BIT 7, A
                JR Z, ReuseFrontX                                               ; переход, если горизонтальная координата неотрицательна и дополнительный знак не ставится

                AND #7F
                LD H, A
                EXX
                SET CIRC_RIGHT_BIT, B
                EXX
ReuseFrontX:    JP DivideFrontX

                ; отдельная ветвь первого бокового вида
SideView:       DEC A
                JP NZ, OtherSide                                                ; переход, если выбран второй боковой вид

                LD A, (Game.Flight.MainGameLoop.BodyX+FCoordinate.SignHigh)
                BIT 7, A
                JP Z, @Game.Universe.DivideCelestialAxis.RejectBody             ; переход, если для первого бокового вида знак X не соответствует направлению камеры

                AND #7F
                LD (Game.Flight.MainGameLoop.BodyX+FCoordinate.SignHigh), A
                ; расчёт горизонтальной проекции по Z/X
                LD HL, (Game.Flight.MainGameLoop.BodyX+FCoordinate.Low)
                EX DE, HL
                LD HL, (Game.Flight.MainGameLoop.BodyZ+FCoordinate.Low)
                LD A, (Game.Flight.MainGameLoop.BodyX)
                LD B, A
                LD A, (Game.Flight.MainGameLoop.BodyZ)
                LD C, A
                LD A, H
                BIT 7, A
                JR NZ, DivideSideX                                              ; переход, если горизонтальная координата отрицательна

                EXX
                SET CIRC_RIGHT_BIT, B
                EXX
DivideSideX:    AND #7F
                LD H, A
                CALL Game.Universe.DivideCelestialAxis.Entry
                LD A, D
                LD (CircleState.OffsetX), A
                ; расчёт вертикальной проекции по Y/X
                LD HL, (Game.Flight.MainGameLoop.BodyX+FCoordinate.Low)
                EX DE, HL
                LD HL, (Game.Flight.MainGameLoop.BodyY+FCoordinate.Low)
                LD A, (Game.Flight.MainGameLoop.BodyX)
                LD B, A
                LD A, (Game.Flight.MainGameLoop.BodyY)
                LD C, A
                LD A, H
                BIT 7, A
                JR NZ, DivideSideY                                              ; переход, если вертикальная координата отрицательна

                EXX
                SET CIRC_UP_BIT, B
                EXX
DivideSideY:    AND #7F
                LD H, A
                CALL Game.Universe.DivideCelestialAxis.Entry
                LD A, D
                LD (CircleState.OffsetY), A
                ; расчёт радиуса по боковой глубине
                EXX
                LD A, B
                EXX
                LD (CircleState.Flags), A
                LD A, (Game.Flight.MainGameLoop.BodyX+FCoordinate.SignHigh)
                AND A
                JR NZ, RadiusFromX                                              ; переход, если старший байт боковой глубины ненулевой

                LD HL, #A000                                                    ; числовой масштаб радиуса при делении на координату, не указатель
                LD DE, (Game.Flight.MainGameLoop.BodyX)
                SBC HL, DE
                JR C, RadiusFromX                                               ; переход, если ближняя боковая глубина выше порога насыщения

                LD A, #FF
                JR CommitSide

RadiusFromX:    LD HL, #A000                                                    ; числовой масштаб радиуса при делении на координату, не указатель
                LD DE, (Game.Flight.MainGameLoop.BodyX+FCoordinate.Low)
                AND A
                SBC HL, DE
                JP C, @Game.Universe.DivideCelestialAxis.RejectBody             ; переход, если боковая глубина превышает предельное A000

                LD A, (Game.Flight.MainGameLoop.BodyX+FCoordinate.SignHigh)
                AND A
                JR Z, ByteXRadius                                               ; переход, если старший байт боковой глубины нулевой

                LD B, A
                LD A, (Game.Flight.MainGameLoop.BodyX+FCoordinate.Low)
                LD C, A
                XOR A
                LD E, #A0
NormalizeX:     SLA C
                RL B
                JR C, DivideXRadius                                             ; переход, если нормализация боковой глубины дошла до старшего разряда

                SLA E
                RLA
                JP NormalizeX

DivideXRadius:  SCF
                RR B
                CALL Game.Universe.DivideBodyProjectionFraction.Entry
                LD A, D
                JR CommitSide

ByteXRadius:    LD A, (Game.Flight.MainGameLoop.BodyX+FCoordinate.Low)
                LD B, A
                LD A, #A0
                CALL Game.Universe.DivideBodyRadiusByte.Entry
                LD A, D
CommitSide:     JP StoreRadius

                ; отдельная ветвь второго бокового вида
OtherSide:      LD A, (Game.Flight.MainGameLoop.BodyX+FCoordinate.SignHigh)
                BIT 7, A
                JP NZ, @Game.Universe.DivideCelestialAxis.RejectBody            ; переход, если для второго бокового вида знак X не соответствует камере

                LD HL, (Game.Flight.MainGameLoop.BodyX+FCoordinate.Low)
                EX DE, HL
                LD HL, (Game.Flight.MainGameLoop.BodyZ+FCoordinate.Low)
                LD A, (Game.Flight.MainGameLoop.BodyX)
                LD B, A
                LD A, (Game.Flight.MainGameLoop.BodyZ)
                LD C, A
                LD A, H
                BIT 7, A
                JR Z, ReuseSideX                                                ; переход, если горизонтальная координата неотрицательна

                EXX
                SET CIRC_RIGHT_BIT, B
                EXX
ReuseSideX:     JP DivideSideX

                ; сохранение радиуса и подтверждение допустимой проекции
StoreRadius:    LD (CircleState.Radius), A
                LD A, #01
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #7799
                endmodule
                endmodule
