                ifndef _LOADER_CONSTANTS_
                define _LOADER_CONSTANTS_

; исходные адреса и размеры, прочитанные из ELITE3.B
CODE_BASE       EQU #C800                                                       ; адрес копии загрузчика в памяти
CODE_SIZE       EQU #010A                                                       ; длина копируемого блока
TRDOS_ENTRY     EQU #3D13                                                       ; диспетчер команд TR-DOS
TRDOS_NAME      EQU #5CDD                                                       ; имя и тип файла в системной области
TRDOS_FIRST     EQU #5CEB                                                       ; первый сектор и дорожка найденного файла
TRDOS_CUR       EQU #5CF4                                                       ; текущая позиция дисковых операций
SYS_BASE        EQU #5C00                                                       ; начало обмениваемой системной области
SYS_COPY        EQU #CC00                                                       ; временное место для #5C00..#5FFF
SYS_SIZE        EQU #0400                                                       ; размер обмениваемой системной области
GAME_RANDOM     EQU #E063                                                       ; генератор из трёх слов в #DEC0..#DEC5
GAME_START      EQU #7394                                                       ; исходная точка запуска загруженной игры
GAME_RESTART    EQU #7ABF                                                       ; сброс стека и переход к Game.Flight.MainGameLoop.DrawObjects
GAME_DISKPOS    EQU #D983                                                       ; сохранённое слово из Loader.TRDOS_CUR


; системные переменные BASIC, исходное размещение ZX Spectrum
SYS_RAMTOP      EQU #5CB2                                                       ; верхняя граница памяти BASIC
SYS_WORKSP      EQU #5C61                                                       ; начало рабочей области BASIC
SYS_STKBOT      EQU #5C63                                                       ; начало стека калькулятора BASIC
SYS_STKEND      EQU #5C65                                                       ; конец стека калькулятора BASIC
BASIC_WORK      EQU #5D3E                                                       ; восстанавливаемое значение WORKSP
BASIC_STACK     EQU #5D48                                                       ; восстанавливаемое значение STKBOT и STKEND


; исходные указатели, размещение памяти не изменяется
SNAP_MIDDLE     EQU Game.Data.SystemBoundaryAndObjects.Continue                 ; начало загружаемого блока снимка #6000..#C7FF
SNAP_HIGH       EQU Game.Interface.MenuDispatchTable.Entry                      ; начало загружаемого блока снимка #D000..#FFFF
RAM_LIMIT       EQU SYS_BASE + SYS_SIZE - 1                                     ; восстанавливаемая верхняя граница памяти BASIC
START_STACK     EQU Memory.Screen + #0120                                       ; исходный стек перед передачей управления игре
MUTATE_BASE     EQU Memory.CockpitAttrs                                         ; нижняя граница выбираемых адресов XOR-преобразования

                endif                                                           ; ~_LOADER_CONSTANTS_
