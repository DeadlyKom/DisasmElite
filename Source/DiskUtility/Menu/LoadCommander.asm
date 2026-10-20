; -----------------------------------------
; загрузка выбранного командира и общий хвост обновления его резервной копии
; исходный диапазон #CC41..#CC71
; In:
;   #DA70, выбранная запись
;   каталог #5000, поля сектора и дорожки по смещениям 14/15
; Out:
;   после копирования HL=#D0BA, DE=#D298, BC=#0100
;   #D054..#D0B9 и резерв #D232..#D297 содержат 102 байта
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   IX после выбора записи указывает FTrDosEntry в DiskBuffer.Catalog
;   Пустая запись возвращает до чтения, но B уже равен 1 и сам по себе не доказывает успех.
;   #D9C1 читает один сектор по каталожному DE в #606F.
;   Первый LDIR переносит 102 байта в активного командира #D054.
;   Общий вход #CC65 копирует активного командира в резерв, затем INC B формирует B=1.
;   #CC65 используется также при завершении сохранения и отмене ввода имени.
; -----------------------------------------
LoadCommander:  CALL GetSelected
                PUSH HL
                POP IX
                LD E, (IX + FTrDosEntry.FirstSector)
                LD D, (IX + FTrDosEntry.FirstTrack)
                LD B, #01
                LD HL, DiskBuffer.Work
                JR Z, ReturnLoad                                                ; переход, если выбранная запись пуста и читать сектор не требуется

                DI
                CALL @Game.Disk.TransferDiskSectors.Entry                       ; чтение B секторов в HL по паре сектор/дорожка DE
                LD HL, DiskBuffer.Work
                NOP
                NOP
                LD DE, State.Name
                LD BC, #0066
                LDIR
BackupPilot:    LD HL, State.Name
                LD DE, Game.Missions.RatingBountyDamageAndNewCommander.NewCommander
                LD BC, #0066
                LDIR
                INC B
ReturnLoad:     RET
