; -----------------------------------------
; Допуск объекта к боевому преследованию
; исходный диапазон #EBA9..#EBC9
; In:
;   IY слот объекта
; Out:
;   C=1 цель допустима, C=0 отказ
; Corrupt:
;   AF
; Note:
;   Значения Flags2=OBJ_STATION_FL и Flags2=1..3 исключены, затем требуется FX_ACTIVE_BIT
;   При FX_GROUP_BIT=1 цель допускается для группы 2/3 либо при OBJ_HOSTILE_BIT в FSpaceObject.Hostility
;   При FX_GROUP_BIT=0 общий TestCollectBit допускает цель при FX_SEARCH_BIT=0, это инверсия критерия груза
; -----------------------------------------
                ; исключение полных сочетаний Flags2=#0C и 1..3 до проверки метаданных
AllowAttack:    LD A, (IY + FSpaceObject.Flags2)
                CP OBJ_STATION_FL
                RET Z                                                           ; выход, если Flags2=#0C, объект исключён из преследования

                DEC A
                CP #03
                CCF
                RET NC                                                          ; выход, если полный байт Flags2 равен 1..3, объект исключён из преследования

                ; проверка активности и группового режима кешированного FEffectRecord10.TypeFlags
                CALL ReadSlotFlags
                AND A
                BIT FX_ACTIVE_BIT, A
                RET Z                                                           ; выход, если FX_ACTIVE_BIT кешированного TypeFlags сброшен

                BIT FX_GROUP_BIT, A
                JR Z, TestCollectBit                                            ; переход, если FX_GROUP_BIT сброшен, применить общий критерий FX_SEARCH_BIT

                ; при групповом режиме достаточно номера группы 2/3 либо враждебности объекта
                BIT 1, A
                JR NZ, ReturnCarry                                              ; переход, если номер двухбитной группы взаимодействий равен 2 или 3, допустить цель

                BIT OBJ_HOSTILE_BIT, (IY + FSpaceObject.Hostility)
                RET Z                                                           ; выход, если OBJ_HOSTILE_BIT поля FSpaceObject.Hostility сброшен

                ; общий успешный допуск цели либо отказ подбора возвращает перенос 1
ReturnCarry:    SCF
                RET
