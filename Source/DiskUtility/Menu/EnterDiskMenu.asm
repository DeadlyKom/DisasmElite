; -----------------------------------------
; вход в дисковое меню, восстановление обработчиков и очистка пула объектов
; исходный диапазон #C800..#C82B
; In:
;   стек, возврат в основной загрузчик оверлея #D94A
; Out:
;   HL=#617F, DE=#6180, BC=0
;   AF, флаги результата меню, A=#3E при обычном возврате
;   #606F..#617F обнулены
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
;   #D548 содержит XOR C в выводе символа, временный NOP заменяет смешивание на прямую запись.
;   #E36B временно получает RET, после BuildSaveList восстанавливаются исходные #A9 и #3E.
;   Общий вход #C816 сохраняет AF до очистки и возвращает его без изменения.
;   Переход CheckSpaceExit в #C816 минует восстановление двух патчей, это исходное поведение.
;   #D975 оставляет B=0, поэтому LD (HL),B и LDIR очищают ровно 273 байта.
; -----------------------------------------
EnterMenu:      XOR A
                LD (Game.Text.XorCharacterScanlines.XorOpcode), A
                LD A, #C9
                LD (ClearInputGate), A
                CALL BuildSaveList
                LD A, #A9
                LD (Game.Text.XorCharacterScanlines.XorOpcode), A
                LD A, #3E
                LD (ClearInputGate), A
                ; сохранение результата перед очисткой атрибутов и семи нестанционных слотов
ReturnMenu:     PUSH AF
                CALL @Game.Text.PrintInlineToken.Entry                          ; обработка следующего байта как встроенного управляющего кода
                DB #08                                                          ; управляющий код текста, адрес возврата пропускает этот байт
                CALL @Game.Disk.BlackAttributesAndOverlayState.Entry            ; очистка 768 атрибутных байтов, на выходе HL=#5B00 и BC=0
                LD HL, DiskBuffer.Work
                LD DE, DiskBuffer.Work + 1
                LD (HL), B
                LD BC, #0110
                LDIR
                POP AF
                RET
