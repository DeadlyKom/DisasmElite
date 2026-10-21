                module Extensions
                module CompareObjectCoordinateDepth
; -----------------------------------------
; сравнение модулей двух координат
; исходный диапазон #FBE0..#FC0F
; смысловое имя CompareObjectCoordinateDepth
; In: IX — сравниваемая FCoordinate, IY — координата перед следующей сравниваемой FCoordinate
; Out: IY увеличен на 3, A=0 при отбраковке, A!=0 при принятии
; Corrupt: DE, AF, IY
; После перехода IY к следующей FCoordinate сравниваются FCoordinate.SignHigh координат IX и IY без знакового бита
; Модуль первого старшего байта <5 принимается без дальнейшего сравнения
; При равных старших модулях сравниваются FCoordinate.Low координат IX и сдвинутого IY
; KeyEvents содержит дополнительные байты и состояние клавиатуры InputState, исполнение после RET не продолжается
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #FBE0
                ; расчёт указателя второго координатного вектора и сравнение модулей
Entry:          LD DE, #0003
                ADD IY, DE
                LD A, (IY+FCoordinate.SignHigh)
                AND #7F
                LD D, A
                LD A, (IX+FCoordinate.SignHigh)
                AND #7F
                CP #05
                JR C, AcceptDepth                                               ; переход, если старший модуль первой координаты меньше 5, принять объект

                CP D
                JR C, RejectDepth                                               ; переход, если старший модуль первой координаты меньше второго, отклонить объект

                RET NZ                                                          ; выход, если старший модуль первой координаты больше второго

                ; сравнение средних байтов при одинаковой старшей части
                LD A, (IX+FCoordinate.Low)
                CP (IY+FCoordinate.Low)
                JR C, RejectDepth                                               ; переход, если при равных старших байтах средний байт первой координаты меньше

                ; принятие объекта с ненулевым результатом
AcceptDepth:    OR #01
                RET

                ; отклонение объекта с A=0 и Z=1
RejectDepth:    XOR A
                RET

                DB #AF, #C9, #F8                                                ; данные #FC05..#FC07
                ; состояние опроса клавиатуры, структура FInputState
KeyEvents       FInputState {
                    #00,                                                        ; FInputState.SystemKeys, маска клавиш Y, 0, I, O, P, K, L, ENTER
                    #00,                                                        ; FInputState.FlightKeys, нормализованные направления и изменение скорости
                    #00,                                                        ; FInputState.ViewJumpKeys, виды кабины, переходы и CAPS SHIFT
                    #00,                                                        ; FInputState.DeviceKeys, маска команд C, Q, W, E, U, F, T, A
                    #00,                                                        ; FInputState.ChartKeys, маска клавиш R, D, B
                    #FF,                                                        ; FInputState.LastKey, последний символ, #FF нет клавиши, #FE сочетание 0 и CAPS SHIFT
                    #8C,                                                        ; FInputState.Config, режим источника, настройки направлений и звук
                    #00                                                         ; FInputState.NumberKeys, цифровые направления до нормализации
                }
                ; проверка исходного конца фрагмента
                ASSERT $ == #FC10
                endmodule
                endmodule
