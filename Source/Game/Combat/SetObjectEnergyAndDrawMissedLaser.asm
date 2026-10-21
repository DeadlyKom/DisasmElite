                module Combat
                module SetObjectEnergyAndDrawMissedLaser
; -----------------------------------------
; запись энергии объекта и отдельный рисунок свободного лазерного луча
; исходный диапазон #B743..#B798
; In:
;   AF, A содержит новую энергию для Game.Combat.SetObjectEnergyAndDrawMissedLaser.Entry
;   IX, объект
; Out:
;   FSpaceObject.Energy обновлён, установлен LASER_PASS_BIT в LaserThreshold
;   для входа Game.Combat.SetObjectEnergyAndDrawMissedLaser.MissedBeam выведены четыре линии лазера
; Corrupt:
;   HL, DE, BC, AF
; Note:
; Game.Combat.SetObjectEnergyAndDrawMissedLaser.Entry заканчивается переходом в Game.Flight.RaiseLaserThreshold.Entry. Game.Combat.SetObjectEnergyAndDrawMissedLaser.MissedBeam отдельный вход случайного рассеивания лазера.
; Малые случайные смещения D/E равны 0 либо 2, два знаковых бита сохраняются в LaserRaster.
; Четыре линии соединяют смещённую центральную точку с двумя парами внешних точек.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #B743
                ; обновление энергии и пометка изменения сцены
Entry:          LD (IX+FSpaceObject.Energy), A
                JP Game.Flight.RaiseLaserThreshold.Entry

                ; отдельный вход расчёта случайного смещения луча
MissedBeam:     CALL Game.Combat.NextRandomByte.Entry
                LD B, A
                AND #0C
                LD C, A
                LD (LaserRaster.Signs), A
                LD A, B
                AND #03
                OR #01
                SUB #01
                LD D, A
                RLC B
                RLC B
                LD A, B
                AND #03
                OR #01
                SUB #01
                LD E, A
                PUSH DE
                LD A, C
                OR #03
                LD C, A
                LD HL, #543F                                                    ; H=84 и L=63, координаты конца лазерного луча
                PUSH HL
                CALL Game.Wireframe.DrawClippedLine.Entry
                POP HL
                POP DE
                LD A, (LaserRaster.Signs)
                OR #01
                LD C, A
                PUSH DE
                CALL Game.Wireframe.DrawClippedLine.Entry
                POP DE
                LD HL, #403F                                                    ; H=64 и L=63, координаты второго конца лазерного луча
                LD A, (LaserRaster.Signs)
                OR #03
                LD C, A
                PUSH HL
                PUSH DE
                CALL Game.Wireframe.DrawClippedLine.Entry
                POP DE
                POP HL
                LD A, (LaserRaster.Signs)
                OR #01
                LD C, A
                JP Game.Wireframe.DrawClippedLine.Entry

                ; проверка исходного конца фрагмента
                ASSERT $ == #B799
                endmodule
                endmodule
