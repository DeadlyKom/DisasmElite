; -----------------------------------------
; сектор состояния ROBOT между двумя исполняемыми оверлеями
; Game.Disk.BlackAttributesAndOverlayState.LoadDemo читает сектор в DiskBuffer.Work, затем копирует ровно 102 байта в State.Name
; первые 102 байта имеют формат FCommander, описанный для QS1 и DEADLY
; остальные 154 байта не включаются в состояние командира
; среди них сохранились похожие на машинный код байты прежнего снимка
; штатная загрузка ROBOT не передаёт им управление и сохраняет их как дополнение
; -----------------------------------------
RobotState      FCommander {
                    {                                                           ; FCommander.Name, имя пилота с завершающим нулём
                        #52, #4F, #42, #4F, #54, #20,
                        #20, #20, #20, #20, #00
                    },
                    #00,                                                        ; FCommander.LegalStatus, юридический статус пилота
                    #C9C9,                                                      ; FCommander.Rating, младшие 16 бит боевого рейтинга
                    #04,                                                        ; FCommander.RankState, старший разряд рейтинга и военное состояние
                    #2A,                                                        ; FCommander.JumpCount, младший байт счётчика гиперпереходов
                    #00,                                                        ; FCommander.JumpFlags, старшая часть счётчика и разрешение выдачи миссии
                    #03,                                                        ; FCommander.Galaxy, индекс галактики, от 0 до 7
                    #0026,                                                      ; FCommander.CashHigh, целые тысячи кредитов
                    #0991,                                                      ; FCommander.CashLow, остаток денежной суммы в десятых кредита
                    #8D,                                                        ; FCommander.MarketRandom, случайный параметр воспроизводимого рынка

                    ; FCommander.Cargo, содержимое трюма, FGoods
                    {
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
                        #03,                                                    ; FGoods.Minerals, минералы, т
                        #00,                                                    ; FGoods.Gold, золото, кг
                        #00,                                                    ; FGoods.Platinum, платина, кг
                        #33,                                                    ; FGoods.Gemstones, драгоценные камни, г
                        #23                                                     ; FGoods.AlienItems, инопланетные предметы, т
                    },

                    #0C,                                                        ; FCommander.FreeCargo, свободное место в трюме, т
                    #42,                                                        ; FCommander.FrontLaser, тип переднего лазера
                    #42,                                                        ; FCommander.RearLaser, тип заднего лазера
                    #01,                                                        ; FCommander.LeftLaser, тип левого лазера
                    #01,                                                        ; FCommander.RightLaser, тип правого лазера
                    #00,                                                        ; FCommander.Mission1, состояние первой миссии
                    #2E,                                                        ; FCommander.Fuel, топливо в десятых светового года
                    #04,                                                        ; FCommander.Missiles, число ракет
                    #FE,                                                        ; FCommander.LargeCargo, код расширенного трюма
                    #7E,                                                        ; FCommander.ECM, код и текущее состояние ECM
                    #83,                                                        ; FCommander.AlienComputer, наличие ALIEN COMPUTER и счётчик событий
                    #15,                                                        ; FCommander.MineralLife, состояние колонии MINERAL LIFE
                    #FE,                                                        ; FCommander.FuelScoops, код топливного ковша
                    #00,                                                        ; FCommander.EscapePod, код спасательной капсулы
                    #FC,                                                        ; FCommander.EnergyBomb, код энергетической бомбы
                    #FC,                                                        ; FCommander.EnergyUnit, код энергетического блока
                    #00,                                                        ; FCommander.DockComputer, код стыковочного компьютера
                    #FE,                                                        ; FCommander.GalacticDrive, код галактического гиперпривода
                    #FD,                                                        ; FCommander.ShipUpgrade, код улучшения корабля Cobra Mk4
                    #00,                                                        ; FCommander.Invasion, фаза и величина области вторжения

                    ; FCommander.GalaxySeed, исходное семя галактики, FSystemSeed
                    {
                        #52,                                                    ; FSystemSeed.NameBits, разряды семени и выбор длины имени
                        #D2,                                                    ; FSystemSeed.Y, координата Y и исходная экономика
                        #42,                                                    ; FSystemSeed.GovBits, разряды семени и код правительства
                        #10,                                                    ; FSystemSeed.X, координата X и разряды технологии
                        #9A,                                                    ; FSystemSeed.MixLow, младший байт третьего слова генератора
                        #BD                                                     ; FSystemSeed.Syllable, разряды семени и индекс слога имени
                    },

                    ; FCommander.SystemSeed, семя текущей системы, FSystemSeed
                    {
                        #7A,                                                    ; FSystemSeed.NameBits, разряды семени и выбор длины имени
                        #3A,                                                    ; FSystemSeed.Y, координата Y и исходная экономика
                        #16,                                                    ; FSystemSeed.GovBits, разряды семени и код правительства
                        #3B,                                                    ; FSystemSeed.X, координата X и разряды технологии
                        #6A,                                                    ; FSystemSeed.MixLow, младший байт третьего слова генератора
                        #47                                                     ; FSystemSeed.Syllable, разряды семени и индекс слога имени
                    },

                    #00,                                                        ; FCommander.Technology, технологический уровень системы, счёт с нуля
                    #00,                                                        ; FCommander.Government, код правительства системы

                    ; FCommander.MarketStock, остатки товаров станции, FGoods
                    {
                        #0B,                                                    ; FGoods.Food, продовольствие, т
                        #0D,                                                    ; FGoods.Textiles, текстиль, т
                        #0D,                                                    ; FGoods.Radioactives, радиоактивные материалы, т
                        #00,                                                    ; FGoods.Slaves, рабы, т
                        #12,                                                    ; FGoods.Liquor, алкоголь, т
                        #26,                                                    ; FGoods.Luxuries, предметы роскоши, т
                        #00,                                                    ; FGoods.Narcotics, наркотики, т
                        #1C,                                                    ; FGoods.Computers, компьютеры, т
                        #20,                                                    ; FGoods.Machinery, промышленное оборудование, т
                        #1B,                                                    ; FGoods.Alloys, сплавы, т
                        #07,                                                    ; FGoods.Firearms, огнестрельное оружие, т
                        #00,                                                    ; FGoods.Furs, меха, т
                        #38,                                                    ; FGoods.Minerals, минералы, т
                        #09,                                                    ; FGoods.Gold, золото, кг
                        #08,                                                    ; FGoods.Platinum, платина, кг
                        #09,                                                    ; FGoods.Gemstones, драгоценные камни, г
                        #00                                                     ; FGoods.AlienItems, инопланетные предметы, т
                    },

                    #00,                                                        ; FCommander.Mission3, этап миссии 3 и служебное состояние войны
                    #43,                                                        ; FCommander.MissionFlags, флаги наград, оборудования и миссионного груза

                    ; FCommander.SunPosition, положение светила, FSpacePosition
                    {
                        { #F0, #00, #12 },                                      ; FSpacePosition.X, координата X, FCoordinate
                        { #33, #98, #03 },                                      ; FSpacePosition.Y, координата Y, FCoordinate
                        { #B6, #FA, #86 }                                       ; FSpacePosition.Z, координата Z, FCoordinate
                    }
                }
                ; проверка границы сериализуемого состояния
                ASSERT $ - RobotState == FCommander
RobotTail       EQU $                                                           ; 154 исходных байта после FCommander, в состояние пилота не копируются
                ; сохранение исходного секторного дополнения
                DB #00, #14, #AD, #08, #C9, #07, #78, #09
                DB #C8, #02, #FD, #0C, #E2, #0B, #00, #06
                DB #65, #00, #01, #00, #00, #0A, #1F, #00
                DB #00, #00, #00, #08, #D5, #C3, #F6, #D0
                DB #C3, #91, #DB, #C3, #23, #D1, #C3, #97
                DB #DE, #00, #C3, #90, #D1, #C3, #D9, #D1
                DB #C3, #C7, #D1, #C3, #4D, #D1, #00, #00
                DB #00, #C3, #E9, #D1, #F5, #11, #17, #0B
                DB #21, #03, #07, #CD, #62, #D1, #F1, #CD
                DB #5F, #D4, #3E, #5D, #CD, #5F, #D4, #21
                DB #04, #0B, #22, #45, #D0, #3E, #5A, #CD
                DB #5F, #D4, #CD, #E8, #E1, #CD, #F7, #E1
                DB #CD, #1D, #D6, #CD, #5E, #E3, #C3, #05
                DB #E2, #11, #1F, #58, #21, #05, #04, #CD
                DB #62, #D1, #CD, #F7, #E1, #FE, #59, #28
                DB #05, #AF, #32, #AF, #D0, #C9, #21, #B0
                DB #D0, #CB, #FE, #3E, #03, #32, #AF, #D0
                DB #11, #17, #59, #21, #00, #02, #CD, #62
                DB #D1, #18, #C7, #21, #62, #D0, #34, #AF
                DB #32, #AF
                ; проверка размера полного сектора
                ASSERT $ - RobotState == 256
