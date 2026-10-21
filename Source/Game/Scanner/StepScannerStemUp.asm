                module Scanner
                module StepScannerStemUp
; -----------------------------------------
; Переход ножки сканера через верхнюю границу знакоместа
; исходный диапазон #987C..#988D
; In:
;   HL адрес после DEC H при пересечении восьми пиксельных строк
; Out:
;   HL предыдущая строка либо переход Game.Scanner.DrawScannerObjects.NextObject после снятия адреса возврата
; Corrupt:
;   HL, AF
; Note:
;   L=0F является верхним пределом маркера, POP AF снимает адрес CALL, JP Game.Scanner.DrawScannerObjects.NextObject завершает объект
; -----------------------------------------
                ASSERT $ == #987C
                ; проверка верхнего края, переход Game.Scanner.DrawScannerObjects.NextObject снимает адрес вызова
Entry:          LD A, L
                CP #0F
                JR NZ, PreviousRow                                              ; переход, если верхняя граница L=0F не достигнута, рассчитать предыдущую строку

                POP AF
                JP Game.Scanner.DrawScannerObjects.NextObject

                ; расчёт предыдущего знакоместа и перехода между третями экрана
PreviousRow:    SUB #20
                LD L, A
                RET C                                                           ; выход, если вычитание 32 заняло старший байт, H уже указывает нужную треть экрана

                LD A, H
                ADD A, #08
                LD H, A
                RET

                ASSERT $ == #988E
                endmodule
                endmodule
