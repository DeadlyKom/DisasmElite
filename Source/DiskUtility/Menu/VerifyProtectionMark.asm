; -----------------------------------------
; проверка временного признака и двух контрольных слов защитного сектора
; исходный диапазон #C9D8..#CA2C
; In:
;   диск, логическая дорожка #0D, сектор 1
;   буфер #606F..#616E и таблица XorMark
; Out:
;   DE, слово #606F при успехе, 0 при двух неудачах
;   AF, C=0/Z=1 при успехе, C=1 при отказе
; Corrupt:
;   HL, DE, BC, AF, IY
; Note:
;   Две попытки начинаются с CheckSpaceExit, выбора дорожки и её измерения.
;   Открытый байт #6161 должен отличаться от измеренного D менее чем на 3.
;   Открытый байт копируется в оба регистра D/E и служит ключом XorMark.
;   Проверяются равенства word(#6071)=word(#606F)+1 и word(#6073)=ключ DE.
;   При отказе выдаётся команда #58 контроллера и производится следующая попытка.
;   После исчерпания попыток MenuBeep и SCF формируют отказ, успешный RET сохраняет C=0.
;   Для исходного ELITE3HL.TRD проверка всех 256 значений D измерителя завершилась C=1 и DE=0.
;   Реальный сектор после XorMark даёт слова #3A90/#F619, равенство первого плюс один второму нарушено.
; -----------------------------------------
                ; подготовка двух попыток проверки
VerifyMark:     LD B, #02
                ; чтение измерения и открытого ключа сектора
RetryMark:      PUSH BC
                CALL CheckSpaceExit
                LD A, #0D
                CALL SetTrackSide
                CALL ReadTrackMark
                PUSH DE
                CALL ReadWork
                DB #01                                                          ; номер сектора после CALL, SectorTransfer изменяет адрес возврата
                POP DE
                LD A, (DiskMark.OpenKey)
                LD E, A
                SUB D
                JR NC, CheckKeyDrift                                            ; переход, если открытый байт не меньше измеренного D и NEG не требуется

                NEG
CheckKeyDrift:  CP #03
                JR NC, Reposition                                               ; переход, если абсолютная разность измерения и открытого байта не меньше 3

                LD D, E
                PUSH DE
                CALL XorMark
                LD HL, (DiskMark.Value)
                LD DE, (DiskMark.NextValue)
                INC HL
                AND A
                SBC HL, DE
                POP DE
                POP BC
                JR NZ, RetryWords                                               ; переход, если второе контрольное слово не равно первому плюс один

                LD HL, (DiskMark.TimingKey)
                SBC HL, DE
                JR Z, ReturnMark                                                ; переход, если слово #6073 совпадает с двухбайтовым ключом и проверка завершена

RetryWords:     PUSH BC
                ; повтор после дополнительной команды позиционирования головки
Reposition:     CALL @Game.Disk.LoadDiskMenuOverlay.CallDosInline               ; передача встроенной пары порт/значение через шлюз ПЗУ TR-DOS
                DB #1F, #58                                                     ; порт и значение для ПЗУ, адрес возврата пропускает оба байта
                CALL @Game.Disk.LoadDiskMenuOverlay.ZeroTrackRead               ; обработчик ПЗУ TR-DOS с начальным адресом HL=0
                POP BC
                DJNZ RetryMark

                CALL MenuBeep
                SCF
                LD DE, #0000
                RET

                ; возврат подтверждённого контрольного значения
ReturnMark:     LD DE, (DiskMark.Value)
                RET
