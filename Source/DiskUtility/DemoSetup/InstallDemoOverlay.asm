; -----------------------------------------
; Установка корутины и виртуальной клавиатуры демо
; исходный диапазон #C82C..#C8C3
; In:
;   командир D054, загруженный второй оверлей C800..CFFF
; Out:
;   код перенесён E6AE..EEFF, игровые вызовы и клавиатура переключены
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Копируются 102 байта командира в D232, кадровый CALL FF35 получает E6AE
;   FD71 становится LD BC,4700, FD76..79 становятся LD A,(BC),NOP,CPL,INC BC, остальная обработка
;   клавиш сохраняется
;   C8CA даёт 5 байтов для 5EF8,4 для 7F87 и 3 для 9D3D, последний заменяет CALL ED69 на LD A,(IX+22)
;   LDIR0852 читает C8D6..D127, первые 072A принадлежат cl.C, последние 0128 основной игре,
;   результат E6AE..EEFF
;   В D983 устанавливается LD(E07A),A / JP739E, переход гибели 7575 перенаправляется на него
;   D000..D014 заменяются 21 RET, D907 тоже RET, остальные патчи подменяют вызовы изменённых оверлеем
;   функций
;   DI сохраняется до возврата вызывающему, цвет бордюра меняется с 0 на 6
; -----------------------------------------
                ; чёрный бордюр и запрет прерываний на время патчей
InstallDemo:    LD A, #00
                OUT (#FE), A
                DI
                ; снимок 102 байтов командира сохраняется в резерв D232
                LD HL, State.Name
                LD DE, Game.Missions.RatingBountyDamageAndNewCommander.NewCommander
                LD BC, #0066
                LDIR
                ; встраивание корутины перед существующим опросом клавиатуры в IM2
                LD HL, @DiskUtility.Demo.FrameHook
                LD (Game.Input.KeyboardControlInterrupt.KeyboardCall), HL
                ; перевод FD69 с физических портов на последовательные байты 4700..4707
                LD HL, Keyboard
                LD (Game.Input.ScanKeyboardMatrix.RowPort), HL
                LD H, #0A
                LD (Game.Input.ScanKeyboardMatrix.ScanRow), HL
                LD HL, #032F
                LD (Game.Input.ScanKeyboardMatrix.KeyReadTail), HL
                ; подмена первого прямого чтения клавиши на виртуальную строку 4701
                LD HL, InputPatches
                LD DE, Game.Extensions.CreateMissileOrMissionCraft.DirectKeyRead
                LD BC, #0005
                LDIR
                ; подмена второго прямого чтения на 4706 с инверсией активного уровня
                LD DE, Game.Universe.ApplyEnhancedFlightControl.DirectKeyRead
                LD C, #04
                LDIR
                ; замена проверки ED69 прямым чтением энергии объекта, IX+FSpaceObject.Energy
                LD DE, Game.Combat.UpdateAllSpaceObjects.EnergyRead
                LD C, #03
                LDIR
                ; перенос 0852 байтов включает 0128 байтов уже загруженной игры за концом оверлея
                LD HL, DemoPayload
                LD DE, @DiskUtility.Demo.FrameHook
                LD BC, #0852
                LDIR
                ; маркер E07A будет сбрасываться при штатном выходе после гибели
                LD HL, OverlayTrack
                LD (Game.Flight.MainGameLoop.DeathTarget), HL
                LD HL, RestartPatch
                LD DE, OverlayTrack
                LD C, #06
                LDIR
                ; отключение первых семи векторов экранов, каждый из 21 байта становится RET
                LD HL, Game.Interface.MenuDispatchTable.Entry
                LD BC, #15C9
DisableScreens: LD (HL), C
                INC HL
                DJNZ DisableScreens

                ; отключение повторного дискового меню и перенос необходимых вызовов в новые копии
                LD HL, Game.Disk.LoadDiskMenuOverlay.Entry
                LD (HL), C
                ; две команды сведений используют копию форматирующего токена 96
                LD HL, @DiskUtility.Demo.FormatToken
                LD (Game.Menus.OpenCommanderStatus.FormatCall), HL
                LD (Game.Menus.PrintStatusFieldAndCargoScreen.FormatCall), HL
                ; вызов старта получает копию установки маскировки и случайного параметра
                LD HL, @DiskUtility.Demo.RestoreFlight
                LD (Game.Flight.LaunchOrDockShip.RestoreCall), HL
                ; кадр дополняется сферой сканера, копированием экрана и маркерами
                LD HL, @DiskUtility.Demo.DrawViewHook
                LD (Game.Flight.MainGameLoop.DrawCall), HL
                ; подмена функции сложения адреса, старое место занято демо
                LD HL, @DiskUtility.Demo.AddByteOffset
                LD (Game.Missions.RatingBountyDamageAndNewCommander.CargoOffset), HL
                ; четыре вызова проверки полосы вторжения направляются в перенесённую копию
                LD HL, @DiskUtility.Demo.CheckInvasion
                LD (Game.Screen.SelectTrafficType.InvasionCall), HL
                LD (Game.Text.NextDescriptionRandom.InvasionCall), HL
                LD (Game.Input.ToggleSecondaryCoordinateObject.InvasionCall), HL
                LD (Game.Universe.ApplyEnhancedFlightControl.InvasionCall), HL
                ; жёлтый бордюр означает завершение установки, EI выполняет внешний поток
                LD A, #06
                OUT (#FE), A
                RET
