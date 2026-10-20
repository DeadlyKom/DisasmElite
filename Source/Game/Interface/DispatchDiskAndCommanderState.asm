                module Interface
                module DispatchDiskAndCommanderState
; -----------------------------------------
; Вектор дискового меню и область состояния пилота
; исходный диапазон #D04E..#D0D9
; In:
;   Нет параметров для вектора
; Out:
;   Переход в D907
; Corrupt:
;   По контракту дискового меню
; Note:
;   D051/D052 координаты курсора, D053 радиус топливного круга, D054..D0B9 сериализуемый блок
;   102 байта, D0BD..D0D0 десять пар сообщений, D0D1..D0D4 режимы регистра текста, D0D7
;   отдельный JP D0F6
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D04E
Entry:          JP Game.Disk.LoadDiskMenuOverlay.Entry
                ; экранный X центра перекрестия
CircleX         DB #61                                                          ; координата X окружности карты
                ; экранный Y центра перекрестия
CircleY         DB #60                                                          ; координата Y окружности карты
                ; радиус отображаемого топливного круга
CircleRadius    DB #46                                                          ; радиус окружности дальности на карте
                ; исходная сериализуемая запись пилота, описание полей и флагов в FCommander
Commander       FCommander {
                    {                                                           ; FCommander.Name, имя командира, поле из 11 байтов
                        #56, #00, #4D, #45, #53, #4F,
                        #4E, #20, #20, #20, #00
                    },
                    #01,                                                        ; FCommander.LegalStatus, степень преследования, 0 законопослушный, от 50 разыскиваемый
                    #7BB8,                                                      ; FCommander.Rating, младшие 16 бит боевого рейтинга
                    #04,                                                        ; FCommander.RankState, старший рейтинг и военное состояние, схема FCommander.RankState
                    #1D,                                                        ; FCommander.JumpCount, младший байт счётчика переходов
                    #00,                                                        ; FCommander.JumpFlags, старшие разряды счётчика и флаг допуска миссий
                    #03,                                                        ; FCommander.Galaxy, номер галактики, 0..7
                    #0147,                                                      ; FCommander.CashHigh, старшая часть денег, тысячи кредитов
                    #268C,                                                      ; FCommander.CashLow, младшая часть денег, десятые доли кредита
                    #E5,                                                        ; FCommander.MarketRandom, случайный параметр воспроизводимого рынка
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
                        #03,                                                    ; FGoods.Minerals, минералы, т
                        #00,                                                    ; FGoods.Gold, золото, кг
                        #00,                                                    ; FGoods.Platinum, платина, кг
                        #5C,                                                    ; FGoods.Gemstones, драгоценные камни, г
                        #07                                                     ; FGoods.AlienItems, инопланетные предметы, т
                    },
                    #19,                                                        ; FCommander.FreeCargo, свободное место в трюме, тонны
                    #42,                                                        ; FCommander.FrontLaser, тип переднего лазера
                    #42,                                                        ; FCommander.RearLaser, тип заднего лазера
                    #01,                                                        ; FCommander.LeftLaser, тип левого лазера
                    #01,                                                        ; FCommander.RightLaser, тип правого лазера
                    #00,                                                        ; FCommander.Mission1, состояние первой миссии
                    #46,                                                        ; FCommander.Fuel, топливо в десятых долях светового года, максимум 70
                    #04,                                                        ; FCommander.Missiles, количество ракет
                    #FF,                                                        ; FCommander.LargeCargo, состояние расширенного трюма
                    #7F,                                                        ; FCommander.ECM, наличие и состояние системы ECM
                    #7F,                                                        ; FCommander.AlienComputer, состояние инопланетного компьютера и счётчик его событий
                    #06,                                                        ; FCommander.MineralLife, состояние живой колонии минералов
                    #FF,                                                        ; FCommander.FuelScoops, наличие и состояние топливного ковша
                    #00,                                                        ; FCommander.EscapePod, наличие спасательной капсулы
                    #FF,                                                        ; FCommander.EnergyBomb, наличие и состояние энергетической бомбы
                    #FF,                                                        ; FCommander.EnergyUnit, наличие и состояние энергетического блока
                    #FF,                                                        ; FCommander.DockComputer, наличие и состояние стыковочного компьютера
                    #FF,                                                        ; FCommander.GalacticDrive, наличие и состояние галактического гиперпривода
                    #00,                                                        ; FCommander.ShipUpgrade, код установленного улучшения корабля
                    #00,                                                        ; FCommander.Invasion, фаза и размер области вторжения
                    {                                                           ; FCommander.GalaxySeed, шесть байтов семени галактики
                        #52,                                                    ; FSystemSeed.NameBits, бит 6 выбирает четыре слога вместо трёх
                        #D2,                                                    ; FSystemSeed.Y, координата Y, биты 2..0 дают исходную экономику
                        #42,                                                    ; FSystemSeed.GovBits, биты 5..3 задают правительство
                        #10,                                                    ; FSystemSeed.X, координата X, биты 1..0 участвуют в технологии
                        #9A,                                                    ; FSystemSeed.MixLow, младший байт третьего слова при шаге генератора
                        #BD                                                     ; FSystemSeed.Syllable, биты 4..0 задают индекс слога имени
                    },
                    {                                                           ; FCommander.SystemSeed, шесть байтов семени текущей системы
                        #7A,                                                    ; FSystemSeed.NameBits, бит 6 выбирает четыре слога вместо трёх
                        #3A,                                                    ; FSystemSeed.Y, координата Y, биты 2..0 дают исходную экономику
                        #22,                                                    ; FSystemSeed.GovBits, биты 5..3 задают правительство
                        #3B,                                                    ; FSystemSeed.X, координата X, биты 1..0 участвуют в технологии
                        #6A,                                                    ; FSystemSeed.MixLow, младший байт третьего слова при шаге генератора
                        #47                                                     ; FSystemSeed.Syllable, биты 4..0 задают индекс слога имени
                    },
                    #0A,                                                        ; FCommander.Technology, технологический уровень системы, счёт с нуля
                    #04,                                                        ; FCommander.Government, тип правительства системы, 0..7
                    {                                                           ; FCommander.MarketStock, остатки товаров станции, структура FGoods
                        #0B,                                                    ; FGoods.Food, продовольствие, т
                        #0D,                                                    ; FGoods.Textiles, текстиль, т
                        #0D,                                                    ; FGoods.Radioactives, радиоактивные материалы, т
                        #00,                                                    ; FGoods.Slaves, рабы, т
                        #0A,                                                    ; FGoods.Liquor, алкоголь, т
                        #26,                                                    ; FGoods.Luxuries, предметы роскоши, т
                        #2D,                                                    ; FGoods.Narcotics, наркотики, т
                        #1C,                                                    ; FGoods.Computers, компьютеры, т
                        #20,                                                    ; FGoods.Machinery, промышленное оборудование, т
                        #13,                                                    ; FGoods.Alloys, сплавы, т
                        #21,                                                    ; FGoods.Firearms, огнестрельное оружие, т
                        #13,                                                    ; FGoods.Furs, меха, т
                        #00,                                                    ; FGoods.Minerals, минералы, т
                        #09,                                                    ; FGoods.Gold, золото, кг
                        #00,                                                    ; FGoods.Platinum, платина, кг
                        #00,                                                    ; FGoods.Gemstones, драгоценные камни, г
                        #00                                                     ; FGoods.AlienItems, инопланетные предметы, т
                    },
                    #00,                                                        ; FCommander.Mission3, этап третьей миссии и отметка попадания
                    #43,                                                        ; FCommander.MissionFlags, награды, особое оборудование и занятость трюма миссией
                    {                                                           ; FCommander.SunPosition, три трёхбайтовые координаты солнца
                        {#F0, #52, #05},                                        ; FSpacePosition.X, FCoordinate {Fraction, Low, SignHigh}
                        {#33, #98, #07},                                        ; FSpacePosition.Y, FCoordinate {Fraction, Low, SignHigh}
                        {#B6, #FA, #8B}                                         ; FSpacePosition.Z, FCoordinate {Fraction, Low, SignHigh}
                    }
                }
                ASSERT $ - Commander == FCommander
                ; флаг повторного миссионного предупреждения
MissionNotice   DB #00                                                          ; флаг, повторное миссионное предупреждение уже подготовлено
                ; галактическая координата X выбранной цели
TargetX         DB #14                                                          ; галактическая координата X выбранной цели
                ; галактическая координата Y выбранной цели
TargetY         DB #AD                                                          ; галактическая координата Y выбранной цели
                ; первые пять пар событий, bit7 первого байта означает ожидание, второй байт токен
FlightEvents    DB #08, #C9                                                     ; десять пар очереди, координата с битом ожидания и токен
IncomingEvent   DB #07, #78                                                     ; вторая пара очереди, сообщение после запуска вражеской ракеты
                DB #09, #C8, #02, #FD                                           ; следующие пары очереди событий
                DB #0C, #E2                                                     ; #D0C5..#D0C6
                ; пара события подобранного предмета, координата и токен
CargoEvent      DW #000B                                                        ; шестая пара очереди, подбор предмета и предложение улучшения
                ; пара специального события, используется также состоянием войны
                DB #06, #65                                                     ; #D0C9..#D0CA
                ; пара очереди, D0CC одновременно флаг подавления нулей при печати
                DB #00                                                          ; продолжение данных #D0CB..#D0CB
ZeroSuppress    DB #01                                                          ; подавление ведущих нулей, одновременно токен восьмой пары очереди
                ; пара очереди, D0CE одновременно минимальная ширина числового поля
                DB #00                                                          ; продолжение данных #D0CD..#D0CD
NumberWidth     DB #00                                                          ; минимальная ширина числа, одновременно токен девятой пары очереди
                ; последняя пара очереди событий
                DB #0A, #1F                                                     ; #D0CF..#D0D0
                ; режим регистра букв, 1 заглавные, 2 строчные
LetterCase      DB #00                                                          ; регистр букв, 1 заглавные, 2 строчные
                ; состояние начала слова для преобразования регистра
WordStart       DB #01                                                          ; флаг, следующий символ начинает слово
                ; одноразовый признак заглавной буквы
CapitalNext     DB #00                                                          ; флаг, следующая буква должна стать заглавной
                ; сохранённый режим текста, проверка в D4D8 нейтрализована NOP
TextMode        DB #00                                                          ; сохранённый режим текста, его проверка нейтрализована NOP
                ; сохранённое слово D508, адрес загрузки экранной базы
TextBasePatch   DW #D508                                                        ; сохранённый адрес команды загрузки экранной базы текста
ShowBoarding:   JP Game.Missions.ShowBoardingMessage.Entry
                ; проверка исходного конца фрагмента
                ASSERT $ == #D0DA
                endmodule
                endmodule
