                module Motion
                module CheckObjectBoxAndChooseCourse
; -----------------------------------------
; проверка близости объекта и выбор курса приближения либо удаления
; исходный диапазон #A40F..#A4B4
; In:
;   DE, порог для X/Y при входе A40F
;   IX, объект
;   IY, модель при входе в общий хвост A42F
; Out:
;   AF, при входе A40F перенос означает попадание в область по всем трём координатам
;   при входе A42F обновлены вектор наведения, команды вращения и ускорение
; Corrupt:
;   HL, DE, BC, AF
; Note:
; A40F проверяет прямоугольную область, не сферическое расстояние. Для Z предел увеличен на #0200.
; A42F является отдельным продолжением тактики из A2C0 и не вызывается самой проверкой близости.
; Внутренний радиус #0200 и больший порог для IX+26.5 создают гистерезис сближения/удаления.
; A47C записывает прямой вектор от игрока к объекту и ставит IX+26.5.
; A498 записывает обратный вектор к игроку и сбрасывает IX+26.5, это также вход наведения ракеты на игрока.
; Оба пути переходят в общий автопилот A587.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #A40F
                ; проверка двух боковых координат относительно прямоугольного порога
Entry:          LD H, (IX + FSpaceObject.X.Low)
                LD L, (IX + FSpaceObject.X.Fraction)
                AND A
                SBC HL, DE
                RET NC                                                          ; выход, если модуль X не меньше заданного порога

                LD H, (IX + FSpaceObject.Y.Low)
                LD L, (IX + FSpaceObject.Y.Fraction)
                AND A
                SBC HL, DE
                RET NC                                                          ; выход, если модуль Y не меньше заданного порога

                ; проверка глубины с дополнительным допуском #0200
                LD H, (IX + FSpaceObject.Z.Low)
                LD L, (IX + FSpaceObject.Z.Fraction)
                INC D
                INC D
                AND A
                SBC HL, DE
                RET

                ; отдельный вход выбора курса после энергетической реакции
ChooseCourse:   CALL Game.Wireframe.ReadObjectTacticsGates.Entry
                RET NC                                                          ; выход, если проверка состояния B4C4 не разрешает обновление курса

                JR Z, CheckInnerBox                                             ; переход, если проверка B4C4 не требует изменения враждебности

                LD A, (State.Rating)
                CP #28
                JR C, CheckInnerBox                                             ; переход, если показатель D060 меньше #28 и враждебность не устанавливается

                SET OBJ_HOSTILE_BIT, (IX + FSpaceObject.Hostility)
                ; проверка внутренней области и гистерезиса удаления
CheckInnerBox:  LD DE, #0200
                CALL Game.Motion.CheckObjectBoxAndChooseCourse.Entry
                JR C, FlyAway                                                   ; переход, если объект находится внутри внутренней области и должен удаляться

                BIT OBJ_RETREAT_BIT, (IX + FSpaceObject.Flags2)
                JR Z, CheckHostility                                            ; переход, если режим удаления ещё не включён и внешний порог не нужен

                LD D, #0A
                CALL Game.Motion.CheckObjectBoxAndChooseCourse.Entry
                JR C, FlyAway                                                   ; переход, если объект остаётся внутри внешней области гистерезиса

                ; проверка враждебности и станционного контекста
CheckHostility: BIT OBJ_HOSTILE_BIT, (IX + FSpaceObject.Hostility)
                RET Z                                                           ; выход, если объект мирный и отдельное преследование не требуется

                LD A, (State.Mission3)
                CP #04
                JR Z, CheckBehavior                                             ; переход, если режим D0AF равен 4 и используется непосредственная проверка поведения

                LD A, (Memory.Station + FSpaceObject.Energy)
                AND A
                JR Z, CheckBehavior                                             ; переход, если станционный слот пуст и используется непосредственная проверка поведения

                BIT OBJ_FLEE_BIT, (IX + FSpaceObject.Hostility)
                JR Z, FlyToward                                                 ; переход, если у объекта сброшен IX+21.3 и выбирается курс к игроку

                JR FlyAway

                ; проверка режима поведения и принудительного ускорения
CheckBehavior:  LD A, (IX + FSpaceObject.Target)
                AND TARGET_AI_MASK
                CP #08
                JR NC, FlyToward                                                ; переход, если параметр поведения IX+25 не меньше 8 и выбирается курс к игроку

                SET TARGET_ACCL_BIT, (IX + FSpaceObject.Target)
                ; создание вектора удаления от игрока
FlyAway:        PUSH IX
                CALL Game.Motion.QuarterCoordinate.Entry
                LD (SteeringVector.X), HL
                CALL Game.Motion.QuarterCoordinate.Entry
                LD (SteeringVector.Y), HL
                CALL Game.Motion.QuarterCoordinate.Entry
                LD (SteeringVector.Z), HL
                POP IX
                SET OBJ_RETREAT_BIT, (IX + FSpaceObject.Flags2)
                JR SteerCourse

                ; создание вектора сближения с игроком
FlyToward:      PUSH IX
                CALL Game.Motion.NegatedQuarterCoordinate.Entry
                LD (SteeringVector.X), HL
                CALL Game.Motion.NegatedQuarterCoordinate.Entry
                LD (SteeringVector.Y), HL
                CALL Game.Motion.NegatedQuarterCoordinate.Entry
                LD (SteeringVector.Z), HL
                POP IX
                RES OBJ_RETREAT_BIT, (IX + FSpaceObject.Flags2)
SteerCourse:    JP Game.Motion.SteerObjectAndTryLaser.Entry
                ; проверка исходного конца фрагмента
                ASSERT $ == #A4B5
                endmodule
                endmodule
