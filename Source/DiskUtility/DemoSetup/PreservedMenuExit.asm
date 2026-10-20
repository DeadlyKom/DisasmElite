; -----------------------------------------
; Сохранённый выход прежнего дискового оверлея
; исходный диапазон #C804..#C82B
; In:
;   игровые обработчики текста и экрана
; Out:
;   восстановлены патчи печати, очищено 273 байта 606F..617F, A=1
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Основной вход C800 сюда не передаёт управление, код сохранён в образе
;   После D975 B=0, первая запись и LDIR272 обнуляют 273 байта
;   CALL D421 поглощает встроенный токен 08, он не исполняется
; -----------------------------------------
                ; остаточный путь временно выключает очистку строки и восстанавливает XOR символов
LegacyMenuExit: LD A, #C9
                LD (ClearInputGate), A
                NOP
                NOP
                NOP
                LD A, #A9
                LD (Game.Text.XorCharacterScanlines.XorOpcode), A
                LD A, #3E
                LD (ClearInputGate), A
                ; печать встроенного токена 08 и очистка атрибутов
                CALL @Game.Text.PrintInlineToken.Entry
                DB #08                                                          ; данные #C819..#C819
                CALL @Game.Disk.BlackAttributesAndOverlayState.Entry
                ; нулевой B после D975 размножается на 273 байта объектного пула
                LD HL, Memory.Objects
                LD DE, Memory.Objects + 1
                LD (HL), B
                LD BC, #0110
                LDIR
                XOR A
                INC A
                RET
