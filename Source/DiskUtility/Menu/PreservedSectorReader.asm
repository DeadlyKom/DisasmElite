; -----------------------------------------
; строка NO SPACE! с перекрывающейся сохранённой последовательностью чтения сектора
; исходный диапазон #C859..#C87C
; In:
;   HL=DiskUtility.Menu.LegacyNoSpace, режим вывода TextDecodeMode=1 для подтверждённого текстового пути
;   для машинного прочтения (LegacyNoSpace + 7) отдельный вход не найден
; Out:
;   строка заканчивается нулём (LegacyNoSpace + 8)
;   условный машинный путь читает сектор в DiskBuffer.Blank и переходит JP (HL)
; Corrupt:
;   для текстовых данных нет, при машинном прочтении HL, DE, BC, AF
; Note:
;   Game.Text.PrintDescriptionByte.Entry переводит #E9 через таблицу диграмм TextSyllables, пара (TextSyllables + #24) содержит CE.
;   В режиме TextDecodeMode=1 девять байтов LegacyNoSpace выводят NO SPACE! и завершают строку.
;   При TextDecodeMode=0 тот же #E9 относится к другой таблице, поэтому режим является частью контракта.
;   Байт (LegacyNoSpace + 6) одновременно допускает JP (HL), (LegacyNoSpace + 7)..(LegacyNoSpace + 9) допускают LD HL,0.
;   Прямые входящие переходы на (LegacyNoSpace + 6)/(LegacyNoSpace + 7) в проверенном коде не обнаружены.
;   Следующий связный машинный фрагмент читает дорожку #0E, сектор 4 в DiskBuffer.Blank.
;   Цикл XOR использует Game.Math.SquareLo, (Game.Math.SquareLo + #FF), (Game.Math.SquareLo + #FE) ... (Game.Math.SquareLo + 1) и 256 байтов DiskBuffer.Blank.
;   После оборота младших байтов HL=DiskBuffer.Blank, DE=Game.Math.SquareLo, JP (HL) передаёт управление в буфер.
;   Это описание операций сохранённых байтов, оно не доказывает вызов этого пути или пригодность сектора.
;   DB в начале необходим из-за доказанного текстового чтения и перекрытия границ инструкций.
; -----------------------------------------
LegacyNoSpace   DB #4E, #4F, #20, #53, #50, #41, #E9, #21, #00, #00
                ; сохранённый машинный фрагмент после перекрывающейся строки, вход не установлен
LegacyRead:     CALL @Game.Disk.BlackAttributesAndOverlayState.Entry            ; очистка 768 атрибутных байтов, на выходе HL=(Memory.Attributes + #0300) и BC=0
                LD A, #0E
                CALL SetTrackSide
                LD HL, DiskBuffer.Blank
                CALL ReadSector
                DB #04                                                          ; номер сектора после CALL, SectorTransfer изменяет адрес возврата
                LD DE, Game.Math.SquareLo
                ; преобразование страницы экрана с обратным обходом таблицы
LegacyXor:      LD A, (DE)
                XOR (HL)
                LD (HL), A
                INC L
                DEC E
                JR NZ, LegacyXor                                                ; переход, если младший байт источника ещё не обошёл все 256 значений

                JP (HL)
