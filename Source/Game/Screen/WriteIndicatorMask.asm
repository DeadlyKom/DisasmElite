                module Screen
                module WriteIndicatorMask
; -----------------------------------------
; запись граничного байта шкалы с коррекцией маркера
; In:
;   HL, адрес граничного байта
;   BC, C содержит маску
; Out:
;   маска записана, при необходимости предыдущий байт заменён на #01
; Corrupt:
;   AF
; Note:
;   при IndicatorDraw.MarkerMode=1 при маске #80 или #81 предыдущий байт перезаписывается значением #01
;   HL восстанавливается после временного DEC L
;   с Game.Screen.WriteIndicatorMask.CircleData начинается блок состояния построения окружностей, это литеральные данные
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #8606
                ; запись текущей маски и проверка необходимости продолжения маркера слева
Entry:          LD (HL), C
                LD A, (IndicatorDraw.MarkerMode)
                DEC A
                RET NZ                                                          ; выход, если рисуется обычная полоса

                LD A, C
                AND #FE
                CP #80
                JR Z, MarkerAtEdge                                              ; переход, если маркер занимает старший бит текущего байта

                RET

MarkerAtEdge:   DEC L
                LD (HL), #01
                INC L
                RET

CircleData      EQU $                                                           ; исходная база блока с отдельным резервным байтом
.Reserved       DB #00                                                          ; исходный резервный байт перед структурой FCircleState
.OffsetY        EQU CircleFields.OffsetY                                        ; адрес поля FCircleState.OffsetY
.OffsetX        EQU CircleFields.OffsetX                                        ; адрес поля FCircleState.OffsetX
.Flags          EQU CircleFields.Flags                                          ; адрес поля FCircleState.Flags
.Radius         EQU CircleFields.Radius                                         ; адрес поля FCircleState.Radius
.ClipY          EQU CircleFields.ClipY                                          ; адрес поля FCircleState.ClipY
.ClipX          EQU CircleFields.ClipX                                          ; адрес поля FCircleState.ClipX
.ScreenY        EQU CircleFields.ScreenY                                        ; адрес поля FCircleState.ScreenY
.ScreenX        EQU CircleFields.ScreenX                                        ; адрес поля FCircleState.ScreenX
.Cathetus       EQU CircleFields.Cathetus                                       ; адрес поля FCircleState.Cathetus
.SavedSP        EQU CircleFields.SavedSP                                        ; адрес поля FCircleState.SavedSP
.Radicand       EQU CircleFields.Radicand                                       ; адрес поля FCircleState.Radicand
.LeftMask       EQU CircleFields.LeftMask                                       ; адрес поля FCircleState.LeftMask
.DirectionDown  EQU CircleFields.DirectionDown                                  ; адрес поля FCircleState.DirectionDown
.OutlineOnly    EQU CircleFields.OutlineOnly                                    ; адрес поля FCircleState.OutlineOnly
.PatchCount     EQU CircleFields.PatchCount                                     ; адрес поля FCircleState.PatchCount

CircleFields    FCircleState {
                    #00,                                                        ; FCircleState.OffsetY, модуль вертикального смещения центра
                    #1F,                                                        ; FCircleState.OffsetX, модуль горизонтального смещения центра
                    #0C,                                                        ; FCircleState.Flags, знаки и признаки диапазона центра, схема в FCircleState
                    #46,                                                        ; FCircleState.Radius, радиус окружности в пикселях
                    #00,                                                        ; FCircleState.ClipY, рабочий модуль Y или расстояние до вертикальной границы
                    #1F,                                                        ; FCircleState.ClipX, рабочий модуль X или расстояние до боковой границы
                    #60,                                                        ; FCircleState.ScreenY, экранная строка центра или начало отсечённой дуги
                    #61,                                                        ; FCircleState.ScreenX, экранный столбец центра
                    #00,                                                        ; FCircleState.Cathetus, катет точки пересечения круга с границей
                    #CFFC,                                                      ; FCircleState.SavedSP, реальный стек до временного заполнения или чтения таблицы
                    #0000,                                                      ; FCircleState.Radicand, подкоренное значение r*r - d*d - входной перенос
                    #10,                                                        ; FCircleState.LeftMask, маска левого края перед заполнением строки
                    #01,                                                        ; FCircleState.DirectionDown, направление дуги, 0 вверх, 1 вниз
                    #01,                                                        ; FCircleState.OutlineOnly, режим окружности, 0 заливка, 1 только контур
                    #20                                                         ; FCircleState.PatchCount, число байтов патча области обзора
                }
                ASSERT $ == #862B
                endmodule
                endmodule
