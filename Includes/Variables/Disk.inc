; -----------------------------------------
; исходные буферы дискового оверлея, память повторно используется между режимами
; каталог и форматируемая дорожка находятся в экранной области
; Work совпадает с игровым пулом объектов, EnterMenu очищает его после возврата
; -----------------------------------------
DiskBuffer      EQU Memory.Objects                                              ; общий секторный буфер, #606F
.Work           EQU DiskBuffer                                                  ; буфер чтения и записи 256 байтов
.Catalog        EQU Memory.Screen + #1000                                       ; восемь секторов каталога, #5000..#57FF
.Blank          EQU Memory.Screen + #0800                                       ; источник нулей после очистки, #4800
.SavedSP        EQU #FFFE                                                       ; сохранённый SP на время форматирования
.ScreenBackup   EQU DiskBuffer.SavedSP - #20                                    ; 32 сохранённых байта экрана, #FFDE..#FFFD
.TimingTrack    EQU DiskBuffer + #91                                            ; выбранная дорожка проверки, #6100
DiskService     EQU DiskBuffer.Work                                             ; представление служебного сектора 9
.FreeSector     EQU DiskService + FTrDosService.FreeSector                      ; сектор и следующая за ним дорожка свободного места
.FreeTrack      EQU DiskService + FTrDosService.FreeTrack                       ; дорожка следующего свободного сектора
.FileCount      EQU DiskService + FTrDosService.FileCount                       ; число каталожных записей
.FreeCount      EQU DiskService + FTrDosService.FreeCount                       ; число свободных секторов
DiskMark        EQU DiskBuffer.Work                                             ; представление защитного сектора
.Value          EQU DiskMark + FDiskMark.Value                                  ; подтверждаемый счётчик
.NextValue      EQU DiskMark + FDiskMark.NextValue                              ; контрольное следующее слово
.TimingKey      EQU DiskMark + FDiskMark.TimingKey                              ; измерение и ключ XOR
.Counters       EQU DiskMark + FDiskMark.Counters                               ; три слова для вывода
.Suffix         EQU DiskMark + FDiskMark.Suffix                                 ; дополнительное слово вывода
.Payload        EQU DiskMark + FDiskMark.Payload                                ; копируемые байты ПЗУ
.OpenKey        EQU DiskMark + FDiskMark.OpenKey                                ; открытый байт ключа
.ByteSuffix     EQU DiskMark.Value + 1                                          ; старший байт счётчика, выводится после двоеточия

; исходная экранная область потоков контроллера
DiskStream      EQU Memory.Screen + #0120                                       ; начало очистки и приёма дорожки, #4120
.Format         EQU DiskStream - #010C                                          ; начало потока форматирования и временный SP, #4014
.SaveEnd        EQU DiskStream - 1                                              ; последний из 32 сохраняемых байтов #4100..#411F
.AbortSP        EQU DiskStream - 6                                              ; начальное значение восстанавливаемого SP, #411A

; первые девять байтов буфера ввода используются как имя и расширение TR-DOS
SaveName        EQU GalaxyState.InputBuffer                                     ; буфер имени сохранения, восемь символов
.Extension      EQU SaveName + FTrDosEntry.Extension                            ; расширение C непосредственно после восьми символов
