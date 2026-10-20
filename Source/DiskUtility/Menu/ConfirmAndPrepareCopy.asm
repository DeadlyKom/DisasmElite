; -----------------------------------------
; подтверждение, чтение и преобразование трёх секторов перед переходом в #C500
; исходный диапазон #CF9C..#CFF5
; In:
;   DE, подтверждённый параметр копирования
;   диск, дорожка #0E и сектора 1..3
;   #BE00..#BEFF, таблица младших байтов квадратов
; Out:
;   N/SPACE возвращают обычным RET
;   Y завершает подготовку с HL=#E000, DE=#C800, IY=#5900 и переходом #C500
; Corrupt:
;   HL, DE, BC, AF, IY
; Note:
;   Сохраняет DE в #CF9A, ждёт N, SPACE или Y, остальные клавиши игнорирует.
;   Сектора 3, 2, 1 читаются соответственно в #C700, #C600, #C500.
;   После цикла HL=#C500 помещается на стек, последний RET использует именно этот адрес.
;   Для байта i преобразование равно ((вход+T[2i]) XOR T[2i+1])-T[2i+2] по модулю 256.
;   Индексы таблицы также берутся по модулю 256, преобразуются 768 байтов.
;   Патчи RET по #CA34/#D975 отключают выход по SPACE и очистку атрибутов.
;   Патч #CE,#00 по #CDB7 меняет LD A,1 на ADC A,0 в FormatTrack.
;   Для данного TRD соответствующие исходные байты лежат в ELITE3.C+#8C00..#8EFF.
;   Их преобразованный результат не подтверждён как связная программа, переход не означает её работоспособность.
;   Прямой вызывающий маршрут ConfirmCopy здесь установлен из CopyMenu, внешний вход CopyMenu не найден.
;   В изолированной проверке N/SPACE вернули управление, Y подтвердил точные 768 байтов и RET в #C500.
;   Проверка использует модель внешнего ПЗУ/FDC, реальные тайминги физической дискеты не моделируются.
; -----------------------------------------
                ; сохранение подтверждённого параметра и вывод запроса
ConfirmCopy:    LD (CopyParameter), DE
                LD HL, ConfirmText
                CALL @Game.Text.PrintDescriptionString.Entry                    ; вывод строки HL до нулевого байта штатным обработчиком игры
AwaitConsent:   CALL WaitMenuKey
                CP #4E
                RET Z                                                           ; выход, если нажата N и продолжение отменяется

                CP #20
                RET Z                                                           ; выход, если нажат SPACE и продолжение отменяется

                CP #59
                JR NZ, AwaitConsent                                             ; переход, если нажата клавиша, отличная от Y, N и SPACE

                CALL @Game.Disk.BlackAttributesAndOverlayState.Entry            ; очистка 768 атрибутных байтов, на выходе HL=#5B00 и BC=0
                LD A, #0E
                CALL SetTrackSide
                LD B, #03
                LD HL, CopyReadPage
                ; чтение очередного сектора в следующую нижнюю страницу
ReadCopySector: PUSH BC
                LD A, B
                LD (CopySector), A
                CALL ReadSector
CopySector      DB #00                                                          ; номер одного из трёх секторов копировщика
                DEC H
                POP BC
                DJNZ ReadCopySector

                INC H
                PUSH HL
                EX DE, HL
                LD HL, Game.Math.SquareLo
                ; обратимое преобразование байта по трём соседним элементам таблицы
DecodeCopyByte: LD A, (DE)
                ADD A, (HL)
                INC L
                XOR (HL)
                INC L
                SUB (HL)
                LD (DE), A
                INC DE
                LD A, D
                CP #C8
                JR NZ, DecodeCopyByte                                           ; переход, если старший байт адреса ещё не достиг #C8 и остаются непреобразованные байты

                LD IY, CopyAttributes
                LD A, #C9
                LD (RestoreStack), A
                LD (Game.Disk.BlackAttributesAndOverlayState.Entry), A
                LD HL, #00CE
                LD (VerifySector), HL
                LD HL, CopyEntryHL
                RET
