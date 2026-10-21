                module Galaxy
                module CopySystemNameToTarget
; -----------------------------------------
; Копирование имени в буфер назначения
; исходный диапазон #E080..#E08B
; In:
;   GalaxyState.GeneratedName = имя 8 байт
; Out:
;   восемь букв GalaxyState.TargetName обновлены, HL указывает на завершающий ноль GeneratedName, DE на ноль TargetName, BC=0
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
