                module Extensions
                module MarkObjectEventAndUpdateMetadata
; -----------------------------------------
; пометка события объекта и условная повторная инициализация его метаданных
; исходный диапазон #F916..#F92C
; смысловое имя MarkObjectEventAndUpdateMetadata
; In: HL — байт состояния, AF — сохраняемое значение для #9C96, IX — объект
; Out: #9C96=A, бит 7 (HL) установлен, при разрешённых условиях вызвана #7A9E
; Corrupt: HL, DE, BC, AF по контракту #7A9E
; INC/DEC проверяют прежнее значение (HL), SET не меняет полученные флаги
; При прежнем нуле #7A9E вызывается сразу, иначе нужны бит 6 (HL) и бит 1 IX+26
; AF вокруг самого вызова сохраняется, но входные флаги до проверок не сохраняются
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #F916
                ; сохранение события и проверка прежнего байта состояния
Entry:          LD (CombatState.ObjectsPresent), A
                INC (HL)
                DEC (HL)
                SET FX_ACTIVE_BIT, (HL)
                JR Z, UpdateMetadata                                            ; переход, если прежний байт состояния был нулевым, переинициализировать метаданные

                ; проверка двух флагов допуска повторной инициализации метаданных
                BIT FX_GROUP_BIT, (HL)
                RET Z                                                           ; выход, если бит 6 состояния сброшен

                BIT OBJ_SCOOP_BIT, (IX+FSpaceObject.Flags2)
                RET Z                                                           ; выход, если флаг захвата объекта ковшом сброшен

                ; обработка события с сохранением AF вокруг общего обработчика
UpdateMetadata: PUSH AF
                CALL Game.Universe.InitializeExtendedObjectMetadata.Entry
                POP AF
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #F92D
                endmodule
                endmodule
