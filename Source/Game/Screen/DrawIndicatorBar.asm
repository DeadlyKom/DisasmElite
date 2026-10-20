                module Screen
                module DrawIndicatorBar
; -----------------------------------------
; рисование пятистрочной шкалы шириной пять байтов
; In:
;   DE, адрес слова с экранной позицией
;   AF, A содержит длину полосы в пикселях
; Out:
;   шкала записана в экран
; Corrupt:
;   HL, DE, BC, AF, BC'
; Note:
;   операнды #856D, #8597 и #85B9 задают #FF для заполненной шкалы
;   величина разбивается на число полных байтов и остаток по модулю 8
;   после заполненных байтов выводится маска границы и очищается оставшаяся часть
;   бит 0 последнего байта сохраняет правую границу шкалы
;   в альтернативном B хранится число оставшихся строк, оно равно пяти
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #854F
                ; настройка заполнения шкалы полными байтами #FF
Entry:          LD B, A
                LD A, #FF
                LD (IndicatorDraw.BoundaryMask), A
                LD (IndicatorDraw.BodyFill), A
                LD (IndicatorDraw.FullFill), A
                ; чтение экранного адреса и подготовка пяти строк
ReadBarAddress: LD A, (DE)
                LD L, A
                INC DE
                LD A, (DE)
                LD H, A
                EXX
                LD B, #05
                EXX
                ; проверка нулевого значения шкалы
                LD A, B
                AND A
                JP Z, Game.Screen.DrawEmptyIndicator.Entry                      ; переход, если шкала имеет нулевую длину

                ; разделение величины на байтовую и битовую части
                LD D, A
                AND #07
BoundaryMask    EQU $ + 1                                                       ; маска границы, #FF для полосы и #03 для маркера
                LD C, #FF
                LD B, A
                LD A, D
                JR Z, CountBarBytes                                             ; переход, если величина кратна восьми

                LD A, (IndicatorDraw.MarkerMode)
                DEC A
                JP Z, Game.Screen.IndicatorMarkerMask.Entry                     ; переход, если вместо полосы требуется маска маркера

                ; расчёт маски последнего неполного байта
                XOR A
BuildMask:      SCF
                RRA
                DJNZ BuildMask

StoreMask:      LD C, A
                LD A, D
                ADD A, #08
                ; расчёт числа полных и пустых байтов
CountBarBytes:  AND #F8
                SRL A
                SRL A
                SRL A
                LD B, A
                LD A, #05
                SUB B
                LD D, A
                JR Z, FullWidthBar                                              ; переход, если пустых байтов после полосы нет

                DEC B
                JR Z, Game.Screen.DrawShortIndicator.Entry                      ; переход, если полоса помещается в начальном байте

                LD E, B
                ; вывод строки с заполненной и пустой частями
DrawBarRow:     PUSH HL
BodyFill        EQU $ + 1                                                       ; заполнитель полных байтов полосы, #FF либо #00
                LD A, #FF
FillBarBytes:   LD (HL), A
                INC L
                DJNZ FillBarBytes

                CALL Game.Screen.WriteIndicatorMask.Entry
                INC L
                LD B, D
                DEC B
                JR Z, DrawRightEdge                                             ; переход, если перед правой границей нет пустых байтов

                XOR A
ClearBarBytes:  LD (HL), A
                INC L
                DJNZ ClearBarBytes

DrawRightEdge:  LD (HL), #01
                INC L
                POP HL
                EXX
                DEC B
                EXX
                RET Z                                                           ; выход, если нарисованы все пять строк

                INC H
                LD B, E
                JR DrawBarRow

                ; вывод строки при заполнении до правой границы
FullWidthBar:   DEC B
                LD E, B
DrawFullRow:    PUSH HL
FullFill        EQU $ + 1                                                       ; заполнитель полной шкалы, #FF либо #00
                LD A, #FF
FillFullRow:    LD (HL), A
                INC L
                DJNZ FillFullRow

                SET 0, C
                CALL Game.Screen.WriteIndicatorMask.Entry
                POP HL
                EXX
                DEC B
                EXX
                RET Z                                                           ; выход, если нарисованы все пять строк

                INC H
                LD B, E
                JR DrawFullRow
                ASSERT $ == #85CC
                endmodule
                endmodule
