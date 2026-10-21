                ifndef _VARIABLES_INPUT_
                define _VARIABLES_INPUT_

InputMotion     EQU Game.Input.InterruptGateAndAcceleration.MotionData          ; адрес структуры FInputMotion
.Roll           EQU InputMotion + FInputMotion.Roll                             ; крен, знако-модульное слово с дробной частью в младшем байте
.Pitch          EQU InputMotion + FInputMotion.Pitch                            ; тангаж, знако-модульное слово с дробной частью в младшем байте
.Speed          EQU InputMotion + FInputMotion.Speed                            ; неотрицательная скорость, дробная часть в младшем байте
InputStack      EQU Game.Input.EnableInterruptMode1AndKeyboardMap.SavedStack    ; сохранённый SP для обработчика клавиатуры и IM1
InputPhase      EQU Game.Input.ToggleSecondaryCoordinateObject.UpdatePhase      ; изменяемый операнд LD A, фаза чередующегося обновления координат

PauseKeyMap     EQU Game.Flight.IndexPauseCommandAndHandlers.PauseKeyMap        ; пары код клавиши и маска изменяемой настройки, завершение нулём
KeyCharacters   EQU Game.Input.ToggleSecondaryCoordinateObject.KeyCharacters    ; 40 кодов символов, индекс по позиции клавиши в матрице
KeyAssignments  EQU Game.Input.EnableInterruptMode1AndKeyboardMap.KeyAssignments; 40 пар смещение и маска, назначение клавиш в InputState

InputViewSkip   EQU Game.Input.ToggleSecondaryCoordinateObject.SkipPhase        ; изменяемое смещение выбора координат
InterruptGate   EQU Game.Input.InterruptGateAndAcceleration.Entry               ; JR либо RET, разрешение обработчика IM2

                endif                                                           ; ~_VARIABLES_INPUT_
