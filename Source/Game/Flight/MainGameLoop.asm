                module Flight
                module MainGameLoop
; -----------------------------------------
; Основной цикл полёта, меню и последовательности гибели
; исходный диапазон #7471..#7583
; In:
;   глобальное состояние корабля, ввода и мира
; Out:
;   постоянный цикл, при гибели 30 кадров обломков и возврат Game.Flight.ShowTitleAndSelectControls.WaitRelease
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
;   FlightState.ControlsLocked блокирует обновление управления, затем Game.Screen.HandleScreenKeys.Entry разбирает клавиши,Game.Flight.HandlePauseMenu.Entry обслуживает паузу
;   При FlightState.FlightStatus=0 выполняются карта и дисковое меню, в полёте обновляются объекты и звёзды, вид 0..3
;   рисует сцену, меню 4+ задерживается 8HALT
;   После обновления приборов FlightState.PlayerDead запускает сцену гибели, останавливает скорость, создаёт обломки,
;   печатает сообщение 9 и ждёт 50HALT
;   Game.Flight.MainGameLoop.SavedSP хранит начальный SP, BodyX, BodyY и BodyZ содержат рабочие координаты светила
;   Game.Flight.MainGameLoop.NovaRadius хранит предыдущий радиус расширения сверхновой
; -----------------------------------------
                ASSERT $ == #7471
                ; проверка блокировки ручного управления при анимации
Entry:          LD A, (FlightState.ControlsLocked)
                AND A
                JR NZ, HandleKeys                                               ; переход, если управление заблокировано, сохранить текущие углы и скорость

                CALL Game.Flight.UpdateFlightControlGauges.Entry
                ; чтение клавиш и меню паузы, перенос после Q возвращает заставку
HandleKeys:     CALL Game.Screen.HandleScreenKeys.Entry
                CALL Game.Flight.HandlePauseMenu.Entry
                JR NC, UpdateStatus                                             ; переход, если выход из паузы не требует возврата к заставке, продолжить игру

                XOR A
                LD (FlightState.View), A
                CALL Game.Screen.RestoreCockpitIfNeeded.Entry
                JP @Game.Flight.ShowTitleAndSelectControls.WaitRelease

                ; общий интерфейс и разделение станции и полёта
UpdateStatus:   CALL Game.Interface.DispatchJumpKey.Entry
                LD A, (FlightState.FlightStatus)
                AND A
                JR NZ, FlightFrame                                              ; переход, если корабль в полёте, перейти к обновлению мира

                ; на станции обслуживаются курсор карты и команда выхода
                CALL Game.Flight.HandleMapCursorKeys.Entry
                LD A, (InputState.FlightKeys)
                BIT FLY_BRAKE_BIT, A
                JR Z, Game.Flight.MainGameLoop.Entry                            ; переход, если на станции не нажата команда выхода, начать следующий кадр

                CALL Game.Interface.DispatchDiskAndCommanderState.Entry
                JP NZ, Game.Flight.ShowTitleAndSelectControls.Entry             ; переход, если обработчик выхода вернул NZ, перезапустить заставку

                CALL Game.Interface.DispatchStatusAndChartKeys.Entry
                JR Game.Flight.MainGameLoop.Entry

                ; в полёте сначала проверяется стыковка, затем события и движение мира
FlightFrame:    LD A, (FlightState.SpaceMode)
                AND A
                JR NZ, UpdateWorld                                              ; переход, если активен особый режим пространства, пропустить обычную стыковку

                CALL Game.Flight.TryAutomaticDocking.Entry
                CALL Game.Extensions.UpdateStationAndFinishGlyph.Entry
UpdateWorld:    CALL Game.Universe.HandleFastTravelStep.Entry
                CALL Game.Universe.UpdateCelestialCoordinates.Entry
                ; выбор обзора кабины либо информационного экрана
                LD A, (FlightState.View)
                CP #04
                JR C, DrawView                                                  ; переход, если выбран один из четырёх видов кабины, рисовать полётную сцену

                CALL Game.Combat.UpdateObjectsAndWeapons.Entry
                LD A, (FlightState.FlightStatus)
                AND A
                JR Z, UpdateEvents                                              ; переход, если состояние полёта нулевое, пропустить индикатор станции

                CALL Game.Scanner.SetYellowFlightStatus.Entry
                CALL Game.Combat.ApplyPlayerDamage.Entry
                ; обновление события и восемь кадров обслуживания карты
UpdateEvents:   CALL Game.Universe.ExpandNovaRadius.Entry
                CALL Game.Interface.DispatchFlightMessage.Entry
                LD B, #08
MapFrame:       PUSH BC
                CALL Game.Flight.HandleMapCursorKeys.Entry
                HALT
                POP BC
                DJNZ MapFrame

                JR CheckDeath

                ; рисование сцены, вне обычного пространства светила пропускаются
DrawView:       CALL Game.Screen.RestoreCockpitIfNeeded.Entry
                CALL Game.Screen.ClearFlightBuffer.Entry
                LD A, (FlightState.SpaceMode)
                AND A
                CALL Z, Game.Universe.DrawSunAndPlanet.Entry                    ; вызов процедуры, если особый режим пространства выключен, вывести светила
                CALL Game.Universe.DrawStarsWithJumpEffect.Entry
DrawObjects:    CALL Game.Interface.DispatchFlightMessage.Entry
                CALL Game.Combat.UpdateObjectsAndWeapons.Entry
                CALL Game.Flight.AnimateTransitionTunnel.Entry
                JR DrawIndicators

                ; сохранённые NOP и JR к завершающему DJNZ цикла MapFrame, действующий путь переходит на DrawIndicators
                DB #00, #18, #DD                                                ; #74FF..#7501
                ; завершение кадра, приборы и проверка маскировки
DrawCall        EQU $ + 1                                                       ; операнд CALL перерисовки индикаторов, демо добавляет обработчик кадра
DrawIndicators: CALL Game.Menus.DrawExplosionAndScanner.Entry
                CALL Game.Screen.UpdateIndicators.Entry
                EI
                CALL Game.Flight.ToggleCloakingDevice.Entry
                CALL Game.Combat.ProcessCombatControls.Entry
                ; обработка вооружения, опасного сближения и признака гибели
CheckDeath:     CALL Game.Screen.UpdateCelestialProximity.Entry
                LD A, (FlightState.PlayerDead)
                AND A
                JP Z, Game.Flight.MainGameLoop.Entry                            ; переход, если корабль не уничтожен, начать следующий кадр

                ; после гибели скорость обнуляется и управление блокируется
                XOR A
                LD (FlightState.Speed), A
                LD (FlightState.XorObjects), A
                INC A
                LD (FlightState.ControlsLocked), A
                LD L, #07
                CALL Game.Extensions.AttributeVectorAndEnergyBomb.Entry
                ; удаление маркеров, подготовка разрушения и звуковых эффектов
                CALL Game.Scanner.RestoreScannerBackground.Entry
                CALL Game.Combat.CreateWreckAndDamageState.Entry
                CALL Game.Sound.PlayDestructionSound.Entry
                CALL Game.Sound.PlayLaunchSound.Entry
                CALL Game.Screen.RestoreCockpitIfNeeded.Entry
                ; тридцать кадров звёзд и надписи о гибели
                LD B, #1E
DeathFrame:     PUSH BC
                CALL Game.Screen.ClearFlightBuffer.Entry
                CALL Game.Universe.DrawStarsWithJumpEffect.Entry
                CALL Game.Combat.UpdateObjectsAndWeapons.Entry
                LD HL, (TextBasePatch)
                INC HL
                INC HL
                PUSH HL
                SET 7, (HL)
                LD HL, #070A
                LD (TextColumn), HL
                LD A, #09
                CALL Game.Flight.PrintMessageAfterMetadataReset.Entry
                POP HL
                RES 7, (HL)
                CALL Game.Screen.CopyFlightView.Entry
                POP BC
                DJNZ DeathFrame

                ; очистка экрана и объектов после анимации гибели
                CALL Game.Screen.ClearFlightBuffer.Entry
                CALL Game.Screen.CopyFlightView.Entry
                CALL Game.Flight.ClearNearbyShipSlots.Entry
                ; пятьдесят кадров ожидания перед возвратом к заставке
                LD B, #32
DeathDelay:     HALT
                DJNZ DeathDelay

                XOR A
                LD (FlightState.ControlsLocked), A
                LD (FlightState.PlayerDead), A
DeathTarget     EQU $ + 1                                                       ; операнд JP после задержки гибели, демо перенаправляет завершение
                JP @Game.Flight.ShowTitleAndSelectControls.WaitRelease

                ; сохранение исходного стека выполняет Bootstrap, возврат на заставку читает это слово
                ; младший байт SP расположен первым, исходный нуль заменяется до первого чтения
SavedSP:        DB #00, #00                                                     ; #7578..#7579, исходный указатель стека
                ; подготовка проекции копирует сюда девять байтов солнца, затем девять байтов планеты
                ; каждая координата имеет формат FCoordinate, дробь, младший модуль, знак и старший модуль
                ; проекция может менять рабочие знаки, исходные координаты светила остаются отдельно
BodyX           FCoordinate {                                                   ; явные исходные значения полей
                    #00,                                                        ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                    #00,                                                        ; FCoordinate.Low, средние восемь разрядов координаты
                    #00                                                         ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                }
BodyY           FCoordinate {                                                   ; явные исходные значения полей
                    #00,                                                        ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                    #00,                                                        ; FCoordinate.Low, средние восемь разрядов координаты
                    #00                                                         ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                }
BodyZ           FCoordinate {                                                   ; явные исходные значения полей
                    #00,                                                        ; FCoordinate.Fraction, младшие восемь разрядов, дробная часть движения
                    #00,                                                        ; FCoordinate.Low, средние восемь разрядов координаты
                    #00                                                         ; FCoordinate.SignHigh, бит 7 задаёт знак, биты 6..0 старшую часть модуля
                }
                ; расширение сверхновой прибавляет два к сохранённому радиусу, нуль выбирает первый радиус
NovaRadius:     DB #00                                                          ; Game.Flight.MainGameLoop.NovaRadius, предыдущий радиус сверхновой
                ASSERT $ == #7584
                endmodule
                endmodule
