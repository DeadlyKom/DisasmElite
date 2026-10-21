; -----------------------------------------
; Установка корутины и виртуальной клавиатуры демо
; исходный диапазон #C82C..#C8C3
; In:
;   командир State, второй оверлей по исходному адресу #C800
; Out:
;   код перенесён в DiskUtility.Demo.FrameHook, игровые вызовы и клавиатура переключены
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Снимок FCommander сохраняется в Game.Missions.RatingBountyDamageAndNewCommander.NewCommander
;   Game.Input.KeyboardControlInterrupt.KeyboardCall переключается на DiskUtility.Demo.FrameHook
;   Game.Input.ScanKeyboardMatrix.RowPort получает Keyboard вместо порта
;   ScanRow и KeyReadTail заменяют IN последовательностью LD A, (BC), NOP, CPL, INC BC
;   InputPatches подменяет два прямых чтения клавиш и чтение FSpaceObject.Energy
;   Из DemoPayload копируется #0852 байта в DiskUtility.Demo.FrameHook
;   первые #072A байта принадлежат cl.C, последние #0128 уже загруженной основной игре
;   RestartPatch записывается в OverlayTrack, Game.Flight.MainGameLoop.DeathTarget указывает туда
;   первые семь векторов Game.Interface.MenuDispatchTable.Entry заменяются 21 командой RET
;   Game.Disk.LoadDiskMenuOverlay.Entry тоже получает RET, повторный вход в дисковое меню отключён
;   Изменённые оверлеем игровые функции вызываются через перенаправленные операнды CALL
;   DI сохраняется до возврата вызывающему, цвет бордюра меняется с 0 на 6
; -----------------------------------------
                ; чёрный бордюр и запрет прерываний на время патчей
InstallDemo:    LD A, #00
                OUT (#FE), A
                DI
                ; снимок 102 байтов командира сохраняется в резерв Game.Missions.RatingBountyDamageAndNewCommander.NewCommander
                LD HL, State.Name
                LD DE, Game.Missions.RatingBountyDamageAndNewCommander.NewCommander
                LD BC, #0066
                LDIR
                ; встраивание корутины перед существующим опросом клавиатуры в IM2
                LD HL, @DiskUtility.Demo.FrameHook
                LD (Game.Input.KeyboardControlInterrupt.KeyboardCall), HL
                ; перевод Game.Input.ScanKeyboardMatrix.Entry с физических портов на восемь строк структуры Keyboard
                LD HL, Keyboard
                LD (Game.Input.ScanKeyboardMatrix.RowPort), HL
                LD H, #0A
                LD (Game.Input.ScanKeyboardMatrix.ScanRow), HL
                LD HL, #032F
                LD (Game.Input.ScanKeyboardMatrix.KeyReadTail), HL
                ; подмена первого прямого чтения клавиши на виртуальную строку Keyboard.RowASDFG
                LD HL, InputPatches
                LD DE, Game.Extensions.CreateMissileOrMissionCraft.DirectKeyRead
                LD BC, #0005
                LDIR
                ; подмена второго прямого чтения на Keyboard.RowEnterLKJH с инверсией активного уровня
                LD DE, Game.Universe.ApplyEnhancedFlightControl.DirectKeyRead
                LD C, #04
                LDIR
                ; замена Game.Menus.ReadVisibleObjectByte.Entry прямым чтением энергии объекта, IX + FSpaceObject.Energy
                LD DE, Game.Combat.UpdateAllSpaceObjects.EnergyRead
                LD C, #03
                LDIR
                ; перенос #0852 байтов включает #0128 байтов уже загруженной игры за концом оверлея
                LD HL, DemoPayload
                LD DE, @DiskUtility.Demo.FrameHook
                LD BC, #0852
                LDIR
                ; маркер LaunchPending будет сбрасываться при штатном выходе после гибели
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
