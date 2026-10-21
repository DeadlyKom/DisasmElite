; -----------------------------------------
; получение каталожной записи выбранного командира
; исходный диапазон #CBF1..#CBF3
; In:
;   SaveSelection, выбранный номер
; Out:
;   HL=DiskBuffer.Catalog+16*номер
;   AF, A содержит первый байт имени, Z=1 для пустой записи
; Corrupt:
;   HL, AF
; Note:
;   Загружает только индекс и непосредственно продолжает GetSaveRecord, BC и DE сохранены.
; -----------------------------------------
GetSelected:    LD A, (SaveSelection)
                ; JP GetSaveRecord, продолжение в GetSaveRecord.asm
