                module Objects
                module InitializeIntroModel
; -----------------------------------------
; инициализация демонстрационной модели в выделенном ракетном слоте
; исходный диапазон #BB75..#BBB9
; In:
;   BC - C индекс модели заставки
; Out:
;   IX=#6159, модель и матрица ориентации установлены
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
;   фактический индекс модели C+2 передаётся #AE35
;   углы LR/DU=#C0, скорость 0, координаты X=Y=0 и Z=512 в принятом формате
;   девять байт #B85D записываются через один в старшие байты девяти компонент осей
;   LDI уменьшает BC с 9 до 0, JP PE проверяет продолжение именно по BC
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #BB75
Entry:          LD IX, Memory.Missile
                LD A, C
                ADD A, #02
                CALL Game.Wireframe.InitializeObjectFromModelNumber.Entry
                LD A, #C0
                LD (IX+FSpaceObject.Roll), A
                LD (IX+FSpaceObject.Pitch), A
                XOR A
                LD (IX+FSpaceObject.Z.Fraction), A
                LD (IX+FSpaceObject.X.Fraction), A
                LD (IX+FSpaceObject.X.Low), A
                LD (IX+FSpaceObject.Y.Fraction), A
                LD (IX+FSpaceObject.Y.Low), A
                LD (IX+FSpaceObject.Z.SignHigh), A
                LD (IX+FSpaceObject.Speed), A
                RES OBJ_ACTIVE_BIT, (IX+FSpaceObject.Flags)
                INC A
                INC A
                LD (IX+FSpaceObject.Z.Low), A
                ; расчёт адресов девяти старших байтов матрицы ориентации заставки
                PUSH IX
                POP HL
                LD DE, #0009
                LD B, D
                LD C, E
                ADD HL, DE
                EX DE, HL
                LD HL, IntroMatrix
CopyComponent:  INC DE
                LDI
                JP PE, CopyComponent                                            ; переход, если BC после LDI ещё не равен нулю

                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #BBBA
                endmodule
                endmodule
