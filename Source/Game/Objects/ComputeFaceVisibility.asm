                module Objects
                module ComputeFaceVisibility
; -----------------------------------------
; расчёт признаков видимости нормалей модели
; исходный диапазон #BCD4..#BD5E
; In:
;   IX - слот объекта
;   IY - заголовок модели
;   #A994 матрица поворота
; Out:
;   байты #A984 и далее содержат признаки видимости граней, IX/IY восстановлены
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   адрес нормалей получается из полей 16/17 заголовка, число нормалей из+05, масштаб из+13
;   порог видимости каждой нормали сравнивается с #A9B8, значение 31 считается безусловным
;   три компоненты нормали преобразуются #BDB4, затем скалярное произведение #BD5F определяет знак
;   видимость записывается как 0/1, при нулевом количестве нормалей создаётся один видимый элемент
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #BCD4
                ; сохранение указателей и поиск массива нормалей модели
Entry:          PUSH IX
                PUSH IY
                PUSH IY
                EX (SP), IX
                POP HL
                LD (FaceState.Object), HL
                LD D, (IX+FModel.Normals+FSignWord.SignHigh)
                CALL Game.Wireframe.LocateFaceNormalData.Entry
                ADD IX, DE
                LD DE, FaceVisibility
                ; сохранение масштаба и количества нормалей
                LD A, (IY+FModel.NormalScale)
                LD (FaceState.Scale), A
                LD A, (IY+FModel.NormalCount)
                AND A
                LD IY, ObjectMatrix
                JR NZ, NextFace                                                 ; переход, если в модели имеется хотя бы одна нормаль

                INC A
                LD (DE), A
                JR RestoreObject

NextFace:       PUSH AF
                PUSH DE
                ; проверка порога расстояния для текущей нормали
                CALL Game.Wireframe.ReadVertexFlags.Entry
                AND #1F
                CP #1F
                JR Z, DotNormal                                                 ; переход, если порог текущей нормали равен 31

                LD B, A
                LD A, (ProjectionState.Depth)
                CP B
                JR C, DotNormal                                                 ; переход, если расстояние до объекта меньше порога нормали

                POP DE
                XOR A
                JR StoreFace

                ; преобразование трёх компонент нормали и расчёт их скалярного произведения
DotNormal:      PUSH IY
                LD HL, (FaceState.Object)
                PUSH HL
                CALL Game.Motion.TransformNormalWithObjectCoordinate.Entry
                LD (FaceState.NormalX), A
                LD (FaceState.PositionX), HL
                CALL Game.Motion.TransformNormalWithObjectCoordinate.Entry
                LD (FaceState.NormalY), A
                LD (FaceState.PositionY), HL
                CALL Game.Motion.TransformNormalWithObjectCoordinate.Entry
                LD (FaceState.NormalZ), A
                LD (FaceState.PositionZ), HL
                POP HL
                PUSH IX
                LD IY, FaceState.PositionX
                LD IX, FaceState.NormalX
                CALL Game.Objects.DotProduct16By8.Entry
                POP IX
                POP IY
                POP DE
                ; преобразование знака скалярного произведения в байт видимости
                XOR A
                SLA H
                JR NC, StoreFace                                                ; переход, если знак скалярного произведения не установлен

                INC A
StoreFace:      LD (DE), A
                INC DE
                ; расчёт адреса следующей записи нормали
                CALL Game.Wireframe.AdvanceNormalFlags.Entry
                ADD IX, BC
                POP AF
                DEC A
                JR NZ, NextFace                                                 ; переход, если остались необработанные нормали

RestoreObject:  POP IY
                POP IX
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #BD5F
                endmodule
                endmodule
