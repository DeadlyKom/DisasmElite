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
;   #EF01 может заменить индекс модели B, HL возвращает каталог #6180
;   указатель заголовка читается из каталог + 4*(B AND 63) + 1 и сохраняется в IX+23/24
;   31 байт шаблона #B83E копируется в IX+00..1E, поле IX+1F не очищается
;   энергия берётся из IY+07, скорость равна половине IY+06
;   флаги IX+21 := (IY+12) AND #6F, EscapePod переносится из бита 7 IY+12 в бит 7 IX+20
;   младшие три бита IX+20 задаются результатом #D60B, бит 6 включается, IX+25=#7E,IX+26=0
;   при сброшенном IX+21 bit2 случайны целые X/Y, дробные X/Y и знаки случайны всегда
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
                ; расчёт начального запаса запусков, обработчик также читает байт за границей слота IX+27
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
