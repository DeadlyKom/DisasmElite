                module Screen
                module HandleScreenKeys
; -----------------------------------------
; выбор вида, экрана меню или команды вылета по событиям клавиатуры
; In:
;   байты событий InputState и InputState.ViewJumpKeys, режим FlightState.View, состояние полёта FlightState.FlightStatus
; Out:
;   выбранный экран или начатый вылет, обработанные события обнулены
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   при активном переходе ViewKeyLock события экранов игнорируются
;   младшие четыре бита InputState.ViewJumpKeys выбирают направления обзора или вылет со станции
;   на станции видовые клавиши переводятся в экраны с номерами 4..6
;   шесть младших битов InputState выбирают последующие экраны 7..12
;   Game.Screen.SelectScreen.Entry меняет режим и сохраняет кабину при переходе к меню
;   Game.Screen.DispatchMenu.Entry вызывает выбранный обработчик по таблице Game.Interface.MenuDispatchTable.Entry
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #80D3
                ; проверка блокировки клавиш во время стыковочного перехода
Entry:          LD A, (ViewKeyLock)
                AND A
                RET NZ                                                          ; выход, если стыковочный переход ещё активен

                ; поиск нажатой видовой клавиши в младших четырёх битах
                LD A, (InputState.ViewJumpKeys)
                AND #0F
                JR Z, ReadInfoKeys                                              ; переход, если видовых клавиш нет

                LD C, #00
                SRL A
                JR C, FirstViewKey                                              ; переход, если нажата первая видовая клавиша

                INC C
                SRL A
                JR C, SecondViewKey                                             ; переход, если нажата вторая видовая клавиша

                INC C
                SRL A
                JR C, SecondViewKey                                             ; переход, если нажата третья видовая клавиша

                INC C
                ; выбор назначения видовой клавиши в полёте и на станции
SecondViewKey:  LD A, (FlightState.FlightStatus)
                AND A
                JR NZ, SetSecondView                                            ; переход, если корабль находится в полёте

                LD A, #03
                ADD A, C
                LD C, A
                CALL Game.Screen.SelectScreen.Entry
                SUB #04
                CALL Game.Screen.DispatchMenu.Entry
                JR ClearEvents

SetSecondView:  CALL Game.Screen.SelectScreen.Entry
                JR ClearEvents

FirstViewKey:   LD A, (FlightState.FlightStatus)
                AND A
                JR NZ, SetFirstView                                             ; переход, если первая клавиша меняет вид в полёте

                CALL Game.Flight.LaunchOrDockShip.Entry
                JR ClearEvents

SetFirstView:   CALL Game.Screen.SelectScreen.Entry
                JR ClearEvents

                ; поиск клавиши информационного экрана
ReadInfoKeys:   LD A, (InputState.SystemKeys)
                AND #3F
                ADD A, A
                RET Z                                                           ; выход, если клавиши информационных экранов не нажаты

                ADD A, A
                LD BC, #0607
FindInfoKey:    ADD A, A
                JR C, OpenInfoView                                              ; переход, если очередной установленный бит выбрал информационный экран

                INC C
                DJNZ FindInfoKey

OpenInfoView:   CALL Game.Screen.SelectScreen.Entry
                CP #07
                JR C, ClearEvents                                               ; переход, если новый режим не требует вызова табличного меню

                SUB #04
                CALL Game.Screen.DispatchMenu.Entry
                ; сброс уже обработанных событий
ClearEvents:    XOR A
                LD (InputState.ViewJumpKeys), A
                LD (InputState.SystemKeys), A
                RET

                ASSERT $ == #813E
                endmodule
                endmodule
