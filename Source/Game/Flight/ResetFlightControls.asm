                module Flight
                module ResetFlightControls
; -----------------------------------------
; Сброс управления, метаданных и начальной скорости
; исходный диапазон #94F4..#94FD
; In:
;   без параметров
; Out:
;   слова InputMotion.Roll и Pitch обнулены, InputMotion.Speed получает #0C00, далее ClearFlightKeyEvents очищает клавиши
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Game.Extensions.ResetObjectMetadata.Entry возвращает HL=InputMotion.Roll,B=5 и обнуляет 80 байтов объектных метаданных,Game.Flight.ClearBytes.Entry очищает пять байтов
;   управления
; -----------------------------------------
                ASSERT $ == #94F4
                ; сброс метаданных и пяти байтов углов, скорость 12
Entry:          LD B, #05
                CALL Game.Extensions.ResetObjectMetadata.Entry
                CALL Game.Flight.ClearBytes.Entry
                LD (HL), #0C                                                    ; далее Game.Flight.ClearFlightKeyEvents.Entry без команды перехода
                ASSERT $ == #94FE
                endmodule
                endmodule
