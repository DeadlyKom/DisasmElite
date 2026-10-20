                module Disk
                module TransferDiskSectors
; -----------------------------------------
; Посекторное чтение или запись через внутренние процедуры TR-DOS
; исходный диапазон #D9C1..#DA13
; In:
;   HL = буфер, DE, D = дорожка, E = сектор 0..15, BC, B = число секторов
; Out:
;   DE = позиция после последнего сектора, H увеличен на число секторов
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   D9C1 выбирает чтение IX=2F1B, D9C7 выбирает запись IX=2D73, выбранный адрес сохраняется в
;   операнд D9E5, при E=16 сектор обнуляется и дорожка увеличивается, вызывающий отключает
;   прерывания
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D9C1
                ; выбор внутреннего обработчика чтения TR-DOS, запись имеет отдельный вход D9C7
Entry:          LD IX, DosReadSector
                JR PrepareSector

                ; вход записи секторов, IX выбирает внутреннюю процедуру TR-DOS #2D73
Write:          LD IX, DosWriteSector
                ; передача очередного сектора и продвижение адреса буфера на 256 байтов
PrepareSector:  LD (DiskSavedIX), IX
                LD IX, DosDriveInit
                CALL Game.Disk.CallDosWithDriveParameter.Entry
                LD IX, DosPrepareIO
                CALL Game.Disk.CallDosInternal.Entry
                INC B
                PUSH BC
                JR SelectTrack

TransferSector: PUSH BC
                PUSH DE
SavedIX         EQU $ + 2                                                       ; сохранённый IX в операнде LD IX после TR-DOS
                LD IX, #0000
                CALL Game.Disk.CallDosInternal.Entry
                POP DE
                INC H
                INC E
                BIT 4, E
                JR Z, NextSector                                                ; переход, если после увеличения номер сектора не достиг 16, следующая дорожка не нужна

                LD E, #00
                INC D
SelectTrack:    LD C, D
                LD IX, DosBaseSide
                CALL Game.Disk.CallDosWithDriveParameter.Entry
                LD A, (DriveFlags)
                AND #02
                LD IX, DosAltSide
                CALL NZ, Game.Disk.ConvertTrackForDrive.Entry                   ; вызов, если в параметре устройства установлен бит 1, преобразовать номер дорожки
                LD A, C
                LD IX, DosSeekTrack
                CALL Game.Disk.CallDosInternal.Entry
NextSector:     POP BC
                DJNZ TransferSector

                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #DA14
                endmodule
                endmodule
