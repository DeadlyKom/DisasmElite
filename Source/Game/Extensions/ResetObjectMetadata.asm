                module Extensions
                module ResetObjectMetadata
; -----------------------------------------
; инициализация общей области метаданных объектов
; исходный диапазон #F9AB..#F9C8
; смысловое имя ResetObjectMetadata
; In: (#D05F) — правовой статус пилота
; Out: #B456=0 либо 4, #B457..#B4A6 обнулены, HL=#FF08, B=5, C=0
; Corrupt: HL, DE, BC, AF
; При #D05F>=#38 включается бит 2 общего режима
; Одна начальная запись нуля и LDIR длиной #4F очищают ровно 80 байтов
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #F9AB
                ; проверка правового статуса и инициализация общего флага метаданных
Entry:          LD HL, ObjectEffects.Flags
                LD (HL), #00
                LD A, (State.LegalStatus)
                CP #38
                JR C, ClearRecords                                              ; переход, если #D05F меньше #38, оставить общий режим нулевым

                SET FX_ALLOW_BIT, (HL)
                ; обнуление 80 байтов рабочих записей последовательным распространением нуля
ClearRecords:   INC HL
                LD DE, ObjectEffects.Records + 1
                LD BC, #004F
                LD (HL), B
                LDIR
                LD B, #05
                LD HL, InputMotion.Roll
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #F9C9
                endmodule
                endmodule
