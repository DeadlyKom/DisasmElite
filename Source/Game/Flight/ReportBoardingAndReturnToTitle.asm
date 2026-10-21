                module Flight
                module ReportBoardingAndReturnToTitle
; -----------------------------------------
; Сообщение о посадке и возврат к выбору корабля
; исходный диапазон #728D..#72A2
; In:
;   Memory.Station + FSpaceObject.Roll поле станции,Game.Flight.MainGameLoop.SavedSP сохранённый SP
; Out:
;   выведено сообщение, восстановлен SP, JP Game.Flight.ShowTitleAndSelectControls.WaitRelease
; Corrupt:
;   HL, DE, BC, AF, SP
; Note:
;   Game.Screen.ChooseEncounterCode.Entry готовит состояние станции, Game.Input.ResetDemoAndNormalizeControls.Entry обнуляет LaunchPending и идёт в сообщение Game.Interface.DispatchDiskAndCommanderState.ShowBoarding
;   JoystickMode хранит последний выбранный джойстик для паузы и начального экрана
; -----------------------------------------
                ASSERT $ == #728D
                ; подготовка посадки перед общим сообщением
Entry:          LD HL, Memory.Station + FSpaceObject.Roll
                CALL Game.Screen.ChooseEncounterCode.Entry
                NOP
                NOP
                ; общий вход сообщения сбрасывает одноразовый счётчик и восстанавливает основной стек
RestartTitle:   CALL Game.Input.ResetDemoAndNormalizeControls.Entry
                CALL Game.Screen.RestoreCockpitIfNeeded.Entry
                LD SP, (Game.Flight.MainGameLoop.SavedSP)
                JP @Game.Flight.ShowTitleAndSelectControls.WaitRelease

                ; последний выбранный джойстик 2/3, нуль до выбора
JoystickMode    DB #00                                                          ; выбранный режим управления джойстиком
                ASSERT $ == #72A3
                endmodule
                endmodule
