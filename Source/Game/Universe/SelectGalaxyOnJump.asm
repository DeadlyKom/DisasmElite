                module Universe
                module SelectGalaxyOnJump
; -----------------------------------------
; выбор номера галактики при завершении межгалактического перехода
; исходный диапазон #79F9..#7A26
; In:
;   HL, адрес номера галактики State.Galaxy
; Out:
;   байт галактики и исходные данные State.GalaxySeed преобразованы
; Corrupt:
;   HL, DE, BC, AF, AF'
; Note:
; Game.Circles.ScanUpgradeKeyRow.Entry опрашивает числовые ряды клавиатуры F7 и EF при допустимом оборудовании.
; Без специального выбора используется следующий номер, разность с прежним номером приводится добавлением 8.
; Каждый шаг разности выполняет три NextGalaxyData над исходными данными.
; Окончательное ограничение номера до 0..7 делает вызывающий код Game.Travel.TickJumpCountdown.Entry.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #79F9
                ; поиск выбранной галактики по двум цифровым рядам
Entry:          LD BC, #01FF
                LD A, #F7
                CALL Game.Circles.ScanUpgradeKeyRow.Entry
                JR NC, CountRotations                                           ; переход, если первая клавиатурная строка уже дала выбранный номер

                LD A, #EF
                CALL Game.Circles.ScanUpgradeKeyRow.Entry
                JR C, SelectGalaxy                                              ; переход, если вторая строка не требует обратного преобразования номера

                LD A, #0E
                SUB C
SelectGalaxy:   LD C, A
                ; расчёт количества преобразований относительно прежнего номера
CountRotations: LD A, C
                SUB (HL)
                JR NC, StoreGalaxy                                              ; переход, если выбранный номер не меньше прежнего

                ADD A, #08
StoreGalaxy:    LD B, A
                LD (HL), C
                LD A, B
                OR B
                RET Z                                                           ; выход, если номер не изменился и преобразовывать данные не нужно

                ; преобразование исходных данных галактики тремя проходами на шаг
RotateGalaxy:   LD B, #03
                LD HL, State.GalaxySeed
RotateWord:     CALL Game.Travel.RotateTwoSeedBytesAdvance.Entry
                DJNZ RotateWord

                DEC A
                JR NZ, RotateGalaxy                                             ; переход, если остались шаги до выбранной галактики

                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #7A27
                endmodule
                endmodule
