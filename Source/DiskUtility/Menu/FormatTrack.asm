; -----------------------------------------
; форматирование потока дорожки с временным переносом стека и проверкой чтения
; исходный диапазон #CD9F..#CDEE
; In:
;   AF, A содержит байт дорожки для идентификаторов секторов
;   DiskUtility.Menu.TrackBuffer, адрес потока, исходно DiskStream.Format
;   контроллер, заранее выбранная дорожка
; Out:
;   SP и 32 байта экрана от DiskStream - 32 до DiskStream.SaveEnd восстановлены
;   прерывания запрещены
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   SP сохраняется в DiskBuffer.SavedSP
;   32 байта экрана от DiskStream - 32 до DiskStream.SaveEnd копируются в DiskBuffer.ScreenBackup
;   Временный SP=DiskStream.Format находится у начала потока, A записывается в шаблон идентификатора.
;   Исходные LD A,#10 и LD A,1 выбирают проверку сектора 1.
;   ConfirmCopy заменяет вторую команду по DiskUtility.Menu.VerifySector на ADC A,0, тогда выбор равен 16+входной перенос.
;   BuildTrackData создаёт поток, команда #F4 и WriteFdcStream отправляют его контроллеру.
;   Команда #84 читает выбранный сектор через Game.Disk.LoadDiskMenuOverlay.ZeroTrackRead с начальным HL=0.
;   Если конечный HL меньше #80, всё форматирование повторяется без ограничения попыток.
;   После успешной проверки фиксированная область и сохранённый SP возвращаются.
; -----------------------------------------
                ; сохранение стека и рабочей области перед записью дорожки
FormatTrack:    LD (DiskBuffer.SavedSP), SP
                LD HL, DiskStream.SaveEnd
                LD DE, DiskBuffer.ScreenBackup + #1F
                LD BC, #0020
                LDDR
                DI
                LD SP, DiskStream.Format
                LD (TrackID), A
                LD A, #10
VerifySector:   LD A, #01
                LD (VerifySectorID), A
                ; построение и передача потока с последующей проверкой сектора
RetryFormat:    CALL BuildTrackData
                CALL @Game.Disk.LoadDiskMenuOverlay.CallDosInline               ; передача встроенной пары порт/значение через шлюз ПЗУ TR-DOS
                DB #1F, #F4                                                     ; порт и значение для ПЗУ, адрес возврата пропускает оба байта
                LD HL, (TrackBuffer)
                CALL WriteFdcStream
                CALL @Game.Disk.LoadDiskMenuOverlay.CallDosInline               ; передача встроенной пары порт/значение через шлюз ПЗУ TR-DOS
                DB #5F                                                          ; порт номера проверочного сектора
VerifySectorID  DB #00                                                          ; номер сектора после форматирования
                CALL @Game.Disk.LoadDiskMenuOverlay.CallDosInline               ; передача встроенной пары порт/значение через шлюз ПЗУ TR-DOS
                DB #1F, #84                                                     ; порт и значение для ПЗУ, адрес возврата пропускает оба байта
                CALL @Game.Disk.LoadDiskMenuOverlay.ZeroTrackRead               ; обработчик ПЗУ TR-DOS с начальным адресом HL=0
                LD DE, #0080
                AND A
                SBC HL, DE
                JR C, RetryFormat                                               ; переход, если проверочное чтение продвинуло HL менее чем на 128 байтов

                LD HL, DiskBuffer.ScreenBackup + #1F
                LD DE, DiskStream.SaveEnd
                LD BC, #0020
                LDDR
                LD SP, (DiskBuffer.SavedSP)
                RET
