                module Objects
                module InitializeObject
; -----------------------------------------
; инициализация слота по индексу четырёхбайтового каталога моделей
; исходный диапазон #B898..#B91D
; In:
;   AF - A индекс модели
;   IX - заполняемый слот
; Out:
;   AF - A=0 и Z установлен
;   IX - тот же слот
;   IY - заголовок выбранной модели
; Corrupt:
;   HL, DE, BC, AF, IY
; Note:
;   Game.Menus.ChooseEncounterVariant.Entry может заменить индекс модели B, HL возвращает каталог Memory.ModelIndex
;   адрес FModel читается из FModelIndex.Address выбранного элемента Memory.ModelIndex и сохраняется в FSpaceObject.Blueprint
;   31 байт ObjectTemplate заполняет FSpaceObject от X до Pitch включительно, FSpaceObject.Payload не очищается
;   FSpaceObject.Energy получает FModel.MaxEnergy, FSpaceObject.Speed получает половину FModel.MaxSpeed
;   FSpaceObject.Hostility получает FModel.Flags после MODEL_AI_MASK, OBJ_ESCAPE_BIT переносится из FModel.Flags в FSpaceObject.Flags
;   Game.Text.CheckObjectRandomGate.Entry задаёт остаток запусков в FSpaceObject.Flags по OBJ_LAUNCH_MASK, OBJ_ACTIVE_BIT включается, FSpaceObject.Target=#7E, FSpaceObject.Flags2=0
;   при сброшенном OBJ_HOSTILE_BIT в FSpaceObject.Hostility случайны FSpaceObject.X.Low и FSpaceObject.Y.Low, дробные части и знаки X/Y случайны всегда
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #B898
Entry:          CALL Game.Menus.ChooseEncounterVariant.Entry
                LD A, B
ModelIndex:     AND #3F
                ADD A, A
                ADD A, A
                ADD A, L
                LD L, A
                JR NC, ReadBlueprint                                            ; переход, если смещение каталога не вызвало перенос младшего байта

                INC H
                ; чтение адреса модели из четырёхбайтового элемента каталога
ReadBlueprint:  INC HL
                LD E, (HL)
                INC HL
                LD D, (HL)
                PUSH DE
                POP IY
                LD (IX+FSpaceObject.Blueprint+FSignWord.SignHigh), D
                LD (IX+FSpaceObject.Blueprint), E
                PUSH IX
                POP DE
                ; копирование начальных координат и осей из 31-байтового шаблона
                LD BC, #001F
                LD HL, ObjectTemplate
                LDIR
                ; перенос максимальной энергии модели в текущую энергию слота
                LD A, (IY+FModel.MaxEnergy)
                LD (IX+FSpaceObject.Energy), A
                ; выделение флагов модели и перенесение EscapePod в отдельный флаг слота
                LD A, (IY+FModel.Flags)
                LD C, A
                AND MODEL_AI_MASK
                LD (IX+FSpaceObject.Hostility), A
                ; расчёт начального запаса запусков с чтением байта сразу за записью, по адресу IX + FSpaceObject, это не дополнительное поле объекта
                CALL Game.Text.CheckObjectRandomGate.Entry
                AND OBJ_LAUNCH_MASK
                RLA
                RL C
                RRA
                LD (IX+FSpaceObject.Flags), A
                ; расчёт начальной скорости как половины предельной скорости модели
                LD A, (IY+FModel.MaxSpeed)
                SRL A
                LD (IX+FSpaceObject.Speed), A
                LD A, #7E
                LD (IX+FSpaceObject.Target), A
                XOR A
                LD (IX+FSpaceObject.Flags2), A
                SET OBJ_ACTIVE_BIT, (IX+FSpaceObject.Flags)
                ; проверка необходимости случайного начального X/Y
                BIT OBJ_HOSTILE_BIT, (IX+FSpaceObject.Hostility)
                JR NZ, RandomPosition                                           ; переход, если бит враждебности модели установлен и целые X/Y берутся из шаблона

                CALL Game.Combat.NextRandomByte.Entry
                AND #07
                LD (IX+FSpaceObject.X.Low), A
                CALL Game.Combat.NextRandomByte.Entry
                AND #07
                LD (IX+FSpaceObject.Y.Low), A
                ; создание дробных координат и случайных знаков X/Y
RandomPosition: CALL Game.Combat.NextRandomByte.Entry
                LD (IX+FSpaceObject.X.Fraction), A
                CALL Game.Combat.NextRandomByte.Entry
                LD (IX+FSpaceObject.Y.Fraction), A
                CALL Game.Combat.NextRandomByte.Entry
                RRA
                RR (IX+FSpaceObject.X.SignHigh)
                RRA
                RR (IX+FSpaceObject.Y.SignHigh)
                XOR A
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #B91E
                endmodule
                endmodule
