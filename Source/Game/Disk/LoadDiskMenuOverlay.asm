                module Disk
                module LoadDiskMenuOverlay
; -----------------------------------------
; Загрузка первого оверлея cl.C и вызов меню
; исходный диапазон #D907..#D974
; In:
;   OverlayTrack = позиция cl.C, прерывания могут быть включены
; Out:
;   Восемь секторов загружены в DiskUtility.Menu.EnterMenu, DemoTrack = следующий сектор, результат AF возвращает оверлей
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   Сначала гасит атрибуты, читает 8 секторов, вызывает DiskUtility.Menu.EnterMenu, сохраняет AF вокруг сигнала и
;   паузы, CallDosInline сохраняет старый TR-DOS-шлюз, EnterDiskRom выполняет его общий выход в ПЗУ
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D907
                ; сохранение игрового состояния, чтение первого дискового оверлея и вызов его меню
Entry:          DI
                CALL Game.Disk.BlackAttributesAndOverlayState.Entry
                LD DE, (OverlayTrack)
                LD HL, Memory.Frame + #0800                                     ; область загрузки дискового оверлея внутри кадрового буфера
                LD B, #08
                CALL Game.Disk.TransferDiskSectors.Entry
                LD (DemoTrack), DE
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                CALL @DiskUtility.Menu.EnterMenu
                EI
                PUSH AF
                CALL Game.Trade.TradeBeepAndPause.Entry
                POP AF
                JP Game.Trade.ClearPressedKeyBits.Entry

                ; сохранённый шлюз TR-DOS, извлечение пары параметров из адреса возврата
CallDosInline:  EX (SP), HL
                LD C, (HL)
                INC HL
                LD D, (HL)
                INC HL
                EX (SP), HL
                PUSH HL
                LD HL, DosInlineCall
                LD B, #01
                JR EnterDiskRom

ZeroTrackRead:  LD HL, #0000
ReadTrackBytes: LD DE, #0000
                LD C, #7F
                PUSH HL
                LD HL, DosReadTrack
EnterDiskRom:   DI
                EX (SP), HL
                JP Rom.CallDosStack

                ; проверка исходного конца фрагмента
                ASSERT $ == #D975
                endmodule
                endmodule
