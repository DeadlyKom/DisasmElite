                module Wireframe
                module CrossProductComponent
; -----------------------------------------
; разность двух знаковых произведений для компоненты векторного произведения
; исходный диапазон #AF22..#AFA7
; In:
;   DE, D и E содержат одну пару знако-модульных байтов
;   BC, B и C содержат другую пару
; Out:
;   HL, знако-модульная разность B*C-D*E в масштабе базиса
; Corrupt:
;   DE, BC, AF
; Note:
; Модули удваиваются перед Game.Wireframe.MultiplyBytesApprox.Entry, знак каждого произведения сохраняется отдельно.
; Сумма противоположно направленных произведений насыщается при переполнении, разность меняет знак по величине.
; Отдельный вход Game.Wireframe.CrossProductComponent.MultiplyHigh вычисляет старшее слово составного произведения, его контракт приведён ниже.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #AF22
                ; расчёт знаков и модулей двух произведений
Entry:          SLA B
                RRA
                XOR C
                SLA C
                AND #80
                LD H, A
                SLA D
                RRA
                XOR E
                SLA E
                AND #80
                XOR H
                SLA H
                RRA
                XOR #80
                PUSH AF
                PUSH DE
                CALL Game.Wireframe.MultiplyBytesApprox.Entry
                POP BC
                PUSH HL
                CALL Game.Wireframe.MultiplyBytesApprox.Entry
                POP DE
                POP AF
                ; проверка знаков перед сложением либо вычитанием
                BIT 6, A
                JR Z, SubtractTerms                                             ; переход, если знаки двух произведений совпадают и требуется разность модулей

                ADD HL, DE
                JR NC, PackProduct                                              ; переход, если сумма модулей произведений не переполнилась

                LD HL, #FFFF
                JR PackProduct

                ; расчёт разности модулей
SubtractTerms:  EX DE, HL
                AND A
                SBC HL, DE
                JR NC, PackProduct                                              ; переход, если модуль первого произведения не меньше второго

                ADD HL, DE
                EX DE, HL
                AND A
                SBC HL, DE
                XOR #80
                ; упаковка знако-модульного результата
PackProduct:    RLA
                RR H
                RR L
                RET

                ; сохранённые машинные байты составного умножения между процедурами

; -----------------------------------------
; старшее слово составного произведения двух беззнаковых 16-битных величин
; In:
;   DE, второй множитель D*256+E
;   BC, C содержит младший байт первого множителя
;   AF, A содержит старший байт первого множителя
; Out:
;   HL, старшее слово составного результата
;   IX сохраняется
; Corrupt:
;   DE, BC, AF
; Note:
;   сохранённая процедура, прямые входящие переходы не найдены
;   первый множитель равен A*256+C, второй D*256+E
;   каждое частичное произведение P(u,v) рассчитывается таблицей Game.Wireframe.MultiplyBytesApprox.Entry
;   при одинаковой чётности P=u*v, при разной P=u*v-min(u,v)
;   результат равен старшему слову P(C,E)+256*P(C,D)+256*P(A,E)+65536*P(A,D)
;   IX накапливает младшее слово, переносы добавляются к сумме старших частей
;   это составное приближение, точное обычное умножение вместо него изменило бы результат
; -----------------------------------------
MultiplyHigh:   ; старшее слово составного произведения двух беззнаковых 16-битных величин
                ; сохранение IX и трёх копий исходных байтов множителей
                PUSH IX
                LD IX, #0000
                LD B, A
                PUSH BC
                PUSH DE
                PUSH BC
                PUSH DE
                PUSH BC
                PUSH DE
                ; расчёт произведения младших байтов
                LD B, E
                CALL Game.Wireframe.MultiplyBytesApprox.Entry
                EX DE, HL
                ADD IX, DE
                ; прибавление первого перекрёстного произведения со сдвигом на восемь битов
                POP DE
                POP BC
                LD B, D
                CALL Game.Wireframe.MultiplyBytesApprox.Entry
                LD E, #00
                LD D, L
                ADD IX, DE
                LD L, H
                LD H, E
                JR NC, AddCrossTerm                                             ; переход, если младшее слово не переполнилось при первом сложении

                INC HL
                ; прибавление второго перекрёстного произведения и переносов
AddCrossTerm:   POP BC
                POP DE
                PUSH HL
                LD B, D
                CALL Game.Wireframe.MultiplyBytesApprox.Entry
                LD E, #00
                LD D, L
                ADD IX, DE
                POP DE
                LD L, H
                LD H, #00
                JR NC, AddHighWord                                              ; переход, если младшее слово не переполнилось при втором сложении

                INC HL
AddHighWord:    ADD HL, DE
                ; прибавление произведения старших байтов и восстановление IX
                POP BC
                POP DE
                LD C, D
                PUSH HL
                CALL Game.Wireframe.MultiplyBytesApprox.Entry
                POP DE
                ADD HL, DE
                POP IX
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #AFA8
                endmodule
                endmodule
