                ifndef _CONST_GRAPHICS_
                define _CONST_GRAPHICS_

; -----------------------------------------
; упакованные признаки окружностей и экранных вершин
; схемы и смысл полей находятся в GraphicsWorkspace.inc
; -----------------------------------------
CIRC_RIGHT_BIT  EQU 0                                                           ; флаг, центр окружности правее середины области
CIRC_UP_BIT     EQU 1                                                           ; флаг, центр окружности выше середины области
CIRC_XRANGE_BIT EQU 2                                                           ; флаг, обычная ветвь проверки горизонтального диапазона
CIRC_YRANGE_BIT EQU 3                                                           ; флаг, обычная ветвь проверки вертикального диапазона
CIRC_RIGHT_MASK EQU 1 << CIRC_RIGHT_BIT                                         ; маска горизонтального направления центра
CIRC_UP_MASK    EQU 1 << CIRC_UP_BIT                                            ; маска вертикального направления центра
CIRC_XRANGE_MSK EQU 1 << CIRC_XRANGE_BIT                                        ; маска обычного горизонтального диапазона
CIRC_YRANGE_MSK EQU 1 << CIRC_YRANGE_BIT                                        ; маска обычного вертикального диапазона
CIRC_SIGN_MASK  EQU CIRC_RIGHT_MASK | CIRC_UP_MASK                              ; два направления центра окружности
CIRC_RANGE_MASK EQU CIRC_XRANGE_MSK | CIRC_YRANGE_MSK                           ; обычный диапазон обеих осей, маска #0C
CIRC_FLAGS_MASK EQU CIRC_SIGN_MASK | CIRC_RANGE_MASK                            ; все четыре признака окружности
CIRC_PROJ_XOR   EQU CIRC_UP_MASK | CIRC_RANGE_MASK                              ; маска #0E после перестановки знаков проекции в формат окружности
PROJ_NEGX_BIT   EQU 1                                                           ; флаг, модуль X вычитается из горизонтального центра
PROJ_POSY_BIT   EQU 0                                                           ; флаг, модуль Y прибавляется к вертикальному центру
PROJ_NEGX_MASK  EQU 1 << PROJ_NEGX_BIT                                          ; маска направления горизонтальной проекции
PROJ_POSY_MASK  EQU 1 << PROJ_POSY_BIT                                          ; маска направления вертикальной проекции
PROJ_SIGN_MASK  EQU PROJ_NEGX_MASK | PROJ_POSY_MASK                             ; оба знака экранной проекции
VERT_HIDDEN_BIT EQU 7                                                           ; флаг, экранная вершина не допускается к рисованию ребра
VERT_HIDDEN     EQU #FF                                                         ; маркер непроецируемой вершины в FProjectedVertex.Flags
SIL_LEFT_BIT    EQU 0                                                           ; флаг, первый байт строки малого силуэта выходит за левый край
SIL_RIGHT_BIT   EQU 1                                                           ; флаг, третий байт строки малого силуэта выходит за правый край
SIL_BACK_BIT    EQU 7                                                           ; флаг, профиль малого силуэта обходится в обратном направлении

                endif                                                           ; ~_CONST_GRAPHICS_
