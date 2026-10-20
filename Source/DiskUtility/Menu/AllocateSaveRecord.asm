; -----------------------------------------
; выделение одного сектора и создание TR-DOS-записи нового командира
; исходный диапазон #CD22..#CD8D
; In:
;   #DED0..#DED8, имя и расширение
;   служебный сектор 9 дорожки 0
; Out:
;   служебный сектор и каталог обновлены
;   переход #CCD4 записывает данные командира
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   #6154/#6155 содержат свободное число секторов, уменьшение с установленным старшим битом отвергается.
;   #6153 содержит число файлов, увеличенное значение с битом 7 также отвергается.
;   #6150/#6151 задают свободные сектор/дорожку, номер сектора хранится от 0 до 15.
;   Переход с сектора 15 обнуляет младший байт и увеличивает дорожку.
;   Сначала записывается служебный сектор, затем сектор каталога, затем данные командира.
;   Отката уже записанного служебного сектора при последующих ошибках в этом коде нет.
;   Каталожный сектор равен 1+(старое число файлов>>4), смещение равно 16*(число&15).
;   К имени и расширению добавляются шаблон #C854 и сохранённая пара сектор/дорожка.
; -----------------------------------------
                ; чтение свободного места и проверка возможности выделить новую запись
AllocateSave:   XOR A
                CALL SetTrackSide
                CALL ReadWork
                DB #09                                                          ; номер сектора после CALL, SectorTransfer изменяет адрес возврата
                LD HL, (DiskService.FreeCount)
                DEC HL
                BIT DOS_SIGN_BIT, H
                JR NZ, ShowNoSpace                                              ; переход, если после уменьшения свободного числа секторов установлен старший бит

                LD (DiskService.FreeCount), HL
                LD HL, DiskService.FileCount
                INC (HL)
                BIT DOS_FULL_BIT, (HL)
                JR NZ, ShowNoSpace                                              ; переход, если увеличенное число файлов достигло 128

                LD HL, (DiskService.FreeSector)
                LD E, L
                LD D, H
                INC L
                LD A, L
                XOR DOS_TRACK_SIZE
                JR NZ, CommitFreeSlot                                           ; переход, если увеличенный номер свободного сектора ещё не равен 16

                LD L, A
                INC H
                ; сохранение следующего свободного адреса и выбор сектора каталога
CommitFreeSlot: LD (DiskService.FreeSector), HL
                PUSH DE
                CALL WriteWork
                DB #09                                                          ; номер сектора после CALL, SectorTransfer изменяет адрес возврата
                LD A, (DiskService.FileCount)
                DEC A
                RRCA
                RRCA
                RRCA
                RRCA
                PUSH AF
                AND DOS_CAT_MASK
                INC A
                LD (ReadCatalogID), A
                LD (WriteCatalogID), A
                CALL ReadWork
ReadCatalogID   DB #57                                                          ; номер сектора каталога для новой записи
                POP AF
                AND DOS_SLOT_MASK
                LD E, A
                LD D, #00
                ADD HL, DE
                PUSH HL
                POP IX
                EX DE, HL
                LD HL, SaveName
                LD BC, #0009
                LDIR
                LD HL, SaveFormat
                LD C, #05
                LDIR
                EX DE, HL
                POP DE
                LD (HL), E
                INC HL
                LD (HL), D
                CALL WriteWork
WriteCatalogID  DB #CD                                                          ; номер изменённого сектора каталога
                JP OverwriteSave
