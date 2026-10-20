                module Galaxy
                module CopySystemNameToTarget
; -----------------------------------------
; Копирование имени в буфер назначения
; исходный диапазон #E080..#E08B
; In:
;   DEDB = имя 8 байт
; Out:
;   DEED..DEF4 обновлены, HL=DEE3, DE=DEF5, BC=0
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Копирует ровно 8 байт, следующий нулевой байт назначения отдельно не меняется
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E080
                ; копирование готового имени системы в девятибайтовый буфер назначения
Entry:          LD BC, #0008
                LD HL, GalaxyState.GeneratedName
                LD DE, GalaxyState.TargetName
                LDIR
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #E08C
                endmodule
                endmodule
