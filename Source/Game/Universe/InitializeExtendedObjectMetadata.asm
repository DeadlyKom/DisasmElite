                module Universe
                module InitializeExtendedObjectMetadata
; -----------------------------------------
; инициализация расширенных признаков и связей объекта по каталогу модели
; исходный диапазон #7A9E..#7B36
; In:
;   HL, адрес десятибайтовой записи
;   IX, объект
;   IY, модель для отдельного входа 7B15
; Out:
;   первый байт признаков и поля+7..9 инициализированы
;   для 7B15 сохранены две экранные точки
; Corrupt:
;   HL, DE, BC, AF
; Note:
; Таймер+7 получает 18, ссылки+8/+9 обнуляются, присутствие станции ставит+9.7.
; Каталог 6180 имеет записи по 4 байта, поиск сравнивает указатель модели с IX+23/+24.
; Нулевой тип до совпадения означает ошибку, устанавливается SP4120 и выполняется переход 74F4.
; Тип C0 сохраняется непосредственно, остальные объединяются с фазой B454 AND3.
; При bit6 признаков допускаются случайные коррекции bit3/bit4/bit5 с учётом D0B0.6 и наличия станции.
; Отдельный вход 7B15 сохраняет проекцию лазерной вершины IY+14 в+1..3 и вершины 3 в+4..6.
; Для второй точки координаты дополнительно XOR3, обе тройки используются расширенными лучевыми эффектами.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #7A9E
                ; создание таймера и сброс ссылок расширенной записи
Entry:          PUSH HL
                LD DE, #0007
                ADD HL, DE
                LD (HL), #18
                INC HL
                LD (HL), D
                INC HL
                LD (HL), D
                LD A, (Memory.Station + FSpaceObject.Energy)
                AND A
                JR Z, FindBlueprint                                             ; переход, если станционный слот пуст и резервная ссылка станции не ставится

                SET FX_NOSTAT_BIT, (HL)
                ; поиск указателя модели в четырёхбайтовом каталоге
FindBlueprint:  LD E, (IX+FSpaceObject.Blueprint)
                LD D, (IX+FSpaceObject.Blueprint+1)
                LD HL, Memory.ModelIndex
NextBlueprint:  LD C, (HL)
                INC C
                DEC C
                JR NZ, CompareModel                                             ; переход, если найдена ненулевая запись каталога и поиск можно продолжать

                LD SP, Memory.Screen + #0120                                    ; аварийное восстановление стека перед продолжением главного кадра
                JP @Game.Flight.MainGameLoop.DrawObjects

                ; проверка совпадения адреса модели
CompareModel:   INC HL
                LD A, (HL)
                INC HL
                CP E
                LD A, (HL)
                INC HL
                INC HL
                JR NZ, NextBlueprint                                            ; переход, если младший адрес модели не совпал

                CP D
                JR NZ, NextBlueprint                                            ; переход, если старший адрес модели не совпал

                ; расчёт основного типа и фазовых признаков
                POP HL
                LD A, C
                CP FX_PAIR_MASK
                JR Z, StoreFlags                                                ; переход, если тип записи равен C0 и фазу добавлять не нужно

                LD A, (ObjectEffects.Phase)
                AND FX_GROUP_MASK
                OR C
StoreFlags:     LD (HL), A
                BIT FX_GROUP_BIT, A
                RET Z                                                           ; выход, если bit6 типа сброшен и случайные уточнения не нужны

                ; случайная настройка дополнительных признаков поведения
                BIT FX_ENERGY_BIT, C
                JR Z, RandomBitFour                                             ; переход, если тип не запрашивает специальный bit3

                RES FX_ENERGY_BIT, (HL)
                LD A, (State.MissionFlags)
                BIT MS_CLOAK_BIT, A
                JR Z, RandomBitFour                                             ; переход, если оборудование D0B0.6 не разрешает специальный bit3

                CALL Game.Combat.NextRandomByte.Entry
                AND #70
                JR NZ, RandomBitFour                                            ; переход, если случайные биты 4..6 ненулевые и bit3 остаётся сброшенным

                SET FX_ENERGY_BIT, (HL)
RandomBitFour:  BIT FX_SEARCH_BIT, (HL)
                JR Z, CheckBitFive                                              ; переход, если bit4 типа уже сброшен

                CALL Game.Combat.NextRandomByte.Entry
                AND (HL)
                JR NZ, CheckBitFive                                             ; переход, если случайная маска ненулевая и bit4 сохраняется

                RES FX_SEARCH_BIT, (HL)
CheckBitFive:   BIT FX_TIMER_BIT, (HL)
                RET Z                                                           ; выход, если bit5 типа сброшен

                LD A, (Memory.Station + FSpaceObject.Energy)
                AND A
                RET NZ                                                          ; выход, если станция присутствует и bit5 сохраняется

                CALL Game.Combat.NextRandomByte.Entry
                AND #06
                RET Z                                                           ; выход, если случайные биты 1..2 нулевые и bit5 сохраняется

                RES FX_TIMER_BIT, (HL)
                RET

ReadLaserPoint: LD A, (IY+FModel.LaserVertex)
                CALL Game.Wireframe.ReadProjectedVertex.Entry
                LD HL, (ObjectEffects.Current)
                INC HL
                LD (HL), A
                INC HL
                LD (HL), D
                INC HL
                LD (HL), E
                PUSH HL
                LD A, #03
                CALL Game.Wireframe.ReadProjectedVertex.Entry
                POP HL
                INC HL
                LD (HL), A
                INC HL
                LD A, D
                XOR #03
                LD (HL), A
                INC HL
                LD A, E
                XOR #03
                LD (HL), A
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #7B37
                endmodule
                endmodule
