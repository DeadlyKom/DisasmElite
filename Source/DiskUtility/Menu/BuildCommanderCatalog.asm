; -----------------------------------------
; чтение каталога, отбор командиров и построение списка меню
; исходный диапазон #CA5F..#CB1D
; In:
;   диск, каталог на дорожке 0
;   SaveSelection и SavePageStart, выбранный номер и начало страницы
; Out:
;   каталог подходящих сохранений уплотнён с DiskBuffer.Catalog
;   управление продолжается в MenuInput
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   IX после выбора записи указывает FTrDosEntry в DiskBuffer.Catalog
;   SP входа сохраняется в операнде CheckSpaceExit, 32 исходных NOP сохраняются.
;   До восьми секторов читаются в DiskBuffer.Catalog, первый нулевой байт имени завершает чтение.
;   При отборе требуются расширение C, длина #0066 и ровно один сектор.
;   Проверка числа секторов выполнена DEC (IX + FTrDosEntry.SectorCount), она изменяет копию каталога в памяти.
;   Подходящие 16-байтовые записи копируются вплотную, затем дописывается 17 нулевых байтов.
;   Количество записей получается из разности адресов, умноженной на 16, старший байт равен числу записей.
;   Недопустимый выбранный индекс сбрасывает выбор и начало страницы в ноль.
;   Атрибуты от ListAttributes до ListAttributes + #01DF заполняются цветами 5/7, крайние столбцы 0 и 31 пропускаются.
;   После вывода заголовка и имён нет RET, следующий физический фрагмент является MenuInput.
; -----------------------------------------
                ; сохранение стека для выхода по SPACE
BuildSaveList:  LD (RestoreStack+1), SP
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
                XOR A
                CALL SetTrackSide
                LD HL, DiskBuffer.Catalog
                PUSH HL
                LD C, #08
                ; расчёт номера следующего каталожного сектора
ReadCatalog:    PUSH BC
                LD A, #09
                SUB C
                LD (CatalogSector), A
                CALL ReadSector
CatalogSector   DB #01                                                          ; номер читаемого сектора каталога, изменяет ReadCatalog
                POP BC
                LD DE, #0010
                LD B, E
ScanRecordEnd:  LD A, (HL)
                AND A
                JR Z, FilterSetup                                               ; переход, если найден нулевой первый байт имени и дальнейшие секторы каталога не требуются

                ADD HL, DE
                DJNZ ScanRecordEnd

                DEC C
                JR NZ, ReadCatalog                                              ; переход, если ещё не просмотрены все восемь секторов каталога

                ; очистка рабочей области перед уплотнением списка
FilterSetup:    LD BC, #0EDF
                CALL ClearWorkArea
                POP DE
                PUSH DE
                POP HL
                ; проверка расширения, длины и выделенного числа секторов
FilterRecord:   LD C, #10
                LD A, (HL)
                AND A
                JR Z, FinishList                                                ; переход, если достигнута нулевая запись и отбор сохранений закончен

                PUSH HL
                POP IX
                LD A, (IX + FTrDosEntry.Extension)
                CP #43
                JR NZ, NextRecord                                               ; переход, если расширение записи отличается от C

                LD A, (IX + FTrDosEntry.LengthLow)
                XOR #66
                JR NZ, NextRecord                                               ; переход, если младший байт длины отличается от #66

                XOR (IX + FTrDosEntry.LengthHigh)
                JR NZ, NextRecord                                               ; переход, если старший байт длины ненулевой

                DEC (IX + FTrDosEntry.SectorCount)                              ; проверка единственного сектора, изменяется только копия каталога
                JR NZ, NextRecord                                               ; переход, если исходное число секторов отличается от одного

                LDIR
NextRecord:     ADD HL, BC
                JR FilterRecord

                ; создание нулевого окончания и расчёт количества выбранных записей
FinishList:     PUSH DE
                LD HL, DiskBuffer.Blank
                INC C
                LDIR
                POP HL
                LD DE, DiskBuffer.Catalog
                AND A
                SBC HL, DE
                ADD HL, HL
                ADD HL, HL
                ADD HL, HL
                ADD HL, HL
                LD C, H
                LD HL, SaveSelection
                LD A, (HL)
                CP C
                JR C, DrawFrame                                                 ; переход, если выбранный индекс меньше количества сохранений и его можно сохранить

                LD (HL), B
                INC HL
                LD (HL), B
                ; заполнение внутренних атрибутных столбцов рамки
DrawFrame:      LD HL, ListAttributes
                LD BC, #5205
FrameCell:      LD A, L
                AND #1F
                JR Z, NextFrameCell                                             ; переход, если текущий столбец равен 0 и крайняя атрибутная ячейка пропускается

                XOR #1F
                JR Z, NextFrameCell                                             ; переход, если текущий столбец равен 31 и крайняя атрибутная ячейка пропускается

                LD (HL), C
NextFrameCell:  INC HL
                DJNZ FrameCell

                LD BC, #0107
                LD A, H
                CP #5A
                JR C, FrameCell                                                 ; переход, если адрес атрибутов ещё не достиг ListAttributes + 15 * 32

                LD HL, #0100
                LD (TextPosition), HL
                LD HL, MenuText
                CALL @Game.Text.PrintDescriptionString.Entry                    ; вывод строки HL до нулевого байта штатным обработчиком игры
                EI
                CALL DrawSaveNames
                ; JP MenuInput, продолжение в DispatchMenuCommand.asm
