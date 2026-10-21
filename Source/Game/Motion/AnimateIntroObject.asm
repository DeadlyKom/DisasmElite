                module Motion
                module AnimateIntroObject
; -----------------------------------------
; поворот и вывод демонстрационного корабля в последнем слоте
; исходный диапазон #A28D..#A2BF
; In:
;   память Memory.Missile, демонстрационный объект и указатель модели
; Out:
;   объект и графический буфер обновлены
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
; Постоянные углы #94/#8C передаются общему хвосту обновления объекта.
; После коррекции базиса хвостовой переход ведёт в проекцию Game.Motion.ProjectObjectAndSelectDetail.Entry.
; SteeringVector.X, Y и Z содержат три слова вектора наведения, SteeringVector.Length хранит его длину
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #A28D
                ; поиск модели и установка демонстрационного вращения
Entry:          LD IX, Memory.Missile
                LD H, (IX + FSpaceObject.Blueprint + FSignWord.SignHigh)
                LD L, (IX + FSpaceObject.Blueprint)
                PUSH HL
                POP IY
                LD A, #94
                LD (RotationState.Roll), A
                LD A, #8C
                CALL Game.Motion.AdvanceObjectAlongLocalAxis.Entry
                CALL Game.Wireframe.OrthogonalizeObjectYAxis.Entry
                LD IX, Memory.Missile + FSpaceObject.AxisX
                CALL Game.Motion.RenormalizeAxisHighBytes.Entry
                CALL Game.Motion.RenormalizeAxisHighBytes.Entry
                LD IX, Memory.Missile
                JP Game.Motion.ProjectObjectAndSelectDetail.Entry

                ; данные вектора наведения и его длины
SteeringData    FSteeringVector {
                    #0000,                                                      ; FSteeringVector.X, знаковая X-компонента
                    #0000,                                                      ; FSteeringVector.Y, знаковая Y-компонента
                    #0000,                                                      ; FSteeringVector.Z, знаковая Z-компонента
                    #0000                                                       ; FSteeringVector.Length, длина вектора
                }
                ; проверка исходного конца фрагмента
                ASSERT $ == #A2C0
                endmodule
                endmodule
