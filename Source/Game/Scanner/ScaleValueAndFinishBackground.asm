                module Scanner
                module ScaleValueAndFinishBackground
; -----------------------------------------
; Масштабирование байта и общий хвост копирования фона
; исходный диапазон #9924..#9945
; In:
;   HL, L множитель, AF, A второй множитель для входа Game.Scanner.ScaleValueAndFinishBackground.Entry
; Out:
;   A=floor(L*((2*A) mod256)/256), либо завершён общий цикл ScannerCopy.SaveCharRow
; Corrupt:
;   HL, AF для Game.Scanner.ScaleValueAndFinishBackground.Entry, HL, DE, BC, AF для ScannerCopy.RestoreRow
; Note:
;   Game.Scanner.ScaleValueAndFinishBackground.Entry обнуляет H, удваивает A и сбрасывает перенос перед умножением Game.Wireframe.MultiplyClippingDistance.Entry
;   десять байтов BackdropMap, совпадающих с прежними командами, читаются как управляющий поток альтернативного фона
;   AdvanceCopy является общим хвостом SaveScannerBackground и RestoreScannerBackground с изменяемыми POP/INC/EX
;   после общего RET сохранён один нулевой байт, входящих обращений к нему не найдено
; -----------------------------------------
                ASSERT $ == #9924
                ; отдельный вход масштабирует L на удвоенный байт A, перенос сбрасывается
Entry:          LD H, #00
                ADD A, A
                AND A
                JP Game.Wireframe.MultiplyClippingDistance.Entry

                ; управляющие байты альтернативного фона, совпадают с прежними машинными командами
BackdropMap     DB #21, #06, #AC, #06, #21, #00, #ED, #A0                       ; байты прежнего кода, используемые как поток альтернативного фона
                DB #ED, #A0                                                     ; #9933..#9934
                ; общий хвост копирования, POP и INC выбираются направлением переноса
RestoreRow      EQU $                                                           ; код POP HL либо POP DE, восстановление экранной строки
AdvanceCopy:    POP HL
AdvanceRow      EQU $                                                           ; код INC H либо INC D, следующая пиксельная строка
                INC H
                DJNZ Game.Scanner.RestoreScannerBackground.CopyPixelRow
                ; расчёт следующего знакоместа увеличивает экранную базу на 32
SelectScreen    EQU $                                                           ; код EX DE,HL либо NOP перед переходом к знакоместу
                EX DE, HL
                POP DE
                EX DE, HL
                LD BC, #0020
                ADD HL, BC
SelectTarget    EQU $                                                           ; код NOP либо EX DE,HL, возврат направления копирования
                NOP
                ; проверка окончания шести рядов знакомест
                DEC A
                JR NZ, Game.Scanner.RestoreScannerBackground.CopyCharRow        ; переход, если не все шесть рядов знакомест скопированы, продолжить общий цикл

                RET

                ; сохранённый нулевой байт после общего RET копировщика
                DB #00                                                          ; #9945..#9945
                ASSERT $ == #9946
                endmodule
                endmodule
