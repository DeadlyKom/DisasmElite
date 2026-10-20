                module Motion
                module AddScaledCoordinate
; -----------------------------------------
; прибавление к координате объекта другой координаты с коэффициентом
; исходный диапазон #A1EA..#A280
; In:
;   HL, смещение изменяемой трёхбайтовой координаты
;   DE, смещение исходной координаты
;   BC, C содержит знако-модульный коэффициент
;   IX, объект
; Out:
;   IX, исходный указатель
;   IY, исходное значение
;   координата назначения обновлена
; Corrupt:
;   HL, DE, BC, AF
; Note:
; Составляет трёхбайтовое произведение из отдельных произведений старшего, среднего и младшего байтов.
; Табличные AB34/AB0B сохраняют исходную погрешность четверть-квадратов.
; Для равных знаков складывает модули, для разных вычитает с выбором знака большего.
; IX и IY восстанавливаются со стека, поэтому четыре последовательных вызова используют один объект.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #A1EA
                ; поиск исходной координаты и назначения внутри одного объекта
Entry:          PUSH IX
                PUSH IX
                EX (SP), IY
                ADD IX, DE
                EX DE, HL
                ADD IY, DE
                ; расчёт знака и трёхбайтового модуля произведения
                LD A, (IX + FCoordinate.SignHigh)
                LD D, (IX + FCoordinate.Low)
                LD E, (IX + FCoordinate.Fraction)
                LD B, A
                XOR C
                AND #80
                PUSH AF
                RES 7, C
                RES 7, B
                PUSH DE
                CALL Game.Wireframe.MultiplyBytesApprox.Entry
                POP DE
                PUSH HL
                LD B, D
                PUSH DE
                CALL Game.Wireframe.MultiplyBytesApprox.Entry
                POP DE
                LD B, E
                LD A, L
                LD L, H
                LD H, #00
                POP DE
                ADD HL, DE
                LD E, A
                PUSH HL
                CALL Game.Wireframe.MultiplyHighByteApprox.Entry
                ADD A, E
                POP HL
                JR NC, AlignProduct                                             ; переход, если сложение младшего вклада произведения не даёт переноса

                INC HL
AlignProduct:   LD B, A
                LD A, H
                LD H, L
                LD L, B
                ; чтение координаты назначения и проверка взаимных знаков
                POP BC
                LD C, B
                LD B, (IY + FCoordinate.SignHigh)
                LD D, (IY + FCoordinate.Low)
                LD E, (IY + FCoordinate.Fraction)
                PUSH AF
                LD A, B
                XOR C
                RLC C
                RLC C
                RLA
                RR C
                RRC C
                SRL A
                LD B, A
                POP AF
                BIT 6, C
                JR NZ, SubtractTerms                                            ; переход, если знаки координаты и добавляемого произведения различаются

                ; расчёт суммы модулей при одинаковых знаках
                ADD A, A
                SLA C
                RRA
                ADD A, B
                ADD HL, DE
                JR NC, StoreAxis                                                ; переход, если сложение младших слов не переносит единицу в старший байт

                INC A
                JR StoreAxis

                ; расчёт разности модулей и выбор результирующего знака
SubtractTerms:  AND A
                EX DE, HL
                SBC HL, DE
                JR NC, SubtractHigh                                             ; переход, если вычитание младших слов не требует заёма из старшего байта

                INC A
SubtractHigh:   LD D, A
                LD A, B
                SUB D
                LD B, A
                JR NC, PackSign                                                 ; переход, если старший модуль координаты не меньше старшего модуля произведения

                CPL
                LD B, A
                LD A, C
                XOR #80
                LD C, A
                EX DE, HL
                AND A
                LD HL, #0000
                SBC HL, DE
PackSign:       LD A, B
                RLA
                SLA C
                RRA
                XOR #80
                ; обновление трёхбайтовой координаты и восстановление указателей
StoreAxis:      LD (IY + FCoordinate.SignHigh), A
                LD (IY + FCoordinate.Low), H
                LD (IY + FCoordinate.Fraction), L
                POP IY
                POP IX
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #A281
                endmodule
                endmodule
