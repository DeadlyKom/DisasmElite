; -----------------------------------------
; загрузка выбранного командира и общий хвост обновления его резервной копии
; исходный диапазон #CC41..#CC71
; In:
;   SaveSelection, выбранная запись
;   каталог DiskBuffer.Catalog, поля FTrDosEntry.FirstSector и FTrDosEntry.FirstTrack
; Out:
;   после копирования HL=State + FCommander, DE=Game.Missions.RatingBountyDamageAndNewCommander.NewCommander + FCommander, BC=#0100
;   State и Game.Missions.RatingBountyDamageAndNewCommander.NewCommander содержат по FCommander
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   IX после выбора записи указывает FTrDosEntry в DiskBuffer.Catalog
;   Пустая запись возвращает до чтения, но B уже равен 1 и сам по себе не доказывает успех.
;   Game.Disk.TransferDiskSectors.Entry читает один сектор по каталожному DE в DiskBuffer.Work.
;   Первый LDIR переносит 102 байта в активного командира State.Name.
;   Общий вход DiskUtility.Menu.BackupPilot копирует активного командира в резерв, затем INC B формирует B=1.
;   DiskUtility.Menu.BackupPilot используется также при завершении сохранения и отмене ввода имени.
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
