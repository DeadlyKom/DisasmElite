                module Input
                module InterruptGateAndAcceleration
; -----------------------------------------
; изменяемый вход IM2 и продолжение увеличения скорости
; исходный диапазон #FEFE..#FF0D
; смысловое имя InterruptGateAndAcceleration
; In: аппаратный IM2 читает вектор InterruptGate, для Game.Input.InterruptGateAndAcceleration.Accelerate HL — скорость, DE=#00A0, B — клавиши
; Out: InterruptGate передаёт управление Game.Input.KeyboardControlInterrupt.Entry, Game.Input.InterruptGateAndAcceleration.Accelerate увеличивает скорость при единственной команде разгона
; Corrupt: по контракту соответствующего продолжения
; Байт #18 в InterruptGate заменяется на RET (#C9) при временном использовании стека Memory.Screen + #0020
; InputMotion.Roll/InputMotion.Pitch/InputMotion.Speed — слова крена, тангажа и скорости, это не команды
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #FEFE
                ; изменяемый трамплин IM2, штатный первый байт #18
Entry:          JR Game.Input.KeyboardControlInterrupt.Entry

                ; проверка одновременного торможения перед увеличением скорости
Accelerate:     BIT FLY_BRAKE_BIT, B
                JR NZ, @Game.Input.ClampAndStoreFlightSpeed.StoreSpeed          ; переход, если нажаты обе команды скорости, сохранить прежнее значение

                ; расчёт увеличения скорости на один шаг
                ADD HL, DE
                JP @Game.Input.ClampAndStoreFlightSpeed.SpeedLimit

                ; слово крена, знак в бите 15 и отдельный модуль
MotionData      FInputMotion {
                    #0000,                                                      ; FInputMotion.Roll, крен, знако-модульное слово с дробной частью в младшем байте
                    #0000,                                                      ; FInputMotion.Pitch, тангаж, знако-модульное слово с дробной частью в младшем байте
                    #0C00                                                       ; FInputMotion.Speed, неотрицательная скорость, дробная часть в младшем байте
                }

Roll            EQU MotionData.Roll                                             ; адрес поля FInputMotion.Roll
Pitch           EQU MotionData.Pitch                                            ; адрес поля FInputMotion.Pitch
Speed           EQU MotionData.Speed                                            ; адрес поля FInputMotion.Speed
                ; проверка исходного конца фрагмента
                ASSERT $ == #FF0E
                endmodule
                endmodule
