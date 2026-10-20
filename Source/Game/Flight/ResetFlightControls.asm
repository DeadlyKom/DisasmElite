                module Flight
                module ResetFlightControls
; -----------------------------------------
; Сброс управления, метаданных и начальной скорости
; исходный диапазон #94F4..#94FD
; In:
;   без параметров
; Out:
;   FF08..FF0C=0,FF0D=12, далее очистка клавиш 94FE
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   F9AB возвращает HL=FF08,B=5 и обнуляет 80 байтов объектных метаданных,9503 очищает пять байтов
;   управления
; -----------------------------------------
                ASSERT $ == #94F4
                ; сброс метаданных и пяти байтов углов, скорость 12
Entry:          LD B, #05
                CALL Game.Extensions.ResetObjectMetadata.Entry
                CALL Game.Flight.ClearBytes.Entry
                LD (HL), #0C
                ASSERT $ == #94FE
                endmodule
                endmodule
