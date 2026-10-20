; -----------------------------------------
; Начальные паузы, разгон и команда старта
; исходный диапазон #E795..#E7CD
; In:
;   IX, Keyboard, начало восьми полурядов виртуальной клавиатуры
;   начальный стек EF00
; Out:
;   IX=4700, E07A=1, сделан снимок командира, затем ApproachBody
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   После первой PauseWithMark следуют 20 кадров пробела и ещё PauseWithMark
;   Копирование 102 байтов заканчивается B=0, поэтому цикл E7C5 выполняется 256 раз с клавишей 1
;   E79C является точкой перезапуска без повторной установки IX, E7BA обновляет снимок командира
; -----------------------------------------
                ; подготовка виртуальной клавиатуры и первая пауза сценария
InitScenario:   LD IX, Keyboard
                CALL PauseWithMark
                ; точка перезапуска выставляетмаркер 1 и очищает семь строк клавиш
RestartFlight:  LD A, #01
                LD (LaunchPending), A
                OUT (#FE), A
                CALL ClearMainKeys
                CALL PauseWithMark
                LD B, #14
                ; двадцать уступок кадра с виртуальным пробелом
LaunchThrottle: CALL ClearMainKeys
                LD (IX + FKeyboardRows.RowSpaceSMNB), #01
                CALL YieldWithBrake
                DJNZ LaunchThrottle

                CALL PauseWithMark
                ; снимок командира после паузы перед последовательностью стартовых команд
BackupPilot:    LD HL, State.Name
                LD DE, Game.Missions.RatingBountyDamageAndNewCommander.NewCommander
                LD BC, #0066
                LDIR
                ; после LDIR регистр B=0, команда 1 повторяется 256 кадров
FrontFrames:    LD (IX + FKeyboardRows.Row12345), #01
                CALL YieldWithBrake
                DJNZ FrontFrames
