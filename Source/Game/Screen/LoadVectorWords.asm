                module Screen
                module LoadVectorWords
; -----------------------------------------
; чтение трёх слов вектора с шагом три байта
; In:
;   IX, адрес выбранных двух байтов первой координаты
; Out:
;   HL, слово третьей координаты
;   DE, слово первой координаты
;   BC, слово второй координаты
; Corrupt:
;   HL, DE, BC
; Note:
;   AF и IX сохраняются
;   IX может указывать на младшие или средние байты, это выбирает точность вызывающий код
; -----------------------------------------
                ; смещения описывают исходные данные, память не выделяется
FirstLow:       EQU 0                                                           ; младший байт выбранного слова первой координаты
FirstHigh:      EQU 1                                                           ; старший байт выбранного слова первой координаты
SecondLow:      EQU FCoordinate                                                 ; младший байт выбранного слова второй координаты
SecondHigh:     EQU FCoordinate+1                                               ; старший байт выбранного слова второй координаты
ThirdLow:       EQU FCoordinate+FCoordinate                                     ; младший байт выбранного слова третьей координаты
ThirdHigh:      EQU FCoordinate+FCoordinate+1                                   ; старший байт выбранного слова третьей координаты

                ; проверка исходного размещения
                ASSERT $ == #8302
Entry:          LD E, (IX + FirstLow)
                LD D, (IX + FirstHigh)
                LD C, (IX + SecondLow)
                LD B, (IX + SecondHigh)
                LD L, (IX + ThirdLow)
                LD H, (IX + ThirdHigh)
                RET
                ASSERT $ == #8315
                endmodule
                endmodule
