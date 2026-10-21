; -----------------------------------------
; выбор цилиндра и стороны Beta Disk по логическому номеру дорожки
; исходный диапазон #C87D..#C89D
; In:
;   AF, A содержит логическую дорожку
; Out:
;   выбрана сторона A&1 и цилиндр A>>1
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   RRA после AND A делит номер на два, перенос сохраняет младший бит стороны.
;   Патчи Cylinder и SideValue задают параметр порта #7F и значение #3C/#2C для порта #FF.
;   Команда #18 в порту #1F запускает поиск дорожки, Game.Disk.LoadDiskMenuOverlay.ZeroTrackRead завершает обмен через ПЗУ.
;   Game.Disk.LoadDiskMenuOverlay.CallDosInline и Game.Disk.LoadDiskMenuOverlay.ZeroTrackRead используют шлюз DiskUtility.DosGateway, сохранность дополнительных регистров зависит от ПЗУ TR-DOS.
;   Вспомогательные вызовы запрещают прерывания, процедура сама EI не выполняет.
; -----------------------------------------
SetTrackSide:   AND A
                RRA
                LD (Cylinder), A
                LD A, #3C
                JR NC, ApplySide                                                ; переход, если младший бит логической дорожки нулевой и выбирается значение порта #FF, равное #3C

                LD A, #2C
ApplySide:      LD (SideValue), A
                CALL @Game.Disk.LoadDiskMenuOverlay.CallDosInline               ; передача встроенной пары порт/значение через шлюз ПЗУ TR-DOS
                DB #FF                                                          ; системный порт Beta Disk
SideValue       DB #3C                                                          ; значение выбора стороны, изменяет SetTrackSide
                CALL @Game.Disk.LoadDiskMenuOverlay.CallDosInline               ; передача встроенной пары порт/значение через шлюз ПЗУ TR-DOS
                DB #7F                                                          ; порт данных команды поиска дорожки
Cylinder        DB #00                                                          ; номер цилиндра, логическая дорожка делённая на два
                CALL @Game.Disk.LoadDiskMenuOverlay.CallDosInline               ; передача встроенной пары порт/значение через шлюз ПЗУ TR-DOS
                DB #1F, #18                                                     ; порт и значение для ПЗУ, адрес возврата пропускает оба байта
                CALL @Game.Disk.LoadDiskMenuOverlay.ZeroTrackRead               ; обработчик ПЗУ TR-DOS с начальным адресом HL=0
                RET
