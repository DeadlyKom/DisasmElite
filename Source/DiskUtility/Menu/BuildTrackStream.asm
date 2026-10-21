; -----------------------------------------
; создание шестнадцати идентификаторов секторов и дополнительного сектора 17
; исходный диапазон #CDEF..#CE34
; In:
;   DiskUtility.Menu.TrackBuffer, начало выходного потока
;   DiskUtility.Menu.VerifySectorID, номер проверочного сектора
;   DiskUtility.Menu.TrackID, байт дорожки для шаблона
; Out:
;   IX, конец созданного потока либо граница Memory.Attributes
;   шаблон DiskUtility.Menu.FormatPattern изменён под последний сектор
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   Межсекторный промежуток выбирается как 44+(R&7), для проверочного сектора 17 он равен 44.
;   Основные сектора имеют номера 1..16, код размера 1 и заполнитель данных 0.
;   При DiskUtility.Menu.VerifySectorID=17 добавляется сектор 17 с кодом размера 0 и заполнителем #80.
;   Количество байтов данных шаблона остаётся B=0, то есть 256, даже при коде размера 0.
;   В конце CALL EmitFillByte дописывает 40 байтов #4E.
;   После этого CALL поток попадает прямо в следующий физический EmitFillByte, при B=0 он дописывает ещё 256.
;   Оба прохода прекращаются у IXH=#58, фактическая длина ограничена буфером.
; -----------------------------------------
                ; расчёт длины промежутка и подготовка обычного сектора
BuildTrackData: LD IX, (TrackBuffer)
                LD A, (VerifySectorID)
                XOR #11
                JR Z, SetTrackGap                                               ; переход, если проверочный сектор равен 17 и промежуток должен быть ровно 44 байта

                LD A, R
                AND #07
SetTrackGap:    ADD A, #2C
                LD (GapCount), A
                XOR A
                LD (SectorFill), A
                INC A
                LD (SectorSize), A
                ; обновление номера идентификатора и развёртывание шаблона
MainSector:     LD (SectorID), A
                PUSH AF
                CALL EmitSectorData
                POP AF
                INC A
                CP #11
                JR C, MainSector                                                ; переход, если ещё не созданы все основные сектора с номерами 1..16

                LD A, (VerifySectorID)
                CP #11
                JR NZ, EndTrackGap                                              ; переход, если проверочный сектор отличается от 17 и дополнительный сектор не нужен

                LD (SectorID), A
                XOR A
                LD (SectorSize), A
                LD A, #80
                LD (SectorFill), A
                CALL EmitSectorData
                ; добавление конечного заполнителя с последующим общим хвостом
EndTrackGap:    LD D, #4E
                LD B, #28
                CALL EmitFillByte
                ; JP EmitFillByte, продолжение в EmitRepeatedByte.asm
