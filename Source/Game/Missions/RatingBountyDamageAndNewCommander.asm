                module Missions
                module RatingBountyDamageAndNewCommander
; -----------------------------------------
; прибавление к рейтингу и обработка переноса, Game.Missions.RatingBountyDamageAndNewCommander.Entry
; исходный диапазон #D1C7..#D2DD
; In:
;   DE, беззнаковое приращение младшего слова State.Rating
; Out:
;   при отсутствии переноса обновлено только младшее слово рейтинга
;   при переносе старший байт увеличен, обработаны вторжение и событие FlightEvents + 6 * FFlightEvent + FFlightEvent.ColumnFlags
;   DE, BC, IX, IY сохранены
; Corrupt:
;   HL, AF
; Note:
;   старший байт объединяет числовой рейтинг и военные состояния, после переноса Game.Extensions.UpdateInvasionOnRatingOverflow.Entry может изменить его
;   PayBounty, DamageItem и ResetCommander являются самостоятельными входами
;   между DamageItem и ResetCommander лежит 102-байтовый исходный шаблон командира
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D1C7
                ; сложение DE с младшими 16 битами рейтинга, перенос увеличивает State.RankState
                ; миссия 7 INVASION, переполнение рейтинга передаётся проверке начала войны
                ; описание в Docs/Manual.md, раздел mission-7-invasion
Entry:          LD HL, State.Rating
                LD A, (HL)
                ADD A, E
                LD (HL), A
                INC HL
                LD A, (HL)
                ADC A, D
                LD (HL), A
                RET NC                                                          ; выход, если приращение не переполнило младшее слово рейтинга

                INC HL
                INC (HL)
                CALL Game.Extensions.UpdateInvasionOnRatingOverflow.Entry
                JR SetEvent

                ; дополнительный вход денежной награды, нулевая сумма не создаёт сообщения
; -----------------------------------------
; зачисление денежной награды и постановка уведомления, Game.Missions.RatingBountyDamageAndNewCommander.PayBounty
; In:
;   DE, сумма в десятых кредита, 0..9999
; Out:
;   при DE=0 немедленный возврат без записи
;   иначе CashLow/CashHigh увеличены, FlightMessage.Reward содержит исходную сумму, FlightEvents + 4 * FFlightEvent + FFlightEvent.ColumnFlags.7=1
;   BC, IX, IY сохранены, рейтинг не изменяется
; Corrupt:
;   HL, DE, AF
; Note:
;   AddCashLow нормализует младшую денежную группу одним переносом при достижении 10000
;   при ненулевой выплате DE=10000 без переноса либо DE=1 при переносе
; -----------------------------------------
PayBounty:      LD A, D
                OR E
                RET Z                                                           ; выход, если денежная награда DE равна нулю

                LD (FlightMessage.Reward), DE
                CALL Game.Economy.AddCashLow.Entry
                LD HL, FlightEvents + 4 * FFlightEvent
SetEvent:       SET EVENT_WAIT_BIT, (HL)
                RET

                ; выбор повреждения из шести старших битов полётного параметра
; -----------------------------------------
; выбор повреждения по сохранённому полётному параметру, Game.Missions.RatingBountyDamageAndNewCommander.DamageItem
; In:
;   FlightMessage.Token, код текущего сообщения
;   FlightState.RandomByte, сохранённый полётный параметр
; Out:
;   при FlightMessage.Token=#FD повреждение запрещено
;   индекс 0 обнуляет топливо, 1..6 повреждают устройство, 7..16 одну тонну товара 2..11
;   индексы 17..63 возвращаются без изменения
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   индекс равен FlightState.RandomByte >> 2, два RRCA и AND #3F выделяют старшие шесть битов
;   новых случайных чисел этот вход не получает
;   нулевое поле устройства или пустой слот груза сохраняются
;   для устройства устанавливается бит 7 и прибавляется 1 по модулю 256
;   после повреждения создаётся событие FlightEvents + 3 * FFlightEvent + FFlightEvent.ColumnFlags и код предмета в FlightMessage.DamagedItem, обновляются цвета приборов
; -----------------------------------------
DamageItem:     LD A, (FlightMessage.Token)
                CP #FD
                RET Z                                                           ; выход, если код текущего сообщения равен FD, повреждение запрещено

                LD A, (FlightState.RandomByte)
                RRCA
                RRCA
                AND #3F
                JP Z, Game.Travel.EmptyFuelWithWarning.Entry                    ; переход, если случайный индекс повреждения равен нулю, потерять топливо

                CP #11
                RET NC                                                          ; выход, если случайный индекс не меньше 17, ничего не повреждать

                DEC A
                CP #06
                JR NC, DamageCargo                                              ; переход, если после вычитания единицы индекс не меньше 6, повреждать груз

                AND A
                JR Z, SelectDevice                                              ; переход, если выбрана первая категория повреждения, сместить индекс оборудования

                ADD A, #02
                ; адресация повреждаемого устройства в странице D0, нулевое поле не меняется
SelectDevice:   ADD A, #85
                LD L, A
                LD H, #D0
                INC (HL)
                DEC (HL)
                RET Z                                                           ; выход, если выбранное оборудование отсутствует

                SET DEVICE_SIGN_BIT, (HL)
                INC (HL)
                ADD A, #E7
QueueDamage:    LD (FlightMessage.DamagedItem), A
                CALL Game.Flight.DispatchDeviceAndAppendDigit.Entry
                LD HL, FlightEvents + 3 * FFlightEvent
                SET EVENT_WAIT_BIT, (HL)
                RET

                ; повреждение грузового слота, уменьшение количества и возврат места в трюме
DamageCargo:    LD HL, State.Cargo - 4
CargoOffset     EQU $ + 1                                                       ; операнд CALL прибавления индекса к адресу груза
                CALL Game.Trade.AddByteOffsetToHL.Entry
                LD A, (HL)
                AND A
                RET Z                                                           ; выход, если в выбранном грузовом слоте нет товара

                DEC (HL)
                LD HL, State.FreeCargo
                INC (HL)
                LD A, #CC
                ADD A, E
                JR QueueDamage

                ; резерв состояния командира, при первом запуске содержит исходного JAMESON
                ; DiskUtility.Menu.BackupPilot перезаписывает его текущей записью при работе с диском
                ; ResetCommander читает резерв при восстановлении пилота
NewCommander    FCommander {
                    {                                                           ; FCommander.Name, имя командира, поле из 11 байтов
                        #4A, #41, #4D, #45, #53, #4F,
                        #4E, #20, #20, #20, #00
                    },
                    #00,                                                        ; FCommander.LegalStatus, степень преследования, 0 законопослушный, от 50 разыскиваемый
                    #0000,                                                      ; FCommander.Rating, младшие 16 бит боевого рейтинга
                    #00,                                                        ; FCommander.RankState, старший рейтинг и военное состояние, схема FCommander.RankState
                    #00,                                                        ; FCommander.JumpCount, младший байт счётчика переходов
                    #00,                                                        ; FCommander.JumpFlags, старшие разряды счётчика и флаг допуска миссий
                    #00,                                                        ; FCommander.Galaxy, номер галактики, 0..7
                    #0000,                                                      ; FCommander.CashHigh, старшая часть денег, тысячи кредитов
                    #03E8,                                                      ; FCommander.CashLow, младшая часть денег, десятые доли кредита
                    #00,                                                        ; FCommander.MarketRandom, случайный параметр воспроизводимого рынка
                    {                                                           ; FCommander.Cargo, количества товаров в трюме, структура FGoods
                        #00,                                                    ; FGoods.Food, продовольствие, т
                        #00,                                                    ; FGoods.Textiles, текстиль, т
                        #00,                                                    ; FGoods.Radioactives, радиоактивные материалы, т
                        #00,                                                    ; FGoods.Slaves, рабы, т
                        #00,                                                    ; FGoods.Liquor, алкоголь, т
                        #00,                                                    ; FGoods.Luxuries, предметы роскоши, т
                        #00,                                                    ; FGoods.Narcotics, наркотики, т
                        #00,                                                    ; FGoods.Computers, компьютеры, т
                        #00,                                                    ; FGoods.Machinery, промышленное оборудование, т
                        #00,                                                    ; FGoods.Alloys, сплавы, т
                        #00,                                                    ; FGoods.Firearms, огнестрельное оружие, т
                        #00,                                                    ; FGoods.Furs, меха, т
                        #00,                                                    ; FGoods.Minerals, минералы, т
                        #00,                                                    ; FGoods.Gold, золото, кг
                        #00,                                                    ; FGoods.Platinum, платина, кг
                        #00,                                                    ; FGoods.Gemstones, драгоценные камни, г
                        #00                                                     ; FGoods.AlienItems, инопланетные предметы, т
                    },
                    #14,                                                        ; FCommander.FreeCargo, свободное место в трюме, тонны
                    #01,                                                        ; FCommander.FrontLaser, тип переднего лазера
                    #00,                                                        ; FCommander.RearLaser, тип заднего лазера
                    #00,                                                        ; FCommander.LeftLaser, тип левого лазера
                    #00,                                                        ; FCommander.RightLaser, тип правого лазера
                    #00,                                                        ; FCommander.Mission1, состояние первой миссии
                    #46,                                                        ; FCommander.Fuel, топливо в десятых долях светового года, максимум 70
                    #03,                                                        ; FCommander.Missiles, количество ракет
                    #00,                                                        ; FCommander.LargeCargo, состояние расширенного трюма
                    #00,                                                        ; FCommander.ECM, наличие и состояние системы ECM
                    #00,                                                        ; FCommander.AlienComputer, состояние инопланетного компьютера и счётчик его событий
                    #00,                                                        ; FCommander.MineralLife, состояние живой колонии минералов
                    #00,                                                        ; FCommander.FuelScoops, наличие и состояние топливного ковша
                    #00,                                                        ; FCommander.EscapePod, наличие спасательной капсулы
                    #00,                                                        ; FCommander.EnergyBomb, наличие и состояние энергетической бомбы
                    #00,                                                        ; FCommander.EnergyUnit, наличие и состояние энергетического блока
                    #00,                                                        ; FCommander.DockComputer, наличие и состояние стыковочного компьютера
                    #00,                                                        ; FCommander.GalacticDrive, наличие и состояние галактического гиперпривода
                    #00,                                                        ; FCommander.ShipUpgrade, код установленного улучшения корабля
                    #00,                                                        ; FCommander.Invasion, фаза и размер области вторжения
                    {                                                           ; FCommander.GalaxySeed, шесть байтов семени галактики
                        #4A,                                                    ; FSystemSeed.NameBits, бит 6 выбирает четыре слога вместо трёх
                        #5A,                                                    ; FSystemSeed.Y, координата Y, биты 2..0 дают исходную экономику
                        #48,                                                    ; FSystemSeed.GovBits, биты 5..3 задают правительство
                        #02,                                                    ; FSystemSeed.X, координата X, биты 1..0 участвуют в технологии
                        #53,                                                    ; FSystemSeed.MixLow, младший байт третьего слова при шаге генератора
                        #B7                                                     ; FSystemSeed.Syllable, биты 4..0 задают индекс слога имени
                    },
                    {                                                           ; FCommander.SystemSeed, шесть байтов семени текущей системы
                        #38,                                                    ; FSystemSeed.NameBits, бит 6 выбирает четыре слога вместо трёх
                        #AD,                                                    ; FSystemSeed.Y, координата Y, биты 2..0 дают исходную экономику
                        #9C,                                                    ; FSystemSeed.GovBits, биты 5..3 задают правительство
                        #14,                                                    ; FSystemSeed.X, координата X, биты 1..0 участвуют в технологии
                        #1D,                                                    ; FSystemSeed.MixLow, младший байт третьего слова при шаге генератора
                        #15                                                     ; FSystemSeed.Syllable, биты 4..0 задают индекс слога имени
                    },
                    #05,                                                        ; FCommander.Technology, технологический уровень системы, счёт с нуля
                    #03,                                                        ; FCommander.Government, тип правительства системы, 0..7
                    {                                                           ; FCommander.MarketStock, остатки товаров станции, структура FGoods
                        #11,                                                    ; FGoods.Food, продовольствие, т
                        #12,                                                    ; FGoods.Textiles, текстиль, т
                        #1A,                                                    ; FGoods.Radioactives, радиоактивные материалы, т
                        #0E,                                                    ; FGoods.Slaves, рабы, т
                        #27,                                                    ; FGoods.Liquor, алкоголь, т
                        #08,                                                    ; FGoods.Luxuries, предметы роскоши, т
                        #00,                                                    ; FGoods.Narcotics, наркотики, т
                        #00,                                                    ; FGoods.Computers, компьютеры, т
                        #0A,                                                    ; FGoods.Machinery, промышленное оборудование, т
                        #19,                                                    ; FGoods.Alloys, сплавы, т
                        #00,                                                    ; FGoods.Firearms, огнестрельное оружие, т
                        #00,                                                    ; FGoods.Furs, меха, т
                        #3D,                                                    ; FGoods.Minerals, минералы, т
                        #0E,                                                    ; FGoods.Gold, золото, кг
                        #11,                                                    ; FGoods.Platinum, платина, кг
                        #0C,                                                    ; FGoods.Gemstones, драгоценные камни, г
                        #00                                                     ; FGoods.AlienItems, инопланетные предметы, т
                    },
                    #00,                                                        ; FCommander.Mission3, этап миссии 3 и служебное состояние войны
                    #00,                                                        ; FCommander.MissionFlags, награды, особое оборудование и занятость трюма миссией
                    {                                                           ; FCommander.SunPosition, три трёхбайтовые координаты солнца
                        {#27, #08, #01},                                        ; FSpacePosition.X, FCoordinate {Fraction, Low, SignHigh}
                        {#2A, #4D, #8F},                                        ; FSpacePosition.Y, FCoordinate {Fraction, Low, SignHigh}
                        {#F2, #88, #05}                                         ; FSpacePosition.Z, FCoordinate {Fraction, Low, SignHigh}
                    }
                }
                ASSERT $ - NewCommander == FCommander
                ; восстановление командира из NewCommander и пересчёт производных данных
; -----------------------------------------
; восстановление командира из резерва и пересчёт производного состояния
; In:
;   NewCommander, резерв структуры FCommander, обновляемый входом DiskUtility.Menu.BackupPilot
; Out:
;   поля перед FCommander.SunPosition скопированы из NewCommander в State.Name
;   NewCommander.SunPosition перенесён отдельно в FlightState.Sun
;   система и рынок пересозданы, имена текущей и выбранной систем согласованы, отсчёт перехода=0
; Corrupt:
;   HL, DE, BC, AF, HL', DE', BC'
; Note:
;   Game.Trade.GenerateMarket.Entry пересчитывает рынок, результат не является копией всех полей резерва
;   команда MarketStore временно заменяется NOP и затем восстанавливается как LD (HL), A
;   адреса исходного размещения сохранены
; -----------------------------------------
                ; общее состояние миссий 1..7, восстановление полей заданий из резерва NewCommander
                ; описание в Docs/Manual.md, раздел mission-shared-state
ResetCommander: CALL Game.Travel.ClearFlightEventsAndHandleJump.Entry
                LD HL, NewCommander
                LD DE, State.Name
                LD BC, #005D
                ; перенос имени, статуса, оборудования, семян и сохранённого рынка в блок командира
                LDIR
                LD A, (State.SystemSeed + FSystemSeed.X)
                LD (TargetX), A
                LD A, (State.SystemSeed + FSystemSeed.Y)
                LD (TargetY), A
                CALL Game.Galaxy.FindNearestSystem.Entry
                LD HL, MarketStore
                LD (HL), #00
                PUSH HL
                CALL Game.Trade.GenerateMarket.Entry
                POP HL
                LD (HL), #77
                LD HL, GalaxyState.TargetName
                LD DE, GalaxyState.CurrentName
                LD BC, #0008
                ; копирование восьми символов выбранной системы в имя текущей системы
                LDIR
                LD HL, NewCommander + FCommander.SunPosition
                LD DE, FlightState.Sun
                LD BC, #0009
                ; восстановление трёх трёхбайтовых координат солнца из изменяемого резерва
                LDIR
                XOR A
                LD (JumpCountdown), A
                RET

                ; остаток десятичного числа после очередного разряда
DecimalRest     DW #0000                                                        ; остаток десятичного преобразования числа
                ; проверка исходного конца фрагмента
                ASSERT $ == #D2DE
                endmodule
                endmodule
