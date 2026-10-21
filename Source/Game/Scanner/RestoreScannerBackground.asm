                module Scanner
                module RestoreScannerBackground
; -----------------------------------------
; Восстановление фона и удаление предыдущих отметок
; исходный диапазон #98CD..#9923
; In:
;   ScannerState.Redraw=1 для восстановления, фон Memory.CockpitAttrs
; Out:
;   ScannerState.Redraw=0, 624 байта возвращены на экран, очищены ещё 8×11 байт
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Только значение 1 в ScannerState.Redraw разрешает операцию, другое значение возвращается без изменений
;   Для восстановления ScannerCopy/ScannerCopy.SelectScreen=NOP, ScannerCopy.SaveCharRow/ScannerCopy.SavePixelRow=PUSH DE, ScannerCopy.RestoreRow=POP DE, ScannerCopy.AdvanceRow=INC D, ScannerCopy.SelectTarget=EX DE,HL
;   Копируются 6 знакомест по 8 строк, по 13 байт каждой, экранная строка нелинейна, буфер линеен
;   CopyBackground продолжается в Game.Scanner.ScaleValueAndFinishBackground.AdvanceCopy, после LDIR переход обходит независимый
;   вход Game.Scanner.ScaleValueAndFinishBackground.Entry
; -----------------------------------------
                ASSERT $ == #98CD
                ; проверка грязного фона, восстановление разрешает только значение 1
Entry:          LD A, (ScannerState.Redraw)
                DEC A
                RET NZ                                                          ; выход, если фон не помечен как содержащий новые маркеры

                ; снятие признака и очистка восьми строк по 11 байт
                LD (ScannerState.Redraw), A
                XOR A
                LD C, #08
                LD HL, Memory.Screen + #102A                                    ; дополнительная область сканера, строка 136, байт 10
ClearExtraRow:  LD B, #0B
                PUSH HL
ClearExtraByte: LD (HL), A
                INC L
                DJNZ ClearExtraByte

                POP HL
                INC H
                DEC C
                JR NZ, ClearExtraRow                                            ; переход, если не все восемь строк дополнительной области очищены, продолжить очистку

                ; подмена команд общего копировщика для направления буфер→экран
                LD BC, #0005
                XOR A
                LD HL, ScannerCopy.SelectSource
                LD (HL), A
                LD A, #D5
                LD HL, ScannerCopy.SaveCharRow
                LD (HL), A
                ADD HL, BC
                LD (HL), A
                LD A, #D1
                LD HL, ScannerCopy.RestoreRow
                ; экранный указатель ведётся через POP DE и INC D
                LD (HL), A
                INC HL
                LD A, #14
                LD (HL), A
                LD A, #EB
                LD HL, ScannerCopy.SelectTarget
                LD (HL), A
                XOR A
                LD HL, ScannerCopy.SelectScreen
                LD (HL), A
                ; общая подготовка линейного буфера Memory.CockpitAttrs и прямоугольника экрана Memory.Screen + #1049
CopyBackground: LD DE, Memory.Screen + #1049                                    ; копируемый фон сканера, строка 144, байт 9
                LD HL, Memory.CockpitAttrs                                      ; линейная копия фона сканера, 624 байта
                ; SMC, EX DE,HL при сохранении выбирает экран источником
SelectSource    EQU $                                                           ; код EX DE,HL либо NOP, выбор источника
                EX DE, HL
                LD A, #06
                ; внешний цикл шести знакомест сохраняет экранную базу подменяемым PUSH
SaveCharRow     EQU $                                                           ; код PUSH HL либо PUSH DE, сохранение экранной базы знакоместа
CopyCharRow:    PUSH HL
                LD B, #08
                LD C, #FF
                ; восемь строк знакоместа, LDIR копирует 13 байт в выбранном направлении
SavePixelRow    EQU $                                                           ; код PUSH HL либо PUSH DE, сохранение экранной строки
CopyPixelRow:   PUSH HL
                PUSH BC
                LD BC, #000D
                LDIR
                POP BC
                JR Game.Scanner.ScaleValueAndFinishBackground.AdvanceCopy

                ASSERT $ == #9924
                endmodule
                endmodule
