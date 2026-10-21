; -----------------------------------------
; Отказ от объекта как собираемого груза
; исходный диапазон #EBCA..#EBE0
; In:
;   IY слот объекта
; Out:
;   C=0 допустим для сбора, C=1 отвергнут
; Corrupt:
;   AF
; Note:
;   Flags2=OBJ_STATION_FL всегда отвергается
;   затем в TypeFlags требуются FX_ACTIVE_BIT=1, FX_GROUP_BIT=0, FX_SEARCH_BIT=1
;   DiskUtility.Demo.CheckCargoFlag принимает готовый A и используется CountCargo, DiskUtility.Demo.TestCollectBit также общий хвост AllowAttack
; -----------------------------------------
                ; полное сочетание Flags2=#0C исключает подбор объекта
RejectCargo:    LD A, (IY + FSpaceObject.Flags2)
                CP OBJ_STATION_FL
                JR Z, ReturnCarry                                               ; переход, если Flags2 объекта равен #0C, вернуть отказ с переносом

                CALL ReadSlotFlags
                ; общая проверка готового классификатора для CountCargo
CheckCargoFlag: SCF
                BIT FX_ACTIVE_BIT, A
                RET Z                                                           ; выход, если FX_ACTIVE_BIT кешированного TypeFlags сброшен, вернуть отказ с переносом

                BIT FX_GROUP_BIT, A
                RET NZ                                                          ; выход, если FX_GROUP_BIT кешированного TypeFlags установлен, вернуть отказ с переносом

                ; FX_SEARCH_BIT завершает противоположные критерии боевой цели и подбора
TestCollectBit: SCF
                BIT 4, A
                RET Z                                                           ; выход, если FX_SEARCH_BIT кешированного TypeFlags сброшен, сохранить перенос результата

                AND A
                RET
