                module Combat
                module HandleEscapeCapsule
; -----------------------------------------
; запуск спасательной капсулы и отсчёт до завершения эвакуации
; исходный диапазон #9C1C..#9C7F
; In:
;   память InputState.DeviceKeys.6, команда капсулы
;   память State.EscapePod, оборудование
;   FlightState.SpaceMode, запрет капсулы вне обычной системы
;   память MissileCount, обратный отсчёт
; Out:
;   обновлены состояние командира, капсула и отсчёт
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
; При активном отсчёте только уменьшает его, нулевое значение передаёт управление Game.Flight.TryAutomaticDocking.RebaseForDock.
; Новый запуск ставит 24 такта, InputMotion.Speed=16, сбрасывает правовой статус State.LegalStatus.
; Game.Screen.ConsumeEscapePod.Entry увеличивает код капсулы State.EscapePod и записывает LaunchPending=0.
; очищаются первые 13 полей State.Cargo от Food до Minerals, MS_CARGO_BIT и AlienItems, затем выполняются ResetCargoCapacity и действие #17
; Game.Interface.DispatchDiskAndCommanderState.Commander.SunPosition.X.Low/Game.Interface.DispatchDiskAndCommanderState.Commander.SunPosition.X.SignHigh сохраняют возвращённое A и координату текущей системы State.SystemSeed + FSystemSeed.Y.
; LegacyCell сохраняет старые байты, недостижимые через предшествующий JP, в конце файла лежит нулевой рабочий хвост
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #9C1C
                ; проверка и уменьшение активного отсчёта
Entry:          LD HL, MissileCount
                LD A, (HL)
                AND A
                JR Z, CheckCommand                                              ; переход, если отсчёт ещё не запущен и нужно проверить команду

                DEC A
                LD (HL), A
                JP Z, @Game.Flight.TryAutomaticDocking.RebaseForDock            ; переход, если отсчёт завершился и начинается итоговая последовательность эвакуации

                RET

                ; проверка команды, оборудования и режима пространства
CheckCommand:   LD A, (InputState.DeviceKeys)
                BIT DEV_ESCAPE_BIT, A
                RET Z                                                           ; выход, если команда капсулы не поступила

                LD A, (State.EscapePod)
                AND A
                RET Z                                                           ; выход, если капсула не установлена

                LD A, (FlightState.SpaceMode)
                AND A
                RET NZ                                                          ; выход, если активно особое пространство и запуск капсулы запрещён

                LD A, #18
                LD (MissileCount), A
                LD HL, #0010
                LD (InputMotion.Speed), HL
                XOR A
                LD HL, State.LegalStatus
                LD (HL), A
                CALL Game.Screen.ConsumeEscapePod.Entry
                ; очистка части грузового состояния
                LD L, #6B
                LD B, #0D
                ; миссии 1, 7+1, 7+3, спасательная капсула снимает признак особого груза после очистки тоннажных товаров
                ; описание в Docs/Manual.md, раздел mission-1, mission-7-1, mission-7-3
ClearCargo:     LD (HL), A
                INC HL
                DJNZ ClearCargo

                LD L, #B0
                RES MS_CARGO_BIT, (HL)
                LD L, #7B
                LD (HL), A
                CALL Game.Screen.ResetCargoCapacity.Entry
                LD A, #17
                ; создание спасательного объекта
                CALL Game.Combat.DispatchObjectAction.Entry
                JR SaveEvacuation

                ; сохранённые машинные байты старого пути

; -----------------------------------------
; выбор значения памяти либо номера минус один
; In:
;   BC, B содержит номер
;   слово MarketWork.CargoCursor задаёт адрес читаемого байта
; Out:
;   HL, адрес из MarketWork.CargoCursor
;   AF, при B<3 возвращает B-1 и CY=1, иначе байт по HL и CY=0
; Corrupt:
;   HL, AF
; Note:
;   сохранённая процедура, прямые входящие переходы не найдены
;   в сохранённом хвосте LegacyCell результат первого LD A, (HL) затем безусловно заменяется значением B
;   NOP сохраняет исходное место, дополнительное назначение прежнего чтения не подтверждено
;   DEC A изменяет Z/S, но сохраняет перенос сравнения CP 3
; -----------------------------------------
LegacyCell:     ; выбор значения памяти либо номера минус один
                LD HL, (MarketWork.CargoCursor)
                LD A, (HL)
                NOP
                LD A, B
                CP #03
                DEC A
                RET C                                                           ; выход, если номер B меньше 3, результат равен B-1

                LD A, (HL)
                RET

                ; сохранение параметров эвакуации
SaveEvacuation: LD (State.SunPosition + FCoordinate.Low), A
                LD A, (State.SystemSeed + FSystemSeed.Y)
                LD (State.SunPosition + FCoordinate.SignHigh), A
                RET

                DB #00, #00, #00, #00, #00
                ; проверка исходного конца фрагмента
                ASSERT $ == #9C80
                endmodule
                endmodule
