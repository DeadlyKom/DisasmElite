                module Disk
                module BlackAttributesAndOverlayState
; -----------------------------------------
; Гашение 768 атрибутов экрана и состояние загрузки оверлеев
; исходный диапазон #D975..#D9C0
; In:
;   Нет параметров
; Out:
;   HL=Memory.CockpitAttrs, BC=0, все 768 байтов Memory.Attributes равны 0
; Corrupt:
;   HL, BC, AF
; Note:
;   OverlayTrack/DemoTrack хранят позиции дисковых оверлеев, Game.Disk.BlackAttributesAndOverlayState.LoadDemo отдельно читает сектор робота в DiskBuffer.Work,
;   восемь секторов оверлея в DiskUtility.DemoSetup.EnterInstaller, копирует 102 байта робота в State и передаёт управление DiskUtility.DemoSetup.EnterInstaller,
;   DriveFlags/DiskParameter параметры дискового устройства
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D975
                ; очистка всех 768 атрибутов, по 256 байтов в каждой из трёх страниц
Entry:          LD HL, Memory.Attributes                                        ; начало всех 768 атрибутов Spectrum
                LD BC, #0300
ClearAttribute: LD (HL), C
                INC L
                JR NZ, ClearAttribute                                           ; переход, если ещё не пройдены 256 атрибутов текущей страницы

                INC H
                DJNZ ClearAttribute

                RET

                ; начальные сектор и дорожка оверлея cl.C
OverlayTrack    DW #1904                                                        ; сектор и дорожка дискового оверлея cl.C
                ; сектор и дорожка загрузки демо и его командира
DemoTrack       DW #0000                                                        ; сектор и дорожка файла демонстрации
                ; сохранённая нулевая область дискового состояния перед загрузчиком демо
                DB #00, #00, #00, #00, #00, #00, #00, #00                       ; #D987..#D98E
                DB #00, #00, #00, #00, #00, #00, #00, #00                       ; #D98F..#D996
                DB #00, #00, #00, #00                                           ; #D997..#D99A
                ; загрузка демо, один сектор командира и восемь секторов кода по DiskUtility.DemoSetup.EnterInstaller
LoadDemo:       DI
                LD DE, (DemoTrack)
                LD HL, Memory.Objects
                LD B, #01
                CALL Game.Disk.TransferDiskSectors.Entry
                LD HL, Memory.Frame + #0800                                     ; область загрузки дискового оверлея внутри кадрового буфера
                LD B, #08
                CALL Game.Disk.TransferDiskSectors.Entry
                LD HL, Memory.Objects
                LD DE, State.Name
                LD BC, #0066
                LDIR
                EI
                JP @DiskUtility.DemoSetup.EnterInstaller

                ; параметры дискового устройства, bit1 включает преобразование дорожки
DriveFlags      DB #16                                                          ; параметр диска, бит 1 включает пересчёт дорожки и стороны
                ; байт параметра внутреннего вызова TR-DOS
DiskParameter   DB #3C                                                          ; параметр внутреннего вызова TR-DOS
                ; проверка исходного конца фрагмента
                ASSERT $ == #D9C1
                endmodule
                endmodule
