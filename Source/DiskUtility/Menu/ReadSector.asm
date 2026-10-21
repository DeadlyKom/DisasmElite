; -----------------------------------------
; выбор команды чтения сектора и обработчика входного потока
; исходный диапазон #C8AE..#C8B5
; In:
;   HL, адрес 256-байтового буфера
;   поток после CALL, номер сектора
; Out:
;   HL, исходный адрес буфера
;   DE, исходный адрес буфера
;   AF, Z=1 при полном обмене
; Corrupt:
;   DE, BC, AF
; Note:
;   DiskUtility.Menu.TransferCmd получает команду #84, DiskUtility.Menu.TransferCall получает адрес входного потока Game.Disk.LoadDiskMenuOverlay.ReadTrackBytes.
;   После подготовки DE код непосредственно продолжается в SectorTransfer.
; -----------------------------------------
ReadSector:     LD A, #84
                LD (TransferCmd), A
                LD DE, Game.Disk.LoadDiskMenuOverlay.ReadTrackBytes
                ; JP SectorTransfer, продолжение в TransferSector.asm
