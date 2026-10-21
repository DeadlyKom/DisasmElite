                module Flight
                module InitializeViewAttributes
; -----------------------------------------
; Инициализация 480 атрибутов верхней области
; исходный диапазон #7461..#7466
; In:
;   без параметров
; Out:
;   первые 15 строк атрибутов обзорного окна от Memory.Attributes + #0020 заполнены 07, HL указывает на следующую строку, B=0
; Corrupt:
;   HL, BC, AF
; Note:
;   CALL Game.Flight.Fill240Attributes.Entry заполняет 240 байтов, затем проваливание Game.Flight.Fill240Attributes.Entry выполняет второй такой же проход
; -----------------------------------------
                ASSERT $ == #7461
                ; два прохода Game.Flight.Fill240Attributes.Entry заполняют 480 атрибутов от Memory.Attributes + #0020
Entry:          LD HL, Memory.Attributes + #0020                                ; атрибуты со второй символьной строки
                CALL Game.Flight.Fill240Attributes.Entry                        ; далее Game.Flight.Fill240Attributes.Entry без команды перехода
                ASSERT $ == #7467
                endmodule
                endmodule
