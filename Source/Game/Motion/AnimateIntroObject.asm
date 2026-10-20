                module Motion
                module AnimateIntroObject
; -----------------------------------------
; поворот и вывод демонстрационного корабля в последнем слоте
; исходный диапазон #A28D..#A2BF
; In:
;   память #6159, демонстрационный объект и указатель модели
; Out:
;   объект и графический буфер обновлены
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
; Постоянные углы #94/#8C передаются общему хвосту обновления объекта.
; После коррекции базиса хвостовой переход ведёт в проекцию #A6DF.
; #A2B8..#A2BF являются тремя словами вектора наведения и словом его длины.
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
SteeringData    EQU $                                                           ; начало сохранённых рабочих данных, исходное размещение
.X              DW #0000                                                        ; знаковая X-компонента вектора к цели
.Y              DW #0000                                                        ; знаковая Y-компонента вектора к цели
.Z              DW #0000                                                        ; знаковая Z-компонента вектора к цели
.Length         DW #0000                                                        ; длина вектора к цели перед нормированием
                ; проверка исходного конца фрагмента
                ASSERT $ == #A2C0
                endmodule
                endmodule
