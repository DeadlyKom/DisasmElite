                module Flight
                module ShowTitleAndSelectControls
; -----------------------------------------
; Начальный экран с вращающимися кораблями и выбором управления
; исходный диапазон #7394..#742F
; In:
;   состояние начального экрана и клавиатуры
; Out:
;   SPACE или джойстик запускает восстановление командира и основной цикл Game.Flight.MainGameLoop.Entry
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
;   Циклический индекс DemoModel выбирает 12 моделей через таблицу DemoModels, значения 12..15 пропускаются
;   Коды джойстика 2/3 берутся из битов 1/3 InputState.NumberKeys, SPACE выбирает клавиатуру 0, младшие 2 бита InputState.Config
;   заменяются
;   Сбрасывает полётные флаги, строит интерфейс Game.Screen.SaveCockpit.Entry, открывает состояние пилота Game.Interface.DispatchStatusAndChartKeys.Entry и инициализирует
;   скорость Game.Flight.ResetFlightControls.Entry
;   DrawDemoTitle выводит вторую демонстрационную подпись, перед ним сохранены десять нулевых байтов
; -----------------------------------------
                ASSERT $ == #7394
                ; начальный передний вид и сброс текущего режима
Entry:          XOR A
                LD (FlightState.View), A
                CALL Game.Interface.DispatchClearView.Entry
                CALL Game.Screen.RestoreCockpitIfNeeded.Entry
                ; пометка демонстрационного объекта и ожидание отпускания клавиши
WaitRelease:    LD HL, Memory.Station + FSpaceObject.Roll
                SET 7, (HL)
                CALL Game.Flight.InitializeViewAttributes.Entry
                LD A, (InputState.LastKey)
                INC A
                JR NZ, WaitRelease                                              ; переход, если клавиша ещё удерживается, повторить ожидание отпускания

                ; выбор следующей из двенадцати моделей по таблице DemoModels
                LD HL, DemoModel
NextModel:      INC (HL)
                LD A, (HL)
                AND #0F
                CP #0C
                JR NC, NextModel                                                ; переход, если индекс модели равен 12..15, пропустить отсутствующую запись

                LD HL, DemoModels
                LD E, A
                LD D, #00
                ADD HL, DE
                LD C, (HL)
                CALL Game.Objects.InitializeIntroModel.Entry
                NOP
                ; очистка буфера и рисование заголовка с вращающейся моделью
AnimateModel:   CALL Game.Screen.ClearFlightBuffer.Entry
                CALL Game.Flight.DrawTitleCaption.Entry
                CALL Game.Combat.AnimateIntroAndObjectPipeline.Entry
                CALL Game.Screen.CopyFlightView.Entry
                LD BC, #FF1F
                LD HL, InputState.NumberKeys
                HALT
                JR ChooseControls

                ; десять сохранённых нулевых байтов, цикл демонстрации перепрыгивает их
                DB #00, #00, #00, #00, #00, #00, #00, #00                       ; #73D8..#73DF
                DB #00, #00                                                     ; #73E0..#73E1
                ; выбор управления, джойстики 2/3 либо клавиатура 0 по пробелу
ChooseControls: LD A, #02
                BIT NUM_5_BIT, (HL)
                JR NZ, SaveJoystick                                             ; переход, если нажат первый вариант джойстика, выбрать режим 2

                INC A
                BIT NUM_6_BIT, (HL)
                JR NZ, SaveJoystick                                             ; переход, если нажат второй вариант джойстика, выбрать режим 3

                LD A, (InputState.LastKey)
                SUB #20
                JR NZ, AnimateModel                                             ; переход, если пробел не нажат, продолжить показ модели

                LD B, A
                JR StoreControls

SaveJoystick:   LD (JoystickMode), A
                AND INPUT_MODE_MASK
                LD B, A
                ; замена младших двух битов управления с сохранением остальных настроек
StoreControls:  LD HL, InputState.Config
                LD A, (HL)
                AND #FC
                OR B
                LD (HL), A
                ; восстановление командира и очистка временных режимов
                CALL Game.Interface.DispatchResetCommander.Entry
                XOR A
                LD (FlightState.SpaceMode), A
                LD (FlightState.FlightStatus), A
                LD (MissionNotice), A
                LD (FlightState.SunScooping), A
                LD (CloakActive), A
                LD (Game.Flight.MainGameLoop.NovaRadius), A
                ; сохранение фона кабины, стартовый экран и начальные параметры управления
                CALL Game.Screen.SaveCockpit.Entry
                CALL Game.Interface.DispatchStatusAndChartKeys.Entry
                CALL Game.Flight.ResetFlightControls.Entry
                JR Game.Flight.MainGameLoop.Entry

                ; отдельная подпись демонстрации, вторичный токен 6 по X=1,Y=14
DrawDemoTitle:  CALL Game.Flight.DrawDemoHeading.Entry
                LD HL, #0E01
                LD A, #06
                JR @Game.Flight.DrawTitleCaption.PrintCaption

                ASSERT $ == #7430
                endmodule
                endmodule
