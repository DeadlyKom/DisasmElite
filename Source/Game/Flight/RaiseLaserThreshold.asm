                module Flight
                module RaiseLaserThreshold
; -----------------------------------------
; Установка старшего разряда вероятностного порога лазера
; исходный диапазон #9389..#9390
; In:
;   без параметров
; Out:
;   LaserThreshold bit7 установлен, HL сохранён
; Corrupt:
;   регистры и флаги сохранены
; Note:
;   PUSH/POP сохраняют HL, команда SET не изменяет флаги, остальные регистры не затрагиваются
; -----------------------------------------
                ASSERT $ == #9389
                ; установка старшего разряда порога CP, проверяемого при включённой маскировке
Entry:          PUSH HL
                LD HL, LaserThreshold
                SET LASER_PASS_BIT, (HL)
                POP HL
                RET
                ASSERT $ == #9391
                endmodule
                endmodule
