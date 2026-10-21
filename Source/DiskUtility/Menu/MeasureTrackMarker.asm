; -----------------------------------------
; измерение положения пары #A1 после чтения дорожки
; исходный диапазон #C92A..#C958
; In:
;   контроллер, выбранная дорожка
;   DiskUtility.Menu.ReadTrackBuffer, адрес приёмного буфера, исходно (Memory.Screen + #0120)
;   обработчик прерываний нужен для 13 HALT
; Out:
;   DE, одинаковые старший и младший байты от (BC поиска << 6)
;   BC, остаток счётчика обратного поиска
;   AF, Z=0 после INC L
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Последовательно выдаёт команды #C4 чтения адреса и #E4 чтения дорожки.
;   Перед приёмом потока ждёт 13 прерываний, затем Game.Disk.LoadDiskMenuOverlay.ReadTrackBytes вновь запрещает их.
;   CPDR начинается с BC=0, поэтому выполняет до 65536 сравнений до первого #A1.
;   Следующий CP (HL) требует ещё один #A1 непосредственно перед найденным.
;   При несовпадении поиск продолжается с оставшимся BC без отдельного предела.
;   Шесть ADD HL,HL оставляют в младшем байте 0/#40/#80/#C0, INC L никогда не даёт ноль.
;   LD L,H дублирует старший байт, EX DE,HL выдаёт итог в DE.
; -----------------------------------------
                ; запрос адреса сектора и всего потока дорожки
ReadTrackMark:  CALL @Game.Disk.LoadDiskMenuOverlay.CallDosInline               ; передача встроенной пары порт/значение через шлюз ПЗУ TR-DOS
                DB #1F, #C4                                                     ; порт и значение для ПЗУ, адрес возврата пропускает оба байта
                CALL @Game.Disk.LoadDiskMenuOverlay.ZeroTrackRead               ; обработчик ПЗУ TR-DOS с начальным адресом HL=0
                CALL @Game.Disk.LoadDiskMenuOverlay.CallDosInline               ; передача встроенной пары порт/значение через шлюз ПЗУ TR-DOS
                DB #1F, #E4                                                     ; порт и значение для ПЗУ, адрес возврата пропускает оба байта
                LD B, #0D
WaitRotation:   EI
                HALT
                DJNZ WaitRotation

                LD HL, (ReadTrackBuffer)
                CALL @Game.Disk.LoadDiskMenuOverlay.ReadTrackBytes              ; приём потока контроллера через ПЗУ TR-DOS
                LD BC, #0000
                LD A, #A1
FindSyncPair:   CPDR
                CP (HL)
                JR NZ, FindSyncPair                                             ; переход, если байт перед найденным #A1 отличается от #A1 и поиск пары продолжается

                LD H, B
                LD L, C
                ADD HL, HL
                ADD HL, HL
                ADD HL, HL
                ADD HL, HL
                ADD HL, HL
                ADD HL, HL
                INC L
                LD L, H
                EX DE, HL
                RET
