                module Extensions
                module UpdateStationAndSpecialShips
; -----------------------------------------
; обновление станции, появление особых кораблей и перенос станции к солнцу
; исходный диапазон #5F11..#5FA0
; смысловое имя UpdateStationAndSpawnSpecialShips
; In: IX=Memory.Station, станционный слот от вызывающего Game.Universe.UpdateStationCoordinates.Entry
; Out: координаты станции обновлены, при условиях создаются Thargoid, Viper либо Asp
; Corrupt: HL, DE, BC, AF и рабочие поля вызываемых процедур, IX восстанавливается после создания
; Game.Combat.ApplyPlayerMotion.Entry учитывает движение игрока, Game.Combat.UpdateClockAndRotateDistantBodies.Entry обновляет счётчик времени вторжения
; Game.Circles.CheckSystemCoordinateBand.Entry выбирает солнечную ветку при разности значений Y - X текущего State.SystemSeed от -8 до 7
; Вне этой полосы оценка расстояния до планеты Game.Screen.PlanetDistanceHint.Entry должна быть меньше 7, затем Game.Text.CheckMissionRegion.Entry с порогом 0 разрешает Thargoid типа #0F при C=1
; При C=0 вместо него допускается Viper типа 8, если галактика State.Galaxy!=0, Mission3!=4 и правовой статус State.LegalStatus>=#7F
; В солнечной полосе Game.Screen.SunDistanceHint.Entry должен вернуть C=0 и A<12, A=6 ничего не меняет
; При A=7..11 создаётся Asp типа #0D, очередь CargoEvent/CargoEvent + FFlightEvent.Token получает #80/#F4, то есть запрос и токен предложения Cobra Mk4
; При A<6 и свободном втором слоте старшие модули/знаки солнца FlightState.Sun переносятся в станцию, затем 39 байтов копируются в Memory.Objects
; Game.Universe.SetStationEnergy.Entry перед копированием задаёт энергию станции #F0, OBJ_HOSTILE_BIT в FSpaceObject.Hostility станции снимается перед копией
; После LDIR и INC HL адрес равен Memory.Objects + FSpaceObject.X.Low, XOR4 меняет бит 2 среднего байта X второго слота, смещая его относительно станции
; Ветка копии удаляет внутренний адрес возврата POP HL и продолжает вызывающий расчёт с Game.Universe.UpdateStationCoordinates.CheckNearFlag
; На пути создания энергия второго слота Memory.Objects + FSpaceObject.Energy временно равна #7E, поэтому поиск Game.Objects.FindFreeObjectSlot.Entry не может занять его, затем прежняя энергия восстанавливается
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #5F11
                ; подготовка боевых и проекционных параметров для добавления объекта
                ; миссии 3, 7 INVASION, оккупированная область выбирает военный корабль, состояние 4 исключает обычный Viper
                ; описание в Docs/Manual.md, раздел mission-3, mission-7-invasion
Entry:          CALL Game.Combat.ApplyPlayerMotion.Entry
                CALL Game.Combat.UpdateClockAndRotateDistantBodies.Entry
                CALL Game.Circles.CheckSystemCoordinateBand.Entry
                JR Z, NearSun                                                   ; переход, если разность Y-X системы находится между-8 и 7, обработать солнечную ветку

                ; проверка допустимого диапазона результата проекции
                CALL Game.Screen.PlanetDistanceHint.Entry
                CP #07
                RET NC                                                          ; выход, если оценка расстояния до планеты не меньше 7, корабль не создаётся

                CALL Game.Text.CheckMissionRegion.Entry
                NOP
                LD B, #0F
                JR C, SpawnShip                                                 ; переход, если текущая система внутри занятой зоны вторжения, создать Thargoid типа #0F

                ; проверка системных условий дополнительного корабля типа 8
                LD A, (State.Galaxy)
                AND A
                RET Z                                                           ; выход, если текущая галактика имеет индекс 0, полицейский Viper не создаётся

                LD A, (State.Mission3)
                CP #04
                RET Z                                                           ; выход, если третья миссия находится в состоянии 4, полицейский Viper не создаётся

                LD A, (State.LegalStatus)
                CP #7F
                LD B, #08
                JR NC, SpawnShip                                                ; переход, если правовой статус не меньше #7F, создать полицейский Viper типа 8

                RET

                ; проверка альтернативного проекционного случая и свободного соседнего слота
                ; миссия 6 Cobra Mk4, околосолнечная ветвь подготавливает особые объекты и предложение Cobra Mk4
                ; описание в Docs/Manual.md, раздел mission-6
NearSun:        CALL Game.Screen.SunDistanceHint.Entry
                RET C                                                           ; выход, если Game.Screen.SunDistanceHint.Entry сообщил геометрический отказ

                CP #0C
                RET NC                                                          ; выход, если результат Game.Screen.SunDistanceHint.Entry не меньше 12, обработка не требуется

                CP #06
                RET Z                                                           ; выход, если результат Game.Screen.SunDistanceHint.Entry равен 6, обработка не требуется

                LD B, #0D
                JR NC, OfferCobra                                               ; переход, если оценка расстояния до солнца находится между 7 и 11, предложить Cobra Mk4 и создать Asp

                LD A, (IX+FSpaceObject+FSpaceObject.Energy)
                AND A
                RET NZ                                                          ; выход, если энергия соседнего слота ненулевая, перенос невозможен

                PUSH IX
                POP HL
                LD B, #03
                LD DE, FlightState.Sun
CopySunAxis:    INC HL
                INC DE
                LD A, (DE)
                LD (HL), A
                INC HL
                INC DE
                LD A, (DE)
                AND #80
                LD (HL), A
                INC HL
                INC DE
                DJNZ CopySunAxis

                LD L, #48
                LD DE, Memory.Objects
                LD C, #27
                RES OBJ_HOSTILE_BIT, (IX+FSpaceObject.Hostility)
                CALL Game.Universe.SetStationEnergy.Entry
                LDIR
                INC HL
                LD A, (HL)
                XOR #04
                LD (HL), A
                POP HL
                JP Game.Universe.UpdateStationCoordinates.CheckNearFlag

                ; установка запроса и токена предложения Cobra Mk4 перед созданием Asp
OfferCobra:     LD HL, #F480                                                    ; H токен #F4, L флаг ожидания #80 в паре события
                LD (CargoEvent), HL
                ; временная защита соседнего слота от поиска свободного места
SpawnShip:      PUSH IX
                LD A, (Memory.Objects + FSpaceObject.Energy)
                PUSH AF
                LD (IX+FSpaceObject+FSpaceObject.Energy), #7E
                ; поиск свободного слота и создание объекта выбранного типа
                PUSH BC
                CALL Game.Objects.FindFreeObjectSlot.Entry
                POP BC
                LD A, B
                CALL Z, Game.Objects.InitializeObject.Entry                     ; вызов, если найден свободный слот, инициализировать выбранный тип
                ; восстановление временной энергии и указателя исходного объекта
                POP AF
                LD (Memory.Objects + FSpaceObject.Energy), A
                POP IX
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #5FA1
                endmodule
                endmodule
