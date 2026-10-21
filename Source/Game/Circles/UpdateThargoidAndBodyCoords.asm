                module Circles
                module UpdateThargoidAndBodyCoords
; -----------------------------------------
; счётчик обработки удаляемого Thargoid и координаты двух далёких тел
; исходный диапазон #8AA3..#8ACC
; смысловое имя ProcessThargoidCounterAndBodyCoordinates
; In: IX — удаляемый объект, HL сохраняется при изменении State.AlienComputer
; Out: при младшем байте FSpaceObject.Blueprint, равном #25, State.AlienComputer увеличен на 2
; Corrupt: AF, при создании контейнера также HL, DE, BC, IY
; ReleaseMissileTargets.CheckTarget вызывает обработчик внутри обхода непустых слотов
; IX указывает на удаляемый объект, IY меняется при обходе связанных объектов
; Одному удалению может соответствовать несколько прибавлений, это не счётчик уничтоженных кораблей
; При обнулении State.AlienComputer слот IX заменяется специальным контейнером
; InitializeObject.Entry на этом пути меняет также HL, DE, BC и IY
; ReleaseMissileTargets не сохраняет регистры обхода вокруг вызова конструктора
; После конструктора FSpaceObject.Flags2 равен 0, DEC устанавливает все его биты
; DistantBodies.First и DistantBodies.Second содержат два вектора по 9 байтов, три знако-модульные координаты XYZ
; Game.Combat.UpdateClockAndRotateDistantBodies.RotateBodies вращает оба вектора через Game.Combat.ApplyPlayerMotion.Entry, временный RET по MotionRaster исключает сдвиг по скорости
; Game.Input.ToggleSecondaryCoordinateObject.Entry чередует эти два вектора в специальном режиме, Game.Extensions.OfferUpgradeAndCorrectPosition.CorrectCentre читает старшие Z по DistantBodies.First.Z + FCoordinate.SignHigh/DistantBodies.Second.Z + FCoordinate.SignHigh
; Game.Circles.UpdateThargoidAndBodyCoords.DistantData.Reserved — исходный резерв без установленного потребителя, сохраняется
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #8AA3
                ; миссия 5 ALIEN COMPUTER, проверка счётчика обработок удаляемой модели перед созданием контейнера
                ; описание в Docs/Manual.md, раздел mission-5
                ; проверка модели Thargoid по младшему байту указателя
Entry:          LD A, (IX + FSpaceObject.Blueprint)
                CP #25
                RET NZ                                                          ; выход, если младший байт FSpaceObject.Blueprint отличается от #25

                ; увеличение State.AlienComputer на 2 для текущего вызова с сохранением ALIEN_OWN_BIT
                PUSH HL
                LD HL, State.AlienComputer
                INC (HL)
                INC (HL)
                POP HL
                RET NZ                                                          ; выход, если после прибавления 2 State.AlienComputer не равен нулю

                ; создание особого контейнера после обнуления счётчика
                LD A, #04
                CALL Game.Objects.InitializeObject.Entry
                DEC (IX + FSpaceObject.Flags2)
                RET

                ; первый вектор далёкого тела, три знако-модульные координаты по 3 байта
DistantData     EQU $                                                           ; исходная база двух координат FSpacePosition
.FirstX         EQU FirstPosition.X                                             ; адрес координаты First.X в FSpacePosition
.FirstY         EQU FirstPosition.Y                                             ; адрес координаты First.Y в FSpacePosition
.FirstZ         EQU FirstPosition.Z                                             ; адрес координаты First.Z в FSpacePosition
.SecondX        EQU SecondPosition.X                                            ; адрес координаты Second.X в FSpacePosition
.SecondY        EQU SecondPosition.Y                                            ; адрес координаты Second.Y в FSpacePosition
.SecondZ        EQU SecondPosition.Z                                            ; адрес координаты Second.Z в FSpacePosition
.Reserved       EQU SecondPosition + FSpacePosition                             ; исходный байт после двух координатных структур

FirstPosition   FSpacePosition {
                    {                                                           ; FSpacePosition.X
                        #00,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #00,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #03                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpacePosition.Y
                        #00,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #00,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #00                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpacePosition.Z
                        #00,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #00,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #03                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    }
                }

SecondPosition  FSpacePosition {
                    {                                                           ; FSpacePosition.X
                        #00,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #00,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #83                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpacePosition.Y
                        #00,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #00,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #00                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    },
                    {                                                           ; FSpacePosition.Z
                        #00,                                                    ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                        #00,                                                    ; FCoordinate.Low, средние восемь разрядов координаты
                        #03                                                     ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                    }
                }
                DB #03                                                          ; DistantData.Reserved, исходный резерв без установленного потребителя
                ; проверка исходного конца фрагмента
                ASSERT $ == #8ACD
                endmodule
                endmodule
