; -----------------------------------------
; вывод либо снятие подсветки выбранной строки каталога
; исходный диапазон #CC02..#CC25
; In:
;   AF, перенос задаёт подсветку
;   SaveSelection и SavePageStart, выбранный индекс и начало страницы
; Out:
;   A=#15 при C=1 на входе, иначе #07
;   F сохранён, десять атрибутных ячеек обновлены
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Относительный номер передаётся SavePosition и переводится в адрес Memory.Attributes+32*B+C.
;   После EI/HALT исходные флаги восстанавливаются POP AF.
;   LD A, INC HL и DJNZ не изменяют восстановленный F, меняется только A.
;   Перед обновлением ожидается одно прерывание, выход оставляет прерывания разрешёнными.
; -----------------------------------------
PaintSelection: PUSH AF
                LD HL, SaveSelection
                LD A, (HL)
                INC HL
                SUB (HL)
                CALL SavePosition
                LD HL, Memory.Attributes
                LD DE, #0020
FindAttrRow:    ADD HL, DE
                DJNZ FindAttrRow

                ADD HL, BC
                LD B, #0A
                EI
                HALT
                POP AF
                LD A, #07
                JR NC, FillHighlight                                            ; переход, если на входе перенос сброшен и используется обычный атрибут #07

                LD A, #15
FillHighlight:  LD (HL), A
                INC HL
                DJNZ FillHighlight

                RET
