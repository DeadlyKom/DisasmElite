                module Flight
                module IndexPauseCommandAndHandlers
; -----------------------------------------
; Поиск команды паузы и обработчики её действий
; исходный диапазон #72D5..#7343
; In:
;   HL таблица пар ключ-значение, AF, A=код клавиши
; Out:
;   C=1 при найденном ключе, HL указывает связанное значение
; Corrupt:
;   HL, AF, BC сохраняется оболочкой, прочие по Rom.FindKeyPair
; Note:
;   Game.Flight.IndexPauseCommandAndHandlers.ToggleScanner переключает сканер через Game.Universe.AddSignedStarCoordinate.ToggleScanner,Game.Flight.IndexPauseCommandAndHandlers.SwapLasers меняет местами пары передних/задних и боковых лазеров Mk4
;   SPACE исполняет XOR A перед общим хвостом очистки и возвращает C=0, Q пропускает XOR A и сохраняет C=1, оба очищают пять
;   клавиатурных байтов
;   команда K через ToggleJoystick переключает младшие два бита джойстика, команда C инвертирует bit1 операнда InputViewSkip
;   при отсутствии Mk4 переход NoUpgrade исполняет старший байт адреса CALL как RST #18
;   сохранена буквально
; -----------------------------------------
                ASSERT $ == #72D5
                ; поиск пары через Rom.FindKeyPair с сохранением BC вызывающего
Entry:          PUSH BC
                LD C, A
                CALL Rom.FindKeyPair
                LD A, C
                POP BC
                RET

                ; команда L переключает проекцию сканера через Game.Universe.AddSignedStarCoordinate.ToggleScanner
ToggleScanner:  CALL Game.Universe.AddSignedStarCoordinate.ToggleScanner
                NOP
                JR AwaitPauseKey

                ; команда A переставляет пары лазеров только после покупки Mk4
                ; миссия 6 Cobra Mk4, наличие Cobra Mk4 разрешает перестановку направлений лазеров
                ; описание в Docs/Manual.md, раздел mission-6
SwapLasers:     LD A, (State.ShipUpgrade)
                AND A
                ; без Mk4 вход Game.Flight.IndexPauseCommandAndHandlers.NoUpgrade исполняет DF как RST18, затем Game.Flight.IndexPauseCommandAndHandlers.StoreOption пишет байт обратно
                JR Z, NoUpgrade                                                 ; переход, если модернизация Mk4 отсутствует, выполнить перекрывающий вход RST18

                ; перестановка переднего с левым и заднего с правым лазером
                LD HL, (State.FrontLaser)
                LD A, H
                LD D, L
                LD HL, (State.LeftLaser)
                LD (State.FrontLaser), HL
                LD H, D
                LD L, A
                LD (State.LeftLaser), HL
                JR AwaitPauseKey

                ; пары клавиша-маска настройки, B10,D08,F40,R04,Y20,S80, нулевой конец
PauseKeyMap     DB #42, #10, #44, #08, #46, #40, #52, #04                       ; пары код клавиши и маска изменяемой настройки, завершение нулём
                DB #59, #20, #53, #80, #00                                      ; #7303..#7307
                ; пары клавиша-младший адрес обработчика, пробел 19,L15,A17,K28,C39,Q1A, конец 0
                DB #20, #19, #4C, #15, #41, #17, #4B, #28                       ; #7308..#730F
                DB #43, #39, #51, #1A, #00                                      ; #7310..#7314
                ; векторы команд L и A из второй таблицы паузы
ScannerKey:     JR ToggleScanner

                JR SwapLasers

                ; пробел сбрасывает перенос через XOR A, Q начинает со следующей LD A, #00 и сохраняет перенос
                XOR A
                LD A, #00
                LD L, #08
                ; очистка пяти клавиатурных масок без изменения переноса результата
                LD (HL), A
                INC HL
                LD (HL), A
                INC HL
                LD (HL), A
                INC HL
                LD (HL), A
                INC HL
                LD (HL), A
                RET

                ; команда K переключает клавиатуру и последний выбранный джойстик
ToggleJoystick: LD D, A
                AND #03
                LD A, (JoystickMode)
                JR NZ, SwitchJoystick                                           ; переход, если включён джойстик, переключить управление через сохранённый режим

                AND A
                JR Z, AwaitPauseKey                                             ; переход, если сохранённый режим джойстика отсутствует, оставить управление

SwitchJoystick: LD A, (JoystickMode)
                XOR D
                JR StoreOption

                ; команда C переключает бит 1 параметра InputViewSkip через Game.Galaxy.OnesComplementDifference.ToggleBit1
                LD HL, InputViewSkip
                ; альтернативный вход Game.Flight.IndexPauseCommandAndHandlers.NoUpgrade исполняет старший байт DF этой команды как RST18
NoUpgrade:      EQU $+2                                                         ; старший байт CALL выполняется как RST #18 при отсутствии Mk4
                CALL Game.Galaxy.OnesComplementDifference.ToggleBit1
                ; запись настройки и подстановка возврата в ожидание паузы
StoreOption:    LD (HL), A
AwaitPauseKey:  LD HL, Game.Flight.HandlePauseMenu.WaitRelease
                PUSH HL                                                         ; далее Game.Flight.PlaySweepingBeeperAndBootstrap.Entry без команды перехода
                ASSERT $ == #7344
                endmodule
                endmodule
