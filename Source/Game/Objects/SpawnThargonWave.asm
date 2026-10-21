                module Objects
                module SpawnThargonWave
; -----------------------------------------
; создание от трёх до шести таргонов до исчерпания слотов
; исходный диапазон #B96B..#B99E
; In:
;   игровое состояние и генератор случайных чисел
; Out:
;   созданные слоты с моделью #0F, ранний выход при отсутствии места
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
;   число попыток равно (результат Game.Universe.CheckSpecialSystemOrRandom.Entry AND 3)+3, старое имя 3_4 неточно
;   каждому объекту устанавливается TARGET_ECM_BIT в FSpaceObject.Target, FSpaceObject.Z.Low=(random AND 15) OR 4, FSpaceObject.Y.Low=0
;   Xm выбирается из бита 3 Zm, направление изменяется через Game.Objects.RandomizeSpawnDirection.Entry
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #B96B
Entry:          CALL Game.Universe.CheckSpecialSystemOrRandom.Entry
                AND #03
                ADD A, #03
                LD C, A
                ; поиск слота для очередного таргона
SpawnNext:      CALL Game.Objects.FindFreeObjectSlot.Entry
                RET NZ                                                          ; выход, если для очередного таргона нет свободного слота

                LD A, #0F
                PUSH BC
                CALL Game.Objects.InitializeObject.Entry
                SET TARGET_ECM_BIT, (IX+FSpaceObject.Target)
                CALL Game.Combat.NextRandomByte.Entry
                AND #0F
                OR #04
                LD (IX+FSpaceObject.Z.Low), A
                RRA
                RRA
                RRA
                AND #01
                LD (IX+FSpaceObject.X.Low), A
                XOR A
                LD (IX+FSpaceObject.Y.Low), A
                CALL Game.Objects.RandomizeSpawnDirection.Entry
                POP BC
                DEC C
                JR NZ, SpawnNext                                                ; переход, если остались неиспользованные попытки создать таргон

                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #B99F
                endmodule
                endmodule
