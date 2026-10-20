; -----------------------------------------
; вывод до 24 восьмибайтовых имён в трёх столбцах
; исходный диапазон #CB96..#CBD2
; In:
;   #DA71, первый индекс страницы
;   каталог #5000, записи по 16 байтов
; Out:
;   BC сохранён
;   HL, адрес следующей записи либо нулевого окончания
; Corrupt:
;   HL, DE, AF
; Note:
;   Счётчик B=#18 задаёт 24 позиции, SavePosition распределяет их по трём столбцам.
;   Каждая запись выводит ровно 8 символов, затем пропускаются 8 байтов метаданных.
;   Байты меньше #20 и от #80 заменяются пробелом, #20..#5A печатаются непосредственно.
;   Диапазон #5B..#7F уменьшается на #20, правило шире преобразования строчных букв.
;   После восстановления BC вход без CALL продолжается в PrintMenuChar с управляющим байтом #08.
; -----------------------------------------
DrawSaveNames:  PUSH BC
                LD A, (SavePageStart)
                CALL GetSaveRecord
                LD B, #18
DrawName:       LD A, (HL)
                AND A
                JR Z, FinishNames                                               ; переход, если встречено нулевое имя и дальнейший вывод списка не требуется

                PUSH BC
                LD A, #18
                SUB B
                CALL SavePosition
                LD (TextPosition), BC
                LD B, #08
NameCharacter:  LD A, (HL)
                INC HL
                CP #80
                JR NC, SpaceCharacter                                           ; переход, если символ не меньше #80 и должен быть заменён пробелом

                CP #20
                JR C, SpaceCharacter                                            ; переход, если символ меньше пробела и должен быть заменён пробелом

                CP #5B
                JR C, EmitCharacter                                             ; переход, если символ меньше #5B и не требует вычитания #20

                SUB #20
                JR EmitCharacter

SpaceCharacter: LD A, #20
EmitCharacter:  CALL PrintMenuChar
                DJNZ NameCharacter

                LD BC, #0008
                ADD HL, BC
                POP BC
                DJNZ DrawName

FinishNames:    POP BC
                LD A, #08
