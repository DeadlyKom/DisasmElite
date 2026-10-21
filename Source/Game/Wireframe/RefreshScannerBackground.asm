                module Wireframe
                module RefreshScannerBackground
; -----------------------------------------
; обновление фона сканера и атрибутов индикаторной области
; исходный диапазон #B3B2..#B43F
; In:
;   память ScannerRaster.BackdropMode, режим и атрибут, исходно 7
;   память ScannerState.Redraw, состояние сканера
;   память ScannerMap, поток альтернативного фона
; Out:
;   экран и атрибуты #5Axx обновлены
; Corrupt:
;   HL, DE, BC, AF, AF'
; Note:
; Ненулевой режим вызывает CopyScaner2Scr и использует A как атрибут.
; Нулевой режим собирает фон из блоков ScannerBlocks по потоку ScannerMap.
; Младшая единица управляющего байта выбирает источник с шагом 9, оставшиеся биты задают строки.
; Строка копирует 11 байтов, адрес корректируется через восьмистрочные границы Spectrum.
; Таблица ScannerAttrs задаёт адреса Memory.Attributes + #0200+(смещение+1), завершается FF.
; после основного кода сохранены пять старых машинных байтов и 8×8 масок отрезков для Game.Wireframe.DrawClippedLine.Entry
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #B3B2
                ; проверка режима фона
BackdropMode    EQU $ + 1                                                       ; операнд LD A, 7 обычный фон и атрибут, 0 альтернативный фон
Entry:          LD A, #07
                AND A
                JR NZ, CopyBackground                                           ; переход, если режим ненулевой и требуется обычное копирование фона

                LD A, (ScannerState.Redraw)
                DEC A
                RET NZ                                                          ; выход, если при нулевом режиме состояние сканера отличается от 1

                ; поиск блоков альтернативного рисунка
                LD DE, Memory.Screen + #102A                                    ; альтернативный фон сканера, строка 136, байт 10
                LD HL, ScannerMap
ReadControl:    LD A, (HL)
                AND A
                JR Z, SetAttributes                                             ; переход, если управляющий поток завершён нулевым байтом

                PUSH HL
                ; расчёт адреса блока по управляющему байту
                LD HL, ScannerBlocks - 9
                LD BC, #0009
FindBlock:      ADD HL, BC
                RRA
                JR NC, FindBlock                                                ; переход, если младшая установленная единица ещё не найдена

                ; перенос строки и коррекция экранного адреса
CopyBlockRow:   PUSH HL
                PUSH DE
                LD C, #0B
                LDIR
                POP HL
                INC H
                EX AF, AF'
                LD A, H
                AND #07
                CALL Z, Game.Screen.NextCharacterRow.Entry                      ; вызов процедуры, если переход пересёк восьмистрочную границу экрана
                EX DE, HL
                POP HL
                EX AF, AF'
                DEC A
                JR NZ, CopyBlockRow                                             ; переход, если в блоке остались строки для копирования

                POP HL
                INC HL
                JR ReadControl

                ; копирование обычного фона сканера
CopyBackground: PUSH AF
                CALL Game.Scanner.RestoreScannerBackground.Entry
                POP AF
                ; обновление атрибутов индикатора
SetAttributes:  LD D, #5A
                LD HL, ScannerAttrs
NextAttribute:  LD E, (HL)
                INC HL
                INC E
                RET Z                                                           ; выход, если таблица атрибутов достигла завершающего FF

                LD (DE), A
                JR NextAttribute

                ; сохранённые байты и таблица масок горизонтальных отрезков
                DB #44, #CB, #50, #20, #02, #FF, #80, #C0
                DB #E0, #F0, #F8, #FC, #FE, #7F, #40, #60
                DB #70, #78, #7C, #7E, #7F, #3F, #20, #30
                DB #38, #3C, #3E, #3F, #3F, #1F, #10, #18
                DB #1C, #1E, #1F, #1F, #1F, #0F, #08, #0C
                DB #0E, #0F, #0F, #0F, #0F, #07, #04, #06
                DB #07, #07, #07, #07, #07, #03, #02, #03
                DB #03, #03, #03, #03, #03, #01, #01, #01
                DB #01, #01, #01, #01, #01
                ; проверка исходного конца фрагмента
                ASSERT $ == #B440
                endmodule
                endmodule
