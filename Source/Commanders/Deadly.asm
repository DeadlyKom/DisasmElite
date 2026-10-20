                ifndef _ELITE_COMMANDER_DEADLY_
                define _ELITE_COMMANDER_DEADLY_
                module CommanderDeadly
; -----------------------------------------
; сохранённый командир DEADLY, структура FCommander, 102 байта
; логическое начало соответствует #D054, поля расположены младшим байтом вперёд
; загрузчик #CC41 читает сектор в #606F и переносит #66 байт в состояние пилота
; #CC65 создаёт резервную копию по #D232, запись #CCD4 берёт сектор от #D054
; имя имеет 11 байтов, редактируются первые восемь, хвост сектора не входит в структуру
; деньги, 73913.3 кредита
; экипировка и миссионные поля сохраняются буквально, без перекодирования
; -----------------------------------------
Begin           FCommander {
                    {                                                           ; FCommander.Name, имя пилота с завершающим нулём
                        #44, #45, #41, #44, #4C, #59,
                        #00, #00, #00, #20, #00
                    },
                    #03,                                                        ; FCommander.LegalStatus, юридический статус пилота
                    #7465,                                                      ; FCommander.Rating, младшие 16 бит боевого рейтинга
                    #00,                                                        ; FCommander.RankState, старший разряд рейтинга и военное состояние
                    #00,                                                        ; FCommander.JumpCount, младший байт счётчика гиперпереходов
                    #00,                                                        ; FCommander.JumpFlags, старшая часть счётчика и разрешение выдачи миссии
                    #00,                                                        ; FCommander.Galaxy, индекс галактики, от 0 до 7
                    #0049,                                                      ; FCommander.CashHigh, целые тысячи кредитов
                    #23AD,                                                      ; FCommander.CashLow, остаток денежной суммы в десятых кредита
                    #AA,                                                        ; FCommander.MarketRandom, случайный параметр воспроизводимого рынка

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
                        #06,                                                    ; FGoods.Gemstones, драгоценные камни, г
                        #00                                                     ; FGoods.AlienItems, инопланетные предметы, т
                    },

                    #20,                                                        ; FCommander.FreeCargo, свободное место в трюме, т
                    #04,                                                        ; FCommander.FrontLaser, тип переднего лазера
                    #00,                                                        ; FCommander.RearLaser, тип заднего лазера
                    #00,                                                        ; FCommander.LeftLaser, тип левого лазера
                    #00,                                                        ; FCommander.RightLaser, тип правого лазера
                    #00,                                                        ; FCommander.Mission1, состояние первой миссии
                    #46,                                                        ; FCommander.Fuel, топливо в десятых светового года
                    #04,                                                        ; FCommander.Missiles, число ракет
                    #FF,                                                        ; FCommander.LargeCargo, код расширенного трюма
                    #7F,                                                        ; FCommander.ECM, код и текущее состояние ECM
                    #16,                                                        ; FCommander.AlienComputer, наличие ALIEN COMPUTER и счётчик событий
                    #02,                                                        ; FCommander.MineralLife, состояние колонии MINERAL LIFE
                    #FF,                                                        ; FCommander.FuelScoops, код топливного ковша
                    #00,                                                        ; FCommander.EscapePod, код спасательной капсулы
                    #FF,                                                        ; FCommander.EnergyBomb, код энергетической бомбы
                    #FF,                                                        ; FCommander.EnergyUnit, код энергетического блока
                    #FF,                                                        ; FCommander.DockComputer, код стыковочного компьютера
                    #00,                                                        ; FCommander.GalacticDrive, код галактического гиперпривода
                    #00,                                                        ; FCommander.ShipUpgrade, код улучшения корабля Cobra Mk4
                    #00,                                                        ; FCommander.Invasion, фаза и величина области вторжения

                    ; FCommander.GalaxySeed, исходное семя галактики, FSystemSeed
                    {
                        #4A,                                                    ; FSystemSeed.NameBits, разряды семени и выбор длины имени
                        #5A,                                                    ; FSystemSeed.Y, координата Y и исходная экономика
                        #48,                                                    ; FSystemSeed.GovBits, разряды семени и код правительства
                        #02,                                                    ; FSystemSeed.X, координата X и разряды технологии
                        #53,                                                    ; FSystemSeed.MixLow, младший байт третьего слова генератора
                        #B7                                                     ; FSystemSeed.Syllable, разряды семени и индекс слога имени
                    },

                    ; FCommander.SystemSeed, семя текущей системы, FSystemSeed
                    {
                        #40,                                                    ; FSystemSeed.NameBits, разряды семени и выбор длины имени
                        #48,                                                    ; FSystemSeed.Y, координата Y и исходная экономика
                        #70,                                                    ; FSystemSeed.GovBits, разряды семени и код правительства
                        #45,                                                    ; FSystemSeed.X, координата X и разряды технологии
                        #2D,                                                    ; FSystemSeed.MixLow, младший байт третьего слова генератора
                        #61                                                     ; FSystemSeed.Syllable, разряды семени и индекс слога имени
                    },

                    #0B,                                                        ; FCommander.Technology, технологический уровень системы, счёт с нуля
                    #06,                                                        ; FCommander.Government, код правительства системы

                    ; FCommander.MarketStock, остатки товаров станции, FGoods
                    {
                        #06,                                                    ; FGoods.Food, продовольствие, т
                        #0C,                                                    ; FGoods.Textiles, текстиль, т
                        #04,                                                    ; FGoods.Radioactives, радиоактивные материалы, т
                        #00,                                                    ; FGoods.Slaves, рабы, т
                        #05,                                                    ; FGoods.Liquor, алкоголь, т
                        #37,                                                    ; FGoods.Luxuries, предметы роскоши, т
                        #2F,                                                    ; FGoods.Narcotics, наркотики, т
                        #39,                                                    ; FGoods.Computers, компьютеры, т
                        #29,                                                    ; FGoods.Machinery, промышленное оборудование, т
                        #1A,                                                    ; FGoods.Alloys, сплавы, т
                        #1E,                                                    ; FGoods.Firearms, огнестрельное оружие, т
                        #06,                                                    ; FGoods.Furs, меха, т
                        #00,                                                    ; FGoods.Minerals, минералы, т
                        #04,                                                    ; FGoods.Gold, золото, кг
                        #01,                                                    ; FGoods.Platinum, платина, кг
                        #00,                                                    ; FGoods.Gemstones, драгоценные камни, г
                        #00                                                     ; FGoods.AlienItems, инопланетные предметы, т
                    },

                    #00,                                                        ; FCommander.Mission3, этап третьей миссии и отметка попадания
                    #00,                                                        ; FCommander.MissionFlags, флаги наград, оборудования и миссионного груза

                    ; FCommander.SunPosition, положение светила, FSpacePosition
                    {
                        { #F0, #52, #05 },                                      ; FSpacePosition.X, координата X, FCoordinate
                        { #33, #98, #07 },                                      ; FSpacePosition.Y, координата Y, FCoordinate
                        { #B6, #FA, #8B }                                       ; FSpacePosition.Z, координата Z, FCoordinate
                    }
                }
End:            EQU $
                ; проверка полного размера записи командира
                ASSERT End - Begin == FCommander
                endmodule
                endif
