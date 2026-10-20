; -----------------------------------------
; поиск совпадающего сохранения либо подготовка создания новой записи
; исходный диапазон #CCC0..#CD21
; In:
;   BC, C содержит заполнитель пустого имени, #20 либо 0
;   #DED0..#DED8, имя и расширение
; Out:
;   существующая запись перезаписана либо переход AllocateSave
;   после записи общий выход #CC65 обновляет резерв командира
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   IX после выбора записи указывает FTrDosEntry в DiskBuffer.Catalog
;   Восемь байтов имени сначала сравниваются с C, полное совпадение означает пустой ввод.
;   Пустой ввод выбирает существующую запись либо CopyPilotName при пустом каталоге.
;   Для непустого ввода восемь байтов копируются в #D054, завершающие пробелы заменяются нулями.
;   Поиск в каталоге сравнивает ровно восемь байтов имени, первый нулевой байт входного имени отвергает совпадение.
;   Общий вход #CCD4 выбирает дорожку IX+15 и сектор IX+14 плюс один.
;   WriteSector записывает полный 256-байтовый сектор начиная с #D054, логическая длина файла остаётся 102.
;   После записи XOR A передаёт A=0/Z=1 в общий хвост, INC B там меняет флаги.
; -----------------------------------------
SaveCommander:  LD HL, SaveName
                LD B, #08
CheckEmptyName: LD A, (HL)
                INC HL
                CP C
                JR NZ, ApplyNewName                                             ; переход, если найден байт имени, отличающийся от заполнителя C

                DJNZ CheckEmptyName

                CALL GetSelected
                JR Z, CopyPilotName                                             ; переход, если при пустом вводе выбранная каталожная запись отсутствует и требуется текущее имя

                PUSH HL
                POP IX
                ; выбор физического сектора существующего сохранения
OverwriteSave:  LD A, (IX + FTrDosEntry.FirstTrack)
                CALL SetTrackSide
                LD A, (IX + FTrDosEntry.FirstSector)
                INC A
                LD (SaveSector), A
                LD HL, State.Name
                CALL WriteSector
SaveSector      DB #21                                                          ; номер записываемого сектора, изменяет OverwriteSave
                XOR A
                JP BackupPilot

                ; обновление имени активного командира и поиск записи с тем же именем
ApplyNewName:   LD HL, SaveName
                LD DE, State.Name
                LD BC, #0008
                LDIR
                EX DE, HL
TrimCommander:  LD (HL), B
                DEC HL
                LD A, (HL)
                CP #20
                JR Z, TrimCommander                                             ; переход, если при удалении окончания найден очередной пробел

                LD HL, DiskBuffer.Catalog
FindSameName:   LD A, (HL)
                AND A
                JR Z, AllocateSave                                              ; переход, если достигнут конец каталога и требуется создать новую запись

                PUSH HL
                LD DE, SaveName
                LD B, #08
CompareName:    LD A, (DE)
                INC DE
                AND A
                JR Z, NextSavedName                                             ; переход, если во входном имени встретился ноль и полное восьмибайтовое совпадение отвергается

                CP (HL)
                INC HL
                JR NZ, NextSavedName                                            ; переход, если очередной байт каталожного имени отличается от введённого

                DJNZ CompareName

                POP IX
                JR OverwriteSave

                ; переход к следующей шестнадцатибайтовой записи
NextSavedName:  POP HL
                LD DE, #0010
                ADD HL, DE
                JR FindSameName
