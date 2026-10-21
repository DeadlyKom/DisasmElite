                ifndef _LOADER_LOAD_
                define _LOADER_LOAD_
; -----------------------------------------
; поиск ELITE3.C, загрузка рабочих областей 48 КБ снимка и запуск игры
; In:
;   системная область BASIC и TR-DOS, доступ к диску
; Out:
;   при отсутствии файла возврат в BASIC, при успехе переход к Loader.GAME_START
; Corrupt:
;   HL, DE, BC, AF, AF'
;   SP, I, режим прерываний и память снимка
; Note:
;   #5C00..#5FFF сначала читаются в Loader.SYS_COPY, чтобы не разрушить TR-DOS
;   область #C800..#CFFF исходного снимка целиком не загружается
;   #C800..#C909 заняты этим загрузчиком, #CC00..#CFFF служат обменным блоком
;   исходное XOR-преобразование снимка сохранено в процедуре MutateMemory
;   ранний возврат при ненайденном файле выполняется после DI, этот путь сам не включает прерывания
;   перед запуском обе сохранённые OUT (#0F),A в хвосте печати заменяются парами NOP
; -----------------------------------------
Load:           ; подготовка имени и типа для поиска записи каталога
                LD HL, FileName
                LD DE, TRDOS_NAME
                LD BC, #0009
                LDIR
                ; поиск ELITE3.C через диспетчер TR-DOS
                LD C, #0A
                CALL TRDOS_ENTRY
                DI
                LD A, C
                ; проверка признака отсутствия файла, найденный индекс меньше 128
                BIT DOS_FAIL_BIT, A
                RET NZ                                                          ; выход, если TR-DOS не нашёл файл

                LD SP, SYS_COPY
                ; чтение дескриптора найденного файла по индексу в A
                LD C, #08
                CALL TRDOS_ENTRY
                XOR A
                OUT (#FE), A

                ; чтение первых 28 секторов снимка в #4000..#5BFF
                LD HL, Memory.Screen
                LD DE, (TRDOS_FIRST)
                LD BC, #1C05
                CALL TRDOS_ENTRY

                ; расчёт позиции 28-го сектора файла с переносом номера дорожки
                LD HL, SYS_COPY
                LD DE, (TRDOS_FIRST)
                LD A, E
                INC D
                ADD A, #0C
                LD E, A
                ; проверка переноса за пределы 16 секторов дорожки
                AND DOS_WRAP_MASK
                JR Z, .Sector                                                   ; переход, если дополнительного переноса дорожки нет

                INC D
.Sector         LD A, E
                AND DOS_SEC_MASK
                LD E, A
                ; чтение четырёх секторов #5C00..#5FFF во временную область Loader.SYS_COPY
                LD BC, #0405
                CALL TRDOS_ENTRY

                ; чтение 104 секторов снимка в #6000..#C7FF
                LD HL, SNAP_MIDDLE
                LD DE, (TRDOS_FIRST)
                INC D
                INC D
                LD BC, #6805
                CALL TRDOS_ENTRY

                ; расчёт дискового адреса блока Loader.SNAP_HIGH, девять дорожек от начала
                LD HL, (TRDOS_FIRST)
                LD DE, #0900
                ADD HL, DE
                EX DE, HL
                ; чтение последних 48 секторов снимка в #D000..#FFFF
                LD HL, SNAP_HIGH
                LD BC, #3005
                CALL TRDOS_ENTRY
                DI

                ; сохранение позиции TR-DOS и обмен системной области со снимком
                CALL SaveState
                ; восстановление байтов снимка исходным XOR-преобразованием
                CALL MutateMemory
                ; восстановление действующей системной области BASIC и TR-DOS
                CALL ExchangeState

                ; установка RAMTOP и указателей рабочей области BASIC
                LD HL, RAM_LIMIT
                LD (SYS_RAMTOP), HL
                LD HL, BASIC_WORK
                LD (SYS_WORKSP), HL
                LD HL, BASIC_STACK
                LD (SYS_STKBOT), HL
                LD (SYS_STKEND), HL
                DI
                ; замена #5C00..#5FFF копией снимка, включая изменённые байты
                LD HL, SYS_COPY
                LD DE, SYS_BASE
                LD BC, SYS_SIZE
                LDIR

                ; отключение двух OUT (#0F),A в хвосте печати Game.Extensions.UpdateStationAndFinishGlyph.FinishGlyph заменой команд на NOP/NOP
                LD HL, #0000
                LD (Game.Extensions.UpdateStationAndFinishGlyph.AuxPortFirst), HL
                LD (Game.Extensions.UpdateStationAndFinishGlyph.AuxPortNext), HL
                ; обнуление исходного слова состояния игры по адресу SaveSelection
                LD HL, #0000
                LD (SaveSelection), HL

                ; восстановление старшего байта таблицы векторов и режима IM 2
                LD A, #FD
                LD I, A
                IM 2
                ; очистка первых 32 атрибутов, одной верхней символьной строки
                LD HL, Memory.Attributes
                LD BC, #2000
.Attributes     LD (HL), C
                INC HL
                DJNZ .Attributes

                LD SP, START_STACK
                ; обнуление двух исходных байтов экрана и установка чёрного бордюра
                XOR A
                LD (Memory.Screen), A
                LD (Memory.Screen + #0020), A
                OUT (#FE), A
                EI
                JP GAME_START

                endif                                                           ; ~_LOADER_LOAD_
