                module Input
                module ResetDemoAndNormalizeControls
; -----------------------------------------
; сброс флага демонстрации и нормализация направлений управления
; исходный диапазон #FC33..#FCB9
; смысловое имя ResetDemoAndNormalizeControls
; In: отдельный Game.Input.ResetDemoAndNormalizeControls.DigitalAxes получает A — режим минус 1, D — клавиатурные направления, E — настройки
; Out: младшая тетрада InputState.FlightKeys заменена нормализованными направлениями
; Corrupt: HL, DE — только D, BC, AF
; Основной Game.Input.ResetDemoAndNormalizeControls.Entry обнуляет LaunchPending и хвостом переходит в Game.Interface.DispatchDiskAndCommanderState.ShowBoarding
; перед DigitalAxes сохранено слово с адресом SwapAxisPairs, поток этого входа начинается в DigitalAxes
; Режимы источника, перестановки осей по битам 4/5 E и конфликтующие клавиши обрабатываются раздельно
; Комбинация клавиши 0 и CAPS SHIFT кодируется #FE в InputState.LastKey
; Старшая тетрада InputState.FlightKeys, включающая скорость, сохраняется при слиянии направлений
; -----------------------------------------
; -----------------------------------------
; настройки управления InputState.Config
;       7    6    5    4    3    2    1    0
;     +----+----+----+----+----+----+----+----+
;     | SN | MJ | VY | RV | BR | ST | MD | MD |
;     +----+----+----+----+----+----+----+----+
; SN [7] - флаг, разрешён звук, проверяют Game.Trade.OptionalBeep.Entry и звуковые обработчики
; MJ [6] - флаг, обычный гиперпереход принудительно выводит в межзвёздное пространство
;   Game.Travel.CommitJumpFuelAndMishap.Entry проверяет его перед случайным выбором выхода, установленный бит ведёт в Game.Travel.CommitJumpFuelAndMishap.Witchspace
; VY [5] - флаг, дополнительно переставить вертикальные направления 2 и 3, обработка Game.Input.ResetDemoAndNormalizeControls.SwapVertical
; RV [4] - флаг, переставить обе пары направлений, 0 с 1 и 2 с 3, обработка Game.Input.ResetDemoAndNormalizeControls.SwapAxisPairs
; BR [3] - флаг, автоматически тормозить отпущенную ось, проверка Game.Input.IntegrateFlightControls.Entry
;   уменьшение модуля за такт составляет #003C для крена и #0024 для тангажа
; ST [2] - флаг, при противоположной команде сразу обнулить угол вместо торможения полным шагом
;   проверяется в Game.Input.IntegrateFlightControls.ReverseRoll и Game.Input.IntegrateFlightControls.ReversePitch, одновременное нажатие обоих направлений обрабатывается отдельно
; MD [1..0] - числовой режим источника, не два независимых флага
;   0 использует буквенную клавиатуру, остальные значения используют цифровые клавиши InputState.NumberKeys
;   для 2 применяется сдвиг цифровой маски, для 1 и 3 дополнительная перестановка битов
;   Game.Flight.ShowTitleAndSelectControls.ChooseControls выбирает 2 по клавише 5, 3 по клавише 6, 0 по SPACE
;   меню паузы переключает SN клавишей S, MJ клавишей F, VY клавишей Y
;   RV переключается клавишей B, BR клавишей D, ST клавишей R, таблица PauseKeyMap
;   K переключает клавиатуру и сохранённый цифровой режим через Game.Flight.IndexPauseCommandAndHandlers.ToggleJoystick
;   отдельного чтения порта Kempston в данном пути нет
; -----------------------------------------

                ; проверка исходного начала фрагмента
                ASSERT $ == #FC33
                ; сброс признака демонстрации перед входом в основное продолжение
Entry:          LD HL, LaunchPending
                LD (HL), #00
                JP Game.Interface.DispatchDiskAndCommanderState.ShowBoarding

                ; сохранённое слово Game.Input.ResetDemoAndNormalizeControls.SwapAxisPairs между независимыми входами
                DB #63, #FC                                                     ; данные #FC3B..#FC3C
                ; перестановка цифровых направлений выбранного интерфейса
DigitalAxes:    DEC A
                LD A, (InputState.NumberKeys)
                RRA
                LD D, A
                JR Z, ZeroKey                                                   ; переход, если исходный режим равен 2, перестановка Sinclair не нужна

                LD D, #00
                RL D
                RRA
                RRA
                RL D
                SLA D
                RRA
                RR D
                RRA
                RL D
                RL D
                ; преобразование цифровой клавиши 0 в дополнительную команду A
ZeroKey:        LD HL, InputState.SystemKeys
                BIT SYS_0_BIT, (HL)
                JR Z, SwapAxisPairs                                             ; переход, если клавиша 0 не нажата, пропустить дополнительную команду

                LD HL, InputState.DeviceKeys
                SET DEV_FIRE_BIT, (HL)
                ; проверка перестановки обеих пар направлений
SwapAxisPairs:  BIT INPUT_INV_BIT, E
                JR Z, SwapVertical                                              ; переход, если бит 4 настроек сброшен, оставить обе пары направлений

                ; перестановка битов 0/1 и 2/3 с сохранением четырёх направлений
                LD A, D
                AND FLY_NEG_MASK
                SLA A
                LD C, A
                LD A, D
                AND FLY_POS_MASK
                SRL A
                OR C
                LD D, A
                ; проверка дополнительной перестановки вертикальной пары
SwapVertical:   BIT INPUT_INVY_BIT, E
                JR Z, KeyConflicts                                              ; переход, если бит 5 настроек сброшен, оставить вертикальную пару

                ; перестановка битов 2/3 без изменения горизонтальной пары 0/1
                LD A, D
                AND FLY_ROLL_MASK
                LD B, A
                LD A, D
                AND FLY_PITCH_MASK
                LD C, A
                SRL C
                SLA A
                OR C
                AND FLY_PITCH_MASK
                OR B
                LD D, A
                ; проверка конфликтов буквенных команд с клавиатурным управлением
KeyConflicts:   LD HL, InputState.FlightKeys
                LD A, (InputState.Config)
                AND INPUT_MODE_MASK
                JR NZ, MergeControls                                            ; переход, если выбран цифровой источник направлений, не очищать конфликты букв

                LD A, (HL)
                AND A
                JR Z, MergeControls                                             ; переход, если направления клавиатуры нулевые, конфликтующих команд нет

                ; снятие конфликтующих битов команд перед сохранением направлений
                INC L
                RES VIEW_PAUSE_BIT, (HL)
                INC L
                RES DEV_LAUNCH_BIT, (HL)
                RES DEV_DOCK_BIT, (HL)
                DEC L
                DEC L
                ; объединение новых направлений со старшими управляющими битами
MergeControls:  LD A, (HL)
                AND FLY_AUX_MASK
                OR D
                LD (HL), A
                ; проверка комбинации цифровой клавиши 0 и CAPS SHIFT
                LD HL, InputState.SystemKeys
                BIT SYS_0_BIT, (HL)
                RET Z                                                           ; выход, если клавиша 0 не нажата

                RES SYS_0_BIT, (HL)
                LD A, (InputState.ViewJumpKeys)
                AND 1 << VIEW_PAUSE_BIT
                RET Z                                                           ; выход, если CAPS SHIFT не нажат, специальная комбинация отсутствует

                ; запись специального кода #FE для комбинации 0 и CAPS SHIFT
                LD A, INPUT_ZERO_KEY
                LD (InputState.LastKey), A
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #FCBA
                endmodule
                endmodule
