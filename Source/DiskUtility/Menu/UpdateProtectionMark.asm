; -----------------------------------------
; обновление служебной отметки после проверки и форматирования дорожки
; исходный диапазон #C975..#C9D7
; In:
;   #6075, разрешающий ненулевой параметр
;   #E07B, накопитель отметки
;   #E07E, счётчик неудачных проверок
; Out:
;   при успешной записи #E07B..#E07E=0, #E07F=#FF
;   на диске обновлён сектор 1 логической дорожки #0D
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
;   Ошибка VerifyMark вызывает MenuBeep, обновление всё же разрешается на каждой восьмой ошибке.
;   Нулевое слово #6075 отменяет работу до записи диска.
;   Сумма #E07B и результата VerifyMark сохраняется, младшие 15 бит и следующее число образуют проверочную пару.
;   В #607D..#616E копируются 242 байта ПЗУ #0000..#00F1, это не заполнение нулями.
;   Выбирается дорожка #0D, в идентификатор форматируемой дорожки передаётся 6.
;   Измерение помещается в #6073, сохранённая ветвь JR Z после ReadTrackMark не срабатывает при её штатном завершении.
;   XorMark шифрует сектор, POP AF извлекает старший байт измерения и оставляет его открытым в #6161.
;   Прямой вызывающий переход этого входа в проверенном коде не обнаружен.
; -----------------------------------------
RefreshMark:    CALL VerifyMark
                JR NC, RewriteMark                                              ; переход, если VerifyMark подтвердил маркер и счётчик неудач не требуется

                CALL MenuBeep
                LD HL, MarkFailures
                INC (HL)
                LD A, (HL)
                CP #08
                RET NZ                                                          ; выход, если счётчик неудачных проверок ещё не достиг 8

                LD (HL), #00
                ; проверка разрешения и расчёт новой пары контрольных слов
RewriteMark:    LD HL, (DiskMark.Counters)
                LD A, H
                OR L
                RET Z                                                           ; выход, если слово #6075 равно нулю и обновление запрещено

                LD HL, (LaunchCount)
                ADD HL, DE
                LD (LaunchCount), HL
                RES MARK_TOP_BIT, H
                LD (DiskMark.Value), HL
                INC HL
                LD (DiskMark.NextValue), HL
                LD HL, ROM_SEED_BASE                                            ; источник LDIR, первые #F2 байта ПЗУ
                LD DE, DiskMark.Payload
                LD BC, #00F2
                LDIR
                LD A, #0D
                CALL SetTrackSide
                LD A, #06
                AND A
                CALL FormatTrack
                CALL ReadTrackMark
                LD (DiskMark.TimingKey), DE
                LD DE, #0000
                JR Z, RewriteMark                                               ; переход, если ReadTrackMark вернул Z=1, для текущей реализации этот исход не возникает

                LD DE, (DiskMark.TimingKey)
                PUSH DE
                CALL XorMark
                POP AF
                LD (DiskMark.OpenKey), A
                CALL WriteWork
                DB #01                                                          ; номер сектора после CALL, SectorTransfer изменяет адрес возврата
                LD HL, #0000
                LD (LaunchCount), HL
                JP AcceptMark
